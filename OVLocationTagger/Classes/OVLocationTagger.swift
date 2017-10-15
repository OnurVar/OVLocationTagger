//
//  OVLocationTagger.swift
//  Pods
//
//  Created by Onur Var on 10/2/17.
//
//

import CoreLocation

public typealias OVLocationTaggerCompletion = (_ location: CLLocation?) -> Void
public class OVLocationTagger: NSObject {
    
    public static let sharedInstance =  OVLocationTagger()
    let locationManager =               CLLocationManager()
    fileprivate var completion:         OVLocationTaggerCompletion!
    fileprivate var lastKnownLocation:  CLLocation!
    fileprivate var timerTagger:        Timer!
    fileprivate var timerInterval       = Double(15.0)
    
    public var desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    public var authType = CLAuthorizationStatus.authorizedWhenInUse
    
    public func register(withCompletion completion: @escaping OVLocationTaggerCompletion){
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
    
    public func setTimerInterval(_ timerInterval: Double){
        self.timerInterval = Double(timerInterval)
    }
    
    public func startTagger(){
        
        //First make sure you stop everything
        stopTagger()
    
        //Then start the location
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||  CLLocationManager.authorizationStatus() == .authorizedAlways {

            //Start the timer if we have location service enabled
            timerTagger = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(self.didTrigger(_:)), userInfo: nil, repeats: true)
            
            locationManager.startUpdatingLocation()
        }
    }
    
    public func stopTagger(){
        
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
