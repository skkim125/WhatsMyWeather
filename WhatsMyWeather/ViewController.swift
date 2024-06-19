//
//  ViewController.swift
//  WhatsMyWeather
//
//  Created by 김상규 on 6/19/24.
//

import UIKit
import Alamofire
import SnapKit
import Kingfisher
import CoreLocation

class ViewController: UIViewController {
    let locationManager = CLLocationManager()
    var openWeather: OpenWeather?
    
    var weatherImage: String {
        guard let ow = self.openWeather else {
            return ""
        }
        return "https://openweathermap.org/img/wn/\(ow.weather.first!.icon)@2x.png"
    }
    
    lazy var myLocationLabel = {
       let label = UILabel()
        label.font = UIFont.hanbit!
        label.textAlignment = .center
        
        return label
    }()

    lazy var weatherInfoStackView = {
        let sv = UIStackView(arrangedSubviews: [weatherImageView, whatsWeatherLabel])
        sv.axis = .vertical
        sv.spacing = 0
        sv.layer.cornerRadius = 12
//        sv.backgroundColor = .white.withAlphaComponent(0.3)
        
        return sv
    }()
    
    lazy var weatherImageView = {
       let imgView = UIImageView()
        imgView.backgroundColor = .white
        imgView.layer.cornerRadius = 12
        imgView.clipsToBounds = true
        
        return imgView
    }()
    
    
    lazy var whatsWeatherLabel = UILabel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.contents = #imageLiteral(resourceName: "gradationImg").cgImage
        locationManager.delegate = self
        
        
        configureHierarchy()
        checkDeviceLocationAuthorization()
        configureLayout()
    }
    
    func configureHierarchy() {
        view.addSubview(myLocationLabel)
        view.addSubview(weatherInfoStackView)
    }
    
    
    func configureLayout() {
        
        weatherInfoStackView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(myLocationLabel).offset(40)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.height.equalTo(200)
        }
        
        weatherImageView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(weatherInfoStackView.snp.top).inset(20)
            make.horizontalEdges.equalTo(weatherInfoStackView.snp.horizontalEdges).inset(80)
            make.height.equalTo(weatherImageView.snp.width)
        }
        
        whatsWeatherLabel.snp.makeConstraints { make in
            make.bottom.equalTo(weatherInfoStackView.snp.bottom).inset(20)
            make.width.equalTo(weatherImageView.snp.width)
            make.centerX.equalTo(weatherInfoStackView)
        }
        
        myLocationLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.height.equalTo(30)
            make.horizontalEdges.equalTo(weatherInfoStackView.snp.horizontalEdges)
        }
    }
    
    func configureUI(weather: OpenWeather) {
        myLocationLabel.text = weather.name
        
        
        let url = URL(string: weatherImage)!
        weatherImageView.kf.setImage(with: url)
        weatherImageView.contentMode = .scaleAspectFit
        
        
        if let w = weather.weather.first {
            whatsWeatherLabel.text = w.description
            whatsWeatherLabel.textColor = .darkGray
            whatsWeatherLabel.textAlignment = .center
            whatsWeatherLabel.font = UIFont.hanbit!
        }
    }
    
    func callRequest(lat: Double, lon: Double) {
        
        let url = OpenWeatherAPIKey.url
        
        let param: Parameters = [
            "lat": "\(lat)",
            "lon": "\(lon)",
            "appid": "\(OpenWeatherAPIKey.key)",
            "exclude": "current",
            "units": "metric",
            "lang": "kr"
        ]
        
        AF.request(url, parameters: param).responseDecodable(of: OpenWeather.self) { response in
            switch response.result {
            case .success(let value):
                print(value)
                self.openWeather = value
                
                if let ow = self.openWeather {
                    self.configureUI(weather: ow)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func checkDeviceLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            checkUserCurrentLocationAuthorization()
        } else {
            print("디바이스 위치 권한을 허용해주세요")
        }
    }
    
    func checkUserCurrentLocationAuthorization() {
        var status: CLAuthorizationStatus
        
        if #available(iOS 14, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            print("")
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            print(status)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        
        if let coordinte = locations.last?.coordinate {
            callRequest(lat: coordinte.latitude, lon: coordinte.longitude)
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviceLocationAuthorization()
    }
}


extension UIFont {
    static let hanbit = UIFont(name: "KCCHanbit", size: 20)
}
