import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBlue

        let button = UIButton(type: .system)
        button.setTitle("Push next screen", for: .normal)
        button.addTarget(self, action: #selector(openNext), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func openNext() {

        let nextVC = UIViewController()
        nextVC.view.backgroundColor = .white
        nextVC.title = "Next Screen"

        navigationController?.pushViewController(nextVC, animated: true)
    }
}

