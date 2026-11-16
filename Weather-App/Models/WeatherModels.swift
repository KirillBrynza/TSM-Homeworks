import Foundation

struct WeatherResponse: Decodable {
    let location: WeatherLocation
    let current: CurrentWeather
}

struct ForecastWeatherResponse: Decodable {
    let location: WeatherLocation
    let current: CurrentWeather
    let forecast: ForecastData
}

struct WeatherLocation: Decodable {
    let name: String
    let localtime: String
}

struct CurrentWeather: Decodable {
    let temp_c: Double
    let feelslike_c: Double
    let humidity: Int
    let wind_kph: Double
    let pressure_mb: Double
    let uv: Double
    let condition: WeatherCondition
    let is_day: Int
}

struct WeatherCondition: Decodable {
    let text: String
    let icon: String
    let code: Int
}

struct ForecastData: Decodable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Decodable {
    let date: String
    let day: ForecastDayInfo
    let astro: ForecastAstro
    let hour: [HourlyForecast]
}

struct ForecastDayInfo: Decodable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let daily_chance_of_rain: Int
    let condition: WeatherCondition
    let uv: Double
}

struct ForecastAstro: Decodable {
    let sunrise: String
    let sunset: String
}

struct HourlyForecast: Decodable {
    let time: String
    let temp_c: Double
    let condition: WeatherCondition
    let chance_of_rain: Int
    let wind_kph: Double
    let humidity: Int
    let vis_km: Double?
    let pressure_mb: Double?
}
