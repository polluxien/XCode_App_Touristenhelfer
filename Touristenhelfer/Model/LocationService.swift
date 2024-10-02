//
//  LocationService.swift
//  Touristenhelfer
//
//  Created by Bennet Panzek on 14.01.24.
//

import Foundation
import CoreLocation

class LocationService: NSObject {
    
    static let shared = LocationService()
    
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()
    
    override private init() {
        super.init()
        self.requestPermissionToAcessLocation()
    }
    
    func requestPermissionToAcessLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            print("error mit Location authoriz change ")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations location: [CLLocation]) {
        if let location = location.last?.coordinate {
          print(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
