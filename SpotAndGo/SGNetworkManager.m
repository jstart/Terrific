//
//  SGNetworkManager.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 9/1/12.
//
//

#import "SGNetworkManager.h"
#import "SVHTTPClient.h"
#import "SGPlace.h"

static SGNetworkManager * sharedManager;

@implementation SGNetworkManager

+(SGNetworkManager*)sharedManager{
    if (sharedManager == nil) {
        sharedManager = [[SGNetworkManager alloc] init];
    }
    return sharedManager;
}

-(void)categorySearchWithCategory:(NSString*)category locationArray:(NSArray*)locationArray success:(void (^)(NSArray * placeArray))success failure:(void (^)(NSError * error))failure {
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjectsAndKeys:category,@"category",locationArray,@"location", nil];
    
    [[SVHTTPClient sharedClient] setSendParametersAsJSON:YES];
    [[SVHTTPClient sharedClient] POST:@"category" parameters:postDictionary completion:^(id response, NSError * error){
        NSLog (@"%@", response);
        NSMutableArray * placeArray = [NSMutableArray array];
        for (NSDictionary * placeDictionary in response) {
            SGPlace * place = [SGPlace objectWithDictionary:placeDictionary];
            [placeArray addObject:place];
        }
        success(placeArray);
        if (error)
            failure(error);
    }];
}

@end
