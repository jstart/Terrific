//
//  UIImageView+AsyncLoader.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+AsyncLoader.h"

@implementation UIImageView (AsyncLoader)

-(void)loadImageFromURL:(NSString *)urlString{
  [UIAsyncImageLoader imageFromURL:[NSURL URLWithString:urlString] andBlock:^(UIImage * image)
   {
     [self setImage:image];
   } ErrorBlock:^(void){
     NSLog (@"error! could not load url: %@", urlString);
   }];
}

-(void)loadImageFromURL:(NSString *)urlString withActivityIndicator:(BOOL)activityIndicator style:(UIActivityIndicatorViewStyle)style{
  UIActivityIndicatorView * view = nil;
  if (activityIndicator) {
    view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    view.frame = self.frame;
    [self addSubview:view];
    [view startAnimating];
  }
  [UIAsyncImageLoader imageFromURL:[NSURL URLWithString:urlString] andBlock:^(UIImage * image)
   {
     [self setImage:image];
     if (view != nil) {
       [view stopAnimating];
       [view removeFromSuperview];
     }
   } ErrorBlock:^(void){
     NSLog (@"error! could not load url: %@", urlString);
     if (view != nil) {
       [view stopAnimating];
       [view removeFromSuperview];
     }
   }];
}


@end
