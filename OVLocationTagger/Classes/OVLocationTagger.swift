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
    
    
    //MARK: Public
    @objc public func register(withCompletion completion: @escaping OVLocationTaggerCompletion){
        NSLog("[OVLocationTagger] Registered (1.3.6)")
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
    
    @objc public func startTagger(){
        
        //First make sure you stop everything
        self.stopTagger()
        
        NSLog("[OVLocationTagger] Started")
        //Get the main thread
        DispatchQueue.main.async {
               
            //Then start the location
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||  CLLocationManager.authorizationStatus() == .authorizedAlways {
                
                //Start the timer if we have location service enabled
                self.timerTagger = Timer.scheduledTimer(timeInterval: self.timerInterval, target: self, selector: #selector(self.didTriggerTimer(_:)), userInfo: nil, repeats: true)
                
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    @objc public func stopTagger(){
        NSLog("[OVLocationTagger] Stopped")
        
        //Get the main thread
        DispatchQueue.main.async {
            
            //First make sure you stop Timer
            if self.timerTagger != nil {
                self.timerTagger.invalidate()
                self.timerTagger = nil
            }
            
            //Then stop location updates
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    @objc public func triggerTagger(){
        NSLog("[OVLocationTagger] Triggered")
        notifyCompletion()
    }

    
    //MARK: Private
    fileprivate func notifyCompletion(){
        completion(lastKnownLocation)
    }
    
    fileprivate func checkStatus(){
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.isLocationEnabled = true;
        }
    }
    
    
    //MARK: Trigger
    @objc fileprivate func didTriggerTimer(_ timer: Timer){
        notifyCompletion()
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

