//
//  SGMapViewController.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
@import CoreLocation;
#import "SGDetailCardViewController.h"

#pragma mark MapViewController

#define kDefaultCurrentLat            34.018661
#define kDefaultCurrentLng            -118.49596
#define kDefaultZoomToStreetLatMeters 1600 * 1
#define kDefaultZoomToStreetLonMeters 1600 * 1
#define kPinEdgePaddingSpan           0.02

@interface SGMapViewController : GAITrackedViewController <MKMapViewDelegate, SGDetailCardViewDelegate>

@property (strong, nonatomic) MKMapView * mapView;
@property (strong, nonatomic) SGDetailCardViewController * placeResultCardViewController;
@property (strong, nonatomic) NSMutableArray * currentPlaces;
@property (strong, nonatomic) NSString * currentCategory;
@property (nonatomic) CLAuthorizationStatus authStatus;
@property (nonatomic, retain) NSArray * polylineArray;

@end
