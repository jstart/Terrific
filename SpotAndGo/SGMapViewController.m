//
//  SGMapViewController.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGMapViewController.h"
#import "SGDetailCardView.h"
#import "SVHTTPClient.h"
#import "CTLocationDataManagerResult.h"
#import "CLTickerView.h"
#import "FLImageView.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@interface SGMapViewController ()

@end

@implementation SGMapViewController
@synthesize mapView;
@synthesize placeResultCardView, currentPlaces, currentCategory;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chosePlace:) name:@"choice" object:nil];
  [self.mapView setShowsUserLocation:YES];
  [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
  [self.navigationController setNavigationBarHidden:NO animated:YES];
  [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:226/255.0f green:225/255.0f blue:222/255.0f alpha:1]];
  self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spotgo_logo.png"]];
  self.placeResultCardView = [[SGDetailCardView alloc] initWithFrame:CGRectMake(0, 216, 320, 200)];
  [[self view] addSubview:placeResultCardView];
  currentCategory = [[NSUserDefaults standardUserDefaults] objectForKey:@"category"];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(kDefaultCurrentLat, kDefaultCurrentLng), kDefaultZoomToStreetLatMeters, kDefaultZoomToStreetLonMeters)];
  [self performSearch];
}

-(void)performSearch{
//    NSArray * locationArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:[self.mapView userLocation].coordinate.latitude]?[NSNumber numberWithFloat:[self.mapView userLocation].coordinate.latitude]:[NSNumber numberWithFloat:kDefaultCurrentLat],[NSNumber numberWithFloat:[self.mapView userLocation].coordinate.longitude]?[NSNumber numberWithFloat:[self.mapView userLocation].coordinate.longitude]:[NSNumber numberWithFloat:kDefaultCurrentLng], nil];
  
  NSArray * locationArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:kDefaultCurrentLat],[NSNumber numberWithFloat:kDefaultCurrentLng], nil];
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjectsAndKeys:currentCategory,@"category",locationArray,@"location", nil];
    [[SVHTTPClient sharedClient] setSendParametersAsJSON:YES];
    [[SVHTTPClient sharedClient] POST:@"category" parameters:postDictionary completion:^(id response, NSError * error){
      NSLog(@"%@", response);
      if ([(NSArray*)response count]>0) {
        self.currentPlaces = (NSMutableArray*)response;
        NSMutableArray * array = [NSMutableArray array];
        for (NSDictionary * dict in response) {
          CTLocationDataManagerResult * annotation = [[CTLocationDataManagerResult alloc] init];
          [annotation setTitle:[dict objectForKey:@"name"]];
          CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[dict objectForKey:@"latitude"] floatValue], [[dict objectForKey:@"longitude"] floatValue]);
          [annotation setCoordinate:coordinate];
          [array addObject:annotation];  
        }
        [self updateResultCards];
        //adjust map region
        lastAnnotationsMapRegion = [self regionOfAnnotations:array];
        [self.mapView setRegion:lastAnnotationsMapRegion];
        [self.mapView addAnnotations:array];
      }
      
    }];
}

-(void)updateResultCards{
  for (int i = 0; i< [self.currentPlaces count]; i++) {
    NSDictionary * dict = [self.currentPlaces objectAtIndex:i];
    NSLog(@"updating... %@", [dict objectForKey:@"name"]);
    UIButton * currentView = [self.placeResultCardView.subviews objectAtIndex:i];
    for (UIView * subview in [currentView subviews]) {
      [subview  removeFromSuperview];
    }
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 150, 20)];
    [label setText:[dict objectForKey:@"name"]];
    UIFont * font = [UIFont fontWithName:@"Futura-Medium" size:14];
    [label setFont:font];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    
    float lat = [[dict objectForKey:@"latitude"] floatValue];
    float lon = [[dict objectForKey:@"longitude"] floatValue];
    
    NSString * googleMapURL = [NSString stringWithFormat:@"http://cbk0.google.com/cbk?output=thumbnail&w=%d&h=%d&ll=%f,%f", 155, 95,lat, lon];
            
    UIImageFromURL( [NSURL URLWithString:googleMapURL], ^( UIImage * image )
    {
      [currentView setImage:image forState:UIControlStateNormal];
    }, ^(void){
      [currentView setBackgroundColor:[UIColor blackColor]];
      NSLog(@"%@",@"error!");
    });
    [currentView addSubview:label];
    [currentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gplaypattern.png"]]];
  }
}

void UIImageFromURL( NSURL * URL, void (^imageBlock)(UIImage * image), void (^errorBlock)(void) )
{
  dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void)
                 {
                   NSData * data = [[NSData alloc] initWithContentsOfURL:URL];
                   UIImage * image = [[UIImage alloc] initWithData:data];
                   dispatch_async( dispatch_get_main_queue(), ^(void){
                     if( image != nil )
                     {
                       imageBlock( image );
                     } else {
                       errorBlock();
                     }
                   });
                 });
}


-(void)chosePlace:(NSNotification*)notification{
  int choice = [[[notification userInfo] objectForKey:@"choice"] intValue];
  if ([[self.mapView annotations] count] >= choice) {
    [[self mapView] selectAnnotation:[[self.mapView annotations] objectAtIndex:choice] animated:YES];
    [self getDirections:choice];
    UIView * currentView = [[[self placeResultCardView] subviews] objectAtIndex:choice];
    //  [self animateView:currentView WithDirection:0];
    [self verticalFlip:currentView WithDuration:1];
    
    NSLog(@"%@", [[notification userInfo] objectForKey:@"choice"]);
  }
 
}

- (void)verticalFlip:(UIView*)yourView WithDuration:(int)duration{
  NSDictionary * currentPlaceDict = [[self currentPlaces] objectAtIndex:yourView.tag];
  [UIView animateWithDuration:duration animations:^{
    yourView.layer.transform = CATransform3DMakeRotation(M_PI_2,1.0,0.0,0.0); //flip halfway
  } completion:^(BOOL complete){
    while ([yourView.subviews count] > 0)
      [[yourView.subviews lastObject] removeFromSuperview]; // remove all subviews
    // Add your new views here 
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 115/2, 150, 40)];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    nameLabel.layer.transform = CATransform3DMakeRotation(M_PI, 1.0f, 0.0f, 0.0f);
    nameLabel.layer.shouldRasterize = TRUE;
    nameLabel.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [nameLabel setText:[currentPlaceDict objectForKey:@"name"]];
    UIFont * font = [UIFont fontWithName:@"Futura-Medium" size:14];

    [nameLabel setFont:font];
    [nameLabel setLineBreakMode:UILineBreakModeWordWrap];
    [nameLabel setNumberOfLines:2];
    UILabel * phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
    [phoneLabel setBackgroundColor:[UIColor clearColor]];
    phoneLabel.layer.transform = CATransform3DMakeRotation(M_PI, 1.0f, 0.0f, 0.0f);
    phoneLabel.layer.shouldRasterize = TRUE;
    phoneLabel.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [phoneLabel setText:[currentPlaceDict objectForKey:@"phone"]];
    [phoneLabel setFont:font];
    [yourView addSubview:nameLabel];
     [yourView addSubview:phoneLabel];
    [UIView animateWithDuration:duration animations:^{
      yourView.layer.transform = CATransform3DMakeRotation(M_PI,1.0,0.0,0.0); //finish the flip
    } completion:^(BOOL complete){
      // Flip completion code here
    }];
  }];
}

-(void)getDirections:(int)placeInteger{
  NSString * start_latitude = [NSString stringWithFormat:@"%f",kDefaultCurrentLat];//[self.mapView userLocation].coordinate.latitude];
  NSString * start_longitude = [NSString stringWithFormat:@"%f",kDefaultCurrentLng];//[self.mapView userLocation].coordinate.longitude];
  NSString * destination_latitude = [NSString stringWithFormat:@"%f",[[[currentPlaces objectAtIndex:placeInteger] objectForKey:@"latitude"] floatValue]];
  NSString * destionation_longitude = [NSString stringWithFormat:@"%f",[[[currentPlaces objectAtIndex:placeInteger] objectForKey:@"longitude"] floatValue]];
  NSDictionary * postDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    start_latitude,@"current_latitude",
                                    start_longitude,@"current_longitude",
                                    destination_latitude,
                                   @"destination_latitude",
                                   destionation_longitude
                                   ,@"destination_longitude", nil];
  [[SVHTTPClient sharedClient] setSendParametersAsJSON:YES];
  [[SVHTTPClient sharedClient] POST:@"location" parameters:postDictionary completion:^(id response, NSError * error){
    NSLog(@"%@", (NSArray*)response);
    
    if (![response isKindOfClass:[NSData class]]&&![response isKindOfClass:[NSArray class]]) {
      [UIView animateWithDuration:1 delay:3 options:UIViewAnimationCurveEaseIn animations:^{
        self.placeResultCardView.layer.transform = CATransform3DMakeRotation(M_PI_2,1.0,0.0,0.0); //flip halfway
      } completion:^(BOOL complete){
        while ([self.placeResultCardView.subviews count] > 0)
          [[self.placeResultCardView.subviews lastObject] removeFromSuperview]; // remove all subviews
        NSArray * directionsArray = [response objectForKey:@"directions"];
        UITextView * scrollv = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        NSMutableString * string = [[NSMutableString alloc] init];
        for (NSString * aString in directionsArray) {
          [string appendString:aString];
          [string appendString:@"\n"];
        }
        [self.placeResultCardView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gplaypattern.png"]]];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        [label setText:string];
        [label setBackgroundColor:[UIColor clearColor]];
        UIFont * font = [UIFont fontWithName:@"Futura-Medium" size:14];
        [label setFont:font];
        [label setLineBreakMode:UILineBreakModeWordWrap];
        [label setNumberOfLines:0];
        label.layer.shouldRasterize = TRUE;
        label.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        [scrollv addSubview:label];
        scrollv.layer.transform = CATransform3DMakeRotation(M_PI, 1.0f, 0.0f, 0.0f);
        scrollv.layer.shouldRasterize = TRUE;
        scrollv.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        [self.placeResultCardView addSubview:scrollv];
        [UIView animateWithDuration:1 animations:^{
          self.placeResultCardView.layer.transform = CATransform3DMakeRotation(M_PI,1.0,0.0,0.0); //finish the flip
          self.placeResultCardView.layer.shouldRasterize = TRUE;
          self.placeResultCardView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
          
        } completion:^(BOOL complete){
          // Flip completion code here
        }];
      }];
    }
    

  }];

}
// Returns a adjust region of the map view that contains at least one annotation, with the same center point.
// if there are annotations fall into the current mapview region, it will return the current mapview region,
// otherwise, it will zoom to the region that contain all the annotations.

- (MKCoordinateRegion)adjustRegionForAnnotations:(NSArray*)annotations {
  MKCoordinateRegion adjustRegion = [self minRegionThatHasAnnotations:annotations];
  if ([self hasVisibleAnnotations] && self.mapView.region.span.latitudeDelta < 0.1 && self.mapView.region.span.longitudeDelta < 0.1) {
    return self.mapView.region;
  }
  else {
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
  }
  else {
    //the first one is nearest onle
    minAnnotation = [annotations objectAtIndex:0];
    
    MKCoordinateSpan span;
    span.latitudeDelta = 2 * fabs(minAnnotation.coordinate.latitude - self.mapView.centerCoordinate.latitude) + kPinEdgePaddingSpan;
    span.longitudeDelta = 2 * fabs(minAnnotation.coordinate.longitude  - self.mapView.centerCoordinate.longitude) + kPinEdgePaddingSpan;
    MKCoordinateRegion newRegion = MKCoordinateRegionMake(self.mapView.centerCoordinate, span);
    return [self.mapView regionThatFits: newRegion];
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
  }
  else {
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

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
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

-(void)animateView:(UIView *)view WithDirection:(int)direction
{
  CALayer *layer = view.layer;
  CATransform3D initialTransform = view.layer.transform;
  initialTransform.m34 = 1.0 / -1000;
  
  [self setAnchorPoint:CGPointMake(-0.3, 0.5) forView:view];
  
  
  [UIView beginAnimations:@"Scale" context:nil];
  [UIView setAnimationDuration:1];
  [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
  layer.transform = initialTransform;
  
  
  CATransform3D rotationAndPerspectiveTransform = view.layer.transform;
  if (direction == 1) {
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI , 0 , 0, 0);
  }else if(direction == 0){
  rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI , view.bounds.size.width , 0, 0);
  }
  
  layer.transform = rotationAndPerspectiveTransform;
  
  [UIView setAnimationDelegate:self];
  [UIView commitAnimations];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setMapView:nil];
  [self setPlaceResultCardView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
