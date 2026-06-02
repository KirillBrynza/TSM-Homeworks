import UIKit

class ModalLauncherViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemOrange

        let button = UIButton(type: .system)
        button.setTitle("Present modal screen", for: .normal)
        button.addTarget(self, action: #selector(showModal), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func showModal() {

        let modalVC = UIViewController()
        modalVC.view.backgroundColor = .white

        modalVC.modalPresentationStyle = .fullScreen

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)

        closeButton.translatesAutoresizingMaskIntoConstraints = false

        modalVC.view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.centerXAnchor.constraint(equalTo: modalVC.view.centerXAnchor),
            closeButton.centerYAnchor.constraint(equalTo: modalVC.view.centerYAnchor)
        ])

        closeButton.addAction(
            UIAction { _ in
                modalVC.dismiss(animated: true)
            },
            for: .touchUpInside
        )

        present(modalVC, animated: true)
    }
}
