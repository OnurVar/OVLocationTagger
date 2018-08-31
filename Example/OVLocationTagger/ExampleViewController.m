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
    [OVLocationTagger shared].desiredAccuracy = kCLLocationAccuracyBest;
    [[OVLocationTagger shared] setTimerInterval:3.0];
    [[OVLocationTagger shared] registerWithBackgroundAccess:true withCompletion:^(CLLocation * location) {
 
    }];
}

@end
