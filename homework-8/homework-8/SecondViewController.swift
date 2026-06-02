import UIKit

class SecondViewController: UIViewController {
    
    let thirdPageButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        // Добавление картинки на задний фон
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: "background2")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true
        
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        
        // Добавление лейбла с приветствием пользователя
        let usernameLabel = UILabel()
        usernameLabel.text = "Welcome, User12322"
        usernameLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        usernameLabel.textColor = .white
        usernameLabel.frame = CGRect(x: 25, y: 105, width: view.frame.width - 60, height: 50)
        
        view.addSubview(usernameLabel)
        
        // Добавление лейбла контроля
        let controlLabel = UILabel()
        controlLabel.text = "Appartment control page 🏠"
        controlLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        controlLabel.textColor = .white
        controlLabel.frame = CGRect(x: 25, y: 175, width: view.frame.width - 60, height: 50)
        view.addSubview(controlLabel)
        
        // Лейбл для свича света
        let lightsLabel = UILabel()
        lightsLabel.text = "Lights"
        lightsLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lightsLabel.textColor = .lightGray
        lightsLabel.frame = CGRect(x: 25, y: 260, width: view.frame.width - 60, height: 50)
        view.addSubview(lightsLabel)
        
        // Добавление кнопки свитч для света
        let items = ["On", "Off"]
        let segmented = UISegmentedControl(items: items)
        
        segmented.selectedSegmentIndex = 1 // Off по умолчанию
        segmented.backgroundColor = .systemGray6
        segmented.selectedSegmentTintColor = .white
        
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmented.frame = CGRect(x: 25, y: 320, width: view.frame.width - 60, height: 30)
        view.addSubview(segmented)
        
        
        // Лейбл для свича дверей
        let doorLabel = UILabel()
        doorLabel.text = "Door"
        doorLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        doorLabel.textColor = .lightGray
        doorLabel.frame = CGRect(x: 25, y: 360, width: view.frame.width - 60, height: 50)
        view.addSubview(doorLabel)
        
        // Кнопка свич для дверей
        let itemsDoor = ["Lock", "Unlock"]
        let segmented1 = UISegmentedControl(items: itemsDoor)
        
        segmented1.selectedSegmentIndex = 1 // Off по умолчанию
        segmented1.backgroundColor = .systemGray6
        segmented1.selectedSegmentTintColor = .white
        
        segmented1.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        segmented1.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmented1.frame = CGRect(x: 25, y: 420, width: view.frame.width - 60, height: 30)
        view.addSubview(segmented1)
        
        // Лейбл для A/C
        
        let ACLabel = UILabel()
        ACLabel.text = "A/C"
        ACLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        ACLabel.textColor = .lightGray
        ACLabel.frame = CGRect(x: 25, y: 460, width: view.frame.width - 60, height: 50)
        view.addSubview(ACLabel)
        
        // Кнопка свич для AC
        let itemsAC = ["Auto", "On", "Off"]
        let segmented2 = UISegmentedControl(items: itemsAC)
        
        segmented2.selectedSegmentIndex = 2 // Off по умолчанию
        segmented2.backgroundColor = .systemGray6
        segmented1.selectedSegmentTintColor = .white
        
        segmented2.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        segmented2.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmented2.frame = CGRect(x: 25, y: 520, width: view.frame.width - 60, height: 30)
        view.addSubview(segmented2)
        
        // Лейбл температуры
        let tempLabel = UILabel()
        tempLabel.text = "Temperature"
        tempLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        tempLabel.textColor = .lightGray
        tempLabel.frame = CGRect(x: 25, y: 560, width: view.frame.width - 60, height: 50)
        view.addSubview(tempLabel)
        
        // Слайдер температуры
        let slider = UISlider()
        slider.value = 20
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.frame = CGRect(x: 25, y: 620, width: view.frame.width - 60, height: 30)
        view.addSubview(slider)
        
        // Кнопка перехода на следующий экран
        thirdPageButton.setTitle("Third Page", for: .normal)
        thirdPageButton.setTitleColor(.white, for: .normal)
        thirdPageButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        thirdPageButton.frame = CGRect(x: 30, y: 650, width: view.frame.width - 60, height: 50)

        // Добавление функции кнопке
        thirdPageButton.addTarget(
            self,
            action: #selector(openThirdScreen),
            for: .touchUpInside
        )

        view.addSubview(thirdPageButton)
    }

    // Метод перехода
    @objc
    func openThirdScreen() {

        let thirdVC = ThirdViewController()

        navigationController?.pushViewController(thirdVC, animated: true)
    }
}
