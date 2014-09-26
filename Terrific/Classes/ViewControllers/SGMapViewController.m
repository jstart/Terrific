//
//  SGMapViewController.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2014 Truman. All rights reserved.
//
#import "SGAppDelegate.h"
#import "SGMapViewController.h"
#import "SGDetailCardViewController.h"
#import "SGPlaceImageViewController.h"
#import "SGNetworkManager.h"
#import "SGPlace.h"
#import "SGAnnotation.h"
#import "SGConstants.h"
#import <TSMessages/TSMessageView.h>
#import <MBLocationManager/MBLocationManager.h>

@interface SGMapViewController ()

@end

@implementation SGMapViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [TSMessage setDefaultViewController:self];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.placeResultCardViewController setDelegate:self];
    
    int rowNumber = isPhone568 ? 3 : 2;
    int mapHeight = [UIScreen mainScreen].bounds.size.height - 100 * rowNumber;
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, mapHeight)];
    [self.mapView setDelegate:self];
    [self.view addSubview:self.mapView];
    
    NSDictionary *appearance = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor], NSForegroundColorAttributeName,
                                [UIColor grayColor], NSShadowAttributeName, nil];
    UIBarButtonItem *item = self.navigationController.navigationItem.backBarButtonItem;
    
    [item setTitleTextAttributes:appearance forState:UIControlStateNormal];
}

- (SGDetailCardViewController *) placeResultCardViewController
{
    if (_placeResultCardViewController == nil)
    {
        _placeResultCardViewController = [[SGDetailCardViewController alloc] init];
        int rowNumber = isPhone568 ? 3 : 2;
        int mapHeight = [UIScreen mainScreen].bounds.size.height - 100 * rowNumber;
        
        int resultsHeight = [UIScreen mainScreen].bounds.size.height - mapHeight;
        [_placeResultCardViewController.view setFrame:CGRectMake(0, mapHeight, [UIScreen mainScreen].bounds.size.width, resultsHeight)];
        
        [_placeResultCardViewController addObserver:self forKeyPath:@"view.frame" options:NSKeyValueObservingOptionNew context:NULL];
        [self addChildViewController:_placeResultCardViewController];
        [[self view] addSubview:_placeResultCardViewController.view];
        [_placeResultCardViewController didMoveToParentViewController:self];
    }
    
    return _placeResultCardViewController;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[MBLocationManager sharedManager].locationManager startUpdatingLocation];

    [self.mapView setShowsUserLocation:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.currentCategory = [[[NSUserDefaults alloc] initWithSuiteName:@"group.truman.Terrific"] objectForKey:@"category"];
    self.title = self.currentCategory;

    self.authStatus = [CLLocationManager authorizationStatus];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ((_authStatus == kCLAuthorizationStatusAuthorizedAlways || _authStatus == kCLAuthorizationStatusAuthorizedWhenInUse) && self.mapView.userLocation.coordinate.latitude != 0.0f && self.mapView.userLocation.coordinate.longitude != 0.0f )
    {
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance([self.mapView userLocation].coordinate, kDefaultZoomToStreetLatMeters, kDefaultZoomToStreetLonMeters) animated:YES];
        
        [self performSearch];
    }
    else if(_authStatus == kCLAuthorizationStatusDenied || _authStatus == kCLAuthorizationStatusNotDetermined || _authStatus == kCLAuthorizationStatusRestricted)
    {
        [TSMessage showNotificationInViewController:self title:@"Location Disabled" subtitle:@"You can enable location for Terrific in your iPhone settings under \"Location Services\"." type:TSMessageNotificationTypeError duration:1.5 canBeDismissedByUser:YES];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [TSMessage dismissActiveNotification];
}

- (void) viewDidDisappear:(BOOL)animated
{
    for (id <MKAnnotation> annotation in self.mapView.annotations)
    {
        if (![annotation isKindOfClass:[MKUserLocation class]])
        {
            [self.mapView removeAnnotation:annotation];
        }
    }
    for (UIView *view in self.placeResultCardViewController.view.subviews)
    {
        [view removeFromSuperview];
    }
    _placeResultCardViewController = nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(userLocation.coordinate, kDefaultZoomToStreetLatMeters, kDefaultZoomToStreetLonMeters) animated:YES];
    [self performSearch];
}

- (void) performSearch
{
    if ([self.mapView userLocation].coordinate.latitude == 0.0 && [self.mapView userLocation].coordinate.longitude == 0.0)
    {
        [TSMessage showNotificationInViewController:self title:@"Location Disabled" subtitle:@"You can enable location for Spot+Go in your iPhone settings under \"Location Services\"." type:TSMessageNotificationTypeError duration:1.5 canBeDismissedByUser:YES];
    }
    
    CLLocation *currentLocation = [[SGAppDelegate sharedAppDelegate] currentLocation];
    NSArray *locationArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:currentLocation.coordinate.latitude] ? [NSNumber numberWithFloat:currentLocation.coordinate.latitude]:[NSNumber numberWithFloat:kDefaultCurrentLat], [NSNumber numberWithFloat:[self.mapView userLocation].coordinate.longitude] ? [NSNumber numberWithFloat:[self.mapView userLocation].coordinate.longitude]:[NSNumber numberWithFloat:kDefaultCurrentLng], nil];
    
    //  NSArray * locationArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:kDefaultCurrentLat],[NSNumber numberWithFloat:kDefaultCurrentLng], nil];
    int numOfResults = isPhone568 ? 6 : 4;
    
    [[SGNetworkManager sharedManager] categorySearchWithCategory:self.currentCategory locationArray:locationArray resultCount:numOfResults success: ^(NSArray *placeArray) {
        [[Mixpanel sharedInstance] track:@"category_search" properties:@{@"location":locationArray, @"category": self.currentCategory}];
        self.currentPlaces = [placeArray mutableCopy];
        
        
        [self.mapView addAnnotations:[placeArray valueForKeyPath:@"placemark"]];
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(self.mapView.userLocation.coordinate);
        MKMapRect zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        for (id <MKAnnotation> annotation in self.mapView.annotations)
        {
            MKMapPoint newAnnotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(newAnnotationPoint.x, newAnnotationPoint.y, 0.1, 0.1);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
        
        [self.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(44, 5, 5, 5) animated:YES];
        
        [self updateResultCards];
    } failure: ^(NSError *error) {
        NSLog(@"error searching categories %@", error);
        [TSMessage showNotificationInViewController:self title:@"No Spots Found" subtitle:@"No great spots were found :( Try again somewhere else!" type:TSMessageNotificationTypeWarning];
    }];
}

- (void) updateResultCards
{
    int totalPlaces = isPhone568 ? 6 : 4;
    NSInteger remainingPlaces = totalPlaces - [self.currentPlaces count];
    
    for (int i = totalPlaces - 1; i > remainingPlaces; i--)
    {
        MPFlipViewController *currentView = [self.placeResultCardViewController.flipViewControllerArray objectAtIndex:i];
        UIViewController *placeImageViewController = [SGPlaceImageViewController blankViewController];
        [currentView setViewController:placeImageViewController direction:MPFlipViewControllerDirectionForward animated:NO completion:nil];
    }
    for (int i = 0; i < (int) [self.currentPlaces count]; i++)
    {
        MKMapItem *mapItem = [self.currentPlaces objectAtIndex:i];
        MPFlipViewController *currentView = [self.placeResultCardViewController.flipViewControllerArray objectAtIndex:i];
        SGPlaceImageViewController *placeImageViewController = [SGPlaceImageViewController placeImageViewControllerWithPlace:mapItem];
        [currentView setViewController:placeImageViewController direction:MPFlipViewControllerDirectionForward animated:YES completion:nil];
    }
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation
{
    return nil;
}

#pragma mark - SGDetailCardViewDelegate

- (void) placeSelected:(SGPlace *)place
{
    SGAnnotation *chosenAnnotation;
    
    for (SGAnnotation *annotation in[self.mapView annotations])
    {
        if ([annotation respondsToSelector:@selector(title)])
        {
            if ([annotation.title isEqualToString:place.name])
            {
                [[Mixpanel sharedInstance] track:@"tapped business" properties:@{ @"business" : annotation.title }];
                chosenAnnotation = annotation;
            }
        }
    }
    if (chosenAnnotation != nil)
    {
        [self.mapView selectAnnotation:chosenAnnotation animated:YES];
    }
}

- (void) displayAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1 :
        {
            NSString *trimmedString = [[[[alertView.message stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
            NSString *phoneURLString = [NSString stringWithFormat:@"tel:%@", trimmedString];
            NSURL *phoneURL = [NSURL URLWithString:phoneURLString];
            [[UIApplication sharedApplication] openURL:phoneURL];
        }
            break;
        default:
            break;
    }
}

@end
