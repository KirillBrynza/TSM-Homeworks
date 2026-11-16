import UIKit

final class SettingsViewController: UIViewController {
    
    private let temperatureControl = UISegmentedControl(
        items: ["°C", "°F"]
    )
    
    private let windControl = UISegmentedControl(
        items: ["м/с", "км/ч"]
    )
    
    private let themeControl = UISegmentedControl(
        items: ["Системная", "Светлая", "Тёмная"]
    )
    
    private let temperatureKey = "temperatureUnit"
    private let windKey = "windSpeedUnit"
    private let themeKey = "appTheme"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Настройки"
        view.backgroundColor = .systemBackground
        
        setupUI()
        loadSettings()
        applyTheme()
    }
    
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 28
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            
            stack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 24
            ),
            stack.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                constant: 20
            ),
            stack.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                constant: -20
            ),
            stack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -24
            ),
            stack.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -40
            )
        ])
        
        stack.addArrangedSubview(
            makeSection(
                title: "Температура",
                subtitle: "Единицы измерения температуры",
                control: temperatureControl
            )
        )
        
        stack.addArrangedSubview(
            makeSection(
                title: "Скорость ветра",
                subtitle: "Единицы измерения скорости ветра",
                control: windControl
            )
        )
        
        stack.addArrangedSubview(
            makeSection(
                title: "Оформление",
                subtitle: "Внешний вид приложения",
                control: themeControl
            )
        )
        
        let resetButton = UIButton(type: .system)
        resetButton.setTitle(
            "Сбросить настройки",
            for: .normal
        )
        resetButton.titleLabel?.font = .systemFont(
            ofSize: 16,
            weight: .medium
        )
        resetButton.addTarget(
            self,
            action: #selector(resetSettings),
            for: .touchUpInside
        )
        
        stack.addArrangedSubview(resetButton)
        
        temperatureControl.addTarget(
            self,
            action: #selector(temperatureChanged),
            for: .valueChanged
        )
        
        windControl.addTarget(
            self,
            action: #selector(windChanged),
            for: .valueChanged
        )
        
        themeControl.addTarget(
            self,
            action: #selector(themeChanged),
            for: .valueChanged
        )
    }
    
    private func makeSection(
        title: String,
        subtitle: String,
        control: UISegmentedControl
    ) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(
            ofSize: 18,
            weight: .semibold
        )
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        
        let stack = UIStackView(
            arrangedSubviews: [
                titleLabel,
                subtitleLabel,
                control
            ]
        )
        
        stack.axis = .vertical
        stack.spacing = 10
        
        return stack
    }
    
    private func loadSettings() {
        temperatureControl.selectedSegmentIndex =
        UserDefaults.standard.integer(forKey: temperatureKey)
        
        windControl.selectedSegmentIndex =
        UserDefaults.standard.integer(forKey: windKey)
        
        themeControl.selectedSegmentIndex =
        UserDefaults.standard.integer(forKey: themeKey)
    }
    
    @objc private func temperatureChanged() {
        UserDefaults.standard.set(
            temperatureControl.selectedSegmentIndex,
            forKey: temperatureKey
        )
        
        notifySettingsChanged()
    }
    
    @objc private func windChanged() {
        UserDefaults.standard.set(
            windControl.selectedSegmentIndex,
            forKey: windKey
        )
        
        notifySettingsChanged()
    }
    
    @objc private func themeChanged() {
        UserDefaults.standard.set(
            themeControl.selectedSegmentIndex,
            forKey: themeKey
        )
        
        applyTheme()
        notifySettingsChanged()
    }
    
    private func applyTheme() {
        let selectedTheme = UserDefaults.standard.integer(
            forKey: themeKey
        )
        
        let style: UIUserInterfaceStyle
        
        switch selectedTheme {
        case 1:
            style = .light
        case 2:
            style = .dark
        default:
            style = .unspecified
        }
        
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else {
                continue
            }
            
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
    
    private func notifySettingsChanged() {
        NotificationCenter.default.post(
            name: Notification.Name("WeatherPreferencesDidChange"),
            object: nil
        )
    }
    
    
    @objc private func resetSettings() {
        let alert = UIAlertController(
            title: "Сбросить настройки?",
            message: "Будут восстановлены Цельсий, м/с и системная тема.",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "Отмена", style: .cancel)
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Сбросить",
                style: .destructive
            ) { [weak self] _ in
                guard let self else { return }
                
                UserDefaults.standard.set(
                    0,
                    forKey: self.temperatureKey
                )
                UserDefaults.standard.set(
                    0,
                    forKey: self.windKey
                )
                UserDefaults.standard.set(
                    0,
                    forKey: self.themeKey
                )
                
                self.loadSettings()
                self.applyTheme()
                self.notifySettingsChanged()
            }
        )
        
        present(alert, animated: true)
    }
}
