//
//  SGPlaceImageViewController.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 9/1/12.
//
//

#import <UIKit/UIKit.h>
@import MapKit;

@class SGPlace;

@interface SGPlaceImageViewController : UIViewController

@property (nonatomic, strong) MKMapItem *place;
@property (nonatomic, strong) UIImageView *mapImageView;
@property (nonatomic, strong) UILabel *nameLabel;

+ (SGPlaceImageViewController *) placeImageViewControllerWithPlace:(MKMapItem *)place;
+ (UIViewController *) blankViewController;

@end
