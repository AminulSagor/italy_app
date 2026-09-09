package com.shafacode.italir_pothe

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioRecord
import android.media.AudioTrack
import android.media.MediaRecorder
import android.media.audiofx.AcousticEchoCanceler
import android.media.audiofx.AutomaticGainControl
import android.media.audiofx.NoiseSuppressor
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayDeque
import kotlin.math.max
import kotlin.math.min

/**
 * Native full-duplex PCM engine for Gemini Live.
 *
 * AudioRecord and AudioTrack stay on dedicated native threads. The playback
 * thread is the only owner of AudioTrack state, so interruption and teardown
 * cannot race with a write in progress.
 */
class AiVoiceAudioEngine(
    context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private val applicationContext = context.applicationContext
    private val methodChannel = MethodChannel(messenger, METHOD_CHANNEL)
    private val eventChannel = EventChannel(messenger, EVENT_CHANNEL)
    private val mainHandler = Handler(Looper.getMainLooper())
    private val queueLock = Object()
    private val playbackQueue = ArrayDeque<ByteArray>()

    @Volatile private var eventSink: EventChannel.EventSink? = null
    @Volatile private var running = false
    @Volatile private var muted = true

    private var audioRecord: AudioRecord? = null
    private var audioTrack: AudioTrack? = null
    private var captureThread: Thread? = null
    private var playbackThread: Thread? = null
    private var echoCanceler: AcousticEchoCanceler? = null
    private var noiseSuppressor: NoiseSuppressor? = null
    private var gainControl: AutomaticGainControl? = null
    private var audioManager: AudioManager? = null
    private var previousAudioMode = AudioManager.MODE_NORMAL
    private var previousSpeakerphoneState = false

    private var inputSampleRate = 16_000
    private var outputSampleRate = 24_000
    private var inputChunkMs = 40
    private var initialPlaybackBufferMs = 300
    private var maxPlaybackBufferMs = 600
    private var targetPlaybackBufferMs = 300
    private var queuedBytes = 0
    private var queueOffset = 0
    private var turnFinished = false
    private var interruptRequested = false
    private var playbackActive = false
    private var hadPlaybackThisTurn = false
    private var framesSubmitted = 0L
    private var stableTurns = 0

    fun register() {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    fun dispose() {
        stopEngine()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "start" -> {
                    @Suppress("UNCHECKED_CAST")
                    startEngine(call.arguments as? Map<String, Any?> ?: emptyMap())
                    result.success(null)
                }
                "enqueuePlayback" -> {
                    val bytes = call.arguments as? ByteArray
                    if (bytes == null || bytes.isEmpty()) {
                        result.error("invalid_audio", "Playback audio is empty.", null)
                    } else {
                        enqueuePlayback(bytes)
                        result.success(null)
                    }
                }
                "finishPlaybackTurn" -> {
                    synchronized(queueLock) {
                        turnFinished = true
                        queueLock.notifyAll()
                    }
                    result.success(null)
                }
                "interruptPlayback" -> {
                    synchronized(queueLock) {
                        interruptRequested = true
                        queueLock.notifyAll()
                    }
                    result.success(null)
                }
                "setMuted" -> {
                    muted = call.arguments as? Boolean ?: true
                    result.success(null)
                }
                "stop" -> {
                    stopEngine()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (error: Throwable) {
            if (call.method == "start") stopEngine()
            emitError(error.message ?: "Native voice audio failed")
            result.error("native_audio_error", error.message, null)
        }
    }

    private fun startEngine(arguments: Map<String, Any?>) {
        stopEngine()
        inputSampleRate = (arguments["inputSampleRate"] as? Number)?.toInt() ?: 16_000
        outputSampleRate = (arguments["outputSampleRate"] as? Number)?.toInt() ?: 24_000
        inputChunkMs = (arguments["inputChunkMs"] as? Number)?.toInt() ?: 40
        initialPlaybackBufferMs =
            (arguments["initialPlaybackBufferMs"] as? Number)?.toInt() ?: 300
        maxPlaybackBufferMs =
            (arguments["maxPlaybackBufferMs"] as? Number)?.toInt() ?: 600
        targetPlaybackBufferMs = initialPlaybackBufferMs

        configureCommunicationAudio()
        val record = createAudioRecord()
        audioRecord = record
        val track = createAudioTrack()
        audioTrack = track
        attachVoiceProcessing(record.audioSessionId)

        synchronized(queueLock) {
            playbackQueue.clear()
            queuedBytes = 0
            queueOffset = 0
            turnFinished = false
            interruptRequested = false
            playbackActive = false
            hadPlaybackThisTurn = false
            framesSubmitted = 0
            stableTurns = 0
        }
        muted = false
        running = true
        record.startRecording()
        captureThread = Thread({ captureLoop(record) }, "ai-voice-capture").apply {
            priority = Thread.MAX_PRIORITY
            start()
        }
        playbackThread = Thread({ playbackLoop(track) }, "ai-voice-playback").apply {
            priority = Thread.MAX_PRIORITY
            start()
        }
    }

    private fun configureCommunicationAudio() {
        val manager = applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager = manager
        previousAudioMode = manager.mode
        previousSpeakerphoneState = manager.isSpeakerphoneOn
        manager.mode = AudioManager.MODE_IN_COMMUNICATION
        manager.isSpeakerphoneOn = true
    }

    private fun createAudioRecord(): AudioRecord {
        val format = AudioFormat.Builder()
            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
            .setSampleRate(inputSampleRate)
            .setChannelMask(AudioFormat.CHANNEL_IN_MONO)
            .build()
        val chunkBytes = inputSampleRate * 2 * inputChunkMs / 1000
        val minimum = AudioRecord.getMinBufferSize(
            inputSampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
        )
        val record = AudioRecord.Builder()
            .setAudioSource(MediaRecorder.AudioSource.VOICE_COMMUNICATION)
            .setAudioFormat(format)
            .setBufferSizeInBytes(max(minimum, chunkBytes * 4))
            .build()
        check(record.state == AudioRecord.STATE_INITIALIZED) {
            "Unable to initialize the communication microphone"
        }
        return record
    }

    private fun createAudioTrack(): AudioTrack {
        val minimum = AudioTrack.getMinBufferSize(
            outputSampleRate,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
        )
        val maximumBufferBytes = outputSampleRate * 2 * maxPlaybackBufferMs / 1000
        val builder = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build(),
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(outputSampleRate)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build(),
            )
            .setTransferMode(AudioTrack.MODE_STREAM)
            .setBufferSizeInBytes(max(minimum, maximumBufferBytes))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            builder.setPerformanceMode(AudioTrack.PERFORMANCE_MODE_LOW_LATENCY)
        }
        val track = builder.build()
        check(track.state == AudioTrack.STATE_INITIALIZED) {
            "Unable to initialize native speech playback"
        }
        return track
    }

    private fun attachVoiceProcessing(audioSessionId: Int) {
        if (AcousticEchoCanceler.isAvailable()) {
            echoCanceler = AcousticEchoCanceler.create(audioSessionId)?.apply { enabled = true }
        }
        if (NoiseSuppressor.isAvailable()) {
            noiseSuppressor = NoiseSuppressor.create(audioSessionId)?.apply { enabled = true }
        }
        if (AutomaticGainControl.isAvailable()) {
            gainControl = AutomaticGainControl.create(audioSessionId)?.apply { enabled = true }
        }
    }

    private fun captureLoop(record: AudioRecord) {
        val chunkBytes = inputSampleRate * 2 * inputChunkMs / 1000
        val buffer = ByteArray(chunkBytes)
        while (running) {
            val read = try {
                record.read(buffer, 0, buffer.size, AudioRecord.READ_BLOCKING)
            } catch (_: Throwable) {
                break
            }
            if (read > 0 && !muted && running) {
                val payload = buffer.copyOf(read)
                emit(mapOf("type" to "microphone", "data" to payload))
            } else if (read < 0 && running) {
                emitError("Microphone read failed ($read)")
                break
            }
        }
    }

    private fun enqueuePlayback(bytes: ByteArray) {
        if (!running) return
        val evenLength = bytes.size - (bytes.size % 2)
        if (evenLength <= 0) return
        val payload = if (evenLength == bytes.size) bytes.copyOf() else bytes.copyOf(evenLength)
        synchronized(queueLock) {
            playbackQueue.addLast(payload)
            queuedBytes += payload.size
            turnFinished = false
            queueLock.notifyAll()
        }
    }

    private fun playbackLoop(track: AudioTrack) {
        val frameBytes = outputSampleRate * 2 * 20 / 1000
        while (running) {
            var interrupt = false
            var startPlayback = false
            var audio: ByteArray? = null
            var checkDrain = false
            var completeAfterUnderflow = false
            synchronized(queueLock) {
                if (!running) return@synchronized
                if (interruptRequested) {
                    interruptRequested = false
                    interrupt = true
                    clearQueueLocked()
                    turnFinished = false
                    playbackActive = false
                    hadPlaybackThisTurn = false
                    framesSubmitted = 0
                    stableTurns = 0
                } else {
                    val targetBytes = outputSampleRate * 2 * targetPlaybackBufferMs / 1000
                    if (!playbackActive &&
                        (queuedBytes >= targetBytes || (turnFinished && queuedBytes > 0))
                    ) {
                        playbackActive = true
                        hadPlaybackThisTurn = true
                        startPlayback = true
                    }
                    if (playbackActive && queuedBytes > 0) {
                        audio = dequeueLocked(frameBytes)
                    } else if (playbackActive && turnFinished && queuedBytes == 0) {
                        checkDrain = true
                    } else if (!playbackActive && turnFinished && hadPlaybackThisTurn) {
                        turnFinished = false
                        hadPlaybackThisTurn = false
                        completeAfterUnderflow = true
                    } else {
                        queueLock.wait(10)
                    }
                }
            }

            if (!running) break
            if (interrupt) {
                resetTrack(track)
                emit(mapOf("type" to "playback_ended"))
                continue
            }
            if (startPlayback) {
                if (track.playState != AudioTrack.PLAYSTATE_PLAYING) track.play()
                emit(mapOf("type" to "playback_started"))
            }
            if (completeAfterUnderflow) {
                emit(mapOf("type" to "playback_ended"))
                continue
            }
            val payload = audio
            if (payload != null) {
                writeFully(track, payload)
                continue
            }
            if (checkDrain) {
                val playedFrames = track.playbackHeadPosition.toLong() and 0xffffffffL
                if (playedFrames >= framesSubmitted) {
                    resetTrack(track)
                    synchronized(queueLock) {
                        playbackActive = false
                        hadPlaybackThisTurn = false
                        turnFinished = false
                        framesSubmitted = 0
                        stableTurns++
                        if (stableTurns >= 3) {
                            stableTurns = 0
                            targetPlaybackBufferMs = max(
                                initialPlaybackBufferMs,
                                targetPlaybackBufferMs - 50,
                            )
                        }
                    }
                    emit(mapOf("type" to "playback_ended"))
                } else {
                    Thread.sleep(8)
                }
            } else if (playbackActive) {
                val playedFrames = track.playbackHeadPosition.toLong() and 0xffffffffL
                if (playedFrames >= framesSubmitted) {
                    resetTrack(track)
                    synchronized(queueLock) {
                        playbackActive = false
                        framesSubmitted = 0
                        stableTurns = 0
                        targetPlaybackBufferMs = min(
                            maxPlaybackBufferMs,
                            targetPlaybackBufferMs + 100,
                        )
                    }
                }
            }
        }
        resetTrack(track)
    }

    private fun writeFully(track: AudioTrack, bytes: ByteArray) {
        var offset = 0
        while (running && offset < bytes.size) {
            val written = track.write(
                bytes,
                offset,
                bytes.size - offset,
                AudioTrack.WRITE_BLOCKING,
            )
            if (written <= 0) {
                if (running) emitError("Speech playback write failed ($written)")
                return
            }
            offset += written
            framesSubmitted += written / 2L
        }
    }

    private fun dequeueLocked(maxBytes: Int): ByteArray {
        val outputSize = min(maxBytes, queuedBytes)
        val output = ByteArray(outputSize)
        var written = 0
        while (written < outputSize && playbackQueue.isNotEmpty()) {
            val current = playbackQueue.first()
            val available = current.size - queueOffset
            val count = min(outputSize - written, available)
            current.copyInto(output, written, queueOffset, queueOffset + count)
            written += count
            queueOffset += count
            queuedBytes -= count
            if (queueOffset >= current.size) {
                playbackQueue.removeFirst()
                queueOffset = 0
            }
        }
        return output
    }

    private fun clearQueueLocked() {
        playbackQueue.clear()
        queuedBytes = 0
        queueOffset = 0
    }

    private fun resetTrack(track: AudioTrack) {
        try {
            if (track.playState == AudioTrack.PLAYSTATE_PLAYING) track.pause()
            track.flush()
        } catch (_: Throwable) {
        }
    }

    private fun stopEngine() {
        running = false
        muted = true
        synchronized(queueLock) {
            interruptRequested = true
            queueLock.notifyAll()
        }
        try {
            audioRecord?.stop()
        } catch (_: Throwable) {
        }
        captureThread?.join(500)
        playbackThread?.join(700)
        captureThread = null
        playbackThread = null
        echoCanceler?.release()
        noiseSuppressor?.release()
        gainControl?.release()
        echoCanceler = null
        noiseSuppressor = null
        gainControl = null
        audioRecord?.release()
        audioTrack?.release()
        audioRecord = null
        audioTrack = null
        synchronized(queueLock) {
            clearQueueLocked()
            playbackActive = false
            hadPlaybackThisTurn = false
            turnFinished = false
            framesSubmitted = 0
        }
        audioManager?.let { manager ->
            manager.isSpeakerphoneOn = previousSpeakerphoneState
            manager.mode = previousAudioMode
        }
        audioManager = null
    }

    private fun emit(event: Map<String, Any>) {
        mainHandler.post {
            if (running) eventSink?.success(event)
        }
    }

    private fun emitError(message: String) {
        emit(mapOf("type" to "error", "message" to message))
    }

    companion object {
        private const val METHOD_CHANNEL = "italir_pothe/ai_voice_audio"
        private const val EVENT_CHANNEL = "italir_pothe/ai_voice_audio_events"
    }
}
