//
//  UIAsyncImageLoader.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIAsyncImageLoader : NSObject
+(void)imageFromURL:(NSURL*)url andBlock:(void (^)(UIImage * image))imageBlock ErrorBlock: (void (^)(void))errorBlock;

@end
