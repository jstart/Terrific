//
//  SGPlaceDetailsViewController.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 9/1/12.
//
//

#import <UIKit/UIKit.h>

@class SGPlace;

@interface SGPlaceDetailsViewController : UIViewController <NIAttributedLabelDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) SGPlace * place;
@property (nonatomic, strong) NINetworkImageView * mapImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) NIAttributedLabel * phoneLabel;
@property (nonatomic, strong) UIButton * directionsButton;

+(SGPlaceDetailsViewController*)placeDetailsViewControllerWithPlace:(SGPlace*)place;

@end
