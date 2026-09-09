package com.hiennv.flutter_callkit_incoming

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.hiennv.flutter_callkit_incoming.Utils.Companion.reapCollection
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.ref.WeakReference

/** FlutterCallkitIncomingPlugin */
@SuppressLint("LongLogTag")
class FlutterCallkitIncomingPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {

    companion object {

        const val EXTRA_CALLKIT_CALL_DATA =
            "EXTRA_CALLKIT_CALL_DATA"

        const val TAG =
            "FlutterCallkitIncomingPlugin"

        @SuppressLint("StaticFieldLeak")
        private lateinit var instance:
                FlutterCallkitIncomingPlugin

        fun getInstance():
                FlutterCallkitIncomingPlugin? {
            return if (hasInstance()) {
                instance
            } else {
                null
            }
        }

        fun hasInstance(): Boolean {
            return ::instance.isInitialized
        }

        private val methodChannels =
            mutableMapOf<BinaryMessenger, MethodChannel>()

        private val eventChannels =
            mutableMapOf<BinaryMessenger, EventChannel>()

        private val eventHandlers =
            mutableMapOf<BinaryMessenger, EventCallbackHandler>()

        private val eventCallbacks =
            mutableListOf<WeakReference<CallkitEventCallback>>()

        fun sendEvent(
            event: String,
            body: Map<String, Any?>
        ) {
            send(event, body)
        }

        fun sendEventCustom(
            event: String,
            body: Map<String, Any>
        ) {
            send(event, body)
        }

        fun acceptCallHandleCallback(
            bundle: Bundle
        ) {
            Handler(Looper.getMainLooper())
                .postDelayed(
                    {
                        val extra =
                            bundle.getSerializable(
                                CallkitConstants
                                    .EXTRA_CALLKIT_EXTRA
                            )

                        methodChannels.values.forEach {
                            it.invokeMethod(
                                "acceptCallHandle",
                                extra
                            )
                        }
                    },
                    750L
                )
        }

        fun invokeFlutterCallback(
            data: Any
        ) {
            Handler(Looper.getMainLooper())
                .postDelayed(
                    {
                        methodChannels.values.forEach {
                            it.invokeMethod(
                                "invokeFlutter",
                                data
                            )
                        }
                    },
                    750L
                )
        }

        /**
         * Sends an event to active Flutter UI listeners.
         * When no UI listener exists, the background executor receives it.
         */
        private fun send(
            event: String,
            body: Map<String, Any?>
        ) {
            val uiHandlers =
                eventHandlers.values.filter {
                    it.hasListener()
                }

            if (uiHandlers.isNotEmpty()) {
                uiHandlers.forEach {
                    it.send(event, body)
                }
            } else if (
                CallkitBackgroundExecutor.registered
            ) {
                CallkitBackgroundExecutor.send(
                    event,
                    body
                )
            }
        }

        /**
         * Registers a native callback that can receive call events
         * even when the main Flutter engine is unavailable.
         */
        fun registerEventCallback(
            callback: CallkitEventCallback
        ) {
            eventCallbacks.add(
                WeakReference(callback)
            )
        }

        fun unregisterEventCallback(
            callback: CallkitEventCallback
        ) {
            eventCallbacks.removeAll {
                it.get() == callback ||
                        it.get() == null
            }
        }

        internal fun notifyEventCallbacks(
            event: CallkitEventCallback.CallEvent,
            callData: Bundle
        ) {
            eventCallbacks
                .reapCollection()
                .forEach { callbackReference ->
                    callbackReference
                        .get()
                        ?.onCallEvent(
                            event,
                            callData
                        )
                }
        }

        fun sharePluginWithRegister(
            flutterPluginBinding:
            FlutterPlugin.FlutterPluginBinding
        ) {
            initSharedInstance(
                flutterPluginBinding.applicationContext,
                flutterPluginBinding.binaryMessenger
            )
        }

        fun initSharedInstance(
            context: Context,
            binaryMessenger: BinaryMessenger
        ) {
            if (!::instance.isInitialized) {
                instance =
                    FlutterCallkitIncomingPlugin()
            }

            val applicationContext =
                context.applicationContext

            /*
             * Always refresh the application context. The static plugin
             * instance can survive a Flutter engine detach.
             */
            instance.context =
                applicationContext

            if (
                instance.callkitSoundPlayerManager == null
            ) {
                instance.callkitSoundPlayerManager =
                    CallkitSoundPlayerManager(
                        applicationContext
                    )
            }

            if (
                instance.callkitNotificationManager == null
            ) {
                instance.callkitNotificationManager =
                    CallkitNotificationManager(
                        applicationContext,
                        instance.callkitSoundPlayerManager
                    )
            }

            val methodChannel =
                MethodChannel(
                    binaryMessenger,
                    "flutter_callkit_incoming"
                )

            methodChannels[binaryMessenger] =
                methodChannel

            methodChannel.setMethodCallHandler(
                instance
            )

            val eventChannel =
                EventChannel(
                    binaryMessenger,
                    "flutter_callkit_incoming_events"
                )

            eventChannels[binaryMessenger] =
                eventChannel

            val eventHandler =
                EventCallbackHandler()

            eventHandlers[binaryMessenger] =
                eventHandler

            eventChannel.setStreamHandler(
                eventHandler
            )
        }
    }

    /**
     * The Activity currently attached to the main Flutter engine.
     */
    private var activity: Activity? = null

    /**
     * Application context. This must remain available when Flutter
     * Activities or individual Flutter engines are detached.
     */
    private var context: Context? = null

    private var callkitNotificationManager:
            CallkitNotificationManager? = null

    private var callkitSoundPlayerManager:
            CallkitSoundPlayerManager? = null

    fun getCallkitNotificationManager():
            CallkitNotificationManager? {
        return callkitNotificationManager
    }

    fun getCallkitSoundPlayerManager():
            CallkitSoundPlayerManager? {
        return callkitSoundPlayerManager
    }

    override fun onAttachedToEngine(
        flutterPluginBinding:
        FlutterPlugin.FlutterPluginBinding
    ) {
        sharePluginWithRegister(
            flutterPluginBinding
        )

        if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.M
        ) {
            InAppCallManager(
                flutterPluginBinding.applicationContext
            ).registerPhoneAccount()
        }
    }

    fun showIncomingNotification(
        data: Data
    ) {
        data.from = "notification"

        val appContext =
            context ?: return

        appContext.sendBroadcast(
            CallkitIncomingBroadcastReceiver
                .getIntentIncoming(
                    appContext,
                    data.toBundle()
                )
        )
    }

    fun showMissCallNotification(
        data: Data
    ) {
        callkitNotificationManager
            ?.showMissCallNotification(
                data.toBundle()
            )
    }

    fun startCall(
        data: Data
    ) {
        val appContext =
            context ?: return

        appContext.sendBroadcast(
            CallkitIncomingBroadcastReceiver
                .getIntentStart(
                    appContext,
                    data.toBundle()
                )
        )
    }

    /**
     * Ends a call from native code.
     *
     * The fullscreen Activity is closed directly before the broadcast.
     * This guarantees that remote cancellation does not leave the
     * incoming-call Activity visible.
     */
    fun endCall(data: Data) {
        val appContext = context ?: return

        callkitSoundPlayerManager?.stop()
        CallkitIncomingActivity.finishCurrent(false)

        // Critical for Android Telecom fullscreen UI.
        CallkitConnection.find(data.id)?.let { connection ->
            connection.markEnded()
        }

        appContext.sendBroadcast(
            CallkitIncomingBroadcastReceiver.getIntentEnded(
                appContext,
                data.toBundle()
            )
        )
    }

    fun endAllCalls() {
        val appContext =
            context ?: return

        stopIncomingCallUi()

        val calls =
            getDataActiveCalls(appContext)

        calls.forEach { call ->
            appContext.sendBroadcast(
                CallkitIncomingBroadcastReceiver
                    .getIntentEnded(
                        appContext,
                        call.toBundle()
                    )
            )
        }

        CallkitNotificationService.stopService(
            appContext
        )

        removeAllCalls(
            appContext
        )
    }

    fun sendEventCustom(
        body: Map<String, Any>
    ) {
        send(
            CallkitConstants.ACTION_CALL_CUSTOM,
            body
        )
    }

    /**
     * Stops only the visible incoming-call UI.
     *
     * This does not send Decline because a remote caller cancellation
     * must not look like the receiver manually declined the call.
     */
    private fun stopIncomingCallUi() {
        try {
            callkitSoundPlayerManager?.stop()
        } catch (error: Exception) {
            Log.w(
                TAG,
                "Unable to stop incoming ringtone",
                error
            )
        }

        try {
            CallkitIncomingActivity
                .finishCurrent(false)
        } catch (error: Exception) {
            Log.w(
                TAG,
                "Unable to close incoming fullscreen Activity",
                error
            )
        }
    }

    /**
     * Cleans all native Android resources for one incoming call.
     */
    private fun cleanupIncomingCall(
        appContext: Context,
        requestedCall: Data
    ) {
        val activeCalls =
            getDataActiveCalls(appContext)

        val currentCall =
            activeCalls.firstOrNull {
                it.id == requestedCall.id
            }

        /*
         * Use requestedCall as a fallback. The active-call collection may
         * already be empty when a remote FCM/background cancellation arrives.
         */
        val callToCleanup =
            currentCall ?: requestedCall

        stopIncomingCallUi()

        try {
            callkitNotificationManager
                ?.clearIncomingNotification(
                    callToCleanup.toBundle(),
                    false
                )
        } catch (error: Exception) {
            Log.w(
                TAG,
                "Unable to clear incoming notification " +
                        "for call ${callToCleanup.id}",
                error
            )
        }

        try {
            CallkitNotificationService
                .stopService(appContext)
        } catch (error: Exception) {
            Log.w(
                TAG,
                "Unable to stop CallkitNotificationService",
                error
            )
        }

        if (callToCleanup.id.isNotEmpty()) {
            try {
                removeCall(
                    appContext,
                    callToCleanup
                )
            } catch (error: Exception) {
                Log.w(
                    TAG,
                    "Unable to remove active call " +
                            callToCleanup.id,
                    error
                )
            }
        }
    }

    @Suppress("UNCHECKED_CAST")
    override fun onMethodCall(
        @NonNull call: MethodCall,
        @NonNull result: Result
    ) {
        try {
            when (call.method) {

                "registerBackgroundHandler" -> {
                    val arguments =
                        call.arguments as Map<*, *>

                    val pluginHandle =
                        (arguments["pluginHandle"] as Number)
                            .toLong()

                    val userHandle =
                        (arguments["userHandle"] as Number)
                            .toLong()

                    addBackgroundCallback(
                        context,
                        pluginHandle,
                        userHandle
                    )

                    CallkitBackgroundExecutor.start(
                        requireNotNull(context),
                        pluginHandle
                    )

                    result.success(null)
                }

                "getBackgroundHandler" -> {
                    val handle =
                        getUserCallback(context)

                    result.success(handle)
                }

                // The readiness handshake is required by iOS. Acknowledge it
                // on Android as well because the Dart background dispatcher is
                // shared by both platforms.
                "backgroundInitialized" -> {
                    result.success(null)
                }

                "setAcceptCallHandle" -> {
                    val arguments =
                        call.arguments as? List<*>

                    if (
                        arguments != null &&
                        arguments.size >= 2
                    ) {
                        val handle =
                            arguments[0] as? Int ?: 0

                        val key =
                            arguments[1] as? String ?: ""

                        saveHandle(
                            context,
                            key,
                            handle
                        )
                    }

                    result.success(null)
                }

                "showCallkitIncoming" -> {
                    val appContext =
                        requireNotNull(context)

                    val data =
                        Data(
                            call.arguments()
                                ?: HashMap()
                        )

                    data.from =
                        "notification"

                    appContext.sendBroadcast(
                        CallkitIncomingBroadcastReceiver
                            .getIntentIncoming(
                                appContext,
                                data.toBundle()
                            )
                    )

                    result.success(true)
                }

                "showCallkitIncomingSilently" -> {
                    val data =
                        Data(
                            call.arguments()
                                ?: HashMap()
                        )

                    data.from =
                        "notification"

                    result.success(true)
                }

                "showMissCallNotification" -> {
                    val data =
                        Data(
                            call.arguments()
                                ?: HashMap()
                        )

                    data.from =
                        "notification"

                    callkitNotificationManager
                        ?.showMissCallNotification(
                            data.toBundle()
                        )

                    result.success(true)
                }

                "startCall" -> {
                    val appContext =
                        requireNotNull(context)

                    val data =
                        Data(
                            call.arguments()
                                ?: HashMap()
                        )

                    appContext.sendBroadcast(
                        CallkitIncomingBroadcastReceiver
                            .getIntentStart(
                                appContext,
                                data.toBundle()
                            )
                    )

                    result.success(true)
                }

                "muteCall" -> {
                    val eventData =
                        buildMap<String, Any> {
                            val arguments =
                                call.arguments

                            if (arguments is Map<*, *>) {
                                putAll(
                                    arguments as
                                            Map<String, Any>
                                )
                            }
                        }

                    sendEvent(
                        CallkitConstants
                            .ACTION_CALL_TOGGLE_MUTE,
                        eventData
                    )

                    result.success(true)
                }

                "holdCall" -> {
                    val eventData =
                        buildMap<String, Any> {
                            val arguments =
                                call.arguments

                            if (arguments is Map<*, *>) {
                                putAll(
                                    arguments as
                                            Map<String, Any>
                                )
                            }
                        }

                    sendEvent(
                        CallkitConstants
                            .ACTION_CALL_TOGGLE_HOLD,
                        eventData
                    )

                    result.success(true)
                }

                "isMuted" -> {
                    result.success(true)
                }

                /**
                 * Remote or programmatic call cancellation.
                 *
                 * Do not broadcast Decline here. A caller cancellation is
                 * not the same as the receiver pressing Decline.
                 */
                "endCall" -> {
                    val appContext = requireNotNull(context)

                    val requestedCall =
                        Data(call.arguments() ?: HashMap())

                    val activeCall =
                        getDataActiveCalls(appContext)
                            .firstOrNull { it.id == requestedCall.id }

                    val callToEnd = activeCall ?: requestedCall

                    // Immediately stop the plugin ringtone.
                    callkitSoundPlayerManager?.stop()

                    // Immediately close the plugin's own fullscreen Activity.
                    CallkitIncomingActivity.finishCurrent(false)

                    /*
                     * Critical:
                     * End Android Telecom's Connection. Otherwise Android's system
                     * fullscreen call UI remains visible even though sound is stopped.
                     */
                    val telecomConnection =
                        CallkitConnection.find(callToEnd.id)

                    if (telecomConnection != null) {
                        telecomConnection.markEnded()
                    } else {
                        Log.w(
                            TAG,
                            "Telecom connection not found: ${callToEnd.id}"
                        )
                    }

                    /*
                     * Send ACTION_CALL_ENDED so the receiver performs the complete
                     * normal end flow:
                     * - Telecom cleanup
                     * - notification cleanup
                     * - foreground service cleanup
                     * - fullscreen Activity cleanup
                     * - active-call removal
                     */
                    appContext.sendBroadcast(
                        CallkitIncomingBroadcastReceiver.getIntentEnded(
                            appContext,
                            callToEnd.toBundle()
                        )
                    )

                    result.success(true)
                }

                "callConnected" -> {
                    val appContext =
                        requireNotNull(context)

                    val activeCalls =
                        getDataActiveCalls(
                            appContext
                        )

                    val requestedCall =
                        Data(
                            call.arguments()
                                ?: HashMap()
                        )

                    val currentCall =
                        activeCalls.firstOrNull {
                            it.id == requestedCall.id
                        }

                    if (currentCall != null) {
                        appContext.sendBroadcast(
                            CallkitIncomingBroadcastReceiver
                                .getIntentConnected(
                                    appContext,
                                    currentCall.toBundle()
                                )
                        )
                    }

                    result.success(true)
                }

                "endAllCalls" -> {
                    val appContext =
                        requireNotNull(context)

                    /*
                     * Close the fullscreen incoming UI before processing
                     * the stored calls.
                     */
                    stopIncomingCallUi()

                    val activeCalls =
                        getDataActiveCalls(
                            appContext
                        )

                    activeCalls.forEach { activeCall ->
                        if (activeCall.isAccepted) {
                            appContext.sendBroadcast(
                                CallkitIncomingBroadcastReceiver
                                    .getIntentEnded(
                                        appContext,
                                        activeCall.toBundle()
                                    )
                            )
                        } else {
                            appContext.sendBroadcast(
                                CallkitIncomingBroadcastReceiver
                                    .getIntentDecline(
                                        appContext,
                                        activeCall.toBundle()
                                    )
                            )
                        }
                    }

                    CallkitNotificationService
                        .stopService(appContext)

                    removeAllCalls(
                        appContext
                    )

                    result.success(true)
                }

                "activeCalls" -> {
                    result.success(
                        getDataActiveCallsForFlutter(
                            context
                        )
                    )
                }

                "getDevicePushTokenVoIP" -> {
                    result.success("")
                }

                "silenceEvents" -> {
                    val silence =
                        call.arguments as? Boolean
                            ?: false

                    CallkitIncomingBroadcastReceiver
                        .silenceEvents =
                        silence

                    result.success(true)
                }

                "requestNotificationPermission" -> {
                    val permissionData =
                        buildMap<String, Any> {
                            val arguments =
                                call.arguments

                            if (arguments is Map<*, *>) {
                                putAll(
                                    arguments as
                                            Map<String, Any>
                                )
                            }
                        }

                    callkitNotificationManager
                        ?.requestNotificationPermission(
                            activity,
                            permissionData
                        )

                    result.success(true)
                }

                "requestFullIntentPermission" -> {
                    callkitNotificationManager
                        ?.requestFullIntentPermission(
                            activity
                        )

                    result.success(true)
                }

                "canUseFullScreenIntent" -> {
                    result.success(
                        callkitNotificationManager
                            ?.canUseFullScreenIntent()
                            ?: true
                    )
                }

                /**
                 * Clears only the visible incoming-call notification/ring.
                 * It also closes the fullscreen incoming-call Activity.
                 */
                "hideCallkitIncoming" -> {
                    val data =
                        Data(
                            call.arguments()
                                ?: HashMap()
                        )

                    stopIncomingCallUi()

                    callkitNotificationManager
                        ?.clearIncomingNotification(
                            data.toBundle(),
                            false
                        )

                    result.success(true)
                }

                /**
                 * Clears native incoming-call UI without sending a Flutter
                 * Decline or End event.
                 */
                "endNativeSubsystemOnly" -> {
                    val appContext =
                        requireNotNull(context)

                    val requestedCall =
                        Data(
                            call.arguments()
                                ?: HashMap()
                        )

                    if (requestedCall.id.isNotEmpty()) {
                        cleanupIncomingCall(
                            appContext,
                            requestedCall
                        )
                    } else {
                        stopIncomingCallUi()

                        val activeCalls =
                            getDataActiveCalls(
                                appContext
                            )

                        activeCalls.forEach {
                            try {
                                callkitNotificationManager
                                    ?.clearIncomingNotification(
                                        it.toBundle(),
                                        false
                                    )
                            } catch (error: Exception) {
                                Log.w(
                                    TAG,
                                    "Unable to clear native call " +
                                            it.id,
                                    error
                                )
                            }
                        }

                        CallkitNotificationService
                            .stopService(appContext)

                        removeAllCalls(
                            appContext
                        )
                    }

                    result.success(true)
                }

                "setAudioRoute" -> {
                    result.success(true)
                }

                else -> {
                    result.notImplemented()
                }
            }
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Method ${call.method} failed",
                error
            )

            result.error(
                "error",
                error.message
                    ?: "Unknown CallKit error",
                null
            )
        }
    }

    override fun onDetachedFromEngine(
        binding: FlutterPlugin.FlutterPluginBinding
    ) {
        methodChannels
            .remove(binding.binaryMessenger)
            ?.setMethodCallHandler(null)

        eventChannels
            .remove(binding.binaryMessenger)
            ?.setStreamHandler(null)

        eventHandlers.remove(binding.binaryMessenger)

        // Only destroy shared managers after every Flutter engine detaches.
        if (methodChannels.isEmpty() && eventChannels.isEmpty()) {
            callkitSoundPlayerManager?.destroy()
            callkitNotificationManager?.destroy()

            callkitSoundPlayerManager = null
            callkitNotificationManager = null
        }
    }

    override fun onAttachedToActivity(
        binding: ActivityPluginBinding
    ) {
        instance.context =
            binding.activity.applicationContext

        instance.activity =
            binding.activity

        binding.addRequestPermissionsResultListener(
            this
        )
    }

    override fun onDetachedFromActivityForConfigChanges() {
        instance.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(
        binding: ActivityPluginBinding
    ) {
        instance.context =
            binding.activity.applicationContext

        instance.activity =
            binding.activity

        binding.addRequestPermissionsResultListener(
            this
        )
    }

    override fun onDetachedFromActivity() {
        /*
         * Keep the application context alive. Only the Activity reference
         * must be removed.
         */
        instance.activity = null
    }

    class EventCallbackHandler :
        EventChannel.StreamHandler {

        @Volatile
        private var eventSink:
                EventChannel.EventSink? = null

        fun hasListener(): Boolean {
            return eventSink != null
        }

        override fun onListen(
            arguments: Any?,
            sink: EventChannel.EventSink
        ) {
            eventSink = sink
        }

        fun send(
            event: String,
            body: Map<String, Any?>
        ) {
            val eventData =
                mapOf(
                    "event" to event,
                    "body" to body
                )

            Handler(Looper.getMainLooper())
                .post {
                    eventSink?.success(
                        eventData
                    )
                }
        }

        override fun onCancel(
            arguments: Any?
        ) {
            eventSink = null
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        instance.callkitNotificationManager
            ?.onRequestPermissionsResult(
                instance.activity,
                requestCode,
                grantResults
            )

        return true
    }
}
