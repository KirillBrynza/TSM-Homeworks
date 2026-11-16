import Foundation

enum WeatherServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Не удалось создать адрес запроса."
        case .invalidResponse:
            return "Сервер вернул некорректный ответ."
        case .apiError(let message):
            return message
        }
    }
}

final class WeatherService {
    // докинуть городов
    private func queryForCity(_ city: String) -> String {
        let cities: [String: String] = [
            "Минск": "Minsk,Belarus",
            "Гомель": "Gomel,Belarus",
            "Могилёв": "Mogilev,Belarus",
            "Могилев": "Mogilev,Belarus",
            "Витебск": "Vitebsk,Belarus",
            "Гродно": "Grodno,Belarus",
            "Брест": "Brest,Belarus",
            "Бобруйск": "Bobruisk,Belarus",
            "Барановичи": "Baranovichi,Belarus",
            "Борисов": "Borisov,Belarus",
            "Пинск": "Pinsk,Belarus",
            "Орша": "Orsha,Belarus",
            "Мозырь": "Mozyr,Belarus",
            "Солигорск": "Soligorsk,Belarus",
            "Новополоцк": "Novopolotsk,Belarus",
            "Лида": "Lida,Belarus",
            "Полоцк": "Polotsk,Belarus",
            "Молодечно": "Molodechno,Belarus",
            "Жлобин": "Zhlobin,Belarus",
            "Светлогорск": "Svetlogorsk,Belarus",
            "Речица": "Rechitsa,Belarus"
        ]
        
        return cities[city] ?? "\(city),Belarus"
    }
    
    private func makeURL(
        endpoint: String,
        city: String,
        days: Int? = nil
    ) throws -> URL {
        guard var components = URLComponents(
            string: "https://api.weatherapi.com/v1/\(endpoint).json"
        ) else {
            throw WeatherServiceError.invalidURL
        }
        
        var items = [
            URLQueryItem(name: "key", value: WeatherAPIKey.value),
            URLQueryItem(name: "q", value: queryForCity(city)),
            URLQueryItem(name: "lang", value: "ru"),
            URLQueryItem(name: "aqi", value: "no")
        ]
        
        if let days {
            items.append(
                URLQueryItem(name: "days", value: "\(days)")
            )
        }
        
        components.queryItems = items
        
        guard let url = components.url else {
            throw WeatherServiceError.invalidURL
        }
        
        return url
    }
    
    private func loadData(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(
            from: url
        )
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherServiceError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let apiError = try? JSONDecoder().decode(
                WeatherAPIErrorResponse.self,
                from: data
            ) {
                throw WeatherServiceError.apiError(
                    apiError.error.message
                )
            }
            
            throw WeatherServiceError.apiError(
                "Ошибка сервера: \(httpResponse.statusCode)"
            )
        }
        
        return data
    }
    
    func fetchWeather(for city: String) async throws -> WeatherResponse {
        let url = try makeURL(
            endpoint: "current",
            city: city
        )
        
        let data = try await loadData(from: url)
        
        return try JSONDecoder().decode(
            WeatherResponse.self,
            from: data
        )
    }
    
    func fetchForecast(
        for city: String
    ) async throws -> ForecastWeatherResponse {
        let url = try makeURL(
            endpoint: "forecast",
            city: city,
            days: 5
        )
        
        let data = try await loadData(from: url)
        
        return try JSONDecoder().decode(
            ForecastWeatherResponse.self,
            from: data
        )
    }
}

private struct WeatherAPIErrorResponse: Decodable {
    let
    error: APIError
    
    struct APIError: Decodable {
        let message: String
    }
}
