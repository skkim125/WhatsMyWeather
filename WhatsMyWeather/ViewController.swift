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
    
    lazy var mapPinImageView = {
       let imgView = UIImageView(image: UIImage(systemName: "location.circle.fill"))
        imgView.tintColor = .purple
        imgView.contentMode = .scaleAspectFit
        
        return imgView
    }()
    
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
        
        return sv
    }()
    
    lazy var weatherImageView = {
       let imgView = UIImageView()
        imgView.backgroundColor = .white
        imgView.layer.cornerRadius = 12
        
        return imgView
    }()
    
    lazy var whatsWeatherLabel = UILabel()
    lazy var weatherDetailInfoCollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        cv.delegate = self
        cv.dataSource = self
        cv.register(WeatherDetailInfoCollectionViewCell.self, forCellWithReuseIdentifier: WeatherDetailInfoCollectionViewCell.id)
        cv.isScrollEnabled = false
        cv.layer.cornerRadius = 12
        cv.backgroundColor = .white.withAlphaComponent(0.3)
        cv.showsHorizontalScrollIndicator = false
        
        return cv
    }()
    
    func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let cellSpacing: CGFloat = 10
        let sectionSpacing: CGFloat = 10
        let width = UIScreen.main.bounds.width - (sectionSpacing*6 + cellSpacing*2)
        
        layout.itemSize = CGSize(width: width/3, height: width/3)
        layout.minimumLineSpacing = cellSpacing
        layout.minimumInteritemSpacing = cellSpacing
        layout.sectionInset = .init(top: sectionSpacing, left: cellSpacing, bottom: sectionSpacing, right: cellSpacing)
        
        return layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.contents = #imageLiteral(resourceName: "gradationImg").cgImage
        locationManager.delegate = self
        
        configureNavigationBar()
        configureHierarchy()
        checkDeviceLocationAuthorization()
        configureLayout()
    }
    
    func configureNavigationBar() {
        navigationItem.title = "What's My Weather"
        let currentButton = UIBarButtonItem(image: UIImage(systemName: "location.fill"), style: .plain, target: self, action: #selector(refreshButtonClicked))
        currentButton.tintColor = .purple
        navigationItem.rightBarButtonItem = currentButton
    }
    
    @objc func refreshButtonClicked() {
        var status: CLAuthorizationStatus
        
        if #available(iOS 14, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .denied:
            let alert = UIAlertController(title: "설정에서 위치 권한 사용에 대하여 허용해주세요", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            let open = UIAlertAction(title: "이동", style: .default)
            
            alert.addAction(cancel)
            alert.addAction(open)
            
            present(alert, animated: true)
        case .authorizedWhenInUse:
            let alert = UIAlertController(title: "새로 고침", message: "새로고침하시겠습니까?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            let open = UIAlertAction(title: "네", style: .default) { _ in
                self.locationManager.startUpdatingLocation()
                self.weatherDetailInfoCollectionView.reloadData()
            }
            
            alert.addAction(cancel)
            alert.addAction(open)
            
            present(alert, animated: true)
        default:
            print("")
        }
        
    }
    
    func configureHierarchy() {
        view.addSubview(myLocationLabel)
        view.addSubview(weatherInfoStackView)
        view.addSubview(weatherDetailInfoCollectionView)
        view.addSubview(mapPinImageView)
    }
    
    func configureLayout() {
        
        weatherInfoStackView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(myLocationLabel).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.height.equalTo(220)
        }
        
        weatherImageView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(weatherInfoStackView.snp.top).inset(20)
            make.horizontalEdges.equalTo(weatherInfoStackView.snp.horizontalEdges).inset(60)
            make.height.equalTo(weatherImageView.snp.width)
        }
        
        whatsWeatherLabel.snp.makeConstraints { make in
            make.bottom.equalTo(weatherInfoStackView.snp.bottom).inset(20)
            make.width.equalTo(weatherImageView.snp.width)
            make.centerX.equalTo(weatherInfoStackView)
        }
        
        myLocationLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.height.equalTo(30)
            make.horizontalEdges.equalTo(weatherInfoStackView.snp.horizontalEdges)
        }
        
        weatherDetailInfoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(weatherInfoStackView.snp.bottom).offset(60)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(weatherDetailInfoCollectionView.snp.width).multipliedBy(0.68)
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
            whatsWeatherLabel.font = UIFont.hanbit!.withSize(24)
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
                
                self.weatherDetailInfoCollectionView.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func checkDeviceLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            checkUserCurrentLocationAuthorization()
        } else {
            let alert = UIAlertController(title: "설정에서 위치 권한 사용에 대하여 허용해주세요", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            let open = UIAlertAction(title: "이동", style: .default)
            
            alert.addAction(cancel)
            alert.addAction(open)
            
            // 4) 알럿 표시하기
            present(alert, animated: true)
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
            callRequest(lat: 37.517742, lon: 126.886463)
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            print(status)
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return WeatherDetail.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherDetailInfoCollectionViewCell.id, for: indexPath) as! WeatherDetailInfoCollectionViewCell
        
        if let weather = openWeather {
            cell.configureCellUI(detail: WeatherDetail.allCases[indexPath.item], weatherValue: weather)
        }
        
        cell.isSelected = false
        
        return cell
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
