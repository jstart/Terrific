//
//  SGDetailCardViewController.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2014 Truman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPFlipViewController.h"
@import MapKit;

@protocol SGDetailCardViewDelegate <NSObject>

- (void) placeSelected:(MKMapItem *)place;

@end

@interface SGDetailCardViewController : UIViewController <MPFlipViewControllerDataSource, MPFlipViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *flipViewControllerArray;
@property (nonatomic, strong) id <SGDetailCardViewDelegate> delegate;

@end
