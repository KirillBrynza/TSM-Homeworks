import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = [
            createHomeTab(),
            createProfileTab(),
            createModalTab()
        ]
    }

    // 1 вкладка
    private func createHomeTab() -> UIViewController {

        let viewController = HomeViewController()
        viewController.title = "Home"

        let navigation = UINavigationController(rootViewController: viewController)

        navigation.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            tag: 0
        )

        return navigation
    }

    // 2 вкладка
    private func createProfileTab() -> UIViewController {

        let vc = ProfileViewController()
        vc.title = "Profile"

        let navigation = UINavigationController(rootViewController: vc)

        navigation.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            tag: 1
        )

        return navigation
    }

    // 3 вкладка через present()
    private func createModalTab() -> UIViewController {

        let viewController = ModalLauncherViewController()

        viewController.tabBarItem = UITabBarItem(
            title: "Modal",
            image: UIImage(systemName: "square.and.arrow.up"),
            tag: 2
        )

        return viewController
    }
}
