import UIKit

class ViewController: UIViewController {

    // Кнопка перехода на второй экран
    let nextPageButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Цвет фона
        view.backgroundColor = .black

        // Добавление картинки на задний фон
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: "background1")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true

        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)

        // Добавление главного лейбла
        let mainPageLabel = UILabel()
        mainPageLabel.text = "My Home Controller"
        mainPageLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        mainPageLabel.textColor = .white
        mainPageLabel.frame = CGRect(x: 55, y: 100, width: view.frame.width - 60, height: 50)

        view.addSubview(mainPageLabel)

        // Добавление лейбла юзера
        let userNameLabel = UILabel()
        userNameLabel.text = "Username"
        userNameLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        userNameLabel.textColor = .white
        userNameLabel.frame = CGRect(x: 30, y: 225, width: view.frame.width - 60, height: 50)

        view.addSubview(userNameLabel)

        // Текстовое поле username
        let userNameTextField = UITextField()
        userNameTextField.placeholder = "Enter your username"
        userNameTextField.borderStyle = .roundedRect
        userNameTextField.frame = CGRect(x: 30, y: 285, width: view.frame.width - 60, height: 50)

        view.addSubview(userNameTextField)

        // Лейбл password
        let passwordLabel = UILabel()
        passwordLabel.text = "Password"
        passwordLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        passwordLabel.textColor = .white
        passwordLabel.frame = CGRect(x: 30, y: 350, width: view.frame.width - 60, height: 50)

        view.addSubview(passwordLabel)

        // Текстовое поле password
        let passwordTextField = UITextField()
        passwordTextField.placeholder = "Enter your password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.frame = CGRect(x: 30, y: 410, width: view.frame.width - 60, height: 50)

        view.addSubview(passwordTextField)

        // Кнопка логина
        let logInButton = UIButton(type: .system)
        logInButton.setTitle("Log In", for: .normal)
        logInButton.setTitleColor(.black, for: .normal)
        logInButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        logInButton.backgroundColor = .white
        logInButton.layer.cornerRadius = 10
        logInButton.frame = CGRect(x: 30, y: 490, width: view.frame.width - 60, height: 50)

        view.addSubview(logInButton)

        // Кнопка перехода на следующий экран
        nextPageButton.setTitle("Next Page", for: .normal)
        nextPageButton.setTitleColor(.white, for: .normal)
        nextPageButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nextPageButton.frame = CGRect(x: 30, y: 650, width: view.frame.width - 60, height: 50)

        // Добавление функции кнопке
        nextPageButton.addTarget(
            self,
            action: #selector(openSecondScreen),
            for: .touchUpInside
        )

        view.addSubview(nextPageButton)
    }

    // Метод перехода
    @objc
    func openSecondScreen() {

        let secondVC = SecondViewController()

        navigationController?.pushViewController(secondVC, animated: true)
    }
}
