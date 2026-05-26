import UIKit

class ThirdViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: "background3")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true
        
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        
        let mainPageLabel = UILabel()
        mainPageLabel.text = "Registration Form"
        mainPageLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        mainPageLabel.textColor = .white
        mainPageLabel.frame = CGRect(x: 45, y: 100, width: view.frame.width - 60, height: 50)

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

      // Лейбл подтверждения пароля
        let passwordConfirmLabel = UILabel()
        passwordConfirmLabel.text = "Confirm Password"
        passwordConfirmLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        passwordConfirmLabel.textColor = .white
        passwordConfirmLabel.frame = CGRect(x: 30, y: 470, width: view.frame.width - 60, height: 50)

        view.addSubview(passwordConfirmLabel)
        
        // Поле подтверждения пароля
        let passwordConfirmTextField = UITextField()
        passwordConfirmTextField.placeholder = "Confirm your password"
        passwordConfirmTextField.borderStyle = .roundedRect
        passwordConfirmTextField.isSecureTextEntry = true
        passwordConfirmTextField.frame = CGRect(x: 30, y: 530, width: view.frame.width - 60, height: 50)

        view.addSubview(passwordConfirmTextField)
        
        // Кнопка сейва
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.purple, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        saveButton.backgroundColor = .white
        saveButton.layer.cornerRadius = 10
        saveButton.frame = CGRect(x: 30, y: 610, width: view.frame.width - 60, height: 50)
        view.addSubview(saveButton)
        
        
    }
}
