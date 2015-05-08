//
//  SGMapViewController.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2014 Truman. All rights reserved.
//
#import "SGAppDelegate.h"
#import "SGMapViewController.h"
#import "SGNetworkManager.h"
#import "SGConstants.h"
#import "SVPulsingAnnotationView.h"
#import <TSMessages/TSMessageView.h>
#import <MBLocationManager/MBLocationManager.h>

@interface SGMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *currentPlaces;
@property (strong, nonatomic) NSString *currentCategory;
@property (nonatomic) CLAuthorizationStatus authStatus;

@end

@implementation SGMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TSMessage setDefaultViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[MBLocationManager sharedManager].locationManager startUpdatingLocation];
    
    [self.mapView setShowsUserLocation:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.currentCategory = [[[NSUserDefaults alloc] initWithSuiteName:@"group.truman.Terrific"] objectForKey:@"category"] ? : @"eat";
    self.title = self.currentCategory;
    
    self.authStatus = [CLLocationManager authorizationStatus];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ((_authStatus == kCLAuthorizationStatusAuthorizedAlways || _authStatus == kCLAuthorizationStatusAuthorizedWhenInUse) && self.mapView.userLocation.coordinate.latitude != 0.0f && self.mapView.userLocation.coordinate.longitude != 0.0f) {
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance([self.mapView userLocation].coordinate, kDefaultZoomToStreetLatMeters, kDefaultZoomToStreetLonMeters) animated:YES];
        [self performSearch];
    }
    else if (_authStatus == kCLAuthorizationStatusDenied || _authStatus == kCLAuthorizationStatusNotDetermined || _authStatus == kCLAuthorizationStatusRestricted) {
        [TSMessage showNotificationInViewController:self title:@"Location Disabled" subtitle:@"You can enable location for Terrific in your iPhone settings under \"Location Services\"." type:TSMessageNotificationTypeError duration:1.5 canBeDismissedByUser:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [TSMessage dismissActiveNotification];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]]) {
            [self.mapView removeAnnotation:annotation];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(userLocation.coordinate, kDefaultZoomToStreetLatMeters, kDefaultZoomToStreetLonMeters) animated:YES];
    [self performSearch];
}

- (void)performSearch {
    if ([self.mapView userLocation].coordinate.latitude == 0.0 && [self.mapView userLocation].coordinate.longitude == 0.0) {
        [TSMessage showNotificationInViewController:self title:@"Location Disabled" subtitle:@"You can enable location for Spot+Go in your iPhone settings under \"Location Services\"." type:TSMessageNotificationTypeError duration:1.5 canBeDismissedByUser:YES];
    }
    
    CLLocation *currentLocation = [[SGAppDelegate sharedAppDelegate] currentLocation];
    NSArray *locationArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:currentLocation.coordinate.latitude] ? [NSNumber numberWithFloat:currentLocation.coordinate.latitude] : [NSNumber numberWithFloat:kDefaultCurrentLat], [NSNumber numberWithFloat:[self.mapView userLocation].coordinate.longitude] ? [NSNumber numberWithFloat:[self.mapView userLocation].coordinate.longitude] : [NSNumber numberWithFloat:kDefaultCurrentLng], nil];
    
    //  NSArray * locationArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:kDefaultCurrentLat],[NSNumber numberWithFloat:kDefaultCurrentLng], nil];
    int numOfResults = 6;
    
    [[SGNetworkManager sharedManager] categorySearchWithCategory:self.currentCategory locationArray:locationArray resultCount:numOfResults success: ^(NSArray *placeArray) {
        [[Mixpanel sharedInstance] track:@"category_search" properties:@{ @"location":locationArray, @"category": self.currentCategory }];
        self.currentPlaces = [placeArray mutableCopy];
        
        
        [self.mapView addAnnotations:[placeArray valueForKeyPath:@"placemark"]];
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(self.mapView.userLocation.coordinate);
        MKMapRect zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        for (id <MKAnnotation> annotation in self.mapView.annotations) {
            MKMapPoint newAnnotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(newAnnotationPoint.x, newAnnotationPoint.y, 0.1, 0.1);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
        
        [self.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(44, 5, 5, 5) animated:YES];
    } failure: ^(NSError *error) {
        NSLog(@"error searching categories %@", error);
        [TSMessage showNotificationInViewController:self title:@"No Spots Found" subtitle:@"No great spots were found :( Try again somewhere else!" type:TSMessageNotificationTypeWarning];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;  // return nil to use default blue dot view
    }
    static NSString *identifier = @"currentLocation";
    SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (pulsingView == nil) {
        pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        pulsingView.annotationColor = [UIColor colorWithRed:0.831 green:0.592 blue:0.965 alpha:1.000];
    }
    
    return pulsingView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
}

@end
