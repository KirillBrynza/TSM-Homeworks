import UIKit

final class WeatherTodayViewController: UIViewController {
    
    
    private let weatherService = WeatherService()
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let cityLabel = UILabel()
    private let dateLabel = UILabel()
    private let weatherIcon = UIImageView()
    private let temperatureLabel = UILabel()
    private let conditionLabel = UILabel()
    private let feelsLikeLabel = UILabel()
    
    private let detailsScrollView = UIScrollView()
    private let detailsStack = UIStackView()
    
    private let hourlyScrollView = UIScrollView()
    private let hourlyStack = UIStackView()
    
    private let dailyStack = UIStackView()
    
    private var cachedWeather: ForecastWeatherResponse?
    private var loadedForecastDays: [ForecastDay] = []
    private var requestedCity = ""
    private var weatherTask: Task<Void, Never>?
    
    private let settingsNotification =
    Notification.Name("WeatherPreferencesDidChange")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Погода"
        view.backgroundColor = .systemBackground
        
        setupNavigation()
        setupUI()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsDidChange),
            name: settingsNotification,
            object: nil
        )
        
        updateSelectedCity()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let selectedCity = UserDefaults.standard.string(
            forKey: "selectedCity"
        ) ?? "Минск"
        
        if selectedCity != requestedCity {
            loadWeather(for: selectedCity)
        }
    }
    
    deinit {
        weatherTask?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(openSearch)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshWeather)
        )
    }
    
    @objc private func openSearch() {
        let searchVC = SearchViewController()
        navigationController?.pushViewController(
            searchVC,
            animated: true
        )
    }
    
    @objc private func refreshWeather() {
        let city = UserDefaults.standard.string(
            forKey: "selectedCity"
        ) ?? requestedCity
        
        loadWeather(for: city.isEmpty ? "Минск" : city)
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentStack.axis = .vertical
        contentStack.alignment = .fill
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
                constant: 16
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                constant: -16
            ),
            contentStack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -24
            ),
            contentStack.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -32
            )
        ])
        
        cityLabel.font = .systemFont(
            ofSize: 28,
            weight: .semibold
        )
        cityLabel.textAlignment = .center
        cityLabel.numberOfLines = 0
        
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .center
        
        weatherIcon.contentMode = .scaleAspectFit
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        
        temperatureLabel.font = .systemFont(
            ofSize: 52,
            weight: .light
        )
        temperatureLabel.textAlignment = .center
        temperatureLabel.adjustsFontSizeToFitWidth = true
        
        conditionLabel.font = .systemFont(
            ofSize: 18,
            weight: .medium
        )
        conditionLabel.textAlignment = .center
        conditionLabel.numberOfLines = 0
        
        feelsLikeLabel.font = .systemFont(ofSize: 15)
        feelsLikeLabel.textColor = .secondaryLabel
        feelsLikeLabel.textAlignment = .center
        
        let currentStack = UIStackView(
            arrangedSubviews: [
                weatherIcon,
                temperatureLabel,
                conditionLabel,
                feelsLikeLabel
            ]
        )
        currentStack.axis = .vertical
        currentStack.alignment = .center
        currentStack.spacing = 8
        
        NSLayoutConstraint.activate([
            weatherIcon.widthAnchor.constraint(equalToConstant: 100),
            weatherIcon.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        contentStack.addArrangedSubview(cityLabel)
        contentStack.addArrangedSubview(dateLabel)
        contentStack.addArrangedSubview(currentStack)
        
        contentStack.addArrangedSubview(
            makeSectionTitle("Текущие показатели")
        )
        
        setupDetailsScrollView()
        contentStack.addArrangedSubview(detailsScrollView)
        
        contentStack.addArrangedSubview(
            makeSectionTitle("Почасовой прогноз")
        )
        
        setupHourlyScrollView()
        contentStack.addArrangedSubview(hourlyScrollView)
        
        contentStack.addArrangedSubview(
            makeSectionTitle("Прогноз на 5 дней")
        )
        
        dailyStack.axis = .vertical
        dailyStack.spacing = 8
        dailyStack.alignment = .fill
        
        contentStack.addArrangedSubview(dailyStack)
    }
    
    private func setupDetailsScrollView() {
        detailsScrollView.showsHorizontalScrollIndicator = false
        
        detailsStack.axis = .horizontal
        detailsStack.spacing = 10
        detailsStack.alignment = .fill
        detailsStack.translatesAutoresizingMaskIntoConstraints = false
        
        detailsScrollView.translatesAutoresizingMaskIntoConstraints = false
        detailsScrollView.addSubview(detailsStack)
        
        NSLayoutConstraint.activate([
            detailsStack.topAnchor.constraint(
                equalTo: detailsScrollView.contentLayoutGuide.topAnchor
            ),
            detailsStack.leadingAnchor.constraint(
                equalTo: detailsScrollView.contentLayoutGuide.leadingAnchor
            ),
            detailsStack.trailingAnchor.constraint(
                equalTo: detailsScrollView.contentLayoutGuide.trailingAnchor
            ),
            detailsStack.bottomAnchor.constraint(
                equalTo: detailsScrollView.contentLayoutGuide.bottomAnchor
            ),
            detailsStack.heightAnchor.constraint(
                equalTo: detailsScrollView.frameLayoutGuide.heightAnchor
            ),
            detailsScrollView.heightAnchor.constraint(
                equalToConstant: 112
            )
        ])
    }
    
    private func setupHourlyScrollView() {
        hourlyScrollView.showsHorizontalScrollIndicator = false
        
        hourlyStack.axis = .horizontal
        hourlyStack.spacing = 10
        hourlyStack.alignment = .fill
        hourlyStack.translatesAutoresizingMaskIntoConstraints = false
        
        hourlyScrollView.translatesAutoresizingMaskIntoConstraints = false
        hourlyScrollView.addSubview(hourlyStack)
        
        NSLayoutConstraint.activate([
            hourlyStack.topAnchor.constraint(
                equalTo: hourlyScrollView.contentLayoutGuide.topAnchor
            ),
            hourlyStack.leadingAnchor.constraint(
                equalTo: hourlyScrollView.contentLayoutGuide.leadingAnchor
            ),
            hourlyStack.trailingAnchor.constraint(
                equalTo: hourlyScrollView.contentLayoutGuide.trailingAnchor
            ),
            hourlyStack.bottomAnchor.constraint(
                equalTo: hourlyScrollView.contentLayoutGuide.bottomAnchor
            ),
            hourlyStack.heightAnchor.constraint(
                equalTo: hourlyScrollView.frameLayoutGuide.heightAnchor
            ),
            hourlyScrollView.heightAnchor.constraint(
                equalToConstant: 145
            )
        ])
    }
    
    private func makeSectionTitle(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(
            ofSize: 20,
            weight: .semibold
        )
        return label
    }
    
    private func updateSelectedCity() {
        let city = UserDefaults.standard.string(
            forKey: "selectedCity"
        ) ?? "Минск"
        
        loadWeather(for: city)
    }
    
    private func loadWeather(for city: String) {
        requestedCity = city
        weatherTask?.cancel()
        
        weatherTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let weather = try await weatherService.fetchForecast(
                    for: city
                )
                
                guard !Task.isCancelled else { return }
                
                cachedWeather = weather
                renderWeather(weather)
                
            } catch {
                guard !Task.isCancelled else { return }
                
                showError(error.localizedDescription)
            }
        }
    }
    
    private func renderWeather(_ weather: ForecastWeatherResponse) {
        cityLabel.text = weather.location.name
        
        dateLabel.text = formattedLocalDate(
            weather.location.localtime
        )
        
        temperatureLabel.text = temperatureText(
            weather.current.temp_c
        )
        
        conditionLabel.text = weather.current.condition.text
        
        feelsLikeLabel.text =
        "Ощущается как \(temperatureText(weather.current.feelslike_c))"
        
        loadWeatherIcon(
            weather.current.condition.icon,
            into: weatherIcon
        )
        
        updateCurrentMetrics(weather.current)
        
        let localDate = String(
            weather.location.localtime.prefix(10)
        )
        
        let today = weather.forecast.forecastday.first {
            $0.date == localDate
        } ?? weather.forecast.forecastday.first
        
        if let today {
            updateHourlyForecast(today.hour)
        }
        
        updateDailyForecast(weather.forecast.forecastday)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Не удалось загрузить погоду",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "Повторить", style: .default) {
                [weak self] _ in
                self?.refreshWeather()
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Закрыть", style: .cancel)
        )
        
        present(alert, animated: true)
    }
    
    private func updateCurrentMetrics(_ current: CurrentWeather) {
        clearStack(detailsStack)
        
        let pressure = current.pressure_mb * 0.750061683
        
        let metrics: [(String, String, String)] = [
            (
                "Влажность",
                "\(current.humidity)%",
                "humidity.fill"
            ),
            (
                "Ветер",
                windSpeedText(fromKph: current.wind_kph),
                "wind"
            ),
            (
                "Давление",
                "\(Int(pressure.rounded())) мм",
                "gauge.with.needle"
            ),
            (
                "УФ-индекс",
                formattedNumber(current.uv),
                "sun.max.fill"
            )
        ]
        
        for metric in metrics {
            detailsStack.addArrangedSubview(
                makeMetricCard(
                    title: metric.0,
                    value: metric.1,
                    symbol: metric.2
                )
            )
        }
    }
    
    private func makeMetricCard(
        title: String,
        value: String,
        symbol: String
    ) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 14
        card.widthAnchor.constraint(
            equalToConstant: 132
        ).isActive = true
        
        let icon = UIImageView(
            image: UIImage(systemName: symbol)
        )
        icon.tintColor = .secondaryLabel
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .secondaryLabel
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.numberOfLines = 1
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(
            ofSize: 16,
            weight: .semibold
        )
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7
        
        let stack = UIStackView(
            arrangedSubviews: [
                icon,
                titleLabel,
                valueLabel
            ]
        )
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(
                equalTo: card.topAnchor,
                constant: 10
            ),
            stack.leadingAnchor.constraint(
                equalTo: card.leadingAnchor,
                constant: 10
            ),
            stack.trailingAnchor.constraint(
                equalTo: card.trailingAnchor,
                constant: -10
            ),
            stack.bottomAnchor.constraint(
                lessThanOrEqualTo: card.bottomAnchor,
                constant: -8
            ),
            icon.widthAnchor.constraint(equalToConstant: 19),
            icon.heightAnchor.constraint(equalToConstant: 19)
        ])
        
        return card
    }
    
    private func updateHourlyForecast(_ hours: [HourlyForecast]) {
        clearStack(hourlyStack)
        
        for hour in hours {
            hourlyStack.addArrangedSubview(
                makeHourlyItem(hour)
            )
        }
    }
    
    private func makeHourlyItem(_ hour: HourlyForecast) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 14
        card.widthAnchor.constraint(
            equalToConstant: 82
        ).isActive = true
        
        let timeLabel = UILabel()
        timeLabel.text = String(hour.time.suffix(5))
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textAlignment = .center
        
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let temperature = UILabel()
        temperature.text = temperatureText(hour.temp_c)
        temperature.font = .systemFont(
            ofSize: 16,
            weight: .semibold
        )
        temperature.textAlignment = .center
        
        let stack = UIStackView(
            arrangedSubviews: [
                timeLabel,
                icon,
                temperature
            ]
        )
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(
                equalTo: card.topAnchor,
                constant: 10
            ),
            stack.leadingAnchor.constraint(
                equalTo: card.leadingAnchor,
                constant: 4
            ),
            stack.trailingAnchor.constraint(
                equalTo: card.trailingAnchor,
                constant: -4
            ),
            stack.bottomAnchor.constraint(
                lessThanOrEqualTo: card.bottomAnchor,
                constant: -8
            ),
            icon.widthAnchor.constraint(equalToConstant: 38),
            icon.heightAnchor.constraint(equalToConstant: 38)
        ])
        
        loadWeatherIcon(hour.condition.icon, into: icon)
        
        return card
    }
    
    private func updateDailyForecast(_ days: [ForecastDay]) {
        loadedForecastDays = days
        clearStack(dailyStack)
        
        for (index, day) in days.enumerated() {
            let row = UIView()
            row.backgroundColor = .secondarySystemBackground
            row.layer.cornerRadius = 12
            row.tag = index
            row.isUserInteractionEnabled = true
            row.translatesAutoresizingMaskIntoConstraints = false
            
            let dateLabel = UILabel()
            dateLabel.text = forecastDateTitle(day.date)
            dateLabel.font = .systemFont(
                ofSize: 14,
                weight: .medium
            )
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let icon = UIImageView()
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            
            let temperatures = UILabel()
            temperatures.text =
            "\(temperatureText(day.day.maxtemp_c)) / " +
            "\(temperatureText(day.day.mintemp_c))"
            temperatures.font = .systemFont(
                ofSize: 14,
                weight: .semibold
            )
            temperatures.textAlignment = .right
            temperatures.adjustsFontSizeToFitWidth = true
            temperatures.minimumScaleFactor = 0.7
            temperatures.translatesAutoresizingMaskIntoConstraints = false
            
            let arrow = UIImageView(
                image: UIImage(systemName: "chevron.right")
            )
            arrow.tintColor = .tertiaryLabel
            arrow.contentMode = .scaleAspectFit
            arrow.translatesAutoresizingMaskIntoConstraints = false
            
            row.addSubview(dateLabel)
            row.addSubview(icon)
            row.addSubview(temperatures)
            row.addSubview(arrow)
            
            NSLayoutConstraint.activate([
                row.heightAnchor.constraint(equalToConstant: 58),
                
                dateLabel.leadingAnchor.constraint(
                    equalTo: row.leadingAnchor,
                    constant: 12
                ),
                dateLabel.centerYAnchor.constraint(
                    equalTo: row.centerYAnchor
                ),
                dateLabel.widthAnchor.constraint(
                    equalToConstant: 82
                ),
                
                icon.leadingAnchor.constraint(
                    equalTo: dateLabel.trailingAnchor,
                    constant: 5
                ),
                icon.centerYAnchor.constraint(
                    equalTo: row.centerYAnchor
                ),
                icon.widthAnchor.constraint(equalToConstant: 34),
                icon.heightAnchor.constraint(equalToConstant: 34),
                
                arrow.trailingAnchor.constraint(
                    equalTo: row.trailingAnchor,
                    constant: -12
                ),
                arrow.centerYAnchor.constraint(
                    equalTo: row.centerYAnchor
                ),
                arrow.widthAnchor.constraint(equalToConstant: 10),
                arrow.heightAnchor.constraint(equalToConstant: 14),
                
                temperatures.leadingAnchor.constraint(
                    greaterThanOrEqualTo: icon.trailingAnchor,
                    constant: 6
                ),
                temperatures.trailingAnchor.constraint(
                    equalTo: arrow.leadingAnchor,
                    constant: -8
                ),
                temperatures.centerYAnchor.constraint(
                    equalTo: row.centerYAnchor
                )
            ])
            
            loadWeatherIcon(day.day.condition.icon, into: icon)
            
            let tap = UITapGestureRecognizer(
                target: self,
                action: #selector(openForecastDay(_:))
            )
            row.addGestureRecognizer(tap)
            
            dailyStack.addArrangedSubview(row)
        }
    }
    
    @objc private func openForecastDay(
        _ recognizer: UITapGestureRecognizer
    ) {
        guard let row = recognizer.view,
              loadedForecastDays.indices.contains(row.tag) else {
            return
        }
        
        let city = cachedWeather?.location.name ?? requestedCity
        let day = loadedForecastDays[row.tag]
        
        let detailVC = ForecastDetailViewController(
            city: city,
            forecastDay: day
        )
        
        navigationController?.pushViewController(
            detailVC,
            animated: true
        )
    }
    
    @objc private func settingsDidChange() {
        guard let cachedWeather else {
            return
        }
        
        renderWeather(cachedWeather)
    }
    
    private func temperatureText(_ celsius: Double) -> String {
        let fahrenheit = UserDefaults.standard.integer(
            forKey: "temperatureUnit"
        ) == 1
        
        let value = fahrenheit
        ? celsius * 9 / 5 + 32
        : celsius
        
        let unit = fahrenheit ? "°F" : "°C"
        
        return "\(Int(value.rounded()))\(unit)"
    }
    
    private func windSpeedText(fromKph kph: Double) -> String {
        let kilometersPerHour = UserDefaults.standard.integer(
            forKey: "windSpeedUnit"
        ) == 1
        
        if kilometersPerHour {
            return "\(Int(kph.rounded())) км/ч"
        }
        
        return String(format: "%.1f м/с", kph / 3.6)
    }
    
    // MARK: - Formatting
    
    private func formattedLocalDate(_ value: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        guard let date = formatter.date(from: value) else {
            return value
        }
        
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        
        return formatter.string(from: date)
    }
    
    private func forecastDateTitle(_ value: String) -> String {
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        input.timeZone = TimeZone(secondsFromGMT: 0)
        input.dateFormat = "yyyy-MM-dd"
        
        guard let date = input.date(from: value) else {
            return value
        }
        
        let output = DateFormatter()
        output.locale = Locale(identifier: "ru_RU")
        output.timeZone = TimeZone(secondsFromGMT: 0)
        
        if Calendar(identifier: .gregorian).isDateInToday(date) {
            return "Сегодня"
        }
        
        output.dateFormat = "EE, d MMM"
        return output.string(from: date)
    }
    
    private func formattedNumber(_ value: Double) -> String {
        if value.rounded() == value {
            return "\(Int(value))"
        }
        
        return String(format: "%.1f", value)
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
    
    private func clearStack(_ stack: UIStackView) {
        for item in stack.arrangedSubviews {
            stack.removeArrangedSubview(item)
            item.removeFromSuperview()
        }
    }
}
