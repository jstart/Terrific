//
//  UIImageView+AsyncLoader.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAsyncImageLoader.h"

@interface UIImageView (AsyncLoader)

-(void)loadImageFromURL:(NSString *)urlString withActivityIndicator:(BOOL)activityIndicator style:(UIActivityIndicatorViewStyle)style;
-(void)loadImageFromURL:(NSString*)urlString;

@end
