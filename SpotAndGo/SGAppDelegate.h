//
//  SGAppDelegate.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RCLocationManager.h"

@interface SGAppDelegate : UIResponder <UIApplicationDelegate, RCLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RCLocationManager * locationManager;
@property (strong, nonatomic) CLGeocoder * geocoder;
@property (strong, nonatomic) CLLocation * currentLocation;

@end
