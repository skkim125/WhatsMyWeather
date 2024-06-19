//
//  Enum.swift
//  WhatsMyWeather
//
//  Created by 김상규 on 6/19/24.
//

import Foundation

enum WeatherDetail: String, CaseIterable {
    case currentTemp = "현재 온도"
    case maxTemp = "최고 온도"
    case minTemp = "최저 온도"
    case feelLikeTemp = "체감 온도"
    case humidity = "습도"
    case wind = "풍속"
    
    
    var detailIcon: String {
        switch self {
        case .currentTemp:
            "thermometer.medium"
        case .maxTemp:
            "thermometer.high"
        case .minTemp:
            "thermometer.low"
        case .feelLikeTemp:
            "thermometer.variable.and.figure"
        case .humidity:
            "humidity.fill"
        case .wind:
            "wind"
        }
    }
}
