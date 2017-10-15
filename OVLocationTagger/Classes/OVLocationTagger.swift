//
//  OVLocationTagger.swift
//  Pods
//
//  Created by Onur Var on 10/2/17.
//
//

import CoreLocation

public typealias OVLocationTaggerCompletion = (_ location: CLLocation?) -> Void
@objc public class OVLocationTagger: NSObject {
    
    
    //Public's
    @objc public static let sharedInstance  = OVLocationTagger()
    @objc public let locationManager        = CLLocationManager()
    @objc public var desiredAccuracy        = kCLLocationAccuracyNearestTenMeters
    @objc public var authType               = CLAuthorizationStatus.authorizedWhenInUse
    @objc public var isLocationEnabled      = false
    @objc public var timerInterval          = Double(15.0)
    
    //Private's
    fileprivate var completion:         OVLocationTaggerCompletion!
    fileprivate var lastKnownLocation:  CLLocation!
    fileprivate var timerTagger:        Timer!
    
    

    
    @objc public func register(withCompletion completion: @escaping OVLocationTaggerCompletion){
        self.completion = completion
        if CLLocationManager.locationServicesEnabled() {
            if authType == .authorizedAlways {
                locationManager.requestAlwaysAuthorization()
            }else{
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.delegate = self
            locationManager.desiredAccuracy = desiredAccuracy
        }
        
        checkStatus()
        
    }

    
    //MARK: Trigger
    @objc public func startTagger(){
        
        //First make sure you stop everything
        stopTagger()
    
        //Then start the location
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||  CLLocationManager.authorizationStatus() == .authorizedAlways {

            //Start the timer if we have location service enabled
            timerTagger = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(self.didTriggerTimer(_:)), userInfo: nil, repeats: true)
            
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc public func stopTagger(){
        
        //First make sure you stop Timer
        if timerTagger != nil {
            timerTagger.invalidate()
            timerTagger = nil
        }
        
        //Then stop location updates
        locationManager.stopUpdatingLocation()
    }
    
    @objc fileprivate func didTriggerTimer(_ timer: Timer){
        completion(lastKnownLocation)
    }
    
    fileprivate func checkStatus(){
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.isLocationEnabled = true;
        }
    }
    
}

extension OVLocationTagger : CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            if let last = locations.last {
                self.lastKnownLocation = last
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkStatus()
    }
}
