import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGreen

        let button = UIButton(type: .system)
        button.setTitle("Open details", for: .normal)
        button.addTarget(self, action: #selector(openDetails), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func openDetails() {

        let detailsVC = UIViewController()
        detailsVC.view.backgroundColor = .systemGray6
        detailsVC.title = "Details"

        navigationController?.pushViewController(detailsVC, animated: true)
    }
}

