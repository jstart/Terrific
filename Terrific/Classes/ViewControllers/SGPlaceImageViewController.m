//
//  SGPlaceImageViewController.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 9/1/12.
//
//

#import "SGPlaceImageViewController.h"
#import "SGPlace.h"

#import <Google-Maps-iOS-SDK/GoogleMaps/GoogleMaps.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
@import MapKit;

@interface SGPlaceImageViewController ()

@end

@implementation SGPlaceImageViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

+ (SGPlaceImageViewController *) placeImageViewControllerWithPlace:(MKMapItem *)place
{
    SGPlaceImageViewController *placeImageViewController = [[SGPlaceImageViewController alloc] init];
    
    placeImageViewController.place = place;
    [[placeImageViewController view] setFrame:CGRectMake(0, 0, 160, 100)];
    [placeImageViewController.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gplaypattern.png"]]];
    placeImageViewController.mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 100)];
    [placeImageViewController.view addSubview:placeImageViewController.mapImageView];
    
    CGRect overlayFrame = placeImageViewController.mapImageView.frame;
    overlayFrame.size.height = overlayFrame.size.height * 0.3;
    overlayFrame.origin.y = placeImageViewController.mapImageView.frame.size.height - overlayFrame.size.height;
    UIView *overlayView = [[UIView alloc] initWithFrame:overlayFrame];
    [overlayView setBackgroundColor:[UIColor blackColor]];
    [overlayView setAlpha:0.75];
    [placeImageViewController.mapImageView addSubview:overlayView];
    
    placeImageViewController.nameLabel = [[UILabel alloc] initWithFrame:overlayFrame];
    placeImageViewController.nameLabel.backgroundColor = [UIColor clearColor];
    placeImageViewController.nameLabel.textAlignment = NSTextAlignmentCenter;
    UIFont *font = [UIFont systemFontOfSize:14];
    [placeImageViewController.nameLabel setFont:font];
    [placeImageViewController.nameLabel setTextColor:[UIColor whiteColor]];
    placeImageViewController.nameLabel.text = place.name;
    [placeImageViewController.mapImageView addSubview:placeImageViewController.nameLabel];
    
    CLLocationDegrees lat = place.placemark.location.coordinate.latitude;
    CLLocationDegrees lon = place.placemark.location.coordinate.longitude;
    
    NSString *googleMapURL = [NSString stringWithFormat:@"http://cbk0.google.com/cbk?output=thumbnail&w=%d&h=%d&ll=%f,%f", 160, 100, lat, lon];
    [placeImageViewController.mapImageView setImageWithURL:[NSURL URLWithString:googleMapURL]];
//    GMSPanoramaView *panoView =
//    [GMSPanoramaView panoramaWithFrame:placeImageViewController.mapImageView.frame
//                        nearCoordinate:place.placemark.location.coordinate];
//    [placeImageViewController.mapImageView addSubview:panoView];
    return placeImageViewController;
}

+ (UIViewController *) blankViewController
{
    UIViewController *blankViewController = [[UIViewController alloc] init];
    
    [[blankViewController view] setFrame:CGRectMake(0, 0, 160, 100)];
    [[blankViewController view] setAlpha:0.0];
    return blankViewController;
}

@end
