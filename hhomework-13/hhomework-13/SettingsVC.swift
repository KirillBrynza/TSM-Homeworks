import UIKit
import SnapKit

// MARK: - Model

struct SettingItem {

    let title: String
    let icon: String
    let iconColor: UIColor
    let type: CellType
}

enum CellType {

    case simple
    case withSwitch(Bool)
    case withDetail(String)
}

// MARK: - ViewController

final class SettingsViewController: UIViewController, UITableViewDelegate {

    // MARK: - UI

    private let tableView: UITableView = {

        let table = UITableView(frame: .zero,
                                style: .insetGrouped)

        return table
    }()

    private let sections: [[SettingItem]] = [

        [
            SettingItem(
                title: "Авиарежим",
                icon: "airplane",
                iconColor: .orange,
                type: .withSwitch(false)
            ),

            SettingItem(
                title: "Wi-Fi",
                icon: "wifi",
                iconColor: .systemBlue,
                type: .withDetail("Не подключено")
            ),

            SettingItem(
                title: "Bluetooth",
                icon: "bolt.horizontal.fill",
                iconColor: .systemBlue,
                type: .withDetail("Вкл.")
            ),

            SettingItem(
                title: "Сотовая связь",
                icon: "antenna.radiowaves.left.and.right",
                iconColor: .green,
                type: .simple
            )
        ],

        [
            SettingItem(
                title: "Уведомления",
                icon: "bell.badge.fill",
                iconColor: .red,
                type: .simple
            ),

            SettingItem(
                title: "Звуки",
                icon: "speaker.wave.3.fill",
                iconColor: .systemPink,
                type: .simple
            ),

            SettingItem(
                title: "Фокусирование",
                icon: "moon.fill",
                iconColor: .purple,
                type: .simple
            )
        ],

        [
            SettingItem(
                title: "Face ID и код-пароль",
                icon: "faceid",
                iconColor: .green,
                type: .simple
            ),

            SettingItem(
                title: "Аккумулятор",
                icon: "battery.100",
                iconColor: .systemGreen,
                type: .simple
            )
        ]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
    }
}

private extension SettingsViewController {

    func setupUI() {

        title = "Настройки"

        view.backgroundColor = .systemBackground

        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in

            make.edges.equalToSuperview()
        }
    }

    func setupTableView() {

        tableView.dataSource = self

        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "cell"
        )
    }
}


extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return sections.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        return sections[section].count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(
            style: .value1,
            reuseIdentifier: "cell"
        )

        let item = sections[indexPath.section][indexPath.row]

        var content = cell.defaultContentConfiguration()

        content.text = item.title
        content.image = UIImage(systemName: item.icon)

        cell.contentConfiguration = content
        
        cell.imageView?.tintColor = item.iconColor

        cell.accessoryView = nil
                cell.accessoryType = .none
                cell.detailTextLabel?.text = nil

                switch item.type {

                case .simple:

                    cell.accessoryType = .disclosureIndicator

                case .withSwitch(let isOn):

                    let switchView = UISwitch()
                    switchView.isOn = isOn

                    cell.accessoryView = switchView

                case .withDetail(let text):

                    cell.detailTextLabel?.text = text
                    cell.accessoryType = .disclosureIndicator
                }

                return cell
            }
        }
