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
#import "SGConstants.h"
#import <MBLocationManager/MBLocationManager.h>
// #import "DCIntrospect.h"
// #import <PonyDebugger.h>
#import <GroundControl/NSUserDefaults+GroundControl.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <UIColor-HexString/UIColor+HexString.h>
#import <GoogleMaps/GoogleMaps.h>

@interface SGAppDelegate ()

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
    [GMSServices provideAPIKey:@"AIzaSyDogBo6yZiDAZOAUVQTfktm2X00JuNR1Ac"];
    #if TARGET_IPHONE_SIMULATOR || DEBUG
        //    [[DCIntrospect sharedIntrospector] start];
        //    PDDebugger *debugger = [PDDebugger defaultInstance];
        //    [debugger enableNetworkTrafficDebugging];
        //    [debugger forwardAllNetworkTraffic];
        //    [debugger enableViewHierarchyDebugging];
        //    [debugger enableRemoteLogging];
        //    [debugger connectToURL:[NSURL URLWithString:@"ws://localhost:9000/device"]];
    #else
        [Crashlytics startWithAPIKey:@"ff6f76d45da103570f8070443d1760ea5199fc81"];
        [Mixpanel sharedInstanceWithToken:@"8ed4b958846a5a4f2336e6ed19687a20"];
        [[Mixpanel sharedInstance] track:@"Launched"];
    #endif
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"eat"])
    {
        NSDictionary *defaultsDictionary = [NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Search_Params.plist"]];
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDictionary];
    }
    
    NSURL *URL = [NSURL URLWithString:@"http://spotandgo-plist.herokuapp.com/defaults.plist"];
    [[NSUserDefaults standardUserDefaults] registerDefaultsWithURL:URL success: ^(NSDictionary *defaults) {
    } failure: ^(NSError *error) {
    }];
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithHexString:@"844fe5"]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:24]}];
    
    [[MBLocationManager sharedManager] startLocationUpdates:kMBLocationManagerModeStandard
                                             distanceFilter:kCLDistanceFilterNone
                                                   accuracy:kCLLocationAccuracyNearestTenMeters];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLocation:)
                                                 name:kMBLocationManagerNotificationLocationUpdatedName
                                               object:nil];
    self.geocoder = [[CLGeocoder alloc] init];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
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

- (void) changeLocation:(NSNotification *)notification
{
    [[MBLocationManager sharedManager] stopLocationUpdates];
    
    CLLocation *location = [[MBLocationManager sharedManager] currentLocation];
    self.currentLocation = location;
    [self.geocoder reverseGeocodeLocation:location completionHandler:
     
     ^(NSArray *placemarks, NSError *error) {
         // Get nearby address
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         
         // String to hold address
         NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         
         self.currentLocationString = locatedAt;
     }];
}

@end
