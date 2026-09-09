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

  func didActivateAudioSession(_ audioSession: AVAudioSession) {}

  func didDeactivateAudioSession(_ audioSession: AVAudioSession) {}

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
