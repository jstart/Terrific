//
//  SGMapViewController.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "SGAppDelegate.h"
#import "SGMapViewController.h"
#import "SGDetailCardViewController.h"
#import "SGPlaceImageViewController.h"
#import "SGNetworkManager.h"
#import "SGPlace.h"
#import "SGAnnotation.h"
#import "SGConstants.h"
#import "YRDropdownView.h"
#import <UINavigationBar+FlatUI.h>
#import <UIBarButtonItem+FlatUI.h>

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


- (void)viewDidLoad
{
  [super viewDidLoad];
  self.screenName = self.currentCategory;
  // Do any additional setup after loading the view.

  self.placeResultCardViewController = [[SGDetailCardViewController alloc] init];
  [self.placeResultCardViewController setDelegate:self];
  
  int rowNumber = isPhone568 ? 3:2;
  int mapHeight = SYSTEM_VERSION_GREATER_THAN(@"6.1.3") ? [UIScreen mainScreen].bounds.size.height - 100 * rowNumber : [UIScreen mainScreen].bounds.size.height - 100 * rowNumber - 44 - 20;
  self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, mapHeight)];
  [self.mapView setDelegate:self];
  [self.view addSubview:self.mapView];
  
  int resultsHeight = [UIScreen mainScreen].bounds.size.height - mapHeight;
  [self.placeResultCardViewController.view setFrame:CGRectMake(0, mapHeight, 320, resultsHeight)];
  
  [self.placeResultCardViewController addObserver:self forKeyPath:@"view.frame" options:NSKeyValueObservingOptionNew context:NULL];
  [self addChildViewController:self.placeResultCardViewController];
  [[self view] addSubview:self.placeResultCardViewController.view];
  [self.placeResultCardViewController didMoveToParentViewController:self];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
  [self.mapView setShowsUserLocation:YES];
  [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (SYSTEM_VERSION_LESS_THAN(@"6.1.4")) {
        [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor colorWithRed:0.719 green:0.716 blue:0.707 alpha:1.000]];
    }

  self.currentCategory = [[NSUserDefaults standardUserDefaults] objectForKey:@"category"];
  self.title = self.currentCategory;
  self.authStatus = [CLLocationManager authorizationStatus];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//  if([keyPath isEqualToString:@"view.frame"]) {
//    CGRect oldFrame = CGRectNull;
//    CGRect newFrame = CGRectNull;
//    if([change objectForKey:@"old"] != [NSNull null]) {
//	    oldFrame = [[change objectForKey:@"old"] CGRectValue];
//    }
//    if([object valueForKeyPath:keyPath] != [NSNull null]) {
//	    newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
//      int rowNumber = isPhone568 ? 3:2;
//      int mapHeight = [UIScreen mainScreen].bounds.size.height - 44 - 20 - 100 * rowNumber;
//      int resultsHeight = [UIScreen mainScreen].bounds.size.height - 44 - mapHeight - 20;
//      if (newFrame.size.height != resultsHeight) {
//        CGRect frame = ((UIViewController *) object).view.frame;
//        frame.size.height = resultsHeight;
//        [((UIViewController *) object).view setFrame:frame];
//	    }
//    }
//  }
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
  [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
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
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]]) {
            [self.mapView removeAnnotation:annotation];
        }
    }
}

- (void)performSearch {
  [TestFlight passCheckpoint:@"performSearch"];
  CLLocation * currentLocation = [[SGAppDelegate sharedAppDelegate] currentLocation];
  NSArray * locationArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:currentLocation.coordinate.latitude] ?[NSNumber numberWithFloat:currentLocation.coordinate.latitude]:[NSNumber numberWithFloat:kDefaultCurrentLat],[NSNumber numberWithFloat:[self.mapView userLocation].coordinate.longitude] ?[NSNumber numberWithFloat:[self.mapView userLocation].coordinate.longitude]:[NSNumber numberWithFloat:kDefaultCurrentLng], nil];

//  NSArray * locationArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:kDefaultCurrentLat],[NSNumber numberWithFloat:kDefaultCurrentLng], nil];
  int numOfResults = isPhone568 ? 6 : 4;
  [[SGNetworkManager sharedManager]categorySearchWithCategory:currentCategory locationArray:locationArray resultCount:numOfResults success:^(NSArray * placeArray){
      self.currentPlaces = [placeArray mutableCopy];
      NSMutableArray * annotationsArray = [NSMutableArray array];
      for (SGPlace * place in self.currentPlaces) {
          SGAnnotation * annotation = [[SGAnnotation alloc] init];
          [annotation setTitle:place.name];

          CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake ([place.latitude floatValue], [place.longitude floatValue]);
          [annotation setCoordinate:coordinate];
          [annotationsArray addObject:annotation];
      }
      
      [self.mapView addAnnotations:annotationsArray];
      
      MKMapPoint annotationPoint = MKMapPointForCoordinate(mapView.userLocation.coordinate);
      MKMapRect zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
      for (id <MKAnnotation> annotation in mapView.annotations)
      {
          MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
          MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
          zoomRect = MKMapRectUnion(zoomRect, pointRect);
      }
      
      if (SYSTEM_VERSION_LESS_THAN(@"6.1.4")) {
          [mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(35, 5, 5, 5) animated:YES];
      }else{
          [mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(44, 5, 5, 5) animated:YES];
      }
      
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
    NSInteger totalPlaces = isPhone568 ? 6:4;
    NSInteger remainingPlaces = totalPlaces - [self.currentPlaces count];
    for (int i = totalPlaces - 1; i > remainingPlaces; i--) {
        MPFlipViewController * currentView = [self.placeResultCardViewController.flipViewControllerArray objectAtIndex:i];
        SGPlaceImageViewController * placeImageViewController = [SGPlaceImageViewController blankViewController];
        [currentView setViewController:placeImageViewController direction:MPFlipViewControllerDirectionForward animated:NO completion:nil];
    }
  for (int i = 0; i < [self.currentPlaces count]; i++) {
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


#pragma mark - SGDetailCardViewDelegate

-(void)placeSelected:(SGPlace*)place{
    SGAnnotation * chosenAnnotation;
    for (SGAnnotation * annotation in [self.mapView annotations]) {
      if ([annotation respondsToSelector:@selector(title)]) {
        if ([annotation.title isEqualToString:place.name]) {
            
            [TestFlight passCheckpoint:[NSString stringWithFormat:@"tapped tile for business %@",annotation.title]];
            [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"tapped tile for business %@",annotation.title]];
            [Flurry logEvent:[NSString stringWithFormat:@"tapped tile for business %@",annotation.title]];
            chosenAnnotation = annotation;
        }
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
