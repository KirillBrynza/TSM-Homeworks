import UIKit
import MapKit
import CoreLocation

private final class WeatherCityAnnotation: MKPointAnnotation {
    var temperatureC: Double?
    var conditionText = ""
}

final class WeatherMapViewController: UIViewController,
                                      MKMapViewDelegate,
                                      CLLocationManagerDelegate {
    
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherService()
    
    private let locationButton = UIButton(type: .system)
    
    private let legendView = UIView()
    private let gradientView = UIView()
    private var gradientLayer: CAGradientLayer?
    
    private var weatherTask: Task<Void, Never>?
    
    private let settingsNotification =
    Notification.Name("WeatherPreferencesDidChange")
    
    private let cities: [(name: String, coordinate: CLLocationCoordinate2D)] = [
        ("Минск", CLLocationCoordinate2D(latitude: 53.9006, longitude: 27.5590)),
        ("Гомель", CLLocationCoordinate2D(latitude: 52.4345, longitude: 30.9754)),
        ("Могилёв", CLLocationCoordinate2D(latitude: 53.9007, longitude: 30.3314)),
        ("Витебск", CLLocationCoordinate2D(latitude: 55.1904, longitude: 30.2049)),
        ("Гродно", CLLocationCoordinate2D(latitude: 53.6694, longitude: 23.8131)),
        ("Брест", CLLocationCoordinate2D(latitude: 52.0976, longitude: 23.7341)),
        ("Бобруйск", CLLocationCoordinate2D(latitude: 53.1384, longitude: 29.2214)),
        ("Барановичи", CLLocationCoordinate2D(latitude: 53.1327, longitude: 26.0139)),
        ("Борисов", CLLocationCoordinate2D(latitude: 54.2279, longitude: 28.5050)),
        ("Пинск", CLLocationCoordinate2D(latitude: 52.1153, longitude: 26.1024)),
        ("Орша", CLLocationCoordinate2D(latitude: 54.5081, longitude: 30.4172)),
        ("Мозырь", CLLocationCoordinate2D(latitude: 52.0495, longitude: 29.2456)),
        ("Солигорск", CLLocationCoordinate2D(latitude: 52.7876, longitude: 27.5415)),
        ("Новополоцк", CLLocationCoordinate2D(latitude: 55.5318, longitude: 28.5987)),
        ("Лида", CLLocationCoordinate2D(latitude: 53.8833, longitude: 25.2997)),
        ("Полоцк", CLLocationCoordinate2D(latitude: 55.4859, longitude: 28.7731)),
        ("Молодечно", CLLocationCoordinate2D(latitude: 54.3167, longitude: 26.8500)),
        ("Жлобин", CLLocationCoordinate2D(latitude: 52.8926, longitude: 30.0240)),
        ("Светлогорск", CLLocationCoordinate2D(latitude: 52.6333, longitude: 29.7333)),
        ("Речица", CLLocationCoordinate2D(latitude: 52.3667, longitude: 30.3917))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Карта"
        view.backgroundColor = .systemBackground
        
        setupMap()
        setupLocationManager()
        setupLocationButton()
        setupLegend()
        addCityAnnotations()
        loadCityTemperatures()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(mapSettingsDidChange),
            name: settingsNotification,
            object: nil
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = gradientView.bounds
    }
    
    deinit {
        weatherTask?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupMap() {
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsUserLocation = true
        mapView.pointOfInterestFilter = .excludingAll
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            mapView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            mapView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            mapView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 53.7,
                longitude: 27.9
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 5.0,
                longitudeDelta: 7.0
            )
        )
        
        mapView.setRegion(region, animated: false)
    }
    
    private func addCityAnnotations() {
        for city in cities {
            let annotation = WeatherCityAnnotation()
            annotation.title = city.name
            annotation.subtitle = "Загружаем погоду…"
            annotation.coordinate = city.coordinate
            
            mapView.addAnnotation(annotation)
        }
    }
    
    private func loadCityTemperatures() {
        weatherTask?.cancel()
        
        weatherTask = Task { [weak self] in
            guard let self else { return }
            
            for city in cities {
                guard !Task.isCancelled else { return }
                
                do {
                    let weather = try await weatherService.fetchWeather(
                        for: city.name
                    )
                    
                    guard !Task.isCancelled else { return }
                    
                    let temperatureC = weather.current.temp_c
                    let condition = weather.current.condition.text
                    
                    await MainActor.run {
                        guard let annotation = self.mapView.annotations
                            .compactMap({ $0 as? WeatherCityAnnotation })
                            .first(where: { $0.title == city.name })
                        else {
                            return
                        }
                        
                        annotation.temperatureC = temperatureC
                        annotation.conditionText = condition
                        
                        self.updateAnnotationSubtitle(annotation)
                        self.updateMarker(for: annotation)
                    }
                    
                } catch {
                    guard !Task.isCancelled else { return }
                    
                    await MainActor.run {
                        let annotation = self.mapView.annotations
                            .compactMap { $0 as? WeatherCityAnnotation }
                            .first { $0.title == city.name }
                        
                        annotation?.subtitle = "Погода недоступна"
                    }
                }
            }
        }
    }
    
    private func formattedTemperature(_ celsius: Double) -> String {
        let isFahrenheit = UserDefaults.standard.integer(
            forKey: "temperatureUnit"
        ) == 1
        
        let value = isFahrenheit
        ? celsius * 9 / 5 + 32
        : celsius
        
        let unit = isFahrenheit ? "°F" : "°C"
        
        return "\(Int(value.rounded()))\(unit)"
    }
    
    private func markerTemperatureText(_ celsius: Double) -> String {
        let isFahrenheit = UserDefaults.standard.integer(
            forKey: "temperatureUnit"
        ) == 1
        
        let value = isFahrenheit
        ? celsius * 9 / 5 + 32
        : celsius
        
        return "\(Int(value.rounded()))°"
    }
    
    private func colorForTemperature(_ celsius: Double) -> UIColor {
        switch celsius {
        case ..<(-10):
            return .systemIndigo
        case -10..<0:
            return .systemBlue
        case 0..<10:
            return .systemTeal
        case 10..<20:
            return .systemGreen
        case 20..<30:
            return .systemOrange
        default:
            return .systemRed
        }
    }
    
    private func updateAnnotationSubtitle(
        _ annotation: WeatherCityAnnotation
    ) {
        guard let temperatureC = annotation.temperatureC else {
            return
        }
        
        annotation.subtitle =
        "\(formattedTemperature(temperatureC)) · " +
        annotation.conditionText
    }
    
    private func updateMarker(
        for annotation: WeatherCityAnnotation
    ) {
        guard let temperatureC = annotation.temperatureC,
              let marker = mapView.view(
                for: annotation
              ) as? MKMarkerAnnotationView else {
            return
        }
        
        marker.markerTintColor = colorForTemperature(temperatureC)
        marker.glyphText = markerTemperatureText(temperatureC)
        marker.glyphImage = nil
    }
    
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        guard let cityAnnotation = annotation as? WeatherCityAnnotation else {
            return nil
        }
        
        let identifier = "WeatherCityMarker"
        
        let marker = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier
        ) as? MKMarkerAnnotationView
        ?? MKMarkerAnnotationView(
            annotation: cityAnnotation,
            reuseIdentifier: identifier
        )
        
        marker.annotation = cityAnnotation
        marker.canShowCallout = true
        
        if let temperatureC = cityAnnotation.temperatureC {
            marker.markerTintColor = colorForTemperature(temperatureC)
            marker.glyphText = markerTemperatureText(temperatureC)
            marker.glyphImage = nil
        } else {
            marker.markerTintColor = .systemBlue
            marker.glyphText = nil
            marker.glyphImage = UIImage(
                systemName: "thermometer.medium"
            )
        }
        
        return marker
    }
    
    func mapView(
        _ mapView: MKMapView,
        didSelect view: MKAnnotationView
    ) {
        guard let annotation = view.annotation
                as? WeatherCityAnnotation,
              let city = annotation.title else {
            return
        }
        
        UserDefaults.standard.set(
            city,
            forKey: "selectedCity"
        )
    }
    
    @objc private func mapSettingsDidChange() {
        for annotation in mapView.annotations {
            guard let cityAnnotation = annotation
                    as? WeatherCityAnnotation else {
                continue
            }
            
            updateAnnotationSubtitle(cityAnnotation)
            updateMarker(for: cityAnnotation)
        }
    }
    
    private func setupLegend() {
        legendView.backgroundColor = .secondarySystemBackground
        legendView.layer.cornerRadius = 14
        legendView.layer.borderWidth = 0.5
        legendView.layer.borderColor = UIColor.separator.cgColor
        legendView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Цветовая шкала, °C"
        titleLabel.font = .systemFont(
            ofSize: 13,
            weight: .semibold
        )
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        gradientView.layer.cornerRadius = 4
        gradientView.clipsToBounds = true
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemIndigo.cgColor,
            UIColor.systemBlue.cgColor,
            UIColor.systemTeal.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemOrange.cgColor,
            UIColor.systemRed.cgColor
        ]
        gradient.locations = [0.0, 0.18, 0.36, 0.56, 0.78, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        
        gradientView.layer.addSublayer(gradient)
        gradientLayer = gradient
        
        let labelsStack = UIStackView()
        labelsStack.axis = .horizontal
        labelsStack.distribution = .equalSpacing
        labelsStack.alignment = .center
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        
        ["−10°", "0°", "10°", "20°", "30°+"].forEach { text in
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 10)
            label.textColor = .secondaryLabel
            labelsStack.addArrangedSubview(label)
        }
        
        legendView.addSubview(titleLabel)
        legendView.addSubview(gradientView)
        legendView.addSubview(labelsStack)
        
        view.addSubview(legendView)
        
        NSLayoutConstraint.activate([
            legendView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 14
            ),
            legendView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            legendView.widthAnchor.constraint(equalToConstant: 235),
            
            titleLabel.topAnchor.constraint(
                equalTo: legendView.topAnchor,
                constant: 10
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: legendView.leadingAnchor,
                constant: 12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: legendView.trailingAnchor,
                constant: -12
            ),
            
            gradientView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),
            gradientView.leadingAnchor.constraint(
                equalTo: legendView.leadingAnchor,
                constant: 12
            ),
            gradientView.trailingAnchor.constraint(
                equalTo: legendView.trailingAnchor,
                constant: -12
            ),
            gradientView.heightAnchor.constraint(equalToConstant: 10),
            
            labelsStack.topAnchor.constraint(
                equalTo: gradientView.bottomAnchor,
                constant: 5
            ),
            labelsStack.leadingAnchor.constraint(
                equalTo: legendView.leadingAnchor,
                constant: 12
            ),
            labelsStack.trailingAnchor.constraint(
                equalTo: legendView.trailingAnchor,
                constant: -12
            ),
            labelsStack.bottomAnchor.constraint(
                equalTo: legendView.bottomAnchor,
                constant: -9
            )
        ])
    }
    
    private func setupLocationButton() {
        locationButton.setImage(
            UIImage(systemName: "location.fill"),
            for: .normal
        )
        
        locationButton.tintColor = .label
        locationButton.backgroundColor = .secondarySystemBackground
        locationButton.layer.cornerRadius = 25
        
        locationButton.layer.shadowColor = UIColor.black.cgColor
        locationButton.layer.shadowOpacity = 0.15
        locationButton.layer.shadowRadius = 5
        locationButton.layer.shadowOffset = CGSize(
            width: 0,
            height: 2
        )
        
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        
        locationButton.addTarget(
            self,
            action: #selector(centerOnUserLocation),
            for: .touchUpInside
        )
        
        view.addSubview(locationButton)
        
        NSLayoutConstraint.activate([
            locationButton.widthAnchor.constraint(equalToConstant: 50),
            locationButton.heightAnchor.constraint(equalToConstant: 50),
            locationButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -18
            ),
            locationButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -18
            )
        ])
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    @objc private func centerOnUserLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            
        case .denied, .restricted:
            showLocationSettingsAlert()
            
        @unknown default:
            break
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else {
            return
        }
        
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.5,
                longitudeDelta: 0.5
            )
        )
        
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        let alert = UIAlertController(
            title: "Не удалось определить местоположение",
            message: "Проверь разрешение на геолокацию и попробуй ещё раз.",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "ОК", style: .default)
        )
        
        present(alert, animated: true)
    }
    
    private func showLocationSettingsAlert() {
        let alert = UIAlertController(
            title: "Доступ к местоположению выключен",
            message: "Разреши доступ к геолокации в настройках iPhone, чтобы центрировать карту.",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "Понятно", style: .default)
        )
        
        present(alert, animated: true)
    }
}
