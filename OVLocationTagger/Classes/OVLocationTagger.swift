//
//  OVLocationTagger.swift
//  Pods
//
//  Created by Onur Var on 10/2/17.
//
//

import CoreLocation


@objc public class OVLocationTagger: NSObject {
    
    //Public's
    @objc public static let shared          = OVLocationTagger()
    @objc public let locationManager        = CLLocationManager()
    @objc public var isLocationEnabled      = false
    
    //Private's
    fileprivate var locationCompletion:                 OVLocationTaggerLocationCompletion?
    fileprivate var locationAuthorizationCompletion:    OVLocationTaggerAuthorizationStatusCompletion?
    fileprivate var locationSignalStrengthCompletion:   OVLocationTaggerSignalStrengthCompletion?
    fileprivate var timerTagger:        Timer!
    fileprivate var lastKnownLocation:  CLLocation?{
        didSet{
            if OVLocationConfiguration.shared.timerInterval <= 0 {
                self.notifyCompletion()
            }
        }
        willSet{
            if let oldLocation = lastKnownLocation, let newLocation = newValue {
                let distanceMeasured = newLocation.distance(from: oldLocation)
                NSLog("[OVLocationTagger] Distance measured %f",distanceMeasured)
            }
        }
    }
    
    
    //MARK: Public Methods
    
    @objc public override init() {
        super.init()
        NSLog("[OVLocationTagger] Initialized (1.3.9)")
        locationManager.delegate = self
        locationManager.desiredAccuracy = OVLocationConfiguration.shared.desiredAccuracy
        locationManager.distanceFilter  = OVLocationConfiguration.shared.distanceFilter
    }
    
    @objc public func setLocationCompletion(aCompletion: @escaping OVLocationTaggerLocationCompletion){
        NSLog("[OVLocationTagger] setLocationCompletion")
        self.locationCompletion = aCompletion
        checkStatus()
    }
    
    @objc public func setAuthorizationStatusCompletion(aCompletion: @escaping OVLocationTaggerAuthorizationStatusCompletion){
        NSLog("[OVLocationTagger] setAuthorizationStatusCompletion")
        self.locationAuthorizationCompletion = aCompletion
    }
    
    @objc public func setSignalStrengthCompletion(aCompletion: @escaping OVLocationTaggerSignalStrengthCompletion){
        NSLog("[OVLocationTagger] setSignalStrengthCompletion")
        self.locationSignalStrengthCompletion = aCompletion
    }
    
    @objc public func startTagger(){
        
        //First make sure you stop everything
        self.stopTagger()
        
        NSLog("[OVLocationTagger] Started")
        //Get the main thread
        DispatchQueue.main.async {
               
            //Then start the location
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||  CLLocationManager.authorizationStatus() == .authorizedAlways {
                
                //Check if timeInterval is set > 0
                if OVLocationConfiguration.shared.timerInterval > 0 {
                    //Start the timer if we have location service enabled
                    self.timerTagger = Timer.scheduledTimer(timeInterval: OVLocationConfiguration.shared.timerInterval, target: self, selector: #selector(self.didTriggerTimer(_:)), userInfo: nil, repeats: true)
                    
                }
                
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

    @objc public func requestPermission(){
        
        switch OVLocationConfiguration.shared.requestType {
        case .WhenInUse:
            locationManager.requestWhenInUseAuthorization()
            break
        case .Background:
            locationManager.requestAlwaysAuthorization()
            break
        case .BackgroundAndSuspended:
            locationManager.requestAlwaysAuthorization()
            if #available(iOS 9.0, *) {
                locationManager.allowsBackgroundLocationUpdates = true
            }
            break
        }
        
    }
    
    
    
    //MARK: Private
    fileprivate func notifyCompletion(){
        
        if let locationCompletion = locationCompletion {
            locationCompletion(lastKnownLocation)
        }
        
        if let locationSignalStrengthCompletion = locationSignalStrengthCompletion {
            locationSignalStrengthCompletion(getSignalStrength(location: lastKnownLocation))
        }
        
    }
    
    fileprivate func checkStatus(){
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.isLocationEnabled = true;
        }
    }
    
    private func getSignalStrength(location: CLLocation?) -> OVSignalStrength {
        if let location = location {
            if (location.horizontalAccuracy < 0){
                return OVSignalStrength.NoSignal
            }else if (location.horizontalAccuracy > 163){
                return OVSignalStrength.Weak
            }else if (location.horizontalAccuracy > 48){
                return OVSignalStrength.Average
            }else{
                return OVSignalStrength.Strong
            }
        }
        return OVSignalStrength.NoSignal
    }
    
    //MARK: Trigger
    @objc fileprivate func didTriggerTimer(_ timer: Timer){
        notifyCompletion()
    }
    

}

extension OVLocationTagger : CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        if let first = locations.first {
            self.lastKnownLocation = first
        }
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        //Notify observer
        if let locationAuthorizationStatusCompletion = locationAuthorizationCompletion {
            locationAuthorizationStatusCompletion(status)
        }
        
        checkStatus()
    }
}

