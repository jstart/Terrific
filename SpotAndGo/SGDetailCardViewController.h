//
//  SGDetailCardViewController.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPFlipViewController.h"

@class SGPlace;

@protocol SGDetailCardViewDelegate <NSObject>

- (void) placeSelected:(SGPlace *)place;

@end

@interface SGDetailCardViewController : GAITrackedViewController <MPFlipViewControllerDataSource, MPFlipViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray * flipViewControllerArray;
@property (nonatomic, strong) id <SGDetailCardViewDelegate> delegate;

@end
