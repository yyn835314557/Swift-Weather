//
//  ViewController.swift
//  Swift Weather
//
//  Created by 游义男 on 15/4/26.
//  Copyright (c) 2015年 游义男. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController , CLLocationManagerDelegate {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loading: UILabel!
    
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var temperature: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.loadingIndicator.startAnimating()
        
        let background = UIImage(named: "photo4.jpg")
        self.view.backgroundColor = UIColor(patternImage: background!)
        
        locationManager.delegate  = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        var location:CLLocation = locations[locations.count-1] as CLLocation

        if (location.horizontalAccuracy > 0) {
   
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
            updateWeatherInfo(location.coordinate.latitude,longitude: location.coordinate.longitude)
            
            locationManager.stopUpdatingLocation()
        }

    }
    
    
    
    func updateWeatherInfo(latitude:CLLocationDegrees,longitude:CLLocationDegrees){
        let manager = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
        
        let paras = ["lat": latitude,"lon":longitude, "cnt":0]
        
        manager.GET(url, parameters: paras, success: {(operation:AFHTTPRequestOperation!,
            responseObject:AnyObject!) in
            println("JSON: " + responseObject.description)
            
            self.updateUISuccess(responseObject as NSDictionary!)
            
            },

            failure: {(operation:AFHTTPRequestOperation!,error:NSError!) in println("Error: " + error.localizedDescription)})
    }
    
    func updateUISuccess(jsonResult:NSDictionary!){
        
        self.loadingIndicator.hidden = true
        self.loadingIndicator.stopAnimating()
        self.loading.text = nil
        
        if let tempResult = (jsonResult["main"] as NSDictionary)["temp"] as? Double{
            var temperature:Double
            if(jsonResult["sys"]?["country"] as String == "US"){
                temperature = round(((tempResult - 273.15) * 1.8) + 32)
            }
            else{
                temperature = round(tempResult - 273.15)
            }
            self.temperature.text = "\(temperature)度"
            self.temperature.font = UIFont.boldSystemFontOfSize(60)
            
            var name = jsonResult["name"]  as String
            self.location.font = UIFont.boldSystemFontOfSize(25)
            self.location.text = "\(name)"
            
            
            
            
            var conditon = (jsonResult["weather"] as NSArray)[0]["id"] as? Int
            var sunrise = (jsonResult["sys"] as NSDictionary) ["sunruse"]  as? Double
            var sunset = (jsonResult["sys"] as NSDictionary)["suset"] as? Double
            
            
            
            
            
            var nightTime = false
           
            var now = NSDate().timeIntervalSince1970
            
            
            //let second = todayDate.timeIntervalSinceDate(eventDate)
            
            if(now < sunrise || now > sunset){
                nightTime = true
            }
            self.updateWeatherIcon(conditon!, nightTime: nightTime)
            
        }
        else{
            self.loading.text = "天气信息不可用"
        }
    }
    
    
    func updateWeatherIcon(condition:Int,nightTime:Bool){
        
        // Thunderstorm
        if(condition < 300){
            if nightTime{
                self.icon.image = UIImage(named: "tstorm1_night")
            }
            else{
                self.icon.image = UIImage(named: "tstorm1")
            }
        }
        

        
        //Drizzle
        else if(condition < 500){
            self.icon.image = UIImage(named: "light_rain")
        }
        
    // Rain/Freezing rain/Shower rain
        else if(condition < 600){
            self.icon.image = UIImage(named: "shower3")
        }
        
        //snow
        else if(condition < 700){
            self.icon.image = UIImage(named: "snow4")
        }
        
            //Fog/Mist /Haze/etc.
        else if(condition < 771){
            if nightTime{
                self.icon.image = UIImage(named: "fog_night")
            }
            else{
                self.icon.image = UIImage(named: "fog")
            }
        }
        
            //Tormado//Squalls
        else if(condition < 800){
            self.icon.image = UIImage(named: "tstorm3")
        }
        
        // Sky is clear
        else if(condition == 800){
        if nightTime{
        self.icon.image = UIImage(named: "sunny_night")
        }
        else{
            self.icon.image = UIImage(named: "sunny")
        }
        }
            
        else if(condition < 804){
            if nightTime{
                self.icon.image = UIImage(named: "cloudy2_night")
            }
            else{
                self.icon.image = UIImage(named: "cloudy2")
            }
        }
        
        else if(condition == 804){

            self.icon.image = UIImage(named: "overcast")
        }
        
        else if((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000 )){
            self.icon.image = UIImage(named: "tstorm3")
        }
        
        else if(condition == 903){
            
            self.icon.image = UIImage(named: "snow5")
        }
        
        else if(condition == 904){
            
            self.icon.image = UIImage(named: "sunny")
        }
        
        else{
            self.icon.image = UIImage(named: "dunno")
        }

}


    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        println(error)
        self.loading.text = "地理位置信息不可获取"
    }

}

