//
//  ViewController.swift
//  Weather
//
//  Created by Bilal Nawaz on 3/29/19.
//  Copyright © 2019 Bilal Nawaz. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController ,CLLocationManagerDelegate{
    
    @IBOutlet weak var locationLabelsStackView: UIStackView!
    @IBOutlet weak var noInternetConnectionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var neighbourhoodLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherConditionImageView: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var hourlySummaryLabel: UILabel!
    @IBOutlet weak var developerlabelsStackView: UIStackView!
    
    var refreshControl = UIRefreshControl()
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var current = [CurrentWeatherModel]()
    var hourlyData = [CurrentWeatherModel]()
    var dailyData = [CurrentWeatherModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.delegate = self
        tableViewModifications()
        checkInternetConnection()
        registerCollectionViewCell()
    }
    @objc func refresh(sender:AnyObject) {
        tableView.backgroundView = nil
        if self.refreshControl.isRefreshing == true {
            DispatchQueue.main.async {
                self.checkInternetConnection()
            }
        }
    }
    fileprivate func registerCollectionViewCell() {
        let nibName = UINib(nibName: "HourlyWeatherCollectionViewCell", bundle:nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: "hourlyWeatherCell")
    }
    fileprivate func tableViewModifications() {
        tableView.rowHeight = 70
        tableView.backgroundView = activityIndicator
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    fileprivate func checkInternetConnection() {
        if Reachability.isConnectedToNetwork(){
            noInternetConnectionLabel.isHidden = true
            checkForUserPermission()
            print("Internet Connection Available!")
        }else{
            self.refreshControl.endRefreshing()
            noInternetConnectionLabel.isHidden = false
            print("Internet Connection not Available!")
        }
    }
    fileprivate func timeStringFromUnixTime(unixTime: Double) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h a"
        return dateFormatter.string(from: date)
    }
    fileprivate func dayStringFromUnixTime(unixTime: Double) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
    fileprivate func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locManager.requestLocation()
        }
    }
    fileprivate func checkForUserPermission(){
        locManager.requestWhenInUseAuthorization()
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            guard let currentLocation = locManager.location else { return }
            let lat = currentLocation.coordinate.latitude
            let long = currentLocation.coordinate.longitude
            fetchJsonFromWeatherApi(lat: lat, long: long)
            fetchJsonFromLocationApi(lat: lat, long: long)
        case .denied:
            print("Denied")
        case .notDetermined:
            locManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Restricted")
        case .authorizedAlways:
            break
        }
    }
    fileprivate func fetchJsonFromWeatherApi(lat : Double,long : Double){
        let weatherApiUrl = "https://api.darksky.net/forecast/08cfe3226887a412af6e7ef5011f9efc/\(lat),\(long)?units=si"
        print(weatherApiUrl)
        guard let url = URL(string: weatherApiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            DispatchQueue.main.async {
                if let err = err {
                    print("Failed to get Data from URL",err)
                    return
                }
                guard let data = data else { return }
                do{
                    let weatherModelNew = try JSONDecoder().decode(WeatherModel.self, from: data)
                    guard let current = weatherModelNew.currently else { return }
                    self.weatherConditionLabel.text = "\(current.summary?.uppercased() ?? "Not Available")"
                    let currentTemp = Int(round(current.temperature ?? 0))
                    self.currentTemperatureLabel.text = "\(currentTemp)°C"
                    let pressure = Int(round(current.pressure ?? 0))
                    self.pressureLabel.text = "\(pressure) hPa"
                    let humidity = Int(round(current.humidity! * 100))
                    self.humidityLabel.text = "\(humidity) %"
                    let weatherImageUrl = URL(string:"https://darksky.net/images/weather-icons/\(current.icon!).png")
                    ImageService.getImage(withURL: weatherImageUrl!) { (image) in
                        self.weatherConditionImageView.image = image
                    }
                    let attributedString = NSMutableAttributedString(string: (weatherModelNew.hourly?.summary)!)
                    attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(1.0), range: NSRange(location: 0, length: attributedString.length))
                    self.hourlySummaryLabel.attributedText = attributedString
                    self.hourlySummaryLabel.isHidden = false
                    self.current.append(current)
                    self.hourlyData.removeAll()
                    self.dailyData.removeAll()
                    guard let hourly = weatherModelNew.hourly?.data else { return }
                    guard let daily = weatherModelNew.daily?.data else { return }
                    for a in hourly{
                        self.hourlyData.append(a)
                    }
                    for b in daily{
                        self.dailyData.append(b)
                    }
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    self.developerlabelsStackView.isHidden = false
                }catch let jsonErr{
                    print("JsonError", jsonErr)
                }
            }
            }.resume()
    }
    fileprivate func fetchJsonFromLocationApi(lat : Double,long : Double){
        let locationApiUrl = "https://us1.locationiq.com/v1/reverse.php?key=4127c618c12b7e&lat=\(lat)&lon=\(long)&format=json&zoom=14"
        guard let url = URL(string: locationApiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            DispatchQueue.main.async {
                if let err = err {
                    print("Failed to get Data from URL",err)
                    return
                }
                guard let data = data else { return }
                do{
                    let getLocationData = try JSONDecoder().decode(LocationModel.self, from: data)
                    guard let location = getLocationData.address else { return }
                    self.neighbourhoodLabel.text = "\(location.neighbourhood ?? "Not Available"),"
                    self.cityLabel.text = location.city
                }catch let jsonErr{
                    print("JsonError", jsonErr)
                }
            }
            }.resume()
    }
    @IBAction func onClickDeveloperNameLabel(_ sender: UIButton) {
        let screenName =  "bil__a__l"
        let appURL = NSURL(string: "twitter://user?screen_name=\(screenName)")!
        let webURL = NSURL(string: "https://twitter.com/\(screenName)")!
        
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    
}
extension ViewController : UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.mainView.layer.cornerRadius = 8
        let day = dayStringFromUnixTime(unixTime: dailyData[indexPath.row].time!)
        cell.dayLabel.text = day
        let tempMin = Int(round(dailyData[indexPath.row].temperatureMin ?? 0))
        let tempMax = Int(round(dailyData[indexPath.row].temperatureMax ?? 0))
        cell.temperatureLabel.text = "\(tempMin)°C - \(tempMax)°C"
        let weatherImageUrl = URL(string:"https://darksky.net/images/weather-icons/\(dailyData[indexPath.row].icon!).png")
        ImageService.getImage(withURL: weatherImageUrl!) { (image) in
            cell.weatherConditionImageView.image = image
        }
        return cell
    }
}
extension ViewController : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourlyWeatherCell", for: indexPath) as! HourlyWeatherCollectionViewCell
        cell.layer.cornerRadius = 8
        let currentTemp = Int(round(hourlyData[indexPath.row].temperature ?? 0))
        cell.currentTemperatureLabel.text = "\(currentTemp)°C"
        let time = timeStringFromUnixTime(unixTime: hourlyData[indexPath.row].time!)
        cell.timeLabel.text = "\(time)"
        let weatherImageUrl = URL(string:"https://darksky.net/images/weather-icons/\(hourlyData[indexPath.row].icon!).png")
        ImageService.getImage(withURL: weatherImageUrl!) { (image) in
           cell.weatherConditionImageView.image = image
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 6 + 7.5 , height: 80)
    }
}

