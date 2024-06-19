//
//  WeatherDetailInfoCollectionView.swift
//  WhatsMyWeather
//
//  Created by 김상규 on 6/19/24.
//

import UIKit
import SnapKit

class WeatherDetailInfoCollectionViewCell: UICollectionViewCell {
    static var id: String {
        String(describing: self)
    }
    
    private lazy var stackView = {
       let sv = UIStackView(arrangedSubviews: [detailImageView, detailTitleLabel])
        sv.axis = .horizontal
        
        
        return sv
    }()
    
    private lazy var detailImageView = {
       let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        
        return imgView
    }()
    
    private lazy var detailTitleLabel = {
       let label = UILabel()
        label.font = UIFont.hanbit!.withSize(17)
        
        return label
    }()
    
    private lazy var detailValueLabel = {
       let label = UILabel()
        label.font = UIFont.hanbit!
        label.textAlignment = .center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        contentView.layer.cornerRadius = 12
        
        configureHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        contentView.addSubview(stackView)
        contentView.addSubview(detailValueLabel)
    }
    
    private func configureLayout() {
        stackView.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
            make.height.equalTo(30)
        }
        
        detailImageView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.top)
            make.leading.equalTo(stackView.snp.leading).offset(5)
            make.width.equalTo(stackView.snp.height).multipliedBy(0.8)
        }
        
        detailTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.top)
            make.leading.equalTo(detailImageView.snp.trailing).offset(10)
            make.trailing.equalTo(stackView.snp.trailing).inset(5)
            make.height.equalTo(stackView.snp.height)
        }
        
        detailValueLabel.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(contentView.safeAreaLayoutGuide)
            make.top.equalTo(stackView.snp.bottom)
        }
        
    }
    
    func configureCellUI(detail: WeatherDetail, weatherValue: OpenWeather) {
        detailImageView.image = UIImage(systemName: "\(detail.detailIcon)")
        detailImageView.tintColor = .darkGray
        detailTitleLabel.text = detail.rawValue
        
        switch detail {
        case .currentTemp:
            detailValueLabel.text = String(format: "%.1f", Double(weatherValue.main.temp)) + "°C"
        case .maxTemp:
            detailValueLabel.text = String(format: "%.1f", Double(weatherValue.main.temp_max)) + "°C"
        case .minTemp:
            detailValueLabel.text = String(format: "%.1f", Double(weatherValue.main.temp_min)) + "°C"
        case .feelLikeTemp:
            detailValueLabel.text = String(format: "%.1f", Double(weatherValue.main.feels_like)) + "°C"
        case .humidity:
            detailValueLabel.text = String(format: "%.1f", Double(weatherValue.main.humidity)) + "%"
        case .wind:
            detailValueLabel.text = String(format: "%.1f", Double(weatherValue.wind.speed)) + "m/s"
        }
    }
}

