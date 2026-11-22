import Flutter
import UIKit
//claude
// "Restart" for iOS.
//
// iOS apps aren't allowed to quit or relaunch themselves (exit() looks like
// a crash and App Review rejects it). Instead, when Dart calls
// 'secondtemple/restart', this throws away the whole Flutter engine and
// starts a fresh one. Destroying the engine frees the Dart heap, the
// GL/Metal context and every texture the game created, and the new engine
// runs main() again, back at the journey screen.

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var restartChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    if let controller = window?.rootViewController as? FlutterViewController {
      attachRestartChannel(controller.binaryMessenger)
    }
    return ok
  }

  private func attachRestartChannel(_ messenger: FlutterBinaryMessenger) {
    restartChannel = FlutterMethodChannel(
      name: "secondtemple/restart", binaryMessenger: messenger)
     //print("attachrestartChannel")
     restartChannel?.setMethodCallHandler { [weak self] call, result in
      if call.method == "restart" {
        result(nil)
        // Let the reply reach Dart before the old engine is torn down
        DispatchQueue.main.async { self?.restartEngine() }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func restartEngine() {
    guard let window = self.window else { return }
   // print("restartEngine")
    let oldController = window.rootViewController as? FlutterViewController
    let oldEngine = oldController?.engine

    // New engine, new Dart isolate: main() runs from the start
    let engine = FlutterEngine(name: "secondtemple", project: nil, allowHeadlessExecution: false)
    engine.run()
    GeneratedPluginRegistrant.register(with: engine)
    let controller = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    window.rootViewController = controller
    window.makeKeyAndVisible()
    attachRestartChannel(controller.binaryMessenger)

    // Free everything the old engine was holding
    oldEngine?.destroyContext()
  }
}
