//
//  OVLocationTypeAlias.swift
//  OVLocationTagger
//
//  Created by Onur Var on 2.09.2018.
//

import CoreLocation


@objc public enum OVSignalStrength: Int {
    case NoSignal
    case Weak
    case Average
    case Strong
}


@objc public enum OVPermissionRequest: Int {
    case WhenInUse
    case Background
    case BackgroundAndSuspended
}


public typealias OVLocationTaggerLocationCompletion = (_ location: CLLocation?) -> Void
public typealias OVLocationTaggerAuthorizationStatusCompletion = (_ status: CLAuthorizationStatus) -> Void
public typealias OVLocationTaggerSignalStrengthCompletion = (_ strength: OVSignalStrength) -> Void
