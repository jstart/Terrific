//
//  SGNetworkManager.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 9/1/12.
//
//

#import <Foundation/Foundation.h>

@interface SGNetworkManager : NSObject

+ (SGNetworkManager *) sharedManager;

- (void) categorySearchWithCategory:(NSString *)category locationArray:(NSArray *)locationArray resultCount:(int)resultCount success:(void (^)(NSArray *placeArray))success failure:(void (^)(NSError *error))failure;

@end
