//
//  SGPlaceDetailsViewController.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 9/1/12.
//
//

#import <UIKit/UIKit.h>

@import MapKit;

@interface SGPlaceDetailsViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) MKMapItem *place;
@property (nonatomic, strong) UIImageView *mapImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UIButton *directionsButton;

+ (SGPlaceDetailsViewController *) placeDetailsViewControllerWithPlace:(MKMapItem *)place;

@end
