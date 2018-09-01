//
//  OVLocationTagger.swift
//  Pods
//
//  Created by Onur Var on 10/2/17.
//
//

import CoreLocation

@objc public enum OVSignalStrength: Int {
    case NoSignal
    case Weak
    case Average
    case Strong
}

public typealias OVLocationTaggerLocationCompletion = (_ location: CLLocation?) -> Void
public typealias OVLocationTaggerAuthorizationStatusCompletion = (_ status: CLAuthorizationStatus) -> Void
public typealias OVLocationTaggerSignalStrengthCompletion = (_ strength: OVSignalStrength) -> Void
@objc public class OVLocationTagger: NSObject {
    
    
    //Public's
    @objc public static let shared  = OVLocationTagger()
    @objc public let locationManager        = CLLocationManager()
    @objc public var desiredAccuracy        = kCLLocationAccuracyNearestTenMeters
    @objc public var isLocationEnabled      = false
    @objc public var timerInterval          = Double(15.0) //Set 0 or negative to receive updates when CLLocationManager updates
    
    //Private's
    fileprivate var locationCompletion:                 OVLocationTaggerLocationCompletion?
    fileprivate var locationAuthorizationCompletion:    OVLocationTaggerAuthorizationStatusCompletion?
    fileprivate var locationSignalStrengthCompletion:   OVLocationTaggerSignalStrengthCompletion?
    fileprivate var timerTagger:        Timer!
    fileprivate var lastKnownLocation:  CLLocation?{
        didSet{
            if self.timerInterval <= 0 {
                self.notifyCompletion()
            }
        }
    }
    
    
    //MARK: Public Methods
    
    @objc public override init() {
        super.init()
        NSLog("[OVLocationTagger] Initialized (1.3.8)")
        locationManager.delegate = self
        locationManager.desiredAccuracy = desiredAccuracy
    }
    
    @objc public func setLocationCompletion(aCompletion: @escaping OVLocationTaggerLocationCompletion){
        NSLog("[OVLocationTagger] setLocation")
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
                if self.timerInterval > 0 {
                    //Start the timer if we have location service enabled
                    self.timerTagger = Timer.scheduledTimer(timeInterval: self.timerInterval, target: self, selector: #selector(self.didTriggerTimer(_:)), userInfo: nil, repeats: true)
                    
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

    @objc public func requestPermission(withBackgroundAccess backgroundAccess: Bool){
        
        //Request Permission
        backgroundAccess ? locationManager.requestAlwaysAuthorization() : locationManager.requestWhenInUseAuthorization()
        
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
       
        if let last = locations.last {
            self.lastKnownLocation = last
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

