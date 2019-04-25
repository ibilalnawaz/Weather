//
//  Model.swift
//  Weather
//
//  Created by Bilal Nawaz on 3/29/19.
//  Copyright © 2019 Bilal Nawaz. All rights reserved.
//

import Foundation

struct WeatherModel: Decodable {
    var currently: CurrentWeatherModel?
    var hourly: HourlyWeatherModel?
    var daily:DailyWeatherModel?
    enum CodingKeys : String, CodingKey {
        case currently = "currently"
        case hourly = "hourly"
        case daily = "daily"
    }
}
struct HourlyWeatherModel:Decodable {
    var data:[CurrentWeatherModel]?
    var summary:String?
    enum CodingKeys : String, CodingKey {
        case data = "data"
        case summary = "summary"
    }
}
struct DailyWeatherModel:Decodable {
    var data:[CurrentWeatherModel]?
    var summary:String?

    enum CodingKeys : String, CodingKey {
        case data = "data"
        case summary = "summary"
    }
}
struct CurrentWeatherModel: Decodable {
    
    let time : Double?
    let temperature: Double?
    let summary: String?
    let apparentTemperature: Double?
    let dewPoint:Double?
    let humidity:Double?
    let pressure:Double?
    let windSpeed:Double?
    let visibility:Double?
    let icon:String?
    let temperatureMin:Double?
    let temperatureMax:Double?

    enum CodingKeys : String, CodingKey {
        case time = "time"
        case temperature = "temperature"
        case summary = "summary"
        case apparentTemperature = "apparentTemperature"
        case dewPoint = "dewPoint"
        case humidity = "humidity"
        case pressure = "pressure"
        case windSpeed = "windSpeed"
        case visibility = "visibility"
        case icon = "icon"
        case temperatureMin = "temperatureMin"
        case temperatureMax = "temperatureMax"

    }
}
struct LocationModel: Decodable {
    var address: CurrentLocationModel?
    enum CodingKeys : String, CodingKey {
        case address = "address"
    }
}
struct CurrentLocationModel:Decodable {
    let neighbourhood: String?
    let city:String?
    
    enum CodingKeys : String, CodingKey {
        case neighbourhood = "neighbourhood"
        case city = "city"
    }
}
