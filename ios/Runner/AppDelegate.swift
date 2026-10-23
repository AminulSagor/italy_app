import AVFAudio
import CallKit
import Flutter
import PushKit
import UIKit
import flutter_callkit_incoming

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate,
  CallkitIncomingAppDelegate
{
  /// A single, explicitly started engine avoids Flutter's iOS 26 ProMotion
  /// implicit-engine race in FlutterViewController.viewDidLoad. It also stays
  /// alive for PushKit/CallKit work while no UI scene is attached.
  private(set) var flutterEngine: FlutterEngine?

  private var aiVoiceAudioPlugin: AiVoiceAudioPlugin?
  private var callAudioSessionCoordinator: CallAudioSessionCoordinator?
  private var courseDeviceAttestationPlugin: CourseDeviceAttestationPlugin?
  private var voipRegistry: PKPushRegistry?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    SwiftFlutterCallkitIncomingPlugin.setBackgroundPluginRegistrant { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    let registry = PKPushRegistry(queue: .main)
    registry.delegate = self
    registry.desiredPushTypes = [.voIP]
    voipRegistry = registry

    // FlutterEngine's Objective-C initializer is imported as non-optional by
    // Swift even though it can return nil for a detached iOS Debug launch.
    let candidateEngine: FlutterEngine? = FlutterEngine(
      name: "italir_pothe_main",
      project: nil,
      allowHeadlessExecution: true
    )
    guard let engine = candidateEngine, engine.run()
    else {
      // A Debug Flutter engine cannot cold-launch from the Home Screen when
      // no Flutter tool or Xcode debugger is attached. Keep UIKit alive so
      // SceneDelegate can show a useful diagnostic instead of constructing a
      // FlutterViewController with a nil engine and aborting the process.
      NSLog("[CallLifecycle] explicit Flutter engine unavailable")
      return super.application(
        application,
        didFinishLaunchingWithOptions: launchOptions
      )
    }

    flutterEngine = engine
    GeneratedPluginRegistrant.register(with: engine)
    aiVoiceAudioPlugin = AiVoiceAudioPlugin(
      messenger: engine.binaryMessenger
    )
    courseDeviceAttestationPlugin = CourseDeviceAttestationPlugin(
      messenger: engine.binaryMessenger
    )
    callAudioSessionCoordinator = CallAudioSessionCoordinator(
      messenger: engine.binaryMessenger
    )
    NSLog("[CallLifecycle] explicit Flutter engine started")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func pushRegistry(
    _ registry: PKPushRegistry,
    didUpdate credentials: PKPushCredentials,
    for type: PKPushType
  ) {
    guard type == .voIP else { return }

    let token = credentials.token.map { String(format: "%02x", $0) }.joined()
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(token)
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    guard type == .voIP else { return }
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
  }

  func pushRegistry(
    _ registry: PKPushRegistry,
    didReceiveIncomingPushWith payload: PKPushPayload,
    for type: PKPushType,
    completion: @escaping () -> Void
  ) {
    guard type == .voIP else {
      completion()
      return
    }

    let dictionary = payload.dictionaryPayload
    let data = flutter_callkit_incoming.Data(args: dictionary as NSDictionary)
    guard let callkitPlugin = SwiftFlutterCallkitIncomingPlugin.sharedInstance else {
      completion()
      return
    }

    callkitPlugin.showCallkitIncoming(
      data,
      fromPushKit: true,
      completion: {
        completion()
      }
    )
  }

  func onAccept(_ call: Call, _ action: CXAnswerCallAction) {
    persistCallKitAction(call, key: "callkit_pending_accepted_call_v1")
    // Keep a durable copy while Dart acknowledges the answer with the server.
    // A cold-started Flutter engine can resume media setup if iOS suspends the
    // process after the CallKit action has been fulfilled.
  }

  func onDecline(_ call: Call, _ action: CXEndCallAction) {
    clearPersistedCallKitAction(key: "callkit_pending_accepted_call_v1")
    persistCallKitAction(call, key: "callkit_pending_declined_call_v1")
    action.fulfill()
  }

  func onEnd(_ call: Call, _ action: CXEndCallAction) {
    clearPersistedCallKitAction(key: "callkit_pending_accepted_call_v1")
    // Ending from the lock screen can outlive the short execution window iOS
    // gives Dart. Persist before fulfilling so the backend notification can
    // be retried on the next launch if the process is suspended or killed.
    persistCallKitAction(call, key: "callkit_pending_ended_call_v1")
    NSLog("[CallLifecycle] native end persisted callId=%@", call.data.uuid)
    action.fulfill()
  }

  func onTimeOut(_ call: Call) {}

  func didActivateAudioSession(_ audioSession: AVAudioSession) {
    callAudioSessionCoordinator?.callKitDidActivate(audioSession)
  }

  func didDeactivateAudioSession(_ audioSession: AVAudioSession) {
    callAudioSessionCoordinator?.callKitDidDeactivate(audioSession)
  }

  func providerDidReset() {}

  private func persistCallKitAction(_ call: Call, key: String) {
    let extra = call.data.extra as? [String: Any] ?? [:]
    let extraCallId = (extra["callId"] as? String)?.trimmingCharacters(
      in: .whitespacesAndNewlines
    ) ?? ""
    let callId = extraCallId.isEmpty ? call.uuid.uuidString : extraCallId
    let payload: [String: Any] = [
      "callId": callId,
      "callData": JSONSerialization.isValidJSONObject(extra) ? extra : [:],
      "answerResponse": [:],
      "createdAt": ISO8601DateFormatter().string(from: Date()),
    ]

    guard
      let data = try? JSONSerialization.data(withJSONObject: payload),
      let encoded = String(data: data, encoding: .utf8)
    else {
      return
    }

    // shared_preferences prefixes its iOS keys with "flutter.".
    UserDefaults.standard.set(encoded, forKey: "flutter.\(key)")
  }

  private func clearPersistedCallKitAction(key: String) {
    UserDefaults.standard.removeObject(forKey: "flutter.\(key)")
  }
}

/// Owns the AVAudioSession policy that Agora must not change while CallKit is
/// active. Outgoing calls activate the session directly; incoming calls wait
/// for CXProviderDelegate to activate it. App backgrounding never deactivates
/// an active call.
private final class CallAudioSessionCoordinator: NSObject {
  private static let channelName = "com.italirpothe/call_audio_session"

  private let channel: FlutterMethodChannel
  private var hasActiveCall = false
  private var isCallKitManaged = false
  private var isVideoCall = false
  private var speakerRequested = false
  private var isCallKitAudioSessionActive = false

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: Self.channelName,
      binaryMessenger: messenger
    )
    super.init()

    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }

    let center = NotificationCenter.default
    center.addObserver(
      self,
      selector: #selector(handleInterruption(_:)),
      name: AVAudioSession.interruptionNotification,
      object: nil
    )
    center.addObserver(
      self,
      selector: #selector(handleRouteChange(_:)),
      name: AVAudioSession.routeChangeNotification,
      object: nil
    )
    center.addObserver(
      self,
      selector: #selector(handleMediaServicesReset(_:)),
      name: AVAudioSession.mediaServicesWereResetNotification,
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "configureCall":
      let arguments = call.arguments as? [String: Any]
      isVideoCall = arguments?["isVideo"] as? Bool ?? false
      isCallKitManaged = arguments?["callKitManaged"] as? Bool ?? false
      speakerRequested = arguments?["speaker"] as? Bool ?? isVideoCall
      hasActiveCall = true

      do {
        try configureSession(activate: !isCallKitManaged)
        result(routeState())
      } catch {
        hasActiveCall = false
        result(
          FlutterError(
            code: "audio_session_configuration_failed",
            message: error.localizedDescription,
            details: nil
          )
        )
      }

    case "setSpeaker":
      speakerRequested =
        (call.arguments as? [String: Any])?["enabled"] as? Bool ?? false
      do {
        try applyRequestedRoute()
        result(routeState())
      } catch {
        result(
          FlutterError(
            code: "audio_route_failed",
            message: error.localizedDescription,
            details: nil
          )
        )
      }

    case "ensureCallAudio":
      guard hasActiveCall else {
        result(["active": false])
        return
      }
      do {
        let mayActivate = !isCallKitManaged || isCallKitAudioSessionActive
        try configureSession(activate: mayActivate)
        result(routeState())
      } catch {
        result(
          FlutterError(
            code: "audio_session_resume_failed",
            message: error.localizedDescription,
            details: nil
          )
        )
      }

    case "endCall":
      let shouldDeactivate = hasActiveCall && !isCallKitManaged
      hasActiveCall = false
      isCallKitManaged = false
      isVideoCall = false
      speakerRequested = false
      if shouldDeactivate {
        try? AVAudioSession.sharedInstance().setActive(
          false,
          options: [.notifyOthersOnDeactivation]
        )
      }
      result(true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func configureSession(activate: Bool) throws {
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(
      .playAndRecord,
      mode: isVideoCall ? .videoChat : .voiceChat,
      options: [.allowBluetooth]
    )
    try session.setPreferredSampleRate(48_000)
    try session.setPreferredIOBufferDuration(0.01)
    if activate {
      try session.setActive(true)
      try applyRequestedRoute()
    }

    guard session.isInputAvailable else {
      throw NSError(
        domain: "CallAudioSession",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "No microphone input is available."]
      )
    }
    logRoute("configured activate=\(activate)")
  }

  private func applyRequestedRoute() throws {
    let session = AVAudioSession.sharedInstance()
    try session.overrideOutputAudioPort(speakerRequested ? .speaker : .none)
    logRoute("route requested speaker=\(speakerRequested)")
  }

  func callKitDidActivate(_ audioSession: AVAudioSession) {
    isCallKitAudioSessionActive = true
    if hasActiveCall && isCallKitManaged {
      try? applyRequestedRoute()
    }
    logRoute("CallKit activated")
    notifyFlutter("callKitAudioActivated", routeState())
  }

  func callKitDidDeactivate(_ audioSession: AVAudioSession) {
    isCallKitAudioSessionActive = false
    logRoute("CallKit deactivated")
    notifyFlutter("callKitAudioDeactivated", routeState())
  }

  @objc private func handleInterruption(_ notification: Notification) {
    guard hasActiveCall,
      let info = notification.userInfo,
      let rawType = info[AVAudioSessionInterruptionTypeKey] as? UInt,
      let type = AVAudioSession.InterruptionType(rawValue: rawType)
    else {
      return
    }

    if type == .began {
      notifyFlutter("interruptionBegan", routeState())
      return
    }

    let rawOptions = info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
    let shouldResume = AVAudioSession.InterruptionOptions(rawValue: rawOptions)
      .contains(.shouldResume)
    if shouldResume && !isCallKitManaged {
      try? configureSession(activate: true)
    }
    notifyFlutter(
      "interruptionEnded",
      routeState().merging(["shouldResume": shouldResume]) { _, new in new }
    )
  }

  @objc private func handleRouteChange(_ notification: Notification) {
    guard hasActiveCall else { return }
    notifyFlutter("routeChanged", routeState())
  }

  @objc private func handleMediaServicesReset(_ notification: Notification) {
    guard hasActiveCall else { return }
    let mayActivate = !isCallKitManaged || isCallKitAudioSessionActive
    try? configureSession(activate: mayActivate)
    notifyFlutter("mediaServicesReset", routeState())
  }

  private func routeState() -> [String: Any] {
    let session = AVAudioSession.sharedInstance()
    return [
      "active": hasActiveCall,
      "sessionActive": !isCallKitManaged || isCallKitAudioSessionActive,
      "callKitManaged": isCallKitManaged,
      "inputAvailable": session.isInputAvailable,
      "speaker": session.currentRoute.outputs.contains {
        $0.portType == .builtInSpeaker
      },
      "outputs": session.currentRoute.outputs.map { $0.portType.rawValue },
    ]
  }

  private func notifyFlutter(_ method: String, _ arguments: [String: Any]) {
    DispatchQueue.main.async { [weak self] in
      self?.channel.invokeMethod(method, arguments: arguments)
    }
  }

  private func logRoute(_ prefix: String) {
    let session = AVAudioSession.sharedInstance()
    NSLog(
      "[CallLifecycle] %@ category=%@ mode=%@ inputs=%@ outputs=%@",
      prefix,
      session.category.rawValue,
      session.mode.rawValue,
      session.currentRoute.inputs.map { $0.portType.rawValue }.joined(separator: ","),
      session.currentRoute.outputs.map { $0.portType.rawValue }.joined(separator: ",")
    )
  }
}
