import Foundation

extension URL {
    
    static func urlForWeatherAPI(city: String) -> URL? {
        
        return URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=8861e65927df02c1122b1fefb6acbd14")
        
    }
    
}
