import UIKit

final class ViewController: UIViewController {

    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupTextView()
        setupToolbar()
    }
    

    private func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false

        textView.font = .systemFont(ofSize: 18)
        textView.backgroundColor = .systemBackground

        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),

            textView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),

            textView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }

    private func setupToolbar() {

        let boldButton = UIBarButtonItem(
            title: "B",
            style: .plain,
            target: self,
            action: #selector(boldTapped)
        )

        let underlineButton = UIBarButtonItem(
            title: "U",
            style: .plain,
            target: self,
            action: #selector(underlineTapped)
        )

        let redButton = UIBarButtonItem(
            title: "Красный",
            style: .plain,
            target: self,
            action: #selector(redTapped)
        )

        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        toolbar.items = [
            boldButton,
            .flexibleSpace(),
            underlineButton,
            .flexibleSpace(),
            redButton
        ]

        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),

            toolbar.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            toolbar.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            toolbar.heightAnchor.constraint(
                equalToConstant: 44
            ),

            textView.topAnchor.constraint(
                equalTo: toolbar.bottomAnchor
            )
        ])
    }

    @objc private func boldTapped() {
        toggleBold()
    }

    @objc private func underlineTapped() {
        toggleUnderline()
    }

    @objc private func redTapped() {
        setTextColor(.red)
    }

    private func toggleBold() {

        let range = textView.selectedRange

        guard range.length > 0 else {
            return
        }

        let attributedText = NSMutableAttributedString(
            attributedString: textView.attributedText
        )

        attributedText.enumerateAttribute(
            .font,
            in: range
        ) { value, subrange, _ in

            let currentFont = value as? UIFont
                ?? UIFont.systemFont(ofSize: 18)

            var traits = currentFont.fontDescriptor.symbolicTraits

            if traits.contains(.traitBold) {
                traits.remove(.traitBold)
            } else {
                traits.insert(.traitBold)
            }

            guard let descriptor =
                    currentFont.fontDescriptor.withSymbolicTraits(traits)
            else {
                return
            }

            let newFont = UIFont(
                descriptor: descriptor,
                size: currentFont.pointSize
            )

            attributedText.addAttribute(
                .font,
                value: newFont,
                range: subrange
            )
        }

        textView.attributedText = attributedText
        textView.selectedRange = range
    }

    private func toggleUnderline() {

        let range = textView.selectedRange

        guard range.length > 0 else {
            return
        }

        let attributedText = NSMutableAttributedString(
            attributedString: textView.attributedText
        )

        var isUnderlined = false

        attributedText.enumerateAttribute(
            .underlineStyle,
            in: range
        ) { value, _, _ in

            if let value = value as? Int,
               value != 0 {
                isUnderlined = true
            }
        }

        if isUnderlined {
            attributedText.removeAttribute(
                .underlineStyle,
                range: range
            )
        } else {
            attributedText.addAttribute(
                .underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: range
            )
        }

        textView.attributedText = attributedText
        textView.selectedRange = range
    }
    

    private func setTextColor(_ color: UIColor) {

        let range = textView.selectedRange

        guard range.length > 0 else {
            return
        }

        let attributedText = NSMutableAttributedString(
            attributedString: textView.attributedText
        )

        attributedText.addAttribute(
            .foregroundColor,
            value: color,
            range: range
        )

        textView.attributedText = attributedText
        textView.selectedRange = range
    }
}
