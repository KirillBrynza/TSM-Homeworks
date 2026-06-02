import UIKit

final class ViewController: UIViewController {

    // MARK: - Лейбл результата
    // без логики поставил 0

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .white
        label.font = .systemFont(ofSize: 72, weight: .light)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Кнопки

    private func makeButton(
        title: String,
        backgroundColor: UIColor,
        textColor: UIColor = .white,
        fontSize: CGFloat = 36
    ) -> UIButton {

        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: fontSize, weight: .regular)
        button.backgroundColor = backgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 40

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 80),
            button.heightAnchor.constraint(equalToConstant: 80)
        ])

        return button
    }

    private func makeHorizontalStack(_ buttons: [UIButton]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        setupLayout()
    }

    // MARK: - Layout линии кнопок

    struct ButtonStyle {
        let title: String
        let bgColor: UIColor
        let fontColor: UIColor
    }

        // линия первая
        let clearButton = makeButton(
            title: "⌫",
            backgroundColor: UIColor.darkGray,
            textColor: .white
            )
            
        let clearAllButton = makeButton(
            title: "AC",
            backgroundColor: UIColor.darkGray,
            textColor: .white
        )

        let percentButton = makeButton(
            title: "%",
            backgroundColor: UIColor.darkGray,
            textColor: .white
        )

        let divideButton = makeButton(
            title: "÷",
            backgroundColor: .orange
        )

        let firstRow = makeHorizontalStack([
            clearButton,
            clearAllButton,
            percentButton,
            divideButton
        ])

        // линия 2
        let secondRow = makeHorizontalStack([
            makeButton(title: "7", backgroundColor: UIColor(white: 0.15, alpha: 1)),
            makeButton(title: "8", backgroundColor: UIColor(white: 0.15, alpha: 1)),
            makeButton(title: "9", backgroundColor: UIColor(white: 0.15, alpha: 1)),
            makeButton(title: "×", backgroundColor: .orange)
        ])

        // линия 3
        let thirdRow = makeHorizontalStack([
            makeButton(title: "4", backgroundColor: UIColor(white: 0.15, alpha: 1)),
            makeButton(title: "5", backgroundColor: UIColor(white: 0.15, alpha: 1)),
            makeButton(title: "6", backgroundColor: UIColor(white: 0.15, alpha: 1)),
            makeButton(title: "−", backgroundColor: .orange)
        ])

        // линия 4
        let fourthRow = makeHorizontalStack([
            makeButton(title: "1", backgroundColor: UIColor(white: 0.15, alpha: 1)),
            makeButton(title: "2", backgroundColor: UIColor(white: 0.15, alpha: 1)),
            makeButton(title: "3", backgroundColor: UIColor(white: 0.15, alpha: 1)),
            makeButton(title: "+", backgroundColor: .orange)
        ])

        // пятая линия
        let plusMinusButton = makeButton(
            title: "+/-",
            backgroundColor: UIColor(white: 0.15, alpha: 1)
        )

        let zeroButton = makeButton(
            title: "0",
            backgroundColor: UIColor(white: 0.15, alpha: 1)
        )

        let commaButton = makeButton(
            title: ",",
            backgroundColor: UIColor(white: 0.15, alpha: 1)
        )

        let equalButton = makeButton(
            title: "=",
            backgroundColor: .orange
        )

        let fifthRow = makeHorizontalStack([
            plusMinusButton,
            zeroButton,
            commaButton,
            equalButton
        ])

        // совмещаю все линии в стэк, задаю им констрейнты
        let mainStack = UIStackView(arrangedSubviews: [
            firstRow,
            secondRow,
            thirdRow,
            fourthRow,
            fifthRow
        ])

        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(resultLabel)
        view.addSubview(mainStack)

        NSLayoutConstraint.activate([

            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultLabel.bottomAnchor.constraint(equalTo: mainStack.topAnchor, constant: -32),

            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}
