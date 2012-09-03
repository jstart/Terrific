//
//  SGMapViewController.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "SGMapViewController.h"
#import "SGDetailCardViewController.h"
#import "SGPlaceImageViewController.h"
#import "SGNetworkManager.h"
#import "SGPlace.h"
#import "SGAnnotation.h"

#import "YRDropdownView.h"


@interface SGMapViewController ()

@end

@implementation SGMapViewController

@synthesize mapView;
@synthesize currentPlaces, currentCategory, authStatus, polylineArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization

  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [self.mapView setDelegate:self];
  self.placeResultCardViewController = [[SGDetailCardViewController alloc] init];
  [self.placeResultCardViewController setDelegate:self];
  [self.placeResultCardViewController.view setFrame:CGRectMake(0, 216, 320, 244)];
  [self addChildViewController:self.placeResultCardViewController];
  [[self view] addSubview:self.placeResultCardViewController.view];
  [self.placeResultCardViewController didMoveToParentViewController:self];
  [[GANTracker sharedTracker] trackPageview:@"/map"
                                  withError:nil];
  [self.mapView setShowsUserLocation:YES];

  [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    
  [self.navigationController setNavigationBarHidden:NO animated:YES];
  [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:226/255.0f green:225/255.0f blue:222/255.0f alpha:1]];

  
  self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spotgo_logo.png"]];
  
  currentCategory = [[NSUserDefaults standardUserDefaults] objectForKey:@"category"];
  authStatus = [CLLocationManager authorizationStatus];
}

- (void)viewDidAppear:(BOOL)animated {
  NSDictionary * appearance = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIColor blackColor], UITextAttributeTextColor,
                               [UIColor grayColor], UITextAttributeTextShadowColor, nil];
  UIBarButtonItem * item = self.navigationController.navigationItem.backBarButtonItem;
  [item setTitleTextAttributes:appearance forState:UIControlStateNormal];
  [TestFlight passCheckpoint:@"SGMapViewController Appeared"];
  if (authStatus == kCLAuthorizationStatusAuthorized) {
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance([self.mapView userLocation].coordinate, kDefaultZoomToStreetLatMeters, kDefaultZoomToStreetLonMeters) animated:YES];
    
    [self performSearch];
  } else{
    [TestFlight passCheckpoint:@"locationDisabled"];
    [YRDropdownView showDropdownInView:self.view
     title:@"Location Disabled"
     detail:@"You can enable location for Spot+Go in your iPhone settings under \"Location Services\"."
     image:[UIImage imageNamed:@"dropdown-alert"]
     animated:YES
     hideAfter:3];
  }
}

-(void)viewDidDisappear:(BOOL)animated{
  [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void)performSearch {
  [TestFlight passCheckpoint:@"performSearch"];
  NSArray * locationArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:[self.mapView userLocation].coordinate.latitude] ?[NSNumber numberWithFloat:[self.mapView userLocation].coordinate.latitude]:[NSNumber numberWithFloat:kDefaultCurrentLat],[NSNumber numberWithFloat:[self.mapView userLocation].coordinate.longitude] ?[NSNumber numberWithFloat:[self.mapView userLocation].coordinate.longitude]:[NSNumber numberWithFloat:kDefaultCurrentLng], nil];

//  NSArray * locationArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:kDefaultCurrentLat],[NSNumber numberWithFloat:kDefaultCurrentLng], nil];
    [[SGNetworkManager sharedManager]categorySearchWithCategory:currentCategory locationArray:locationArray success:^(NSArray * placeArray){
        self.currentPlaces = [placeArray mutableCopy];
        NSMutableArray * annotationsArray = [NSMutableArray array];
        for (SGPlace * place in self.currentPlaces) {
            SGAnnotation * annotation = [[SGAnnotation alloc] init];
            [annotation setTitle:place.name];
            [[GANTracker sharedTracker] trackEvent:@"show_square"
                                                 action:@"flip"
                                                  label:place.name
                                                  value:0
                                         withError:nil];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake ([place.latitude floatValue], [place.longitude floatValue]);
            [annotation setCoordinate:coordinate];
            [annotationsArray addObject:annotation];
        }
        lastAnnotationsMapRegion = [self regionOfAnnotations:annotationsArray];
        [self.mapView setRegion:lastAnnotationsMapRegion animated:YES];
        [self.mapView addAnnotations:annotationsArray];
        [self updateResultCards];
    } failure:^(NSError* error){
        NSLog(@"error searching categories %@", error);
        [YRDropdownView showDropdownInView:self.view
                                     title:@"No Spots Found"
                                    detail:@"No great spots were found :( Try again!"
                                     image:[UIImage imageNamed:@"dropdown-alert"]
                                  animated:YES
                                 hideAfter:3];
    }];       
}

- (void)updateResultCards {
  for (int i = 0; i< [self.currentPlaces count]; i++) {
    SGPlace * place = [self.currentPlaces objectAtIndex:i];
    NSLog(@"updating... %@", place.name);
    MPFlipViewController * currentView = [self.placeResultCardViewController.flipViewControllerArray objectAtIndex:i];
    SGPlaceImageViewController * placeImageViewController = [SGPlaceImageViewController placeImageViewControllerWithPlace:place];
    [currentView setViewController:placeImageViewController direction:MPFlipViewControllerDirectionForward animated:YES completion:nil];
  }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {

  return nil;
}


# pragma mark - MKMapViewDelegate

- (void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
}

// Returns a adjust region of the map view that contains at least one annotation, with the same center point.
// if there are annotations fall into the current mapview region, it will return the current mapview region,
// otherwise, it will zoom to the region that contain all the annotations.

- (MKCoordinateRegion)adjustRegionForAnnotations:(NSArray*)annotations {
  MKCoordinateRegion adjustRegion = [self minRegionThatHasAnnotations:annotations];
  if ([self hasVisibleAnnotations] && self.mapView.region.span.latitudeDelta < 0.1 && self.mapView.region.span.longitudeDelta < 0.1) {
    return self.mapView.region;
  } else {
    return adjustRegion;
  }
}

- (MKCoordinateRegion)regionThatFitAnnotations:(NSArray*)annotations {
  CLLocationDegrees latDistanceMin = fabs(lastAnnotationsMapRegion.center.latitude - 0.5 * lastAnnotationsMapRegion.span.latitudeDelta - self.mapView.centerCoordinate.latitude);
  CLLocationDegrees latDistanceMax = fabs(lastAnnotationsMapRegion.center.latitude + 0.5 * lastAnnotationsMapRegion.span.latitudeDelta - self.mapView.centerCoordinate.latitude);
  CLLocationDegrees lonDistanceMin = fabs(lastAnnotationsMapRegion.center.longitude - 0.5 * lastAnnotationsMapRegion.span.longitudeDelta - self.mapView.centerCoordinate.longitude);
  CLLocationDegrees lonDistanceMax = fabs(lastAnnotationsMapRegion.center.longitude + 0.5 * lastAnnotationsMapRegion.span.longitudeDelta - self.mapView.centerCoordinate.longitude);

  CLLocationDegrees latDistance = kPinEdgePaddingSpan + ((latDistanceMax > latDistanceMin) ? latDistanceMax : latDistanceMin);
  CLLocationDegrees lonDistance = kPinEdgePaddingSpan + ((lonDistanceMax > lonDistanceMin) ? lonDistanceMax : lonDistanceMin);


  MKCoordinateSpan span;
  span.latitudeDelta =  2 * latDistance;
  span.longitudeDelta = 2 * lonDistance;

  MKCoordinateRegion newRegion = MKCoordinateRegionMake(self.mapView.centerCoordinate, span);
  return newRegion;
}

//return a mapRegion that has at least one annotations
- (MKCoordinateRegion)minRegionThatHasAnnotations:(NSArray*)annotations {
  id<MKAnnotation> minAnnotation = nil;
  if (![annotations count]) {
    return self.mapView.region;
  } else {
    //the first one is nearest onle
    minAnnotation = [annotations objectAtIndex:0];

    MKCoordinateSpan span;
    span.latitudeDelta = 2 * fabs(minAnnotation.coordinate.latitude - self.mapView.centerCoordinate.latitude) + kPinEdgePaddingSpan;
    span.longitudeDelta = 2 * fabs(minAnnotation.coordinate.longitude  - self.mapView.centerCoordinate.longitude) + kPinEdgePaddingSpan;
    MKCoordinateRegion newRegion = MKCoordinateRegionMake(self.mapView.centerCoordinate, span);
    return [self.mapView regionThatFits:newRegion];
  }
}

- (MKCoordinateRegion)regionOfAnnotations:(NSArray*)annotations {

  CLLocationDegrees maxLat = -90;
  CLLocationDegrees maxLon = -180;
  CLLocationDegrees minLat = 90;
  CLLocationDegrees minLon = 180;
  for (id<MKAnnotation> annotation in annotations) {
    if (annotation.coordinate.latitude > maxLat) {
      maxLat = annotation.coordinate.latitude;
    }
    if (annotation.coordinate.latitude < minLat) {
      minLat = annotation.coordinate.latitude;
    }
    if (annotation.coordinate.longitude > maxLon) {
      maxLon = annotation.coordinate.longitude;
    }
    if (annotation.coordinate.longitude < minLon) {
      minLon = annotation.coordinate.longitude;
    }
  }
  if ([annotations count] > 0) {
    CLLocationCoordinate2D newCenter;
    newCenter.latitude = 0.5 *(minLat + maxLat);
    newCenter.longitude = 0.5 * (minLon + maxLon);
    return MKCoordinateRegionMake(newCenter, MKCoordinateSpanMake(fabs(minLat - maxLat), fabs(minLon - maxLon)));
  } else {
    return self.mapView.region;
  }
}

//return true if  the region contains the coorinate
- (BOOL)mapRegion:(MKCoordinateRegion)mapRegion containsCoordinate:(CLLocationCoordinate2D)coordinate {
  return ((fabs(coordinate.latitude - mapRegion.center.latitude) <= 0.5 * mapRegion.span.latitudeDelta) &&
          (fabs(coordinate.longitude - mapRegion.center.longitude) <= 0.5 * mapRegion.span.longitudeDelta));
}

//current mapview has visible annotations
- (BOOL)hasVisibleAnnotations {

  for (id<MKAnnotation> annotation in self.mapView.annotations) {
    if ([self coordinateIsVisible:annotation.coordinate]) {

      //we found a visible annotation, just return;
      return YES;
    }
  }
  return NO;
}

- (BOOL)coordinateIsVisible:(CLLocationCoordinate2D)coordinate {
  CGPoint annPoint = [self.mapView convertCoordinate:coordinate
                      toPointToView:self.mapView];

  return (annPoint.x > 0.0 && annPoint.y > 0.0 &&
          annPoint.x < self.mapView.frame.size.width &&
          annPoint.y < self.mapView.frame.size.height);
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
  CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
  CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);

  newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
  oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);

  CGPoint position = view.layer.position;

  position.x -= oldPoint.x;
  position.x += newPoint.x;

  position.y -= oldPoint.y;
  position.y += newPoint.y;

  view.layer.position = position;
  view.layer.anchorPoint = anchorPoint;
}

#pragma mark - SGDetailCardViewDelegate

-(void)placeSelected:(SGPlace*)place{
    SGAnnotation * chosenAnnotation;
    for (SGAnnotation * annotation in [self.mapView annotations]) {
        if ([annotation.title isEqualToString:place.name]) {
            if (![[GANTracker sharedTracker] trackEvent:@"show_directions"
                                                 action:@"flip"
                                                  label:place.name
                                                  value:0
                                              withError:nil])
            
            [TestFlight passCheckpoint:[NSString stringWithFormat:@"tapped tile for business %@",annotation.title]];
            [[MixpanelAPI sharedAPI] track:[NSString stringWithFormat:@"tapped tile for business %@",annotation.title]];
            [FlurryAnalytics logEvent:[NSString stringWithFormat:@"tapped tile for business %@",annotation.title]];
            chosenAnnotation = annotation;
        }
    }
    if (chosenAnnotation != nil) {
        [self.mapView selectAnnotation:chosenAnnotation animated:YES];
    }
}

-(void) displayAlert:(NSString*) title message:(NSString*) message {
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	[alert show];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
  [self setMapView:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  switch (buttonIndex) {
    case 1:
    {
      NSString * trimmedString = [[[[alertView.message stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
      NSString *phoneURLString = [NSString stringWithFormat:@"tel:%@", trimmedString];
      NSURL *phoneURL = [NSURL URLWithString:phoneURLString];
      [[UIApplication sharedApplication] openURL:phoneURL];
    }
      break;
      
    default:
      break;
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
