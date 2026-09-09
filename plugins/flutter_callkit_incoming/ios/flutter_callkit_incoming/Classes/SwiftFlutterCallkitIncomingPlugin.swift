import Flutter
import UIKit
import CallKit
import AVFoundation
import UserNotifications

@available(iOS 10.0, *)
public class SwiftFlutterCallkitIncomingPlugin: NSObject, FlutterPlugin, CXProviderDelegate {
    
    static let ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP = "com.hiennv.flutter_callkit_incoming.DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP"
    
    static let ACTION_CALL_INCOMING = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_INCOMING"
    static let ACTION_CALL_START = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_START"
    static let ACTION_CALL_ACCEPT = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_ACCEPT"
    static let ACTION_CALL_DECLINE = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_DECLINE"
    static let ACTION_CALL_ENDED = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_ENDED"
    static let ACTION_CALL_TIMEOUT = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_TIMEOUT"
    static let ACTION_CALL_CALLBACK = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_CALLBACK"
    static let ACTION_CALL_CUSTOM = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_CUSTOM"
    static let ACTION_CALL_CONNECTED = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_CONNECTED"
    
    static let ACTION_CALL_PROVIDER_DID_RESET = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_PROVIDER_DID_RESET"
    
    static let ACTION_CALL_TOGGLE_HOLD = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_TOGGLE_HOLD"
    static let ACTION_CALL_TOGGLE_MUTE = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_TOGGLE_MUTE"
    static let ACTION_CALL_TOGGLE_DMTF = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_TOGGLE_DMTF"
    static let ACTION_CALL_TOGGLE_GROUP = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_TOGGLE_GROUP"
    static let ACTION_CALL_TOGGLE_AUDIO_SESSION = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_TOGGLE_AUDIO_SESSION"
    
    @objc public private(set) static var sharedInstance: SwiftFlutterCallkitIncomingPlugin!
    private static var backgroundPluginRegistrant: ((FlutterPluginRegistry) -> Void)?

    public static func setBackgroundPluginRegistrant(
        _ callback: @escaping (FlutterPluginRegistry) -> Void
    ) {
        backgroundPluginRegistrant = callback
    }

    static func registerBackgroundPlugins(with registry: FlutterPluginRegistry) -> Bool {
        guard let callback = backgroundPluginRegistrant else {
            return false
        }
        callback(registry)
        return true
    }
    
    private var streamHandlers: WeakArray<EventCallbackHandler> = WeakArray([])
    
    private var callManager: CallManager
    
    private var sharedProvider: CXProvider? = nil
    
    private var outgoingCall : Call?
    private var answerCall : Call?
    private var pendingAnswerActions: [UUID: CXAnswerCallAction] = [:]
    private var isCallKitAudioSessionActive = false
    
    private var data: Data?
    private var isFromPushKit: Bool = false
    private var silenceEvents: Bool = false
    private let devicePushTokenVoIP = "DevicePushTokenVoIP"
    private var pendingMainEngineEvents: [(
        event: String,
        body: [String: Any?],
        completion: (() -> Void)?
    )] = []

    private func lifecycleLog(_ message: String) {
        NSLog("[CallLifecycle] %@", message)
    }

    
    @discardableResult
    private func sendEvent(
        _ event: String,
        _ body: [String : Any?]?,
        backgroundCompletion: (() -> Void)? = nil
    ) -> Bool {
        if silenceEvents {
            return false
        }

        let activeHandlers = streamHandlers.reap().compactMap { handler in
            handler?.hasListener == true ? handler : nil
        }

        if !activeHandlers.isEmpty {
            lifecycleLog("event=\(event) delivery=main-engine")
            activeHandlers.forEach { handler in
                handler.send(event, body ?? [:])
            }
            backgroundCompletion?()
            return false
        }

        // AppDelegate owns one explicit, headless-capable FlutterEngine. Do
        // not start a second engine during PushKit launch: on iOS 26 ProMotion
        // devices that can race UIScene/FlutterViewController initialization
        // and crash inside VSyncClient with a null platform task runner.
        if pendingMainEngineEvents.count >= 32 {
            pendingMainEngineEvents.removeFirst()
        }
        pendingMainEngineEvents.append((
            event: event,
            body: body ?? [:],
            completion: backgroundCompletion
        ))
        lifecycleLog("event=\(event) delivery=queued-main-engine")
        return true
        
    }
    
    @objc public func sendEventCustom(_ event: String, body: NSDictionary?) {
        streamHandlers.reap().forEach { handler in
            handler?.send(event, body ?? [:])
        }
    }
    
    public static func sharePluginWithRegister(with registrar: FlutterPluginRegistrar) {
        if(sharedInstance == nil){
            sharedInstance = SwiftFlutterCallkitIncomingPlugin(messenger: registrar.messenger())
        }
        sharedInstance.shareHandlers(with: registrar)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        sharePluginWithRegister(with: registrar)
    }
    
    private static func createMethodChannel(messenger: FlutterBinaryMessenger) -> FlutterMethodChannel {
        return FlutterMethodChannel(name: "flutter_callkit_incoming", binaryMessenger: messenger)
    }
    
    private static func createEventChannel(messenger: FlutterBinaryMessenger) -> FlutterEventChannel {
        return FlutterEventChannel(name: "flutter_callkit_incoming_events", binaryMessenger: messenger)
    }
    
    public init(messenger: FlutterBinaryMessenger) {
        callManager = CallManager()
    }
    
    private func shareHandlers(with registrar: FlutterPluginRegistrar) {
        registrar.addMethodCallDelegate(self, channel: Self.createMethodChannel(messenger: registrar.messenger()))
        let eventsHandler = EventCallbackHandler()
        eventsHandler.onListenHandler = { [weak self] in
            self?.flushPendingMainEngineEvents()
        }
        self.streamHandlers.append(eventsHandler)
        Self.createEventChannel(messenger: registrar.messenger()).setStreamHandler(eventsHandler)
    }

    private func flushPendingMainEngineEvents() {
        let activeHandlers = streamHandlers.reap().compactMap { handler in
            handler?.hasListener == true ? handler : nil
        }
        guard !activeHandlers.isEmpty, !pendingMainEngineEvents.isEmpty else {
            return
        }

        let events = pendingMainEngineEvents
        pendingMainEngineEvents.removeAll()
        events.forEach { item in
            activeHandlers.forEach { handler in
                handler.send(item.event, item.body)
            }
            item.completion?()
        }
        lifecycleLog("flushed queued events count=\(events.count)")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "registerBackgroundHandler":
            guard
                let args = call.arguments as? [String: Any],
                let pluginHandle = (args["pluginHandle"] as? NSNumber)?.int64Value,
                let userHandle = (args["userHandle"] as? NSNumber)?.int64Value
            else {
                result(FlutterError(
                    code: "invalid_background_handler",
                    message: "pluginHandle and userHandle are required",
                    details: nil
                ))
                return
            }

            if CallkitBackgroundExecutor.shared.register(
                pluginHandle: pluginHandle,
                userHandle: userHandle
            ) {
                result(nil)
            } else {
                result(FlutterError(
                    code: "background_engine_start_failed",
                    message: "Unable to start the CallKit background Flutter engine",
                    details: nil
                ))
            }
            break
        case "getBackgroundHandler":
            result(CallkitBackgroundExecutor.shared.userCallbackHandle())
            break
        case "backgroundInitialized":
            CallkitBackgroundExecutor.shared.markReady()
            result(nil)
            break
        case "showCallkitIncoming":
            guard let args = call.arguments else {
                result(true)
                return
            }
            if let getArgs = args as? [String: Any] {
                self.data = Data(args: getArgs)
                showCallkitIncoming(self.data!, fromPushKit: false)
            }
            result(true)
            break
        case "showMissCallNotification":
            guard let args = call.arguments else {
                result(true)
                return
            }
            if let getArgs = args as? [String: Any] {
                self.data = Data(args: getArgs)
                self.showMissedCallNotification(data!)
            }
            result(true)
            break
        case "startCall":
            guard let args = call.arguments else {
                result(true)
                return
            }
            if let getArgs = args as? [String: Any] {
                self.data = Data(args: getArgs)
                self.startCall(self.data!, fromPushKit: false)
            }
            result(true)
            break
        case "endCall":
            guard let args = call.arguments else {
                result(true)
                return
            }
            if(self.isFromPushKit){
                self.endCall(self.data!)
            }else{
                if let getArgs = args as? [String: Any] {
                    self.data = Data(args: getArgs)
                    self.endCall(self.data!)
                }
            }
            result(true)
            break
        case "muteCall":
            guard let args = call.arguments as? [String: Any] ,
                  let callId = args["id"] as? String,
                  let isMuted = args["isMuted"] as? Bool else {
                result(true)
                return
            }
            
            self.muteCall(callId, isMuted: isMuted)
            result(true)
            break
        case "isMuted":
            guard let args = call.arguments as? [String: Any] ,
                  let callId = args["id"] as? String else{
                result(false)
                return
            }
            guard let callUUID = UUID(uuidString: callId),
                  let call = self.callManager.callWithUUID(uuid: callUUID) else {
                result(false)
                return
            }
            result(call.isMuted)
            break
        case "holdCall":
            guard let args = call.arguments as? [String: Any] ,
                  let callId = args["id"] as? String,
                  let onHold = args["isOnHold"] as? Bool else {
                result(true)
                return
            }
            self.holdCall(callId, onHold: onHold)
            result(true)
            break
        case "callConnected":
            guard let args = call.arguments else {
                result(true)
                return
            }
            if(self.isFromPushKit){
                self.connectedCall(self.data!)
            }else{
                    if let getArgs = args as? [String: Any] {
                    self.data = Data(args: getArgs)
                    self.connectedCall(self.data!)
                    }
            }
            result(true)
            break
        case "activeCalls":
            result(self.callManager.activeCalls())
            break;
        case "endAllCalls":
            self.callManager.endCallAlls()
            result(true)
            break
        case "getDevicePushTokenVoIP":
            result(self.getDevicePushTokenVoIP())
            break;
        case "silenceEvents":
            guard let silence = call.arguments as? Bool else {
                result(true)
                return
            }
            
            self.silenceEvents = silence
            result(true)
            break;
        case "requestNotificationPermission":
            guard let args = call.arguments else {
                result(true)
                return
            }
            if let getArgs = args as? [String: Any] {
                self.requestNotificationPermission(getArgs)
            }
            result(true)
            break
         case "requestFullIntentPermission": 
            result(true)
            break
         case "canUseFullScreenIntent": 
            result(true)
            break
        case "hideCallkitIncoming":
            result(true)
            break
        case "endNativeSubsystemOnly":
            if let getArgs = call.arguments as? [String: Any],
               let callId = getArgs["id"] as? String {
                self.endNativeSubsystemOnly(callId)
            }
            result(true)
            break
        case "completeAnswer":
            guard let args = call.arguments as? [String: Any],
                  let callId = args["id"] as? String else {
                result(false)
                return
            }
            result(self.resolvePendingAnswer(callId, succeeded: true))
            break
        case "failAnswer":
            guard let args = call.arguments as? [String: Any],
                  let callId = args["id"] as? String else {
                result(false)
                return
            }
            result(self.resolvePendingAnswer(callId, succeeded: false))
            break
        case "isAudioSessionActive":
            result(self.isCallKitAudioSessionActive)
            break
        case "resumeCallAudio":
            guard self.isCallKitAudioSessionActive else {
                result(false)
                return
            }
            // The RTC engine may attach after CallKit's original didActivate
            // callback during a lock-screen cold start.
            self.sendDefaultAudioInterruptionNotificationToStartAudioResource()
            result(true)
            break
        case "setAudioRoute":
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    @objc public func setDevicePushTokenVoIP(_ deviceToken: String) {
        UserDefaults.standard.set(deviceToken, forKey: devicePushTokenVoIP)
        self.sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP, ["deviceTokenVoIP":deviceToken])
    }
    
    @objc public func getDevicePushTokenVoIP() -> String {
        return UserDefaults.standard.string(forKey: devicePushTokenVoIP) ?? ""
    }
    
    @objc public func getAcceptedCall() -> Data? {
        if data?.uuid.lowercased() == answerCall?.uuid.uuidString.lowercased() {
            return data
        }
        return nil
    }
    
    @objc public func showCallkitIncoming(_ data: Data, fromPushKit: Bool, onError: ((Error?) -> Void)? = nil) {
        self.isFromPushKit = fromPushKit
        if(fromPushKit){
            self.data = data
        }
        
        if(data.isShowMissedCallNotification){
            CallkitNotificationManager.shared.addNotificationCategory(data.missedNotificationCallbackText)
        }
        
        var handle: CXHandle?
        handle = CXHandle(type: self.getHandleType(data.handleType), value: data.getEncryptHandle())
        
        let callUpdate = CXCallUpdate()

        callUpdate.remoteHandle = handle
        callUpdate.supportsDTMF = data.supportsDTMF
        callUpdate.supportsHolding = data.supportsHolding
        callUpdate.supportsGrouping = data.supportsGrouping
        callUpdate.supportsUngrouping = data.supportsUngrouping
        callUpdate.hasVideo = data.type > 0 ? true : false
        callUpdate.localizedCallerName = data.nameCaller
        
        initCallkitProvider(data)
        
        // Guard against malformed UUID — see CallManager.swift:startCall for rationale.
        guard let uuid = UUID(uuidString: data.uuid) else {
            return
        }
        
        self.configureAudioSession()
        self.sharedProvider?.reportNewIncomingCall(with: uuid, update: callUpdate) { error in
            if(error == nil) {
                self.configureAudioSession()
                let call = Call(uuid: uuid, data: data)
                call.handle = data.handle
                self.callManager.addCall(call)
                self.sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_INCOMING, data.toJSON())
                self.endCallNotExist(data)
            } else {
                onError?(error)
            }
        }
    }
    
    @objc public func showCallkitIncoming(_ data: Data, fromPushKit: Bool) {
        self.showCallkitIncoming(data, fromPushKit: fromPushKit, onError: nil)
    }
    
    @objc public func showCallkitIncoming(_ data: Data, fromPushKit: Bool, completion: @escaping () -> Void) {
        self.isFromPushKit = fromPushKit
        if(fromPushKit){
            self.data = data
        }
        
        if(data.isShowMissedCallNotification){
            CallkitNotificationManager.shared.addNotificationCategory(data.missedNotificationCallbackText)
        }
        
        var handle: CXHandle?
        handle = CXHandle(type: self.getHandleType(data.handleType), value: data.getEncryptHandle())
        
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = handle
        callUpdate.supportsDTMF = data.supportsDTMF
        callUpdate.supportsHolding = data.supportsHolding
        callUpdate.supportsGrouping = data.supportsGrouping
        callUpdate.supportsUngrouping = data.supportsUngrouping
        callUpdate.hasVideo = data.type > 0 ? true : false
        callUpdate.localizedCallerName = data.nameCaller
        
        initCallkitProvider(data)
        
        // Guard against malformed UUID — see CallManager.swift:startCall for rationale.
        // PushKit call MUST report within ~5s deadline; on invalid UUID we still call
        // completion() so iOS doesn't penalize the app for the missed deadline.
        guard let uuid = UUID(uuidString: data.uuid) else {
            completion()
            return
        }
        
        self.sharedProvider?.reportNewIncomingCall(with: uuid, update: callUpdate) { error in
            if(error == nil) {
                self.configureAudioSession()
                let call = Call(uuid: uuid, data: data)
                call.handle = data.handle
                self.callManager.addCall(call)
                self.sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_INCOMING, data.toJSON())
                self.endCallNotExist(data)
            }
            completion()
        }
    }
    
    
    @objc public func startCall(_ data: Data, fromPushKit: Bool) {
        self.isFromPushKit = fromPushKit
        if(fromPushKit){
            self.data = data
        }
        initCallkitProvider(data)
        self.callManager.startCall(data)
    }
    
    @objc public func muteCall(_ callId: String, isMuted: Bool) {
        guard let callId = UUID(uuidString: callId),
              let call = self.callManager.callWithUUID(uuid: callId) else {
            return
        }
        if call.isMuted == isMuted {
            self.sendMuteEvent(callId.uuidString, isMuted)
        } else {
            self.callManager.muteCall(call: call, isMuted: isMuted)
        }
    }
    
    @objc public func holdCall(_ callId: String, onHold: Bool) {
        guard let callId = UUID(uuidString: callId),
              let call = self.callManager.callWithUUID(uuid: callId) else {
            return
        }
        if call.isOnHold == onHold {
            self.sendHoldEvent(callId.uuidString, onHold)
        } else {
            self.callManager.holdCall(call: call, onHold: onHold)
        }
    }
    
    @objc public func endCall(_ data: Data) {
        // Guard against malformed UUID — see CallManager.swift:startCall for rationale.
        // PushKit branch reads uuid from self.data (stored during showCallkitIncoming);
        // non-PushKit reads from the incoming data. Either source can be invalid.
        let uuidSourceString: String
        if self.isFromPushKit {
            guard let stored = self.data else {
                return
            }
            uuidSourceString = stored.uuid
            self.isFromPushKit = false
            self.sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_ENDED, data.toJSON())
        } else {
            uuidSourceString = data.uuid
        }
        guard let uuid = UUID(uuidString: uuidSourceString) else {
            return
        }
        let call = Call(uuid: uuid, data: data)


        self.callManager.endCall(call: call)
    }

    /// Removes CallKit UI for a call that Flutter has already resolved.
    /// Reporting a remote end avoids CXEndCallAction, which iOS otherwise
    /// reports back to Flutter as if the receiver tapped Decline.
    @objc public func endNativeSubsystemOnly(_ callId: String) {
        guard let uuid = UUID(uuidString: callId) else {
            return
        }

        if let pendingAnswer = pendingAnswerActions.removeValue(forKey: uuid) {
            pendingAnswer.fail()
        }

        if let call = self.callManager.callWithUUID(uuid: uuid) {
            call.endCall()
            self.callManager.removeCall(call)
        }

        self.sharedProvider?.reportCall(
            with: uuid,
            endedAt: Date(),
            reason: .remoteEnded
        )
    }

    private func resolvePendingAnswer(_ callId: String, succeeded: Bool) -> Bool {
        guard
            let uuid = UUID(uuidString: callId),
            let action = pendingAnswerActions.removeValue(forKey: uuid)
        else {
            return false
        }

        if succeeded {
            action.fulfill()
        } else {
            action.fail()
        }
        return true
    }
    
    @objc public func connectedCall(_ data: Data) {
        // Guard against malformed UUID — see CallManager.swift:startCall for rationale.
        let uuidSourceString: String
        if self.isFromPushKit {
            guard let stored = self.data else {
                return
            }
            uuidSourceString = stored.uuid
            self.isFromPushKit = false
        } else {
            uuidSourceString = data.uuid
        }
        guard let uuid = UUID(uuidString: uuidSourceString) else {
            return
        }
        let call = Call(uuid: uuid, data: data)
        self.callManager.connectedCall(call: call)
    }
    
    @objc public func activeCalls() -> [[String: Any]] {
        return self.callManager.activeCalls()
    }
    
    @objc public func endAllCalls() {
        self.isFromPushKit = false
        self.callManager.endCallAlls()
    }
    
    public func saveEndCall(_ uuid: String, _ reason: Int) {
        // Guard against malformed UUID — see CallManager.swift:startCall for rationale.
        // Single guard at top covers all five branches.
        guard let callUuid = UUID(uuidString: uuid) else {
            return
        }
        switch reason {
        case 1:
            self.sharedProvider?.reportCall(with: callUuid, endedAt: Date(), reason: CXCallEndedReason.failed)
            break
        case 2, 6:
            self.sharedProvider?.reportCall(with: callUuid, endedAt: Date(), reason: CXCallEndedReason.remoteEnded)
            break
        case 3:
            self.sharedProvider?.reportCall(with: callUuid, endedAt: Date(), reason: CXCallEndedReason.unanswered)
            break
        case 4:
            self.sharedProvider?.reportCall(with: callUuid, endedAt: Date(), reason: CXCallEndedReason.answeredElsewhere)
            break
        case 5:
            self.sharedProvider?.reportCall(with: callUuid, endedAt: Date(), reason: CXCallEndedReason.declinedElsewhere)
            break
        default:
            break
        }
    }
    
    
    func endCallNotExist(_ data: Data) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(data.duration)) {
            // Guard against malformed UUID — see CallManager.swift:startCall for rationale.
            guard let uuid = UUID(uuidString: data.uuid) else {
                return
            }
            let call = self.callManager.callWithUUID(uuid: uuid)
            if (call != nil && self.answerCall == nil && self.outgoingCall == nil) {
                self.callEndTimeout(data)
            }
        }
    }
    
    
    
    func callEndTimeout(_ data: Data) {
        self.saveEndCall(data.uuid, 3)
        // Guard against malformed UUID — see CallManager.swift:startCall for rationale.
        guard let uuid = UUID(uuidString: data.uuid) else {
            return
        }
        guard let call = self.callManager.callWithUUID(uuid: uuid) else {
            return
        }
        self.showMissedCallNotification(data)
        sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_TIMEOUT, data.toJSON())
        call.endCall()
        self.callManager.removeCall(call)
        if let appDelegate = UIApplication.shared.delegate as? CallkitIncomingAppDelegate {
            appDelegate.onTimeOut(call)
        }
    }
    
    func getHandleType(_ handleType: String?) -> CXHandle.HandleType {
        var typeDefault = CXHandle.HandleType.generic
        switch handleType {
        case "number":
            typeDefault = CXHandle.HandleType.phoneNumber
            break
        case "email":
            typeDefault = CXHandle.HandleType.emailAddress
        default:
            typeDefault = CXHandle.HandleType.generic
        }
        return typeDefault
    }
    
    func initCallkitProvider(_ data: Data) {
        if(self.sharedProvider == nil){
            self.sharedProvider = CXProvider(configuration: createConfiguration(data))
            self.sharedProvider?.setDelegate(self, queue: nil)
        } else {
            self.sharedProvider?.configuration = createConfiguration(data)
        }
        self.callManager.setSharedProvider(self.sharedProvider!)
    }
    
    func createConfiguration(_ data: Data) -> CXProviderConfiguration {
        let configuration = CXProviderConfiguration(localizedName: data.appName)
        configuration.supportsVideo = data.supportsVideo
        configuration.maximumCallGroups = data.maximumCallGroups
        configuration.maximumCallsPerCallGroup = data.maximumCallsPerCallGroup
        
        configuration.supportedHandleTypes = [
            CXHandle.HandleType.generic,
            CXHandle.HandleType.emailAddress,
            CXHandle.HandleType.phoneNumber
        ]
        if #available(iOS 11.0, *) {
            configuration.includesCallsInRecents = data.includesCallsInRecents
        }
        if !data.iconName.isEmpty {
            if let image = UIImage(named: data.iconName) {
                configuration.iconTemplateImageData = image.pngData()
            }
        }
        if !data.ringtonePath.isEmpty && data.ringtonePath != "system_ringtone_default" {
            configuration.ringtoneSound = data.ringtonePath
        }
        return configuration
    }
    
    func sendDefaultAudioInterruptionNotificationToStartAudioResource(){
        var userInfo : [AnyHashable : Any] = [:]
        let intrepEndeRaw = AVAudioSession.InterruptionType.ended.rawValue
        userInfo[AVAudioSessionInterruptionTypeKey] = intrepEndeRaw
        userInfo[AVAudioSessionInterruptionOptionKey] = AVAudioSession.InterruptionOptions.shouldResume.rawValue
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: self, userInfo: userInfo)
    }
    
    func configureAudioSession(){
        if data?.configureAudioSession != false {
            let session = AVAudioSession.sharedInstance()
            do{
                // A two-way call needs the Bluetooth HFP route. A2DP is
                // playback-only and duckOthers is inappropriate for CallKit's
                // full-duplex, system-priority audio session.
                try session.setCategory(
                    AVAudioSession.Category.playAndRecord,
                    mode: self.getAudioSessionMode(data?.audioSessionMode),
                    options: [.allowBluetooth]
                )
                // CallKit activates/deactivates the audio session and reports
                // that lifecycle through provider(_:didActivate:). Activating
                // it while the incoming UI is still ringing is rejected by
                // iOS and can tear down Agora immediately after answer.
                try session.setPreferredSampleRate(data?.audioSessionPreferredSampleRate ?? 44100.0)
                try session.setPreferredIOBufferDuration(data?.audioSessionPreferredIOBufferDuration ?? 0.005)
                lifecycleLog(
                    "audio configured category=\(session.category.rawValue) " +
                    "mode=\(session.mode.rawValue) sampleRate=\(session.sampleRate)"
                )
            } catch {
                lifecycleLog("audio configure failed error=\(error.localizedDescription)")
            }
        }
    }
    
    func getAudioSessionMode(_ audioSessionMode: String?) -> AVAudioSession.Mode {
        var mode = AVAudioSession.Mode.default
        switch audioSessionMode {
        case "gameChat":
            mode = AVAudioSession.Mode.gameChat
            break
        case "measurement":
            mode = AVAudioSession.Mode.measurement
            break
        case "moviePlayback":
            mode = AVAudioSession.Mode.moviePlayback
            break
        case "spokenAudio":
            mode = AVAudioSession.Mode.spokenAudio
            break
        case "videoChat":
            mode = AVAudioSession.Mode.videoChat
            break
        case "videoRecording":
            mode = AVAudioSession.Mode.videoRecording
            break
        case "voiceChat":
            mode = AVAudioSession.Mode.voiceChat
            break
        case "voicePrompt":
            if #available(iOS 12.0, *) {
                mode = AVAudioSession.Mode.voicePrompt
            } else {
                // Fallback on earlier versions
            }
            break
        default:
            mode = AVAudioSession.Mode.default
        }
        return mode
    }
    
    public func providerDidReset(_ provider: CXProvider) {
        pendingAnswerActions.values.forEach { $0.fail() }
        pendingAnswerActions.removeAll()
        for call in self.callManager.calls {
            call.endCall()
        }
        self.callManager.removeAllCalls()
        sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_PROVIDER_DID_RESET, [:])
        if let appDelegate = UIApplication.shared.delegate as? CallkitIncomingAppDelegate {
            appDelegate.providerDidReset()
        }
    }
    
    public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        let call = Call(uuid: action.callUUID, data: self.data!, isOutGoing: true)
        call.handle = action.handle.value
        configureAudioSession()
        call.hasStartedConnectDidChange = { [weak self] in
            self?.sharedProvider?.reportOutgoingCall(with: call.uuid, startedConnectingAt: call.connectData)
        }
        call.hasConnectDidChange = { [weak self] in
            self?.sharedProvider?.reportOutgoingCall(with: call.uuid, connectedAt: call.connectedData)
        }
        self.outgoingCall = call;
        self.callManager.addCall(call)
        self.sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_START, self.data?.toJSON())
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = self.callManager.callWithUUID(uuid: action.callUUID) else{
            action.fail()
            return
        }
        // Apple requires the session to be configured immediately before the
        // answer action is fulfilled. CallKit, not the app, activates it.
        self.configureAudioSession()
        lifecycleLog("answer configured uuid=\(action.callUUID.uuidString)")

        call.hasConnectDidChange = { [weak self] in
            self?.sharedProvider?.reportOutgoingCall(with: call.uuid, connectedAt: call.connectedData)
        }
        call.data.isAccepted = true
        self.answerCall = call
        // Persist before dispatching the event. Dart can process an active
        // engine event immediately, so writing afterwards could resurrect a
        // stale pending answer after the Dart path has already completed.
        if let appDelegate = UIApplication.shared.delegate as? CallkitIncomingAppDelegate {
            appDelegate.onAccept(call, action)
        }

        // Do not hold CXAnswerCallAction open while a Flutter engine cold
        // starts, performs HTTP, or initializes Agora. A delayed action is
        // timed out by CallKit and the system tears down the accepted call.
        action.fulfill()
        lifecycleLog("answer fulfilled uuid=\(action.callUUID.uuidString)")

        sendEvent(
            SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_ACCEPT,
            call.data.toJSON()
        )
    }
    
//    private func checkUnlockedAndFulfill(action: CXAnswerCallAction, counter: Int) {
//        if UIApplication.shared.isProtectedDataAvailable {
//            action.fulfill()
//        } else if counter > 180 { // fail if waiting for more then 3 minutes
//            action.fail()
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.checkUnlockedAndFulfill(action: action, counter: counter + 1)
//            }
//        }
//    }
    
    
    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        lifecycleLog("end requested uuid=\(action.callUUID.uuidString)")
        if let pendingAnswer = pendingAnswerActions.removeValue(
            forKey: action.callUUID
        ) {
            pendingAnswer.fail()
        }
        guard let call = self.callManager.callWithUUID(uuid: action.callUUID) else {
            if(self.answerCall == nil && self.outgoingCall == nil){
                sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_TIMEOUT, self.data?.toJSON())
            } else {
                sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_ENDED, self.data?.toJSON())
            }
            action.fail()
            return
        }
        call.endCall()
        self.callManager.removeCall(call)
        if (self.answerCall == nil && self.outgoingCall == nil) {
            if let appDelegate = UIApplication.shared.delegate as? CallkitIncomingAppDelegate {
                appDelegate.onDecline(call, action)
            } else {
                action.fulfill()
            }
            // The decline is persisted by the app delegate before the Dart
            // event is allowed to clear it.
            sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_DECLINE, call.data.toJSON())
        }else {
            self.answerCall = nil
            if let appDelegate = UIApplication.shared.delegate as? CallkitIncomingAppDelegate {
                appDelegate.onEnd(call, action)
            } else {
                action.fulfill()
            }
            // Persist/fulfill the native action before Dart starts network
            // work; iOS may suspend the process immediately after hang-up.
            sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_ENDED, call.data.toJSON())
            lifecycleLog("end fulfilled uuid=\(action.callUUID.uuidString)")
        }
    }
    
    
    public func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard let call = self.callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        call.isOnHold = action.isOnHold
        call.isMuted = action.isOnHold
        self.callManager.setHold(call: call, onHold: action.isOnHold)
        sendHoldEvent(action.callUUID.uuidString, action.isOnHold)
        if !action.isOnHold {
            sendDefaultAudioInterruptionNotificationToStartAudioResource()
        }
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard let call = self.callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        call.isMuted = action.isMuted
        sendMuteEvent(action.callUUID.uuidString, action.isMuted)
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetGroupCallAction) {
        guard (self.callManager.callWithUUID(uuid: action.callUUID)) != nil else {
            action.fail()
            return
        }
        self.sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_TOGGLE_GROUP, [ "id": action.callUUID.uuidString, "callUUIDToGroupWith" : action.callUUIDToGroupWith?.uuidString])
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        guard (self.callManager.callWithUUID(uuid: action.callUUID)) != nil else {
            action.fail()
            return
        }
        self.sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_TOGGLE_DMTF, [ "id": action.callUUID.uuidString, "digits": action.digits, "type": action.type.rawValue ])
        action.fulfill()
    }
    
    
    public func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        let callUUID = (action as? CXCallAction)?.callUUID
        if let callUUID = callUUID {
            pendingAnswerActions.removeValue(forKey: callUUID)
        }

        // A late mute/hold/DTMF transaction must not terminate a healthy
        // media call. Only an answer/start timeout is terminal.
        guard action is CXAnswerCallAction || action is CXStartCallAction else {
            action.fail()
            return
        }

        guard
            let callUUID = callUUID,
            let call = self.callManager.callWithUUID(uuid: callUUID)
        else {
            action.fail()
            return
        }
        sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_TIMEOUT, self.data?.toJSON())
        if let appDelegate = UIApplication.shared.delegate as? CallkitIncomingAppDelegate {
            appDelegate.onTimeOut(call)
        }
        call.endCall()
        self.callManager.removeCall(call)
        self.sharedProvider?.reportCall(
            with: call.uuid,
            endedAt: Date(),
            reason: .failed
        )
        action.fail()
    }
    
    public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {

        isCallKitAudioSessionActive = true
        let route = audioSession.currentRoute
        lifecycleLog(
            "audio didActivate category=\(audioSession.category.rawValue) " +
            "mode=\(audioSession.mode.rawValue) inputs=\(route.inputs.map { $0.portType.rawValue }) " +
            "outputs=\(route.outputs.map { $0.portType.rawValue })"
        )

        if let appDelegate = UIApplication.shared.delegate as? CallkitIncomingAppDelegate {
            appDelegate.didActivateAudioSession(audioSession)
        }

        if(self.answerCall?.hasConnected ?? false){
            sendDefaultAudioInterruptionNotificationToStartAudioResource()
            return
        }
        if(self.outgoingCall?.hasConnected ?? false){
            sendDefaultAudioInterruptionNotificationToStartAudioResource()
            return
        }
        self.outgoingCall?.startCall(withAudioSession: audioSession) {success in
            if success {
                self.callManager.addCall(self.outgoingCall!)
                self.outgoingCall?.startAudio()
            }
        }
        self.answerCall?.ansCall(withAudioSession: audioSession) { success in
            if success{
                self.answerCall?.startAudio()
            }
        }
        sendDefaultAudioInterruptionNotificationToStartAudioResource()

        self.sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_TOGGLE_AUDIO_SESSION, [ "isActive": true ])
    }
    
    public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {

        isCallKitAudioSessionActive = false
        lifecycleLog("audio didDeactivate")
        
        if let appDelegate = UIApplication.shared.delegate as? CallkitIncomingAppDelegate {
            appDelegate.didDeactivateAudioSession(audioSession)
        }

        if self.outgoingCall?.isOnHold ?? false || self.answerCall?.isOnHold ?? false{
            return
        }
        
        self.sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_TOGGLE_AUDIO_SESSION, [ "isActive": false ])
    }
    
    private func sendMuteEvent(_ id: String, _ isMuted: Bool) {
        self.sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_TOGGLE_MUTE, [ "id": id, "isMuted": isMuted ])
    }
    
    private func sendHoldEvent(_ id: String, _ isOnHold: Bool) {
        self.sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_TOGGLE_HOLD, [ "id": id, "isOnHold": isOnHold ])
    }
    
    @objc public func sendCallbackEvent(_ data: [String: Any]?) {
        self.sendEvent(SwiftFlutterCallkitIncomingPlugin.ACTION_CALL_CALLBACK, data)
    }
    
    
    private func requestNotificationPermission(_ map: [String: Any]) {
        CallkitNotificationManager.shared.requestNotificationPermission(map)
    }
    
    
    private func showMissedCallNotification(_ data: Data) {
        if(!data.isShowMissedCallNotification){
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "\(data.nameCaller)"
        content.body = "\(data.missedNotificationSubtitle)"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "MISSED_CALL_CATEGORY"
        content.userInfo = data.toJSON()

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: data.uuid,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
    
}

/// Owns the headless Flutter engine used to deliver CallKit actions while the
/// application's foreground event stream is not listening.
final class CallkitBackgroundExecutor {
    static let shared = CallkitBackgroundExecutor()

    private let backgroundChannelName = "flutter_callkit_incoming_background"
    private let pluginCallbackHandleKey = "flutter_callkit_incoming.callback_handle"
    private let userCallbackHandleKey = "flutter_callkit_incoming.user_callback_handle"

    private var engine: FlutterEngine?
    private var channel: FlutterMethodChannel?
    private var isReady = false
    private var pendingEvents: [(
        event: String,
        body: [String: Any?],
        backgroundTaskToken: UUID?,
        completion: (() -> Void)?
    )] = []
    private var backgroundTasks: [UUID: UIBackgroundTaskIdentifier] = [:]

    private init() {}

    var isRunning: Bool {
        engine != nil
    }

    func register(pluginHandle: Int64, userHandle: Int64) -> Bool {
        let defaults = UserDefaults.standard
        defaults.set(NSNumber(value: pluginHandle), forKey: pluginCallbackHandleKey)
        defaults.set(NSNumber(value: userHandle), forKey: userCallbackHandleKey)
        return FlutterCallbackCache.lookupCallbackInformation(pluginHandle) != nil
    }

    func userCallbackHandle() -> Int64 {
        guard let value = UserDefaults.standard.object(forKey: userCallbackHandleKey) as? NSNumber else {
            return 0
        }
        return value.int64Value
    }

    @discardableResult
    func send(
        event: String,
        body: [String: Any?],
        completion: (() -> Void)? = nil
    ) -> Bool {
        let backgroundTaskToken = beginBackgroundTask(for: event)
        pendingEvents.append((
            event: event,
            body: body,
            backgroundTaskToken: backgroundTaskToken,
            completion: completion
        ))

        guard ensureStarted() else {
            pendingEvents.removeLast()
            finishBackgroundTask(backgroundTaskToken)
            return false
        }

        flushPendingEventsIfReady()
        return true
    }

    func markReady() {
        isReady = true
        flushPendingEventsIfReady()
    }

    private func ensureStarted() -> Bool {
        if engine != nil {
            return true
        }

        guard
            let value = UserDefaults.standard.object(forKey: pluginCallbackHandleKey) as? NSNumber
        else {
            return false
        }

        return start(pluginHandle: value.int64Value)
    }

    private func flushPendingEventsIfReady() {
        guard isReady, let channel = channel, !pendingEvents.isEmpty else {
            return
        }

        let events = pendingEvents
        pendingEvents.removeAll()

        events.forEach { item in
            channel.invokeMethod(item.event, arguments: item.body) { [weak self] _ in
                item.completion?()
                self?.finishBackgroundTask(item.backgroundTaskToken)
            }
        }
    }

    private func beginBackgroundTask(for event: String) -> UUID? {
        if !Thread.isMainThread {
            return DispatchQueue.main.sync {
                beginBackgroundTask(for: event)
            }
        }

        let token = UUID()
        let identifier = UIApplication.shared.beginBackgroundTask(
            withName: "CallKitBackground.\(event)"
        ) { [weak self] in
            self?.finishBackgroundTask(token)
        }

        guard identifier != .invalid else {
            return nil
        }

        backgroundTasks[token] = identifier
        return token
    }

    private func finishBackgroundTask(_ token: UUID?) {
        guard let token = token else {
            return
        }

        let finish = { [weak self] in
            guard
                let self = self,
                let identifier = self.backgroundTasks.removeValue(forKey: token)
            else {
                return
            }
            UIApplication.shared.endBackgroundTask(identifier)
        }

        if Thread.isMainThread {
            finish()
        } else {
            DispatchQueue.main.async(execute: finish)
        }
    }

    private func start(pluginHandle: Int64) -> Bool {
        if engine != nil {
            return true
        }

        guard let callbackInfo = FlutterCallbackCache.lookupCallbackInformation(pluginHandle) else {
            return false
        }

        let backgroundEngine = FlutterEngine(
            name: "flutter_callkit_incoming_background",
            project: nil,
            allowHeadlessExecution: true
        )

        guard backgroundEngine.run(
            withEntrypoint: callbackInfo.callbackName,
            libraryURI: callbackInfo.callbackLibraryPath
        ) else {
            return false
        }

        // Register every application plugin needed by the callback, including
        // secure storage, shared preferences and Firebase. Registering only
        // CallKit leaves the headless isolate unable to load its auth token.
        if !SwiftFlutterCallkitIncomingPlugin.registerBackgroundPlugins(
            with: backgroundEngine
        ), let registrar = backgroundEngine.registrar(
            forPlugin: "FlutterCallkitIncomingBackgroundPlugin"
        ) {
            // Keep a minimal fallback for host applications that have not
            // installed a generated-plugin registrant callback.
            SwiftFlutterCallkitIncomingPlugin.sharePluginWithRegister(
                with: registrar
            )
        }

        channel = FlutterMethodChannel(
            name: backgroundChannelName,
            binaryMessenger: backgroundEngine.binaryMessenger
        )
        engine = backgroundEngine
        return true
    }
}

class EventCallbackHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    var onListenHandler: (() -> Void)?

    var hasListener: Bool {
        eventSink != nil
    }
    
    public func send(_ event: String, _ body: Any) {
        let data: [String : Any] = [
            "event": event,
            "body": body
        ]
        eventSink?(data)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        onListenHandler?()
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

@available(iOS 10.0, *)
@objc(FlutterCallkitIncomingPlugin)
public class FlutterCallkitIncomingPlugin: NSObject, FlutterPlugin {
    @objc public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftFlutterCallkitIncomingPlugin.register(with: registrar)
    }
}
