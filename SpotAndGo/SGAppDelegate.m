//
//  SGAppDelegate.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGAppDelegate.h"
#import "SVHTTPClient.h"
#import "SGConstants.h"
#import "RCLocationManager.h"
#import "OpenUDID.h"
#import "YRDropdownView.h"
#import "DCIntrospect.h"

@interface SGAppDelegate()

@property (nonatomic, strong) NSString* currentLocationString;

@end

@implementation SGAppDelegate

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;
static NSString* const kAnalyticsAccountId = @"UA-31324397-1";

@synthesize window = _window;

-(BOOL)application:(UIApplication *)application 
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions { 

    [[SVHTTPClient sharedClient] setBasePath:kBaseURL];
    [MixpanelAPI sharedAPIWithToken:@"8ed4b958846a5a4f2336e6ed19687a20"];
    [[MixpanelAPI sharedAPI] identifyUser:[OpenUDID value]];
    [FlurryAnalytics startSession:@"FJX9G2A6P8VGCM5736M7"];
    [FlurryAnalytics setUserID:[OpenUDID value]];
    
    [TestFlight takeOff:@"30d92a896df4ab4b4873886ea58f8b06_NzE0NzIyMDEyLTAzLTE0IDEzOjQ0OjU4Ljk3MDAxOQ"];

    [TestFlight setDeviceIdentifier:[OpenUDID value]];
    [[MixpanelAPI sharedAPI] track:@"Launched"];
        
    [[GANTracker sharedTracker] startTrackerWithAccountID:kAnalyticsAccountId
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    NSError *error;
    [[GANTracker sharedTracker] trackPageview:@"/app_entry_point"
                                    withError:&error];
    if (error) {
        NSLog(@"error in trackPageview %@", error);
    }

    if (!self.locationManager) {
        self.locationManager = [[RCLocationManager alloc] initWithUserDistanceFilter:kCLLocationAccuracyHundredMeters userDesiredAccuracy:kCLLocationAccuracyBest purpose:@"Spot and Go would like to show you nearby businesses and activities." delegate:self];
        [self.locationManager startUpdatingLocation];
    }
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
#if TARGET_IPHONE_SIMULATOR
    [[DCIntrospect sharedIntrospector] start];
#endif
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  
  NSError *error;
  if (![[GANTracker sharedTracker] trackEvent:@"Application iOS"
                                      action:@"Background iOS"
                                       label:@"Example iOS"
                                       value:0
                                   withError:&error]) {
  NSLog(@"error in trackEvent");
  }
  [[MixpanelAPI sharedAPI] track:@"Sent to Background"];
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  NSError *error;
  if (![[GANTracker sharedTracker] trackEvent:@"Application iOS"
                                       action:@"Foreground iOS"
                                        label:@"Example iOS"
                                        value:0
                                    withError:&error]) {
    NSLog(@"error in trackEvent");
  }
  [[MixpanelAPI sharedAPI] track:@"Brought to foreground"];

  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  NSError *error;
  if (![[GANTracker sharedTracker] trackEvent:@"Application iOS"
                                       action:@"Quit iOS"
                                        label:@"Example iOS"
                                        value:0
                                    withError:&error]) {
    NSLog(@"error in trackEvent");
  }
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - RCLocationManagerDelegate

- (void)locationManager:(RCLocationManager *)manager didFailWithError:(NSError *)error{
    [YRDropdownView showDropdownInView:self.window.rootViewController.view
                                 title:@"Location Disabled"
                                detail:@"You can enable location for Spot+Go in your iPhone settings under \"Location Services\"."
                                 image:[UIImage imageNamed:@"dropdown-alert"]
                              animated:YES
                             hideAfter:3];
}

- (void)locationManager:(RCLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    self.currentLocation = newLocation;
    [self.geocoder reverseGeocodeLocation:self.locationManager.location completionHandler:
     
     ^(NSArray *placemarks, NSError *error) {
         //Get nearby address
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
    
         //String to hold address
         NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
    
         //Print the location to console
         NSLog(@"I am currently at %@",locatedAt);
         self.currentLocationString = locatedAt;
     }];
}

- (void)locationManager:(RCLocationManager *)manager didEnterRegion:(CLRegion *)region{
    
}

- (void)locationManager:(RCLocationManager *)manager didExitRegion:(CLRegion *)region{
    
}

- (void)locationManager:(RCLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    
}

@end
