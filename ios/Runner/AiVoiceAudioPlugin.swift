import AVFoundation
import Flutter

/// Native full-duplex PCM engine for Gemini Live.
///
/// AVAudioEngine voice processing supplies system echo cancellation while a
/// serial playback queue keeps PCM buffers continuous and interruption-safe.
final class AiVoiceAudioPlugin: NSObject, FlutterStreamHandler {
  private let methodChannel: FlutterMethodChannel
  private let eventChannel: FlutterEventChannel
  private let engine = AVAudioEngine()
  private let player = AVAudioPlayerNode()
  private let playbackQueue = DispatchQueue(label: "com.shafacode.italir-pothe.ai-voice-playback")
  private let captureQueue = DispatchQueue(label: "com.shafacode.italir-pothe.ai-voice-capture")

  private var eventSink: FlutterEventSink?
  private var converter: AVAudioConverter?
  private var inputTapInstalled = false
  private var playerAttached = false
  private var captureAccumulator = Data()
  private var playbackAccumulator = Data()
  private var running = false
  private var muted = true
  private var playbackStarted = false
  private var turnFinished = false
  private var scheduledBuffers = 0
  private var playbackGeneration = 0
  private var stableTurns = 0
  private var inputSampleRate = 16_000
  private var outputSampleRate = 24_000
  private var inputChunkMs = 40
  private var initialPlaybackBufferMs = 300
  private var maxPlaybackBufferMs = 600
  private var targetPlaybackBufferMs = 300

  init(messenger: FlutterBinaryMessenger) {
    methodChannel = FlutterMethodChannel(
      name: "italir_pothe/ai_voice_audio",
      binaryMessenger: messenger
    )
    eventChannel = FlutterEventChannel(
      name: "italir_pothe/ai_voice_audio_events",
      binaryMessenger: messenger
    )
    super.init()
    methodChannel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    eventChannel.setStreamHandler(self)
  }

  deinit {
    stopEngine()
  }

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    do {
      switch call.method {
      case "start":
        let arguments = call.arguments as? [String: Any] ?? [:]
        try startEngine(arguments)
        result(nil)
      case "enqueuePlayback":
        guard let data = call.arguments as? FlutterStandardTypedData,
              !data.data.isEmpty else {
          result(FlutterError(code: "invalid_audio", message: "Playback audio is empty.", details: nil))
          return
        }
        enqueuePlayback(data.data)
        result(nil)
      case "finishPlaybackTurn":
        finishPlaybackTurn()
        result(nil)
      case "interruptPlayback":
        interruptPlayback()
        result(nil)
      case "setMuted":
        muted = call.arguments as? Bool ?? true
        result(nil)
      case "stop":
        stopEngine()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    } catch {
      if call.method == "start" {
        stopEngine()
      }
      emitError(error.localizedDescription)
      result(FlutterError(code: "native_audio_error", message: error.localizedDescription, details: nil))
    }
  }

  private func startEngine(_ arguments: [String: Any]) throws {
    stopEngine()
    inputSampleRate = arguments["inputSampleRate"] as? Int ?? 16_000
    outputSampleRate = arguments["outputSampleRate"] as? Int ?? 24_000
    inputChunkMs = arguments["inputChunkMs"] as? Int ?? 40
    initialPlaybackBufferMs = arguments["initialPlaybackBufferMs"] as? Int ?? 300
    maxPlaybackBufferMs = arguments["maxPlaybackBufferMs"] as? Int ?? 600
    targetPlaybackBufferMs = initialPlaybackBufferMs

    let session = AVAudioSession.sharedInstance()
    try session.setCategory(
      .playAndRecord,
      mode: .voiceChat,
      options: [.defaultToSpeaker, .allowBluetooth]
    )
    try session.setPreferredIOBufferDuration(0.02)
    try session.setActive(true)

    let input = engine.inputNode
    try input.setVoiceProcessingEnabled(true)
    let inputFormat = input.inputFormat(forBus: 0)
    guard inputFormat.sampleRate > 0,
          let targetFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: Double(inputSampleRate),
            channels: 1,
            interleaved: false
          ),
          let audioConverter = AVAudioConverter(from: inputFormat, to: targetFormat) else {
      throw NativeVoiceError.unavailableFormat
    }
    converter = audioConverter

    if !playerAttached {
      engine.attach(player)
      playerAttached = true
    } else {
      engine.disconnectNodeOutput(player)
    }
    let playbackFormat = AVAudioFormat(
      standardFormatWithSampleRate: Double(outputSampleRate),
      channels: 1
    )!
    engine.connect(player, to: engine.mainMixerNode, format: playbackFormat)
    input.installTap(onBus: 0, bufferSize: 1_024, format: inputFormat) { [weak self] buffer, _ in
      self?.captureQueue.async {
        self?.handleCapturedBuffer(buffer, targetFormat: targetFormat)
      }
    }
    inputTapInstalled = true

    prepareStateForStart()
    engine.prepare()
    try engine.start()
    running = true
    muted = false
  }

  private func prepareStateForStart() {
    captureAccumulator.removeAll(keepingCapacity: true)
    playbackQueue.sync {
      playbackAccumulator.removeAll(keepingCapacity: true)
      playbackStarted = false
      turnFinished = false
      scheduledBuffers = 0
      playbackGeneration += 1
      stableTurns = 0
    }
  }

  private func handleCapturedBuffer(
    _ inputBuffer: AVAudioPCMBuffer,
    targetFormat: AVAudioFormat
  ) {
    guard running, let converter else { return }
    let ratio = targetFormat.sampleRate / inputBuffer.format.sampleRate
    let capacity = AVAudioFrameCount(ceil(Double(inputBuffer.frameLength) * ratio)) + 8
    guard let converted = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: capacity) else {
      return
    }
    var suppliedInput = false
    var conversionError: NSError?
    let status = converter.convert(to: converted, error: &conversionError) { _, inputStatus in
      if suppliedInput {
        inputStatus.pointee = .noDataNow
        return nil
      }
      suppliedInput = true
      inputStatus.pointee = .haveData
      return inputBuffer
    }
    guard status != .error,
          conversionError == nil,
          converted.frameLength > 0,
          let samples = converted.int16ChannelData?[0] else {
      return
    }
    let byteCount = Int(converted.frameLength) * MemoryLayout<Int16>.size
    captureAccumulator.append(Data(bytes: samples, count: byteCount))
    let chunkBytes = inputSampleRate * MemoryLayout<Int16>.size * inputChunkMs / 1_000
    while captureAccumulator.count >= chunkBytes {
      let chunk = captureAccumulator.prefix(chunkBytes)
      captureAccumulator.removeFirst(chunkBytes)
      if !muted {
        emit(["type": "microphone", "data": FlutterStandardTypedData(bytes: Data(chunk))])
      }
    }
  }

  private func enqueuePlayback(_ incoming: Data) {
    guard running else { return }
    let evenCount = incoming.count - (incoming.count % 2)
    guard evenCount > 0 else { return }
    let data = incoming.prefix(evenCount)
    playbackQueue.async { [weak self] in
      guard let self, self.running else { return }
      self.turnFinished = false
      if !self.playbackStarted {
        self.playbackAccumulator.append(data)
        let targetBytes = self.outputSampleRate * 2 * self.targetPlaybackBufferMs / 1_000
        if self.playbackAccumulator.count >= targetBytes {
          self.startBufferedPlayback()
        }
      } else {
        self.schedulePlaybackBuffer(Data(data))
      }
    }
  }

  private func startBufferedPlayback() {
    guard !playbackAccumulator.isEmpty else { return }
    let initialData = playbackAccumulator
    playbackAccumulator.removeAll(keepingCapacity: true)
    playbackStarted = true
    schedulePlaybackBuffer(initialData)
    if !player.isPlaying {
      player.play()
    }
    emit(["type": "playback_started"])
  }

  private func schedulePlaybackBuffer(_ data: Data) {
    guard !data.isEmpty else { return }
    let format = AVAudioFormat(
      standardFormatWithSampleRate: Double(outputSampleRate),
      channels: 1
    )!
    let frames = AVAudioFrameCount(data.count / 2)
    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames),
          let output = buffer.floatChannelData?[0] else {
      emitError("Unable to allocate native speech buffer")
      return
    }
    buffer.frameLength = frames
    data.withUnsafeBytes { raw in
      let samples = raw.bindMemory(to: Int16.self)
      for index in 0..<Int(frames) {
        output[index] = Float(samples[index]) / 32_768.0
      }
    }
    scheduledBuffers += 1
    let generation = playbackGeneration
    player.scheduleBuffer(buffer, completionCallbackType: .dataPlayedBack) { [weak self] _ in
      self?.playbackQueue.async {
        guard let self, self.playbackGeneration == generation else { return }
        self.scheduledBuffers = max(0, self.scheduledBuffers - 1)
        self.completeTurnIfDrained()
      }
    }
  }

  private func finishPlaybackTurn() {
    playbackQueue.async { [weak self] in
      guard let self, self.running else { return }
      self.turnFinished = true
      if !self.playbackStarted && !self.playbackAccumulator.isEmpty {
        self.startBufferedPlayback()
      }
      self.completeTurnIfDrained()
    }
  }

  private func completeTurnIfDrained() {
    guard turnFinished, playbackStarted, scheduledBuffers == 0 else { return }
    playbackStarted = false
    turnFinished = false
    stableTurns += 1
    if stableTurns >= 3 {
      stableTurns = 0
      targetPlaybackBufferMs = max(initialPlaybackBufferMs, targetPlaybackBufferMs - 50)
    }
    emit(["type": "playback_ended"])
  }

  private func interruptPlayback() {
    playbackQueue.async { [weak self] in
      guard let self else { return }
      let wasPlaying = self.playbackStarted || self.scheduledBuffers > 0 || !self.playbackAccumulator.isEmpty
      self.playbackGeneration += 1
      self.player.stop()
      self.playbackAccumulator.removeAll(keepingCapacity: true)
      self.scheduledBuffers = 0
      self.playbackStarted = false
      self.turnFinished = false
      self.stableTurns = 0
      self.targetPlaybackBufferMs = min(
        self.maxPlaybackBufferMs,
        self.targetPlaybackBufferMs + 50
      )
      if wasPlaying {
        self.emit(["type": "playback_ended"])
      }
    }
  }

  private func stopEngine() {
    running = false
    muted = true
    if inputTapInstalled {
      engine.inputNode.removeTap(onBus: 0)
      inputTapInstalled = false
    }
    engine.stop()
    playbackQueue.sync {
      playbackGeneration += 1
      player.stop()
      playbackAccumulator.removeAll(keepingCapacity: false)
      scheduledBuffers = 0
      playbackStarted = false
      turnFinished = false
    }
    converter = nil
    captureAccumulator.removeAll(keepingCapacity: false)
    try? AVAudioSession.sharedInstance().setActive(
      false,
      options: .notifyOthersOnDeactivation
    )
  }

  private func emit(_ event: [String: Any]) {
    DispatchQueue.main.async { [weak self] in
      guard self?.running == true else { return }
      self?.eventSink?(event)
    }
  }

  private func emitError(_ message: String) {
    emit(["type": "error", "message": message])
  }
}

private enum NativeVoiceError: LocalizedError {
  case unavailableFormat

  var errorDescription: String? {
    switch self {
    case .unavailableFormat:
      return "The device audio format is unavailable for live voice."
    }
  }
}
