//
//  SGAppDelegate.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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

@interface SGAppDelegate ()

@property (nonatomic, strong) NSString * currentLocationString;

@end

@implementation SGAppDelegate

#define TESTFLIGHT 0

// Dispatch period in seconds

#if TARGET_IPHONE_SIMULATOR
static NSString * const kAnalyticsAccountId = @"UA-31324397-2";
#elif TESTFLIGHT
static NSString * const kAnalyticsAccountId = @"UA-31324397-3";
#else
static NSString * const kAnalyticsAccountId = @"UA-31324397-4";
#endif

@synthesize window = _window;

+ (SGAppDelegate *) sharedAppDelegate
{
    return (SGAppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (BOOL) application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"eat"])
    {
        NSDictionary * defaultsDictionary = [NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Search_Params.plist"]];
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDictionary];
    }

    NSURL * URL = [NSURL URLWithString:@"http://spotandgo-plist.herokuapp.com/defaults.plist"];
    [[NSUserDefaults standardUserDefaults] registerDefaultsWithURL:URL success: ^(NSDictionary * defaults) {
     } failure: ^(NSError * error) {
     }];

    [Crashlytics startWithAPIKey:@"ff6f76d45da103570f8070443d1760ea5199fc81"];
    [Mixpanel sharedInstanceWithToken:@"8ed4b958846a5a4f2336e6ed19687a20"];
    [[Mixpanel sharedInstance] identify:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    [Flurry startSession:@"FJX9G2A6P8VGCM5736M7"];
    [Flurry setUserID:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];

    [TestFlight takeOff:@"149fea64-54e2-4696-8c05-844a849d7f6a"];

    [[Mixpanel sharedInstance] track:@"Launched"];

//    PDDebugger *debugger = [PDDebugger defaultInstance];
//    [debugger enableNetworkTrafficDebugging];
//    [debugger forwardAllNetworkTraffic];
//    [debugger enableViewHierarchyDebugging];
//    [debugger enableRemoteLogging];
//    [debugger connectToURL:[NSURL URLWithString:@"ws://localhost:9000/device"]];

    // Optional: automatically send uncaught exceptions to Google Analytics.
//    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
//    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
//  [GAI sharedInstance].debug = YES;
    // Create tracker instance.
//    [[GAI sharedInstance] trackerWithTrackingId:kAnalyticsAccountId];
//    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
    
    NSError * error;
    if (error)
    {
        NSLog(@"error in trackPageview %@", error);
    }

    [[MBLocationManager sharedManager] startLocationUpdates:kMBLocationManagerModeStandard
                                             distanceFilter:kCLDistanceFilterNone
                                                   accuracy:kCLLocationAccuracyNearestTenMeters];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLocation:)
                                                 name:kMBLocationManagerNotificationLocationUpdatedName
                                               object:nil];
    if (!self.geocoder)
    {
        self.geocoder = [[CLGeocoder alloc] init];
    }

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

#if TARGET_IPHONE_SIMULATOR
//    [[DCIntrospect sharedIntrospector] start];
#endif
    return YES;
}

- (void) applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
    [[Mixpanel sharedInstance] track:@"Sent to Background"];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
    [[Mixpanel sharedInstance] track:@"Brought to foreground"];

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void) applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) changeLocation:(NSNotification *)notification
{
    [[MBLocationManager sharedManager] stopLocationUpdates];

    CLLocation * location = [[MBLocationManager sharedManager] currentLocation];
    self.currentLocation = location;
    [self.geocoder reverseGeocodeLocation:location completionHandler:

     ^(NSArray * placemarks, NSError * error) {
         // Get nearby address
         CLPlacemark * placemark = [placemarks objectAtIndex:0];

         // String to hold address
         NSString * locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];

         // Print the location to console
         NSLog(@"I am currently at %@", locatedAt);
         self.currentLocationString = locatedAt;
     }];
}

@end
