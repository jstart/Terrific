//
//  UIButton+AsyncLoader.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIButton+AsyncLoader.h"

@implementation UIButton (AsyncLoader)

-(void)loadImageFromURL:(NSString *)urlString{
  [UIAsyncImageLoader imageFromURL:[NSURL URLWithString:urlString] andBlock:^(UIImage * image)
   {
     [self setImage:image forState:UIControlStateNormal];
     [self setUserInteractionEnabled:YES];
   } ErrorBlock:^(void){
     NSLog (@"error! could not load url: %@", urlString);
   }];
}

-(void)loadImageFromURL:(NSString *)urlString withActivityIndicator:(BOOL)activityIndicator style:(UIActivityIndicatorViewStyle)style{
  UIActivityIndicatorView * view = nil;
  if (activityIndicator) {
    view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    view.frame = self.frame;
    view.tag = 500;
    [self addSubview:view];
    [view startAnimating];
  }
  
  [UIAsyncImageLoader imageFromURL:[NSURL URLWithString:urlString] andBlock:^(UIImage * image)
   {
     [self setImage:image forState:UIControlStateNormal];
     [self setUserInteractionEnabled:YES];
     UIActivityIndicatorView * activityView = [self viewWithTag:500];
     if (activityView != nil) {
       [activityView stopAnimating];
       [activityView removeFromSuperview];
     }
   }
   ErrorBlock:^(void){
     NSLog (@"error! could not load url: %@", urlString);
     UIActivityIndicatorView * activityView = [self viewWithTag:500];
     if (activityView != nil) {
       [activityView stopAnimating];
       [activityView removeFromSuperview];
     }
   }];
}

@end
