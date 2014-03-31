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
#import <TSMessages/TSMessageView.h>

@interface SGMapViewController ()

@end

@implementation SGMapViewController

@synthesize mapView;
@synthesize currentPlaces, currentCategory, authStatus, polylineArray;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        [TSMessage setDefaultViewController:self];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.placeResultCardViewController = [[SGDetailCardViewController alloc] init];
    [self.placeResultCardViewController setDelegate:self];

    int rowNumber = isPhone568 ? 3 : 2;
    int mapHeight = SYSTEM_VERSION_GREATER_THAN(@"6.1.4") ? [UIScreen mainScreen].bounds.size.height - 100 * rowNumber : [UIScreen mainScreen].bounds.size.height - 100 * rowNumber - 44 - 20;
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

- (void) viewWillAppear:(BOOL)animated
{
    [self.mapView setShowsUserLocation:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.currentCategory = [[NSUserDefaults standardUserDefaults] objectForKey:@"category"];
    self.title = self.currentCategory;
    self.authStatus = [CLLocationManager authorizationStatus];
}

- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    NSDictionary * appearance = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIColor blackColor], NSForegroundColorAttributeName,
                                 [UIColor grayColor], NSShadowAttributeName, nil];
    UIBarButtonItem * item = self.navigationController.navigationItem.backBarButtonItem;

    [item setTitleTextAttributes:appearance forState:UIControlStateNormal];
    [TestFlight passCheckpoint:@"SGMapViewController Appeared"];
    if (authStatus == kCLAuthorizationStatusAuthorized)
    {
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance([self.mapView userLocation].coordinate, kDefaultZoomToStreetLatMeters, kDefaultZoomToStreetLonMeters) animated:YES];

        [self performSearch];
    }
    else
    {
        [TestFlight passCheckpoint:@"locationDisabled"];
        [TSMessage showNotificationInViewController:self title:@"Location Disabled" subtitle:@"You can enable location for Spot+Go in your iPhone settings under \"Location Services\"." type:TSMessageNotificationTypeError duration:1.5 canBeDismissedByUser:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
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
}

- (void) performSearch
{
    if ([self.mapView userLocation].coordinate.latitude == 0.0 && [self.mapView userLocation].coordinate.longitude == 0.0)
    {
        [TSMessage showNotificationInViewController:self title:@"Location Disabled" subtitle:@"You can enable location for Spot+Go in your iPhone settings under \"Location Services\"." type:TSMessageNotificationTypeError duration:1.5 canBeDismissedByUser:YES];
    }
    [TestFlight passCheckpoint:@"performSearch"];
    CLLocation * currentLocation = [[SGAppDelegate sharedAppDelegate] currentLocation];
    NSArray * locationArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:currentLocation.coordinate.latitude] ? [NSNumber numberWithFloat:currentLocation.coordinate.latitude]:[NSNumber numberWithFloat:kDefaultCurrentLat], [NSNumber numberWithFloat:[self.mapView userLocation].coordinate.longitude] ? [NSNumber numberWithFloat:[self.mapView userLocation].coordinate.longitude]:[NSNumber numberWithFloat:kDefaultCurrentLng], nil];

//  NSArray * locationArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:kDefaultCurrentLat],[NSNumber numberWithFloat:kDefaultCurrentLng], nil];
    int numOfResults = isPhone568 ? 6 : 4;
    [[SGNetworkManager sharedManager]categorySearchWithCategory:currentCategory locationArray:locationArray resultCount:numOfResults success: ^(NSArray * placeArray) {
         self.currentPlaces = [placeArray mutableCopy];
         NSMutableArray * annotationsArray = [NSMutableArray array];
         for (SGPlace * place in self.currentPlaces)
         {
             SGAnnotation * annotation = [[SGAnnotation alloc] init];
             [annotation setTitle:place.name];

             CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([place.latitude floatValue], [place.longitude floatValue]);
             [annotation setCoordinate:coordinate];
             [annotationsArray addObject:annotation];
         }

         [self.mapView addAnnotations:annotationsArray];

         MKMapPoint annotationPoint = MKMapPointForCoordinate(self->mapView.userLocation.coordinate);
         MKMapRect zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
         for (id <MKAnnotation> annotation in self->mapView.annotations)
         {
             MKMapPoint newAnnotationPoint = MKMapPointForCoordinate(annotation.coordinate);
             MKMapRect pointRect = MKMapRectMake(newAnnotationPoint.x, newAnnotationPoint.y, 0.1, 0.1);
             zoomRect = MKMapRectUnion(zoomRect, pointRect);
         }

         if (SYSTEM_VERSION_LESS_THAN(@"6.1.4"))
         {
             [self->mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(35, 5, 5, 5) animated:YES];
         }
         else
         {
             [self->mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(44, 5, 5, 5) animated:YES];
         }

         [self updateResultCards];
     } failure: ^(NSError * error) {
         NSLog(@"error searching categories %@", error);
         [TSMessage showNotificationInViewController:self title:@"Location Disabled" subtitle:@"You can enable location for Spot+Go in your iPhone settings under \"Location Services\"." type:TSMessageNotificationTypeError duration:1.5 canBeDismissedByUser:YES];
         [TSMessage showNotificationInViewController:self title:@"No Spots Found" subtitle:@"No great spots were found :( Try again somewhere else!" type:TSMessageNotificationTypeWarning];
     }];
}

- (void) updateResultCards
{
    int totalPlaces = isPhone568 ? 6 : 4;
    NSInteger remainingPlaces = totalPlaces - [self.currentPlaces count];

    for (int i = totalPlaces - 1; i > remainingPlaces; i--)
    {
        MPFlipViewController * currentView = [self.placeResultCardViewController.flipViewControllerArray objectAtIndex:i];
        UIViewController * placeImageViewController = [SGPlaceImageViewController blankViewController];
        [currentView setViewController:placeImageViewController direction:MPFlipViewControllerDirectionForward animated:NO completion:nil];
    }
    for (int i = 0; i < (int) [self.currentPlaces count]; i++)
    {
        SGPlace * place = [self.currentPlaces objectAtIndex:i];
        NSLog(@"updating... %@", place.name);
        MPFlipViewController * currentView = [self.placeResultCardViewController.flipViewControllerArray objectAtIndex:i];
        SGPlaceImageViewController * placeImageViewController = [SGPlaceImageViewController placeImageViewControllerWithPlace:place];
        [currentView setViewController:placeImageViewController direction:MPFlipViewControllerDirectionForward animated:YES completion:nil];
    }
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation
{
    return nil;
}

# pragma mark - MKMapViewDelegate

- (void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
}

#pragma mark - SGDetailCardViewDelegate

- (void) placeSelected:(SGPlace *)place
{
    SGAnnotation * chosenAnnotation;

    for (SGAnnotation * annotation in[self.mapView annotations])
    {
        if ([annotation respondsToSelector:@selector(title)])
        {
            if ([annotation.title isEqualToString:place.name])
            {
                [TestFlight passCheckpoint:[NSString stringWithFormat:@"tapped tile for business %@", annotation.title]];
                [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"tapped tile for business %@", annotation.title]];
                [Flurry logEvent:[NSString stringWithFormat:@"tapped tile for business %@", annotation.title]];
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
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];

    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1 :
            {
                NSString * trimmedString = [[[[alertView.message stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
                NSString * phoneURLString = [NSString stringWithFormat:@"tel:%@", trimmedString];
                NSURL * phoneURL = [NSURL URLWithString:phoneURLString];
                [[UIApplication sharedApplication] openURL:phoneURL];
            }
            break;

        default :
            break;
    }
}

@end
