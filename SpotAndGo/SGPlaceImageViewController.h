//
//  SGPlaceImageViewController.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 9/1/12.
//
//

#import <UIKit/UIKit.h>

@class SGPlace;

@interface SGPlaceImageViewController : GAITrackedViewController

@property (nonatomic, strong) SGPlace * place;
@property (nonatomic, strong) UIImageView * mapImageView;
@property (nonatomic, strong) UILabel * nameLabel;

+(SGPlaceImageViewController*)placeImageViewControllerWithPlace:(SGPlace*)place;
+(SGPlaceImageViewController*)blankViewController;

@end
