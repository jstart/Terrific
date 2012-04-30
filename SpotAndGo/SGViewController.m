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
@synthesize logoImageView, categoryButtons, locationManager;

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:226/255.0f green:225/255.0f blue:222/255.0f alpha:1]];
  [self.navigationController setNavigationBarHidden:YES animated:YES];
  [TestFlight passCheckpoint:@"SGViewController Appeared"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  if ([self.navigationController isNavigationBarHidden]) {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
  }else{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
  }
  self.locationManager = [[CLLocationManager alloc] init];
  [self.locationManager setPurpose:@"Spot+Go would like to show you cool spots near you!"];
  [self.locationManager setDelegate:self];
  [self.locationManager setDesiredAccuracy:10];
  [self.locationManager startUpdatingLocation];
  
	// Do any additional setup after loading the view, typically from a nib.
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
  [[NSUserDefaults standardUserDefaults] setObject:chosenCategory forKey:@"category"];
  [self performSegueWithIdentifier:@"map" sender:self];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
