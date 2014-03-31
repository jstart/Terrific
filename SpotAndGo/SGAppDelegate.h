//
//  SGAppDelegate.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;

@interface SGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) CLGeocoder * geocoder;
@property (strong, nonatomic) CLLocation * currentLocation;

+ (SGAppDelegate *) sharedAppDelegate;

@end
