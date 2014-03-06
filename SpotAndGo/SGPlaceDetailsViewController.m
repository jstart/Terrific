//
//  SGPlaceDetailsViewController.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 9/1/12.
//
//

#import "SGPlaceDetailsViewController.h"
#import "SGPlace.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#include <QuartzCore/QuartzCore.h>

@interface SGPlaceDetailsViewController ()

@end

@implementation SGPlaceDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

+(SGPlaceDetailsViewController*)placeDetailsViewControllerWithPlace:(SGPlace*)place{
    SGPlaceDetailsViewController * placeDetailsViewController = [[SGPlaceDetailsViewController alloc] init];

    placeDetailsViewController.place = place;
    [placeDetailsViewController.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gplaypattern.png"]]];
    
    if (![place.phone_number isKindOfClass:[NSNull class]] && ![place.phone_number isEqualToString:@""]) {
        
        placeDetailsViewController.phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake (0, 10, 160, 30)];
        
        NSAttributedString * attrString = [[NSAttributedString alloc] initWithString:place.phone_number attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}];
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
    
    UIButton * directionsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
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
    
//    placeDetailsViewController.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake (0, 115/2, 150, 40)];
//    [placeDetailsViewController.nameLabel setTextAlignment:NSTextAlignmentCenter];
//    placeDetailsViewController.nameLabel.backgroundColor = [UIColor clearColor];
//    [placeDetailsViewController.nameLabel setFont:font];
//    [placeDetailsViewController.nameLabel setTextColor:[UIColor blackColor]];
//    placeDetailsViewController.nameLabel.text = place.name;
//    [placeDetailsViewController.nameLabel setLineBreakMode:UILineBreakModeWordWrap];
//    [placeDetailsViewController.nameLabel setNumberOfLines:2];
//    [placeDetailsViewController.view addSubview:placeDetailsViewController.nameLabel];

    return placeDetailsViewController;
}

//#pragma mark -
//#pragma mark TTTAttributedLabelDelegate
//
//- (void)attributedLabel:(TTTAttributedLabel *)label
//didSelectLinkWithPhoneNumber:(NSString *)phoneNumber{
//    [self handleTap];
//}

-(void)handleTap{
    NSString * cleanedPhoneString = [[[self.phoneLabel.text stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    NSString * telephoneSchemeString = [NSString stringWithFormat:@"tel:1-%@", cleanedPhoneString];
    NSLog(@"%@", telephoneSchemeString);
    NSURL * phoneURL = [NSURL URLWithString:telephoneSchemeString];
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    }else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Your device can't make phone calls" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)getDirections{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.place.latitude doubleValue], [self.place.longitude doubleValue]);
    NSString * mapsURLFormatted = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@",coord.latitude, coord.longitude, self.place.street];
    if ([NSClassFromString(@"MKMapItem") instancesRespondToSelector:@selector(isCurrentLocation)]){
        NSDictionary * addressDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.place.street, kABPersonAddressStreetKey,
                                            self.place.city,kABPersonAddressCityKey,
                                            self.place.state,kABPersonAddressStateKey,
                                            self.place.postal_code,kABPersonAddressZIPKey, nil];
        MKPlacemark * placemark = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:addressDictionary];
        MKMapItem * mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:self.place.name];
        [mapItem setPhoneNumber:self.place.phone_number];
        if (![self.place.website isKindOfClass:[NSNull class]]) {
            [mapItem setUrl:[NSURL URLWithString:self.place.website]];
        }
        [MKMapItem openMapsWithItems:@[ mapItem ] launchOptions:nil];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapsURLFormatted]];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ((touch.view == self.phoneLabel)) {//change it to your condition
        return YES;
    }
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  self.screenName = self.place.name;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
