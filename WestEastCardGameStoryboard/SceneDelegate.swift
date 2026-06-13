import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let rootVC = storyboard.instantiateInitialViewController() else {
            print("ERROR: Main.storyboard has no Initial View Controller")
            return
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootVC
        window.makeKeyAndVisible()

        self.window = window
    }
}
