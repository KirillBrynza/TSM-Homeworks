import UIKit

final class ForecastDetailViewController: UIViewController {

    private let city: String
    private let forecastDay: ForecastDay

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    init(city: String, forecastDay: ForecastDay) {
        self.city = city
        self.forecastDay = forecastDay
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) не поддерживается")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = city
        view.backgroundColor = .systemBackground

        setupLayout()
        fillContent()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        contentStack.axis = .vertical
        contentStack.spacing = 20

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

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

            contentStack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 20
            ),
            contentStack.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                constant: 20
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                constant: -20
            ),
            contentStack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -24
            ),
            contentStack.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -40
            )
        ])
    }

    private func fillContent() {
        let dateLabel = UILabel()
        dateLabel.text = formattedDate(forecastDay.date)
        dateLabel.font = .systemFont(ofSize: 17, weight: .medium)
        dateLabel.textColor = .secondaryLabel

        contentStack.addArrangedSubview(dateLabel)
        contentStack.addArrangedSubview(makeWeatherCard())

        contentStack.addArrangedSubview(
            makeSectionTitle("Температура по часам")
        )

        if !forecastDay.hour.isEmpty {
            let chart = TemperatureChartView(
                hours: forecastDay.hour
            )
            chart.translatesAutoresizingMaskIntoConstraints = false
            chart.heightAnchor.constraint(
                equalToConstant: 220
            ).isActive = true

            contentStack.addArrangedSubview(chart)
        }

        contentStack.addArrangedSubview(
            makeSectionTitle("Показатели за день")
        )

        let visibilityValues = forecastDay.hour.compactMap {
            $0.vis_km
        }

        let pressureValues = forecastDay.hour.compactMap {
            $0.pressure_mb
        }

        let visibilityText: String

        if let averageVisibility = average(visibilityValues) {
            visibilityText = String(
                format: "%.1f км",
                averageVisibility
            )
        } else {
            visibilityText = "Нет данных"
        }

        let pressureText: String

        if let averagePressure = average(pressureValues) {
            // Перевод из миллибар в мм рт. ст.
            let pressure = averagePressure * 0.750061683

            pressureText =
                "\(Int(pressure.rounded())) мм рт. ст."
        } else {
            pressureText = "Нет данных"
        }

        let firstRow = makeMetricRow([
            makeMetricCard(
                title: "Вероятность дождя",
                value: "\(forecastDay.day.daily_chance_of_rain)%",
                symbol: "drop.fill"
            ),
            makeMetricCard(
                title: "Видимость",
                value: visibilityText,
                symbol: "eye"
            )
        ])

        let secondRow = makeMetricRow([
            makeMetricCard(
                title: "Давление",
                value: pressureText,
                symbol: "gauge.with.needle"
            ),
            makeMetricCard(
                title: "УФ-индекс",
                value: formattedNumber(forecastDay.day.uv),
                symbol: "sun.max.fill"
            )
        ])

        contentStack.addArrangedSubview(firstRow)
        contentStack.addArrangedSubview(secondRow)

        contentStack.addArrangedSubview(
            makeSectionTitle("Восход и закат")
        )

        let sunRow = makeMetricRow([
            makeMetricCard(
                title: "Восход",
                value: forecastDay.astro.sunrise,
                symbol: "sunrise.fill"
            ),
            makeMetricCard(
                title: "Закат",
                value: forecastDay.astro.sunset,
                symbol: "sunset.fill"
            )
        ])

        contentStack.addArrangedSubview(sunRow)
    }

    private func makeWeatherCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 20

        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let conditionLabel = UILabel()
        conditionLabel.text = forecastDay.day.condition.text
        conditionLabel.font = .systemFont(
            ofSize: 17,
            weight: .medium
        )
        conditionLabel.numberOfLines = 0

        let temperatureLabel = UILabel()
        temperatureLabel.text =
            "\(temperatureText(forecastDay.day.maxtemp_c)) / " +
            "\(temperatureText(forecastDay.day.mintemp_c))"
        temperatureLabel.font = .systemFont(
            ofSize: 27,
            weight: .semibold
        )
        temperatureLabel.adjustsFontSizeToFitWidth = true

        let captionLabel = UILabel()
        captionLabel.text = "Максимум / минимум"
        captionLabel.font = .systemFont(ofSize: 12)
        captionLabel.textColor = .secondaryLabel

        let labels = UIStackView(
            arrangedSubviews: [
                conditionLabel,
                temperatureLabel,
                captionLabel
            ]
        )

        labels.axis = .vertical
        labels.spacing = 7
        labels.alignment = .leading
        labels.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconView)
        card.addSubview(labels)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(
                equalTo: card.leadingAnchor,
                constant: 12
            ),
            iconView.centerYAnchor.constraint(
                equalTo: card.centerYAnchor
            ),
            iconView.widthAnchor.constraint(equalToConstant: 76),
            iconView.heightAnchor.constraint(equalToConstant: 76),

            labels.leadingAnchor.constraint(
                equalTo: iconView.trailingAnchor,
                constant: 8
            ),
            labels.topAnchor.constraint(
                equalTo: card.topAnchor,
                constant: 20
            ),
            labels.trailingAnchor.constraint(
                equalTo: card.trailingAnchor,
                constant: -16
            ),
            labels.bottomAnchor.constraint(
                equalTo: card.bottomAnchor,
                constant: -20
            )
        ])

        loadWeatherIcon(
            forecastDay.day.condition.icon,
            into: iconView
        )

        return card
    }

    private func makeMetricRow(
        _ cards: [UIView]
    ) -> UIStackView {
        let row = UIStackView(arrangedSubviews: cards)

        row.axis = .horizontal
        row.alignment = .fill
        row.distribution = .fillEqually
        row.spacing = 12

        return row
    }

    private func makeMetricCard(
        title: String,
        value: String,
        symbol: String
    ) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 16

        let icon = UIImageView(
            image: UIImage(systemName: symbol)
        )
        icon.tintColor = .secondaryLabel
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .secondaryLabel
        titleLabel.numberOfLines = 0

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(
            ofSize: 17,
            weight: .semibold
        )
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7
        valueLabel.numberOfLines = 0

        let stack = UIStackView(
            arrangedSubviews: [
                icon,
                titleLabel,
                valueLabel
            ]
        )

        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(
                equalTo: card.topAnchor,
                constant: 14
            ),
            stack.leadingAnchor.constraint(
                equalTo: card.leadingAnchor,
                constant: 12
            ),
            stack.trailingAnchor.constraint(
                equalTo: card.trailingAnchor,
                constant: -12
            ),
            stack.bottomAnchor.constraint(
                equalTo: card.bottomAnchor,
                constant: -14
            ),

            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22)
        ])

        return card
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(
            ofSize: 20,
            weight: .semibold
        )
        return label
    }

    private func temperatureText(_ celsius: Double) -> String {
        let isFahrenheit = UserDefaults.standard.integer(
            forKey: "temperatureUnit"
        ) == 1

        let value = isFahrenheit
            ? celsius * 9 / 5 + 32
            : celsius

        let unit = isFahrenheit ? "°F" : "°C"

        return "\(Int(value.rounded()))\(unit)"
    }

    private func formattedDate(_ value: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = inputFormatter.date(from: value) else {
            return value
        }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ru_RU")
        outputFormatter.dateFormat = "EEEE, d MMMM"

        return outputFormatter.string(from: date)
    }

    private func formattedNumber(_ value: Double) -> String {
        if value.rounded() == value {
            return "\(Int(value))"
        }

        return String(format: "%.1f", value)
    }

    private func average(_ values: [Double]) -> Double? {
        guard !values.isEmpty else {
            return nil
        }

        return values.reduce(0, +) / Double(values.count)
    }

    private func loadWeatherIcon(
        _ path: String,
        into imageView: UIImageView
    ) {
        let urlString = path.hasPrefix("//")
            ? "https:\(path)"
            : path

        guard let url = URL(string: urlString) else {
            return
        }

        imageView.accessibilityIdentifier = urlString

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(
                    from: url
                )

                guard
                    let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode),
                    let image = UIImage(data: data)
                else {
                    return
                }

                await MainActor.run {
                    guard imageView.accessibilityIdentifier == urlString else {
                        return
                    }

                    imageView.image = image
                }
            } catch {
            }
        }
    }
}

private final class TemperatureChartView: UIView {

    private let hours: [HourlyForecast]

    init(hours: [HourlyForecast]) {
        self.hours = hours
        super.init(frame: .zero)
        backgroundColor = .clear
        contentMode = .redraw
        isAccessibilityElement = true
        accessibilityLabel = "График температуры по часам"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) не поддерживается")
    }

    override func draw(_ rect: CGRect) {
        guard !hours.isEmpty else {
            return
        }

        let left: CGFloat = 42
        let right: CGFloat = 12
        let top: CGFloat = 20
        let bottom: CGFloat = 30

        let plot = CGRect(
            x: left,
            y: top,
            width: bounds.width - left - right,
            height: bounds.height - top - bottom
        )

        guard plot.width > 0, plot.height > 0 else {
            return
        }

        let temperatures = hours.map { $0.temp_c }
        guard let minimum = temperatures.min(),
              let maximum = temperatures.max() else {
            return
        }

        let padding = max((maximum - minimum) * 0.15, 1.0)
        let lower = minimum - padding
        let upper = maximum + padding
        let range = max(upper - lower, 1.0)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        for step in 0...3 {
            let fraction = CGFloat(step) / 3
            let y = plot.minY + plot.height * fraction

            let grid = UIBezierPath()
            grid.move(to: CGPoint(x: plot.minX, y: y))
            grid.addLine(to: CGPoint(x: plot.maxX, y: y))

            UIColor.tertiaryLabel.setStroke()
            grid.lineWidth = 0.5
            grid.stroke()

            let celsiusValue =
                upper - Double(step) / 3 * range

            let fahrenheit = UserDefaults.standard.integer(
                forKey: "temperatureUnit"
            ) == 1

            let displayValue = fahrenheit
                ? celsiusValue * 9 / 5 + 32
                : celsiusValue

            let text = "\(Int(displayValue.rounded()))°"

            (text as NSString).draw(
                at: CGPoint(x: 1, y: y - 7),
                withAttributes: attributes
            )
        }

        func point(for index: Int) -> CGPoint {
            let denominator = max(hours.count - 1, 1)

            let x = plot.minX
                + plot.width * CGFloat(index) / CGFloat(denominator)

            let fraction = (hours[index].temp_c - lower) / range
            let y = plot.maxY - plot.height * CGFloat(fraction)

            return CGPoint(x: x, y: y)
        }

        let linePath = UIBezierPath()
        linePath.move(to: point(for: 0))

        for index in 1..<hours.count {
            linePath.addLine(to: point(for: index))
        }

        let areaPath = UIBezierPath(cgPath: linePath.cgPath)
        areaPath.addLine(
            to: CGPoint(x: plot.maxX, y: plot.maxY)
        )
        areaPath.addLine(
            to: CGPoint(x: plot.minX, y: plot.maxY)
        )
        areaPath.close()

        UIColor.systemBlue.withAlphaComponent(0.10).setFill()
        areaPath.fill()

        UIColor.systemBlue.setStroke()
        linePath.lineWidth = 2.5
        linePath.lineCapStyle = .round
        linePath.lineJoinStyle = .round
        linePath.stroke()

        for index in hours.indices {
            let point = point(for: index)

            let dot = UIBezierPath(
                ovalIn: CGRect(
                    x: point.x - 3,
                    y: point.y - 3,
                    width: 6,
                    height: 6
                )
            )

            UIColor.systemBlue.setFill()
            dot.fill()
        }

        let labelStep = max(1, hours.count / 6)

        var indices = Array(
            stride(
                from: 0,
                to: hours.count,
                by: labelStep
            )
        )

        if let last = hours.indices.last,
           indices.last != last {
            indices.append(last)
        }

        for index in indices {
            let time = String(hours[index].time.suffix(5))
            let size = (time as NSString).size(
                withAttributes: attributes
            )

            let x = point(for: index).x - size.width / 2

            (time as NSString).draw(
                at: CGPoint(
                    x: min(
                        max(x, plot.minX),
                        plot.maxX - size.width
                    ),
                    y: plot.maxY + 8
                ),
                withAttributes: attributes
            )
        }
    }
}
