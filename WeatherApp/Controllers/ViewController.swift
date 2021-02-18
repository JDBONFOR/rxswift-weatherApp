import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    // MARK: - Vars
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

}

// MARK: - Private Methods
private extension ViewController {
    
    func setupUI() {
        
        // Subscribe textfield write and execute when search button is pressed
        cityNameTextField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .map { self.cityNameTextField.text }
            .subscribe(onNext: { city in
                
                if let city = city {
                    if city.isEmpty {
                        self.displayWeather(nil)
                    } else {
                        self.fetchData(by: city)
                    }
                }
                
            }).disposed(by: disposeBag)
        
        // Subscribe textfield write all changes
//        cityNameTextField.rx.value
//            .subscribe(onNext: { city in
//
//                if let city = city {
//                    if city.isEmpty {
//                        self.displayWeather(nil)
//                    } else {
//                        self.fetchData(by: city)
//                    }
//                }
//
//            }).disposed(by: disposeBag)
        
    }
    
    // MARK: - FetchData normally
    func fetchData(by city: String) {
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let url = URL.urlForWeatherAPI(city: cityEncoded) else { return }
        
        let resource = Resource<WeatherWrapper>(url: url)
        
//        Old version without error managing
//        URLRequest.load(resource: resource)
//            .observeOn(MainScheduler.instance)
//            .catchErrorJustReturn(WeatherWrapper.empty)
//            .subscribe(onNext: { result in
//
//                let weather = result.main
//                self.displayWeather(weather)
//
//            }).disposed(by: disposeBag)
        
        let search = URLRequest.load(resource: resource)
            .retry(3) // To retry if Internet Connection is unavailable
            .observeOn(MainScheduler.instance)
            .catchError { error in
                print(error.localizedDescription)
                return Observable.just(WeatherWrapper.empty)
            }.asDriver(onErrorJustReturn: WeatherWrapper.empty)
        
        search.map { "\($0.main.temp) F" }
            .drive(self.temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        search.map { "\($0.main.humidity) 💦" }
            .drive(self.humidityLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - FetchData binding Observable
    func fetchDataBindingObservable(by city: String) {
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let url = URL.urlForWeatherAPI(city: cityEncoded) else { return }
        
        let resource = Resource<WeatherWrapper>(url: url)
        
        let search = URLRequest.load(resource: resource)
            .observeOn(MainScheduler.instance)
            .catchErrorJustReturn(WeatherWrapper.empty)
            
        search.map { "\($0.main.temp) F" }
            .bind(to: self.temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        search.map { "\($0.main.humidity) 💦" }
            .bind(to: self.humidityLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - FetchData Driver
    func fetchDataDriver(by city: String) {
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let url = URL.urlForWeatherAPI(city: cityEncoded) else { return }
        
        let resource = Resource<WeatherWrapper>(url: url)
        
        let search = URLRequest.load(resource: resource)
            .observeOn(MainScheduler.instance)
            .asDriver(onErrorJustReturn: WeatherWrapper.empty)
        
        search.map { "\($0.main.temp) F" }
            .drive(self.temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        search.map { "\($0.main.humidity) 💦" }
            .drive(self.humidityLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func displayWeather(_ weather: Weather?) {
        if let weather = weather {
            temperatureLabel.text = "\(weather.humidity) F"
            humidityLabel.text = "\(weather.humidity) 💦"
        } else {
            temperatureLabel.text = "🙈"
            humidityLabel.text = ""
        }
    }
}

// MARK: - Extensions
