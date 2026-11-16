import UIKit

enum WeatherPreferences {
    
    static let didChange = Notification.Name(
        "WeatherPreferencesDidChange"
    )
    
    private static let temperatureKey = "temperatureUnit"
    private static let windKey = "windSpeedUnit"
    private static let themeKey = "appTheme"
    
    static var temperatureUnit: Int {
        get {
            UserDefaults.standard.object(
                forKey: temperatureKey
            ) as? Int ?? 0
        }
        set {
            UserDefaults.standard.set(
                newValue == 1 ? 1 : 0,
                forKey: temperatureKey
            )
        }
    }
    
    static var windUnit: Int {
        get {
            UserDefaults.standard.object(
                forKey: windKey
            ) as? Int ?? 0
        }
        set {
            UserDefaults.standard.set(
                newValue == 1 ? 1 : 0,
                forKey: windKey
            )
        }
    }
    
    static var theme: Int {
        get {
            UserDefaults.standard.object(
                forKey: themeKey
            ) as? Int ?? 0
        }
        set {
            UserDefaults.standard.set(
                min(max(newValue, 0), 2),
                forKey: themeKey
            )
        }
    }
    
    static func temperatureText(_ celsius: Double) -> String {
        let value: Double
        
        if temperatureUnit == 1 {
            value = celsius * 9 / 5 + 32
        } else {
            value = celsius
        }
        
        let unit = temperatureUnit == 1 ? "°F" : "°C"
        
        return "\(Int(value.rounded()))\(unit)"
    }
    
    static func windSpeedText(fromKph kph: Double) -> String {
        if windUnit == 1 {
            return "\(Int(kph.rounded())) км/ч"
        }
        
        return String(format: "%.1f м/с", kph / 3.6)
    }
    
    static func applyTheme() {
        let style: UIUserInterfaceStyle
        
        switch theme {
        case 1:
            style = .light
        case 2:
            style = .dark
        default:
            style = .unspecified
        }
        
        DispatchQueue.main.async {
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else {
                    continue
                }
                
                for window in windowScene.windows {
                    window.overrideUserInterfaceStyle = style
                }
            }
        }
    }
    
    static func notifyChanged() {
        NotificationCenter.default.post(
            name: didChange,
            object: nil
        )
    }
}
