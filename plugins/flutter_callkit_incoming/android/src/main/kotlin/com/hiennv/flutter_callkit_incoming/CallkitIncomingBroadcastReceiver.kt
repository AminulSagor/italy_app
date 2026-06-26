package com.hiennv.flutter_callkit_incoming

import android.Manifest
import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.telecom.TelecomManager
import android.telecom.VideoProfile
import android.util.Log
import androidx.core.content.ContextCompat

class CallkitIncomingBroadcastReceiver : BroadcastReceiver() {

    companion object {

        private const val TAG = "CallkitIncomingReceiver"

        @Volatile
        var silenceEvents = false

        fun getIntent(
            context: Context,
            action: String,
            data: Bundle?
        ): Intent {
            return createIntent(
                context = context,
                action = action,
                data = data
            )
        }

        fun getIntentIncoming(
            context: Context,
            data: Bundle?
        ): Intent {
            return createIntent(
                context = context,
                action = CallkitConstants.ACTION_CALL_INCOMING,
                data = data
            )
        }

        fun getIntentStart(
            context: Context,
            data: Bundle?
        ): Intent {
            return createIntent(
                context = context,
                action = CallkitConstants.ACTION_CALL_START,
                data = data
            )
        }

        fun getIntentAccept(
            context: Context,
            data: Bundle?
        ): Intent {
            return createIntent(
                context = context,
                action = CallkitConstants.ACTION_CALL_ACCEPT,
                data = data
            )
        }

        fun getIntentDecline(
            context: Context,
            data: Bundle?
        ): Intent {
            return createIntent(
                context = context,
                action = CallkitConstants.ACTION_CALL_DECLINE,
                data = data
            )
        }

        fun getIntentEnded(
            context: Context,
            data: Bundle?
        ): Intent {
            return createIntent(
                context = context,
                action = CallkitConstants.ACTION_CALL_ENDED,
                data = data
            )
        }

        fun getIntentTimeout(
            context: Context,
            data: Bundle?
        ): Intent {
            return createIntent(
                context = context,
                action = CallkitConstants.ACTION_CALL_TIMEOUT,
                data = data
            )
        }

        fun getIntentCallback(
            context: Context,
            data: Bundle?
        ): Intent {
            return createIntent(
                context = context,
                action = CallkitConstants.ACTION_CALL_CALLBACK,
                data = data
            )
        }

        fun getIntentHeldByCell(
            context: Context,
            data: Bundle?
        ): Intent {
            return createIntent(
                context = context,
                action = CallkitConstants.ACTION_CALL_HELD,
                data = data
            )
        }

        fun getIntentUnHeldByCell(
            context: Context,
            data: Bundle?
        ): Intent {
            return createIntent(
                context = context,
                action = CallkitConstants.ACTION_CALL_UNHELD,
                data = data
            )
        }

        fun getIntentConnected(
            context: Context,
            data: Bundle?
        ): Intent {
            return createIntent(
                context = context,
                action = CallkitConstants.ACTION_CALL_CONNECTED,
                data = data
            )
        }

        private fun createIntent(
            context: Context,
            action: String,
            data: Bundle?
        ): Intent {
            return Intent().apply {
                setClassName(
                    context.packageName,
                    "com.hiennv.flutter_callkit_incoming." +
                            "CallkitIncomingBroadcastReceiver"
                )

                this.action =
                    "${context.packageName}.$action"

                putExtra(
                    CallkitConstants.EXTRA_CALLKIT_INCOMING_DATA,
                    data
                )

                `package` = context.packageName
            }
        }
    }

    /**
     * Retrieves the notification manager from the currently active
     * plugin instance.
     */
    private fun getCallkitNotificationManager():
            CallkitNotificationManager? {
        return FlutterCallkitIncomingPlugin
            .getInstance()
            ?.getCallkitNotificationManager()
    }

    /**
     * Retrieves the ringtone manager from the active plugin instance.
     */
    private fun getCallkitSoundPlayerManager():
            CallkitSoundPlayerManager? {
        return FlutterCallkitIncomingPlugin
            .getInstance()
            ?.getCallkitSoundPlayerManager()
    }

    /**
     * Stops the incoming ringtone and closes the fullscreen incoming
     * call Activity.
     *
     * Both a broadcast and a direct Activity reference are used.
     * The direct call acts as a fallback when a device delays or drops
     * dynamically registered broadcasts.
     */
    private fun closeIncomingCallUi(
        context: Context,
        isAccepted: Boolean
    ) {
        try {
            getCallkitSoundPlayerManager()?.stop()
        } catch (error: Exception) {
            Log.w(
                TAG,
                "Unable to stop incoming ringtone",
                error
            )
        }

        try {
            context.sendBroadcast(
                CallkitIncomingActivity.getIntentEnded(
                    context,
                    isAccepted
                )
            )
        } catch (error: Exception) {
            Log.w(
                TAG,
                "Unable to broadcast fullscreen close",
                error
            )
        }

        try {
            CallkitIncomingActivity.finishCurrent(
                isAccepted
            )
        } catch (error: Exception) {
            Log.w(
                TAG,
                "Unable to directly close fullscreen Activity",
                error
            )
        }
    }

    /**
     * Safely converts the Android Bundle into CallKit Data.
     */
    private fun parseCallData(
        data: Bundle
    ): Data? {
        return try {
            Data.fromBundle(data)
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Unable to parse incoming call data",
                error
            )

            null
        }
    }

    @SuppressLint("MissingPermission")
    private fun registerTelecomIncomingCall(
        context: Context,
        data: Bundle
    ) {
        if (
            Build.VERSION.SDK_INT <
            Build.VERSION_CODES.O
        ) {
            return
        }

        val parsedCall =
            parseCallData(data) ?: return

        if (parsedCall.id.isEmpty()) {
            Log.w(
                TAG,
                "Telecom incoming call skipped because call ID is empty"
            )

            return
        }

        if (
            CallkitConnection.find(
                parsedCall.id
            ) != null
        ) {
            Log.d(
                TAG,
                "Telecom call already registered " +
                        "id=${parsedCall.id}; skipping"
            )

            return
        }

        if (
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.MANAGE_OWN_CALLS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            Log.w(
                TAG,
                "MANAGE_OWN_CALLS not granted; " +
                        "Telecom incoming call skipped"
            )

            return
        }

        val telecomManager =
            context.getSystemService(
                Context.TELECOM_SERVICE
            ) as? TelecomManager
                ?: return

        val inAppCallManager =
            InAppCallManager(
                context.applicationContext
            )

        val phoneAccountHandle =
            inAppCallManager.getPhoneAccountHandle()

        val videoState =
            if (parsedCall.type > 0) {
                VideoProfile.STATE_BIDIRECTIONAL
            } else {
                VideoProfile.STATE_AUDIO_ONLY
            }

        val telecomExtras =
            Bundle().apply {
                putBundle(
                    CallkitConnection.EXTRA_CALL_BUNDLE,
                    data
                )

                putInt(
                    TelecomManager.EXTRA_INCOMING_VIDEO_STATE,
                    videoState
                )
            }

        try {
            telecomManager.addNewIncomingCall(
                phoneAccountHandle,
                telecomExtras
            )

            Log.d(
                TAG,
                "Telecom addNewIncomingCall " +
                        "id=${parsedCall.id}"
            )
        } catch (error: SecurityException) {
            Log.w(
                TAG,
                "Telecom addNewIncomingCall rejected: " +
                        error.message,
                error
            )
        } catch (error: Exception) {
            Log.w(
                TAG,
                "Telecom addNewIncomingCall failed: " +
                        error.message,
                error
            )
        }
    }

    private fun driveTelecomConnection(
        context: Context,
        data: Bundle,
        action: String
    ) {
        if (
            Build.VERSION.SDK_INT <
            Build.VERSION_CODES.M
        ) {
            return
        }

        val parsedCall =
            parseCallData(data) ?: return

        val connection =
            CallkitConnection.find(
                parsedCall.id
            ) ?: return

        try {
            when (action) {
                CallkitConstants.ACTION_CALL_ACCEPT -> {
                    connection.markAccepted()
                }

                CallkitConstants.ACTION_CALL_DECLINE -> {
                    connection.markDeclined(context)
                }

                CallkitConstants.ACTION_CALL_ENDED -> {
                    connection.markEnded()
                }

                CallkitConstants.ACTION_CALL_TIMEOUT -> {
                    connection.markMissed()
                }
            }
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Unable to update Telecom connection " +
                        "for action=$action",
                error
            )
        }
    }

    @SuppressLint("MissingPermission")
    override fun onReceive(
        context: Context,
        intent: Intent
    ) {
        val action =
            intent.action ?: run {
                Log.w(
                    TAG,
                    "Broadcast ignored because action is null"
                )

                return
            }

        val data =
            intent.getBundleExtra(
                CallkitConstants
                    .EXTRA_CALLKIT_INCOMING_DATA
            ) ?: run {
                Log.w(
                    TAG,
                    "Broadcast ignored because call data is missing. " +
                            "action=$action"
                )

                return
            }

        Log.d(
            TAG,
            "Received action=$action"
        )

        when (action) {

            "${context.packageName}." +
                    CallkitConstants.ACTION_CALL_INCOMING -> {
                handleIncomingCall(
                    context,
                    data
                )
            }

            "${context.packageName}." +
                    CallkitConstants.ACTION_CALL_START -> {
                handleStartCall(
                    context,
                    data
                )
            }

            "${context.packageName}." +
                    CallkitConstants.ACTION_CALL_ACCEPT -> {
                handleAcceptCall(
                    context,
                    data
                )
            }

            "${context.packageName}." +
                    CallkitConstants.ACTION_CALL_DECLINE -> {
                handleDeclineCall(
                    context,
                    data
                )
            }

            "${context.packageName}." +
                    CallkitConstants.ACTION_CALL_ENDED -> {
                handleEndedCall(
                    context,
                    data
                )
            }

            "${context.packageName}." +
                    CallkitConstants.ACTION_CALL_TIMEOUT -> {
                handleTimeoutCall(
                    context,
                    data
                )
            }

            "${context.packageName}." +
                    CallkitConstants.ACTION_CALL_CONNECTED -> {
                handleConnectedCall(
                    data
                )
            }

            "${context.packageName}." +
                    CallkitConstants.ACTION_CALL_CALLBACK -> {
                handleCallback(
                    context,
                    data
                )
            }

            "${context.packageName}." +
                    CallkitConstants.ACTION_CALL_HELD -> {
                sendEventFlutter(
                    CallkitConstants.ACTION_CALL_HELD,
                    data
                )
            }

            "${context.packageName}." +
                    CallkitConstants.ACTION_CALL_UNHELD -> {
                sendEventFlutter(
                    CallkitConstants.ACTION_CALL_UNHELD,
                    data
                )
            }

            else -> {
                Log.w(
                    TAG,
                    "Unhandled CallKit action=$action"
                )
            }
        }
    }

    private fun handleIncomingCall(
        context: Context,
        data: Bundle
    ) {
        try {
            registerTelecomIncomingCall(
                context,
                data
            )

            val incomingCall =
                parseCallData(data) ?: return

            /*
             * Save the incoming call before showing either notification
             * mode or fullscreen mode. This allows remote endCall and
             * endAllCalls to find a fullscreen incoming call.
             */
            addCall(
                context,
                incomingCall
            )

            sendEventFlutter(
                CallkitConstants.ACTION_CALL_INCOMING,
                data
            )

            if (incomingCall.isFullScreen) {
                val activityIntent =
                    CallkitIncomingActivity.getIntent(
                        context,
                        data
                    )

                context.startActivity(
                    activityIntent
                )
            } else {
                getCallkitNotificationManager()
                    ?.showIncomingNotification(
                        data
                    )
            }
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Unable to show incoming call",
                error
            )
        }
    }

    private fun handleStartCall(
        context: Context,
        data: Bundle
    ) {
        try {
            CallkitNotificationService
                .startServiceWithAction(
                    context,
                    CallkitConstants.ACTION_CALL_START,
                    data
                )

            sendEventFlutter(
                CallkitConstants.ACTION_CALL_START,
                data
            )

            parseCallData(data)?.let {
                addCall(
                    context,
                    it,
                    true
                )
            }
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Unable to start call",
                error
            )
        }
    }

    private fun handleAcceptCall(
        context: Context,
        data: Bundle
    ) {
        try {
            driveTelecomConnection(
                context,
                data,
                CallkitConstants.ACTION_CALL_ACCEPT
            )

            FlutterCallkitIncomingPlugin
                .notifyEventCallbacks(
                    CallkitEventCallback.CallEvent.ACCEPT,
                    data
                )

            /*
             * Close the fullscreen incoming-call Activity. Passing true
             * keeps the existing accepted-call delayed close behavior.
             */
            closeIncomingCallUi(
                context,
                true
            )

            CallkitNotificationService
                .startServiceWithAction(
                    context,
                    CallkitConstants.ACTION_CALL_ACCEPT,
                    data
                )

            sendEventFlutter(
                CallkitConstants.ACTION_CALL_ACCEPT,
                data
            )

            parseCallData(data)?.let {
                addCall(
                    context,
                    it,
                    true
                )
            }

            FlutterCallkitIncomingPlugin
                .acceptCallHandleCallback(
                    data
                )
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Unable to accept call",
                error
            )
        }
    }

    private fun handleDeclineCall(
        context: Context,
        data: Bundle
    ) {
        try {
            driveTelecomConnection(
                context,
                data,
                CallkitConstants.ACTION_CALL_DECLINE
            )

            FlutterCallkitIncomingPlugin
                .notifyEventCallbacks(
                    CallkitEventCallback.CallEvent.DECLINE,
                    data
                )

            closeIncomingCallUi(
                context,
                false
            )

            getCallkitNotificationManager()
                ?.clearIncomingNotification(
                    data,
                    false
                )

            CallkitNotificationService
                .stopService(
                    context
                )

            sendEventFlutter(
                CallkitConstants.ACTION_CALL_DECLINE,
                data
            )

            parseCallData(data)?.let {
                removeCall(
                    context,
                    it
                )
            }
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Unable to decline call",
                error
            )
        }
    }

    /**
     * Handles a call ended event.
     *
     * This is used when the caller cancels before the receiver accepts.
     * It directly closes the fullscreen Activity and does not convert
     * the remote cancellation into a DECLINE event.
     */
    private fun handleEndedCall(
        context: Context,
        data: Bundle
    ) {
        try {
            val callData =
                parseCallData(data)

            val callId =
                callData?.id
                    ?: data.getString(
                        CallkitConstants.EXTRA_CALLKIT_ID,
                        ""
                    )

            Log.d(
                TAG,
                "handleEndedCall: id=$callId"
            )

            /*
             * End the Android Telecom Connection first.
             * Android's system call screen remains open until the
             * Connection is disconnected and destroyed.
             */
            val connection =
                CallkitConnection.find(callId)

            if (connection != null) {
                Log.d(
                    TAG,
                    "Ending Telecom connection: $callId"
                )

                connection.markEnded()
            } else {
                Log.w(
                    TAG,
                    "No Telecom connection found for id=$callId"
                )
            }

            FlutterCallkitIncomingPlugin
                .notifyEventCallbacks(
                    CallkitEventCallback.CallEvent.END,
                    data
                )

            // Stop ringtone.
            FlutterCallkitIncomingPlugin
                .getInstance()
                ?.getCallkitSoundPlayerManager()
                ?.stop()

            // Close plugin fullscreen Activity.
            context.sendBroadcast(
                CallkitIncomingActivity.getIntentEnded(
                    context,
                    false
                )
            )

            CallkitIncomingActivity.finishCurrent(false)

            // Remove incoming notification.
            getCallkitNotificationManager()
                ?.clearIncomingNotification(
                    data,
                    false
                )

            // Stop foreground notification service.
            CallkitNotificationService.stopService(
                context
            )

            sendEventFlutter(
                CallkitConstants.ACTION_CALL_ENDED,
                data
            )

            if (callData != null) {
                removeCall(
                    context,
                    callData
                )
            }
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Failed to completely end call",
                error
            )
        }
    }

    private fun handleTimeoutCall(
        context: Context,
        data: Bundle
    ) {
        try {
            driveTelecomConnection(
                context,
                data,
                CallkitConstants.ACTION_CALL_TIMEOUT
            )

            closeIncomingCallUi(
                context,
                false
            )

            val notificationManager =
                getCallkitNotificationManager()

            notificationManager
                ?.clearIncomingNotification(
                    data,
                    false
                )

            CallkitNotificationService
                .stopService(
                    context
                )

            notificationManager
                ?.showMissCallNotification(
                    data
                )

            sendEventFlutter(
                CallkitConstants.ACTION_CALL_TIMEOUT,
                data
            )

            parseCallData(data)?.let {
                removeCall(
                    context,
                    it
                )
            }
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Unable to timeout call",
                error
            )
        }
    }

    private fun handleConnectedCall(
        data: Bundle
    ) {
        try {
            getCallkitNotificationManager()
                ?.showOngoingCallNotification(
                    data,
                    true
                )

            sendEventFlutter(
                CallkitConstants.ACTION_CALL_CONNECTED,
                data
            )
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Unable to mark call as connected",
                error
            )
        }
    }

    private fun handleCallback(
        context: Context,
        data: Bundle
    ) {
        try {
            getCallkitNotificationManager()
                ?.clearMissCallNotification(
                    data
                )

            sendEventFlutter(
                CallkitConstants.ACTION_CALL_CALLBACK,
                data
            )

            if (
                Build.VERSION.SDK_INT <
                Build.VERSION_CODES.S
            ) {
                val closeNotificationPanel =
                    Intent(
                        Intent.ACTION_CLOSE_SYSTEM_DIALOGS
                    )

                context.sendBroadcast(
                    closeNotificationPanel
                )
            }
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Unable to process call callback",
                error
            )
        }
    }

    private fun sendEventFlutter(
        event: String,
        data: Bundle
    ) {
        if (silenceEvents) {
            Log.d(
                TAG,
                "Flutter event silenced: $event"
            )

            return
        }

        val android =
            mapOf(
                "isCustomNotification" to
                        data.getBoolean(
                            CallkitConstants
                                .EXTRA_CALLKIT_IS_CUSTOM_NOTIFICATION,
                            false
                        ),

                "isCustomSmallExNotification" to
                        data.getBoolean(
                            CallkitConstants
                                .EXTRA_CALLKIT_IS_CUSTOM_SMALL_EX_NOTIFICATION,
                            false
                        ),

                "ringtonePath" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_RINGTONE_PATH,
                            ""
                        ),

                "backgroundColor" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_BACKGROUND_COLOR,
                            ""
                        ),

                "backgroundUrl" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_BACKGROUND_URL,
                            ""
                        ),

                "actionColor" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_ACTION_COLOR,
                            ""
                        ),

                "textColor" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_TEXT_COLOR,
                            ""
                        ),

                "incomingCallNotificationChannelName" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_INCOMING_CALL_NOTIFICATION_CHANNEL_NAME,
                            ""
                        ),

                "missedCallNotificationChannelName" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_MISSED_CALL_NOTIFICATION_CHANNEL_NAME,
                            ""
                        ),

                "isImportant" to
                        data.getBoolean(
                            CallkitConstants
                                .EXTRA_CALLKIT_IS_IMPORTANT,
                            true
                        ),

                "isBot" to
                        data.getBoolean(
                            CallkitConstants
                                .EXTRA_CALLKIT_IS_BOT,
                            false
                        )
            )

        val missedCallNotification =
            mapOf(
                "id" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_MISSED_CALL_ID,
                            data.getString(
                                CallkitConstants
                                    .EXTRA_CALLKIT_ID,
                                ""
                            )
                        ),

                "showNotification" to
                        data.getBoolean(
                            CallkitConstants
                                .EXTRA_CALLKIT_MISSED_CALL_SHOW,
                            true
                        ),

                "count" to
                        data.getInt(
                            CallkitConstants
                                .EXTRA_CALLKIT_MISSED_CALL_COUNT,
                            1
                        ),

                "subtitle" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_MISSED_CALL_SUBTITLE,
                            ""
                        ),

                "callbackText" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_MISSED_CALL_CALLBACK_TEXT,
                            ""
                        ),

                "isShowCallback" to
                        data.getBoolean(
                            CallkitConstants
                                .EXTRA_CALLKIT_MISSED_CALL_CALLBACK_SHOW,
                            true
                        )
            )

        val callingNotification =
            mapOf(
                "id" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_CALLING_ID,
                            data.getString(
                                CallkitConstants
                                    .EXTRA_CALLKIT_ID,
                                ""
                            )
                        ),

                "showNotification" to
                        data.getBoolean(
                            CallkitConstants
                                .EXTRA_CALLKIT_CALLING_SHOW,
                            true
                        ),

                "subtitle" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_CALLING_SUBTITLE,
                            ""
                        ),

                "callbackText" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_CALLING_HANG_UP_TEXT,
                            ""
                        ),

                "isShowCallback" to
                        data.getBoolean(
                            CallkitConstants
                                .EXTRA_CALLKIT_CALLING_HANG_UP_SHOW,
                            true
                        )
            )

        val forwardData =
            mapOf(
                "id" to
                        data.getString(
                            CallkitConstants.EXTRA_CALLKIT_ID,
                            ""
                        ),

                "nameCaller" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_NAME_CALLER,
                            ""
                        ),

                "avatar" to
                        data.getString(
                            CallkitConstants.EXTRA_CALLKIT_AVATAR,
                            ""
                        ),

                "number" to
                        data.getString(
                            CallkitConstants.EXTRA_CALLKIT_HANDLE,
                            ""
                        ),

                "type" to
                        data.getInt(
                            CallkitConstants.EXTRA_CALLKIT_TYPE,
                            0
                        ),

                "duration" to
                        data.getLong(
                            CallkitConstants.EXTRA_CALLKIT_DURATION,
                            0L
                        ),

                "textAccept" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_TEXT_ACCEPT,
                            ""
                        ),

                "textDecline" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_TEXT_DECLINE,
                            ""
                        ),

                "acceptColor" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_ACCEPT_COLOR,
                            ""
                        ),

                "declineColor" to
                        data.getString(
                            CallkitConstants
                                .EXTRA_CALLKIT_DECLINE_COLOR,
                            ""
                        ),

                "extra" to
                        data.getSerializable(
                            CallkitConstants.EXTRA_CALLKIT_EXTRA
                        ),

                "missedCallNotification" to
                        missedCallNotification,

                "callingNotification" to
                        callingNotification,

                "android" to
                        android
            )

        FlutterCallkitIncomingPlugin.sendEvent(
            event,
            forwardData
        )
    }
}