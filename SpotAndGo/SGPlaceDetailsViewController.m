//
//  SGPlaceDetailsViewController.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 9/1/12.
//
//

#import "SGPlaceDetailsViewController.h"
#import "SGPlace.h"

@import CoreLocation;
@import MapKit;
@import AddressBook;
@import QuartzCore;

@interface SGPlaceDetailsViewController ()

@end

@implementation SGPlaceDetailsViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

+ (SGPlaceDetailsViewController *) placeDetailsViewControllerWithPlace:(MKMapItem *)place
{
    SGPlaceDetailsViewController *placeDetailsViewController = [[SGPlaceDetailsViewController alloc] init];
    
    placeDetailsViewController.place = place;
    [placeDetailsViewController.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gplaypattern.png"]]];
    
    if (place.phoneNumber)
    {
        placeDetailsViewController.phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 160, 30)];
        
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:place.phoneNumber attributes:@{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) }];
        [placeDetailsViewController.phoneLabel setAttributedText:attrString];
        
        [placeDetailsViewController.phoneLabel setFont:[UIFont systemFontOfSize:18]];
        [placeDetailsViewController.phoneLabel setTextColor:[UIColor colorWithRed:0.268 green:0.260 blue:1.000 alpha:1.000]];
        [placeDetailsViewController.phoneLabel setContentMode:UIViewContentModeCenter];
        [placeDetailsViewController.phoneLabel setTextAlignment:NSTextAlignmentCenter];
        [placeDetailsViewController.phoneLabel setBackgroundColor:[UIColor clearColor]];
        [placeDetailsViewController.phoneLabel setUserInteractionEnabled:YES];
        
        [placeDetailsViewController.view addSubview:placeDetailsViewController.phoneLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:placeDetailsViewController action:@selector(handleTap)];
        tap.delegate = placeDetailsViewController;
        [placeDetailsViewController.phoneLabel addGestureRecognizer:tap];
    }
    
    UIButton *directionsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [directionsButton setFrame:CGRectMake(10, 55, 135, 30)];
    [directionsButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    directionsButton.backgroundColor = [UIColor clearColor];
    directionsButton.alpha = 0.8;
    directionsButton.layer.borderColor = [UIColor blackColor].CGColor;
    directionsButton.layer.borderWidth = 2;
    directionsButton.layer.cornerRadius = 10;
    [directionsButton setTitle:@"Directions" forState:UIControlStateNormal];
    [directionsButton addTarget:placeDetailsViewController action:@selector(getDirections) forControlEvents:UIControlEventTouchUpInside];
    [placeDetailsViewController.view addSubview:directionsButton];
    
    return placeDetailsViewController;
}

- (void) handleTap
{
    NSString *cleanedPhoneString = [[[self.phoneLabel.text stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    NSString *telephoneSchemeString = [NSString stringWithFormat:@"tel:1-%@", cleanedPhoneString];
    NSURL *phoneURL = [NSURL URLWithString:telephoneSchemeString];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL])
    {
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Your device can't make phone calls" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void) getDirections
{
    [MKMapItem openMapsWithItems:@[self.place] launchOptions:nil];
}

- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ((touch.view == self.phoneLabel))
    {
        return YES;
    }
    return NO;
}

@end
