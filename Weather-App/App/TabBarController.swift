import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let weatherVC = UINavigationController(
            rootViewController: WeatherTodayViewController()
        )
        
        let mapVC = UINavigationController(
            rootViewController: WeatherMapViewController()
        )
        
        let settingsVC = UINavigationController(
            rootViewController: SettingsViewController()
        )
        
        weatherVC.tabBarItem = UITabBarItem(
            title: "Погода",
            image: UIImage(systemName: "cloud.sun.fill"),
            tag: 0
        )
        
        mapVC.tabBarItem = UITabBarItem(
            title: "Карта",
            image: UIImage(systemName: "map.fill"),
            tag: 1
        )
        
        settingsVC.tabBarItem = UITabBarItem(
            title: "Настройки",
            image: UIImage(systemName: "gearshape.fill"),
            tag: 2
        )
        
        viewControllers = [
            weatherVC,
            mapVC,
            settingsVC
        ]
    }
}
