//
//  SGAppDelegate.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2014 Truman. All rights reserved.
//

#import "SGAppDelegate.h"

@import AdSupport;

#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>

#import "SGConstants.h"
#import <MBLocationManager/MBLocationManager.h>
#import <GroundControl/NSUserDefaults+GroundControl.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <UIColor-HexString/UIColor+HexString.h>
#import <NotificationCenter/NotificationCenter.h>

@interface SGAppDelegate () <CLLocationManagerDelegate>

@property (nonatomic, strong) NSString *currentLocationString;

@end

@implementation SGAppDelegate

@synthesize window = _window;

+ (SGAppDelegate *) sharedAppDelegate
{
    return (SGAppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (BOOL) application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if TARGET_IPHONE_SIMULATOR || DEBUG
    
#else
    //        [GMSServices provideAPIKey:@"AIzaSyDogBo6yZiDAZOAUVQTfktm2X00JuNR1Ac"];
    [Fabric with:@[CrashlyticsKit]];
    [Mixpanel sharedInstanceWithToken:@"8ed4b958846a5a4f2336e6ed19687a20"];
    [[Mixpanel sharedInstance] track:@"Launched"];
#endif
    
    if (![[[NSUserDefaults alloc] initWithSuiteName:@"group.truman.Terrific"] objectForKey:@"eat"])
    {
        NSDictionary *defaultsDictionary = [NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Search_Params.plist"]];
        [[[NSUserDefaults alloc] initWithSuiteName:@"group.truman.Terrific"] registerDefaults:defaultsDictionary];
    }
    
    NSURL *URL = [NSURL URLWithString:@"http://spotandgo-plist.herokuapp.com/defaults.plist"];
    [[[NSUserDefaults alloc] initWithSuiteName:@"group.truman.Terrific"] registerDefaultsWithURL:URL success: ^(NSDictionary *defaults) {
    } failure: ^(NSError *error) {
    }];
    
    [[MBLocationManager sharedManager].locationManager setDelegate:self];
    [[MBLocationManager sharedManager].locationManager requestWhenInUseAuthorization];
    [[MBLocationManager sharedManager] startLocationUpdates:kMBLocationManagerModeStandard
                                             distanceFilter:kCLDistanceFilterNone
                                                   accuracy:kCLLocationAccuracyHundredMeters];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[NCWidgetController widgetController] setHasContent:YES forWidgetWithBundleIdentifier:@"spotngo.Nearby-Places"];
    
    return YES;
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
    [[Mixpanel sharedInstance] track:@"Sent to Background"];
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
    [[Mixpanel sharedInstance] track:@"Brought to foreground"];
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [[NCWidgetController widgetController] setHasContent:YES forWidgetWithBundleIdentifier:@"spotngo.Nearby-Places"];
        
        [[MBLocationManager sharedManager] startLocationUpdates:kMBLocationManagerModeStandard
                                                 distanceFilter:kCLDistanceFilterNone
                                                       accuracy:kCLLocationAccuracyNearestTenMeters];
    }
    else if (status == kCLAuthorizationStatusDenied)
    {
        [[NCWidgetController widgetController] setHasContent:NO forWidgetWithBundleIdentifier:@"spotngo.Nearby-Places"];
    }
    else
    {
        [[MBLocationManager sharedManager].locationManager requestWhenInUseAuthorization];
    }
}

@end
