//
//  UIAsyncImageLoader.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIAsyncImageLoader.h"

@implementation UIAsyncImageLoader

+ (void)imageFromURL:(NSURL*)url andBlock:(void (^)(UIImage * image))imageBlock ErrorBlock:(void (^)(void))errorBlock {
  UIImageFromURL( url, imageBlock, errorBlock);
}

void UIImageFromURL( NSURL * URL, void (^imageBlock)(UIImage * image), void (^errorBlock)(void) )
{
  dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void)
                  {
                    NSData * data = [[NSData alloc] initWithContentsOfURL:URL];
                    UIImage * image = [[UIImage alloc] initWithData:data];
                    dispatch_async (dispatch_get_main_queue (), ^(void){
                                      if( image != nil )
                                      {
                                        imageBlock (image);
				      } else {
                                        errorBlock ();
				      }
				    });
		  });
}

@end
