import Foundation

struct WeatherWrapper: Decodable {
    let main: Weather
}

extension WeatherWrapper {
    
    static var empty: WeatherWrapper {
        return WeatherWrapper(main: Weather(temp: 0, humidity: 0))
    }
}

struct Weather: Decodable {
    let temp: Double
    let humidity: Double
}

