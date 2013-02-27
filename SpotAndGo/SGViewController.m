//
//  SGViewController.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGViewController.h"

@interface SGViewController ()

@end

@implementation SGViewController
@synthesize logoImageView, categoryButtons, locationManager, mapViewController;

-(void)viewWillAppear:(BOOL)animated{
  [Flurry logAllPageViews:self.navigationController];
  [[Mixpanel sharedInstance] track:@"Main Menu Appeared"];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:226/255.0f green:225/255.0f blue:222/255.0f alpha:1]];
  if ([self.navigationController isNavigationBarHidden]) {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
  }else{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
  }
  [TestFlight passCheckpoint:@"SGViewController Appeared"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  self.trackedViewName = @"Menu";
  if ([self.navigationController isViewLoaded]) {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
  }else{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
  }
  self.locationManager = [[CLLocationManager alloc] init];
  [self.locationManager setPurpose:@"Spot+Go would like to show you cool spots near you!"];
  [self.locationManager setDelegate:self];
  [self.locationManager setDesiredAccuracy:10];
  [self.locationManager startUpdatingLocation];
  CLLocation *location = locationManager.location;
[Flurry setLatitude:location.coordinate.latitude            longitude:location.coordinate.longitude            horizontalAccuracy:location.horizontalAccuracy            verticalAccuracy:location.verticalAccuracy];
	// Do any additional setup after loading the view, typically from a nib.
  self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"map"];
}

- (void)viewDidUnload
{
    [self setLogoImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)buttonSelected:(id)sender{
  NSString * chosenCategory;
  switch (((UIButton*)sender).tag) {
    case 0:
      chosenCategory = @"eat";
      [TestFlight passCheckpoint:@"eat"];
      break;
    case 1:
      chosenCategory = @"shop";
      [TestFlight passCheckpoint:@"shop"];
      break;
    case 2:
      chosenCategory = @"watch";
      [TestFlight passCheckpoint:@"watch"];
      break;
    case 3:
      chosenCategory = @"play";
      [TestFlight passCheckpoint:@"play"];
      break;      
    default:
      chosenCategory = @"eat";
      [TestFlight passCheckpoint:@"invalid category"];
      break;
  }
  [[Mixpanel sharedInstance] track:@"chose" properties:[NSDictionary dictionaryWithObject:chosenCategory forKey:@"category"]];
  [Flurry logEvent:@"chose" withParameters:[NSDictionary dictionaryWithObject:chosenCategory forKey:@"category"]];
  [[NSUserDefaults standardUserDefaults] setObject:chosenCategory forKey:@"category"];
  [self.navigationController pushViewController:mapViewController animated:YES];
  [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"Category Choice" withAction:chosenCategory withLabel:@"Chose Category" withValue:@(0)];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
