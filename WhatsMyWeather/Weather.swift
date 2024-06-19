//
//  Weather.swift
//  WhatsMyWeather
//
//  Created by 김상규 on 6/19/24.
//

import Foundation

struct OpenWeather: Decodable {
    let name: String
    let main: MyWeather
    let wind: Wind
    let weather: [WeatherImg]
}

struct MyWeather: Decodable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
    let feels_like: Double
    let humidity: Double
}

struct Wind: Decodable {
    let speed: Double
}


struct WeatherImg: Decodable {
    let description: String
    let icon: String
}
