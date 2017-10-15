//
//  ExampleViewController.m
//  OVLocationTagger_Example
//
//  Created by Onur Var on 10/15/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

#import "ExampleViewController.h"
#import <CoreLocation/CoreLocation.h>

@implementation ExampleViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [OVLocationTagger sharedInstance].desiredAccuracy = kCLLocationAccuracyBest;
    [OVLocationTagger sharedInstance].authType = kCLAuthorizationStatusAuthorizedAlways;
    [[OVLocationTagger sharedInstance] setTimerInterval:3.0];
    [[OVLocationTagger sharedInstance] registerWithCompletion:^(CLLocation * location) {
        
    }];
    
//    OVLocationTagger.sharedInstance.desiredAccuracy = kCLLocationAccuracyBest
//    OVLocationTagger.sharedInstance.authType = .authorizedAlways
//    OVLocationTagger.sharedInstance.setTimerInterval(3.0)
//    OVLocationTagger.sharedInstance.register { (location) in
//        let stringTest = String.init(format: "%f - %f", (location?.coordinate.latitude)!, (location?.coordinate.longitude)!)
//        print(stringTest)
//    }
}

@end
