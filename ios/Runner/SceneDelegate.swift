import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard
      let windowScene = scene as? UIWindowScene,
      let appDelegate = UIApplication.shared.delegate as? AppDelegate
    else {
      return
    }

    guard let flutterEngine = appDelegate.flutterEngine else {
      let unavailableController = UIViewController()
      unavailableController.view.backgroundColor = .systemBackground

      let messageLabel = UILabel()
      messageLabel.translatesAutoresizingMaskIntoConstraints = false
      messageLabel.numberOfLines = 0
      messageLabel.textAlignment = .center
      messageLabel.text =
        "This Debug build must be launched from Xcode or Flutter. "
        + "Use a Profile or Release build for lock-screen call testing."
      unavailableController.view.addSubview(messageLabel)
      NSLayoutConstraint.activate([
        messageLabel.leadingAnchor.constraint(
          greaterThanOrEqualTo: unavailableController.view.leadingAnchor,
          constant: 32
        ),
        messageLabel.trailingAnchor.constraint(
          lessThanOrEqualTo: unavailableController.view.trailingAnchor,
          constant: -32
        ),
        messageLabel.centerXAnchor.constraint(
          equalTo: unavailableController.view.centerXAnchor
        ),
        messageLabel.centerYAnchor.constraint(
          equalTo: unavailableController.view.centerYAnchor
        ),
      ])

      let appWindow = UIWindow(windowScene: windowScene)
      appWindow.rootViewController = unavailableController
      window = appWindow
      appWindow.makeKeyAndVisible()
      return
    }

    let flutterViewController = FlutterViewController(
      engine: flutterEngine,
      nibName: nil,
      bundle: nil
    )
    flutterViewController.loadDefaultSplashScreenView()

    let appWindow = UIWindow(windowScene: windowScene)
    appWindow.rootViewController = flutterViewController
    window = appWindow
    appWindow.makeKeyAndVisible()

    super.scene(
      scene,
      willConnectTo: session,
      options: connectionOptions
    )
  }

  override func sceneDidDisconnect(_ scene: UIScene) {
    if
      let appDelegate = UIApplication.shared.delegate as? AppDelegate,
      let flutterEngine = appDelegate.flutterEngine
    {
      // The engine remains headless for CallKit, but it must not retain a
      // controller belonging to a discarded iOS scene.
      flutterEngine.viewController = nil
    }
    super.sceneDidDisconnect(scene)
  }
}
