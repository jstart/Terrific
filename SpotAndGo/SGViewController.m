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
@synthesize logoImageView, categoryButtons;

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:226/255.0f green:225/255.0f blue:222/255.0f alpha:1]];
  [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  [self.navigationController setNavigationBarHidden:YES animated:NO];

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
      break;
    case 1:
      chosenCategory = @"shop";
      break;
    case 2:
      chosenCategory = @"watch";
      break;
    case 3:
      chosenCategory = @"play";
      break;      
    default:
      chosenCategory = @"eat";
      break;
  }
  [[NSUserDefaults standardUserDefaults] setObject:chosenCategory forKey:@"category"];
  [self performSegueWithIdentifier:@"map" sender:self];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
