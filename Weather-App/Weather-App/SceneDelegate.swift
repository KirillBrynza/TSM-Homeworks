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
        
        let window = UIWindow(windowScene: windowScene)
        
        let savedTheme = UserDefaults.standard.integer(
            forKey: "appTheme"
        )
        
        switch savedTheme {
        case 1:
            window.overrideUserInterfaceStyle = .light
            
        case 2:
            window.overrideUserInterfaceStyle = .dark
            
        default:
            window.overrideUserInterfaceStyle = .unspecified
        }
        
        window.rootViewController = TabBarController()
        
        self.window = window
        window.makeKeyAndVisible()
    }
}
