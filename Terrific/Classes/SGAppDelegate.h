//
//  SGAppDelegate.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2014 Truman. All rights reserved.
//

@import UIKit;
@import CoreLocation;

@interface SGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLLocation *currentLocation;

+ (SGAppDelegate *) sharedAppDelegate;

@end
