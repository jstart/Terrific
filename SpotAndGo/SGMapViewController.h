//
//  SGMapViewController.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SGDetailCardView.h"

@interface SGMapViewController : UIViewController<MKMapViewDelegate>{
  MKCoordinateRegion lastAnnotationsMapRegion;  
}
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) SGDetailCardView *placeResultCardView;
@property (strong, nonatomic) NSMutableArray *currentPlaces;
@property (strong, nonatomic) NSString * currentCategory;
@property (nonatomic) CLAuthorizationStatus authStatus;
@property (nonatomic, retain) NSArray * polylineArray;
@end

#pragma mark MapViewController

#define kDefaultCurrentLat 34.018661
#define kDefaultCurrentLng -118.49596
#define kDefaultLocationLatMeters 1600*1
#define kDefaultLocationLonMeters 1600*1
#define kDefaultZoomToStreetLatMeters 1600*1
#define kDefaultZoomToStreetLonMeters 1600*1
#define kMinLeftEdgePadding 30
#define kMinRightEdgePadding 30
#define kPinEdgePaddingSpan 0.002
#define kPinEdgePaddingPercent 10
#define kCenterPercentDeltaThreshold .6
#define kMinDegreeSpan .001
#define kSpanPercentDeltaThreshold .4