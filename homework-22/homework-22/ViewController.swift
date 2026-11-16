import UIKit

final class ViewController: UIViewController {

    // MARK: - Data

    private let pizzaSizes = [
        "Маленькая 25см",
        "Средняя 30см",
        "Большая 35см",
        "Семейная 45см"
    ]

    private let doughTypes = [
        "Тонкое",
        "Традиционное",
        "Пышное",
        "Сырный бортик"
    ]

    private let cities = [
        "Москва",
        "Санкт-Петербург",
        "Казань",
        "Екатеринбург",
        "Новосибирск",
        "Самара"
    ]

    private var selectedToppings: [String] = []

    // Храним изображение отдельно
    private var receiptImage: UIImage?

    // Какое поле сейчас редактируется
    private var activeField: UITextField?

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Секция 1

    private let sizeTextField = UITextField()
    private let doughTextField = UITextField()
    private let cityTextField = UITextField()

    // Отдельный UIPickerView для каждого поля
    private let sizePicker = UIPickerView()
    private let doughPicker = UIPickerView()
    private let cityPicker = UIPickerView()

    // Секция 2

    private let toppingsButton = UIButton(type: .system)
    private let toppingsLabel = UILabel()

    // Секция 3

    private let receiptImageView = UIImageView()
    private let receiptLabel = UILabel()
    private let photoAddedLabel = UILabel()

    // Кнопка заказа

    private let orderButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Заказ пиццы"
        view.backgroundColor = .systemBackground

        setupPickers()
        setupUI()
        setupConstraints()
    }

    // MARK: - Picker Setup

    private func setupPickers() {

        sizePicker.dataSource = self
        sizePicker.delegate = self

        doughPicker.dataSource = self
        doughPicker.delegate = self

        cityPicker.dataSource = self
        cityPicker.delegate = self

        // UIPickerView вместо клавиатуры

        sizeTextField.inputView = sizePicker
        doughTextField.inputView = doughPicker
        cityTextField.inputView = cityPicker

        // Toolbar с кнопкой "Готово"

        sizeTextField.inputAccessoryView = createToolbar()
        doughTextField.inputAccessoryView = createToolbar()
        cityTextField.inputAccessoryView = createToolbar()

        // Определяем активное поле

        sizeTextField.addTarget(
            self,
            action: #selector(textFieldDidBeginEditing(_:)),
            for: .editingDidBegin
        )

        doughTextField.addTarget(
            self,
            action: #selector(textFieldDidBeginEditing(_:)),
            for: .editingDidBegin
        )

        cityTextField.addTarget(
            self,
            action: #selector(textFieldDidBeginEditing(_:)),
            for: .editingDidBegin
        )
    }

    private func createToolbar() -> UIToolbar {

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexibleSpace = UIBarButtonItem(
            systemItem: .flexibleSpace
        )

        let doneButton = UIBarButtonItem(
            title: "Готово", image: nil,
            target: self,
            action: #selector(donePicker)
        )

        toolbar.items = [
            flexibleSpace,
            doneButton
        ]

        return toolbar
    }

    @objc private func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {

        activeField = textField
    }

    @objc private func donePicker() {

        guard let activeField else {
            return
        }

        if activeField == sizeTextField {

            let row = sizePicker.selectedRow(inComponent: 0)
            sizeTextField.text = pizzaSizes[row]

        } else if activeField == doughTextField {

            let row = doughPicker.selectedRow(inComponent: 0)
            doughTextField.text = doughTypes[row]

        } else if activeField == cityTextField {

            let row = cityPicker.selectedRow(inComponent: 0)
            cityTextField.text = cities[row]
        }

        activeField.resignFirstResponder()
    }

    // MARK: - UI Setup

    private func setupUI() {

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // ---------- Секция 1 ----------

        let pizzaSectionTitle = createSectionTitle(
            "1. Параметры пиццы"
        )

        configureTextField(
            sizeTextField,
            placeholder: "Выберите размер"
        )

        configureTextField(
            doughTextField,
            placeholder: "Выберите тип теста"
        )

        configureTextField(
            cityTextField,
            placeholder: "Выберите город доставки"
        )

        // ---------- Секция 2 ----------

        let toppingsSectionTitle = createSectionTitle(
            "2. Топпинги"
        )

        toppingsButton.translatesAutoresizingMaskIntoConstraints = false
        toppingsButton.setTitle(
            "Выбрать топпинги",
            for: .normal
        )

        toppingsButton.titleLabel?.font = .systemFont(
            ofSize: 17,
            weight: .semibold
        )

        toppingsButton.backgroundColor = .systemBlue
        toppingsButton.tintColor = .white
        toppingsButton.layer.cornerRadius = 10

        toppingsButton.addTarget(
            self,
            action: #selector(selectToppingsTapped),
            for: .touchUpInside
        )

        toppingsLabel.translatesAutoresizingMaskIntoConstraints = false
        toppingsLabel.text = "Без топпингов"
        toppingsLabel.numberOfLines = 0
        toppingsLabel.textAlignment = .center
        toppingsLabel.textColor = .secondaryLabel

        // ---------- Секция 3 ----------

        let receiptSectionTitle = createSectionTitle(
            "3. Фото чека"
        )

        receiptImageView.translatesAutoresizingMaskIntoConstraints = false
        receiptImageView.backgroundColor = .systemGray5
        receiptImageView.contentMode = .scaleAspectFill
        receiptImageView.clipsToBounds = true
        receiptImageView.layer.cornerRadius = 12
        receiptImageView.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(receiptImageTapped)
        )

        receiptImageView.addGestureRecognizer(tapGesture)

        receiptLabel.translatesAutoresizingMaskIntoConstraints = false
        receiptLabel.text = "Добавьте фото чека (опционально)"
        receiptLabel.textAlignment = .center
        receiptLabel.textColor = .secondaryLabel

        photoAddedLabel.translatesAutoresizingMaskIntoConstraints = false
        photoAddedLabel.text = "✓ Фото добавлено"
        photoAddedLabel.textColor = .systemGreen
        photoAddedLabel.textAlignment = .center
        photoAddedLabel.isHidden = true

        // ---------- Кнопка заказа ----------

        orderButton.translatesAutoresizingMaskIntoConstraints = false
        orderButton.setTitle(
            "Оформить заказ",
            for: .normal
        )

        orderButton.titleLabel?.font = .systemFont(
            ofSize: 18,
            weight: .bold
        )

        orderButton.backgroundColor = .systemRed
        orderButton.tintColor = .white
        orderButton.layer.cornerRadius = 12

        orderButton.addTarget(
            self,
            action: #selector(orderTapped),
            for: .touchUpInside
        )

        // Добавляем элементы

        contentView.addSubview(pizzaSectionTitle)
        contentView.addSubview(sizeTextField)
        contentView.addSubview(doughTextField)
        contentView.addSubview(cityTextField)

        contentView.addSubview(toppingsSectionTitle)
        contentView.addSubview(toppingsButton)
        contentView.addSubview(toppingsLabel)

        contentView.addSubview(receiptSectionTitle)
        contentView.addSubview(receiptImageView)
        contentView.addSubview(receiptLabel)
        contentView.addSubview(photoAddedLabel)

        contentView.addSubview(orderButton)

        // Сохраняем ссылки через tag не нужно,
        // поэтому constraints создаем ниже

        pizzaSectionTitle.tag = 101
        toppingsSectionTitle.tag = 102
        receiptSectionTitle.tag = 103
    }

    private func configureTextField(
        _ textField: UITextField,
        placeholder: String
    ) {

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect

        // Показываем стрелку справа

        let imageView = UIImageView(
            image: UIImage(
                systemName: "chevron.down"
            )
        )

        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .center

        imageView.frame = CGRect(
            x: 0,
            y: 0,
            width: 40,
            height: 40
        )

        textField.rightView = imageView
        textField.rightViewMode = .always
    }

    private func createSectionTitle(
        _ text: String
    ) -> UILabel {

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(
            ofSize: 20,
            weight: .bold
        )

        return label
    }

    // MARK: - Constraints

    private func setupConstraints() {

        guard
            let pizzaTitle = contentView.viewWithTag(101),
            let toppingsTitle = contentView.viewWithTag(102),
            let receiptTitle = contentView.viewWithTag(103)
        else {
            return
        }

        NSLayoutConstraint.activate([

            // ScrollView

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
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),

            // ContentView

            contentView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),

            contentView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),

            contentView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),

            contentView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),

            contentView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),

            // Section 1

            pizzaTitle.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 24
            ),

            pizzaTitle.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            sizeTextField.topAnchor.constraint(
                equalTo: pizzaTitle.bottomAnchor,
                constant: 16
            ),

            sizeTextField.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            sizeTextField.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            sizeTextField.heightAnchor.constraint(
                equalToConstant: 48
            ),

            doughTextField.topAnchor.constraint(
                equalTo: sizeTextField.bottomAnchor,
                constant: 12
            ),

            doughTextField.leadingAnchor.constraint(
                equalTo: sizeTextField.leadingAnchor
            ),

            doughTextField.trailingAnchor.constraint(
                equalTo: sizeTextField.trailingAnchor
            ),

            doughTextField.heightAnchor.constraint(
                equalToConstant: 48
            ),

            cityTextField.topAnchor.constraint(
                equalTo: doughTextField.bottomAnchor,
                constant: 12
            ),

            cityTextField.leadingAnchor.constraint(
                equalTo: sizeTextField.leadingAnchor
            ),

            cityTextField.trailingAnchor.constraint(
                equalTo: sizeTextField.trailingAnchor
            ),

            cityTextField.heightAnchor.constraint(
                equalToConstant: 48
            ),

            // Section 2

            toppingsTitle.topAnchor.constraint(
                equalTo: cityTextField.bottomAnchor,
                constant: 30
            ),

            toppingsTitle.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            toppingsButton.topAnchor.constraint(
                equalTo: toppingsTitle.bottomAnchor,
                constant: 16
            ),

            toppingsButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            toppingsButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            toppingsButton.heightAnchor.constraint(
                equalToConstant: 50
            ),

            toppingsLabel.topAnchor.constraint(
                equalTo: toppingsButton.bottomAnchor,
                constant: 12
            ),

            toppingsLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            toppingsLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            // Section 3

            receiptTitle.topAnchor.constraint(
                equalTo: toppingsLabel.bottomAnchor,
                constant: 30
            ),

            receiptTitle.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            receiptImageView.topAnchor.constraint(
                equalTo: receiptTitle.bottomAnchor,
                constant: 16
            ),

            receiptImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            receiptImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            receiptImageView.heightAnchor.constraint(
                equalToConstant: 220
            ),

            receiptLabel.topAnchor.constraint(
                equalTo: receiptImageView.bottomAnchor,
                constant: 10
            ),

            receiptLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            receiptLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            photoAddedLabel.topAnchor.constraint(
                equalTo: receiptLabel.bottomAnchor,
                constant: 8
            ),

            photoAddedLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            photoAddedLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            // Order button

            orderButton.topAnchor.constraint(
                equalTo: photoAddedLabel.bottomAnchor,
                constant: 30
            ),

            orderButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            orderButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            orderButton.heightAnchor.constraint(
                equalToConstant: 56
            ),

            orderButton.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -30
            )
        ])
    }

    // MARK: - Toppings

    @objc private func selectToppingsTapped() {

        let alert = UIAlertController(
            title: "Выберите топпинги",
            message: "Введите до 5 топпингов",
            preferredStyle: .alert
        )

        // Создаем 5 текстовых полей

        for index in 0..<5 {

            alert.addTextField { textField in

                textField.placeholder = "Топпинг \(index + 1)"

                // Если топпинг уже был выбран —
                // подставляем его обратно

                if index < self.selectedToppings.count {
                    textField.text = self.selectedToppings[index]
                }
            }
        }

        let doneAction = UIAlertAction(
            title: "Готово",
            style: .default
        ) { [weak self] _ in

            guard let self else {
                return
            }

            // Берем только непустые значения

            self.selectedToppings = alert.textFields?
                .compactMap { textField -> String? in

                    guard let text = textField.text?
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ),
                          !text.isEmpty
                    else {
                        return nil
                    }

                    return text
                } ?? []

            // Обновляем label

            if self.selectedToppings.isEmpty {

                self.toppingsLabel.text = "Без топпингов"

            } else {

                self.toppingsLabel.text =
                    self.selectedToppings.joined(
                        separator: ", "
                    )
            }
        }

        let cancelAction = UIAlertAction(
            title: "Отмена",
            style: .cancel
        )

        alert.addAction(doneAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    // MARK: - Receipt Photo

    @objc private func receiptImageTapped() {

        let actionSheet = UIAlertController(
            title: "Фото чека",
            message: "Выберите источник",
            preferredStyle: .actionSheet
        )

        let cameraAction = UIAlertAction(
            title: "Сделать фото",
            style: .default
        ) { [weak self] _ in

            self?.openImagePicker(
                sourceType: .camera
            )
        }

        let galleryAction = UIAlertAction(
            title: "Выбрать из галереи",
            style: .default
        ) { [weak self] _ in

            self?.openImagePicker(
                sourceType: .photoLibrary
            )
        }

        let cancelAction = UIAlertAction(
            title: "Отмена",
            style: .cancel
        )

        actionSheet.addAction(cameraAction)
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(cancelAction)

        // Для iPad

        if let popover = actionSheet.popoverPresentationController {

            popover.sourceView = receiptImageView
            popover.sourceRect = receiptImageView.bounds
        }

        present(actionSheet, animated: true)
    }

    private func openImagePicker(
        sourceType: UIImagePickerController.SourceType
    ) {

        // Проверяем доступность источника

        guard UIImagePickerController.isSourceTypeAvailable(
            sourceType
        ) else {

            showAlert(
                title: "Ошибка",
                message: "Выбранный источник недоступен"
            )

            return
        }

        let picker = UIImagePickerController()

        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = false

        present(picker, animated: true)
    }

    // MARK: - Order

    @objc private func orderTapped() {

        // Валидация размера

        guard let size = sizeTextField.text,
              !size.isEmpty else {

            showAlert(
                title: "Ошибка",
                message: "Выберите размер пиццы"
            )

            return
        }

        // Валидация теста

        guard let dough = doughTextField.text,
              !dough.isEmpty else {

            showAlert(
                title: "Ошибка",
                message: "Выберите тип теста"
            )

            return
        }

        // Валидация города

        guard let city = cityTextField.text,
              !city.isEmpty else {

            showAlert(
                title: "Ошибка",
                message: "Выберите город доставки"
            )

            return
        }

        let price = calculatePrice()

        let toppingsText: String

        if selectedToppings.isEmpty {
            toppingsText = "Без топпингов"
        } else {
            toppingsText = selectedToppings.joined(
                separator: ", "
            )
        }

        let photoText = receiptImage == nil
            ? "Нет"
            : "Да"

        let message = """
        Размер: \(size)

        Тесто: \(dough)

        Топпинги: \(toppingsText)

        Город доставки: \(city)

        Фото чека: \(photoText)

        Итоговая цена: \(price) ₽
        """

        let actionSheet = UIAlertController(
            title: "Ваш заказ",
            message: message,
            preferredStyle: .actionSheet
        )

        let confirmAction = UIAlertAction(
            title: "Подтвердить заказ",
            style: .default
        ) { [weak self] _ in

            guard let self else {
                return
            }

            self.finishOrder(price: price)
        }

        let cancelAction = UIAlertAction(
            title: "Отмена",
            style: .cancel
        )

        actionSheet.addAction(confirmAction)
        actionSheet.addAction(cancelAction)

        // Для iPad

        if let popover = actionSheet.popoverPresentationController {

            popover.sourceView = orderButton
            popover.sourceRect = orderButton.bounds
        }

        present(actionSheet, animated: true)
    }

    // MARK: - Price

    private func calculatePrice() -> Int {

        var total = 0

        // Цена размера

        switch sizeTextField.text {

        case "Маленькая 25см":
            total = 400

        case "Средняя 30см":
            total = 600

        case "Большая 35см":
            total = 800

        case "Семейная 45см":
            total = 1100

        default:
            total = 0
        }

        // Каждый топпинг +50

        total += selectedToppings.count * 50

        // Сырный бортик +150

        if doughTextField.text == "Сырный бортик" {
            total += 150
        }

        return total
    }

    // MARK: - Finish Order

    private func finishOrder(price: Int) {

        let title: String
        let message: String

        if price > 2000 {

            title = "Поздравляем!"
            message = "Вам доступна бесплатная доставка"

        } else {

            title = "Заказ оформлен"
            message = "Спасибо за ваш заказ!"
        }

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(
            title: "OK",
            style: .default
        ) { [weak self] _ in

            // После закрытия финального alert
            // сбрасываем всю форму

            self?.resetForm()
        }

        alert.addAction(okAction)

        present(alert, animated: true)
    }

    // MARK: - Reset Form

    private func resetForm() {

        sizeTextField.text = nil
        doughTextField.text = nil
        cityTextField.text = nil

        selectedToppings.removeAll()

        toppingsLabel.text = "Без топпингов"

        receiptImage = nil
        receiptImageView.image = nil

        photoAddedLabel.isHidden = true

        sizePicker.selectRow(
            0,
            inComponent: 0,
            animated: false
        )

        doughPicker.selectRow(
            0,
            inComponent: 0,
            animated: false
        )

        cityPicker.selectRow(
            0,
            inComponent: 0,
            animated: false
        )
    }

    // MARK: - Alert Helper

    private func showAlert(
        title: String,
        message: String
    ) {

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDataSource

extension ViewController: UIPickerViewDataSource {

    func numberOfComponents(
        in pickerView: UIPickerView
    ) -> Int {

        return 1
    }

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {

        if pickerView == sizePicker {
            return pizzaSizes.count
        }

        if pickerView == doughPicker {
            return doughTypes.count
        }

        return cities.count
    }
}

// MARK: - UIPickerViewDelegate

extension ViewController: UIPickerViewDelegate {

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {

        if pickerView == sizePicker {
            return pizzaSizes[row]
        }

        if pickerView == doughPicker {
            return doughTypes[row]
        }

        return cities[row]
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ViewController:
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info:
        [UIImagePickerController.InfoKey: Any]
    ) {

        guard let image = info[
            .originalImage
        ] as? UIImage else {

            dismiss(animated: true)
            return
        }

        receiptImage = image
        receiptImageView.image = image

        photoAddedLabel.isHidden = false

        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(
        _ picker: UIImagePickerController
    ) {

        dismiss(animated: true)
    }
}
