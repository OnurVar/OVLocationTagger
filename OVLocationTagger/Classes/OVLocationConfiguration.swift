//
//  OVLocationConfiguration.swift
//  OVLocationTagger
//
//  Created by Onur Var on 2.09.2018.
//

import CoreLocation

@objc public class OVLocationConfiguration: NSObject {

    
    //MARK: Public statics
    @objc public static let shared          = OVLocationConfiguration()
    
    
    //MARK: Public variables
    @objc public var desiredAccuracy        = kCLLocationAccuracyThreeKilometers
    @objc public var distanceFilter         = kCLDistanceFilterNone
    @objc public var timerInterval          = Double(0.0) //Set 0 or negative to receive updates when CLLocationManager updates
    @objc public var requestType            = OVPermissionRequest.WhenInUse
    
}
