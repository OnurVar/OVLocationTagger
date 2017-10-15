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
    @objc public static let sharedInstance =  OVLocationTagger()
    @objc public let locationManager =               CLLocationManager()
    @objc public var desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    @objc public var authType = CLAuthorizationStatus.authorizedWhenInUse
    
    
    //Private's
    fileprivate var completion:         OVLocationTaggerCompletion!
    fileprivate var lastKnownLocation:  CLLocation!
    fileprivate var timerTagger:        Timer!
    fileprivate var timerInterval       = Double(15.0)
    

    
    @objc public func register(withCompletion completion: @escaping OVLocationTaggerCompletion){
        self.completion = completion
        if CLLocationManager.locationServicesEnabled() {
            if authType == .authorizedWhenInUse {
                locationManager.requestAlwaysAuthorization()
            }else{
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.delegate = self
            locationManager.desiredAccuracy = desiredAccuracy
        }
    }
    
    @objc public func setTimerInterval(_ timerInterval: Double){
        self.timerInterval = Double(timerInterval)
    }
    
    @objc public func startTagger(){
        
        //First make sure you stop everything
        stopTagger()
    
        //Then start the location
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||  CLLocationManager.authorizationStatus() == .authorizedAlways {

            //Start the timer if we have location service enabled
            timerTagger = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(self.didTrigger(_:)), userInfo: nil, repeats: true)
            
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
    
    @objc func didTrigger(_ timer: Timer){
        completion(lastKnownLocation)
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
}
