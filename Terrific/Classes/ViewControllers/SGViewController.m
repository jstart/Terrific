//
//  SGViewController.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2014 Truman. All rights reserved.
//

#import "SGViewController.h"
#import <MBLocationManager/MBLocationManager.h>
#import "SGConstants.h"

@interface SGViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *background;

@end

@implementation SGViewController
@synthesize logoImageView, categoryButtons, mapViewController;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.navigationController isViewLoaded])
    {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
//    CLLocation *location = [MBLocationManager sharedManager].locationManager.location;

    // Do any additional setup after loading the view, typically from a nib.
    self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"map"];
    if (isPhone568) {
        self.background.image = [UIImage imageNamed:@"Default-568h@2x.png"];
    }else{
        self.background.image = [UIImage imageNamed:@"Default@2x.png"];
    }
}


- (void) viewWillAppear:(BOOL)animated
{
    [[Mixpanel sharedInstance] track:@"Main Menu Appeared"];
    
    if ([self.navigationController isNavigationBarHidden])
    {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (IBAction) buttonSelected:(id)sender
{
    [[MBLocationManager sharedManager] startLocationUpdates:kMBLocationManagerModeStandard
                                             distanceFilter:kCLDistanceFilterNone
                                                   accuracy:kCLLocationAccuracyNearestTenMeters];
    NSString *chosenCategory;
    switch (((UIButton *) sender).tag)
    {
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
    [[Mixpanel sharedInstance] track:@"chose" properties:[NSDictionary dictionaryWithObject:chosenCategory forKey:@"category"]];
    [[NSUserDefaults standardUserDefaults] setObject:chosenCategory forKey:@"category"];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

@end
