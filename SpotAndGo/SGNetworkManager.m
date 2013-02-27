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

-(void)categorySearchWithCategory:(NSString*)category locationArray:(NSArray*)locationArray resultCount:(int)resultCount success:(void (^)(NSArray * placeArray))success failure:(void (^)(NSError * error))failure {
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjectsAndKeys:category,@"category",locationArray,@"location", @(resultCount), @"result_count", nil];
    NSString * trackingString = [NSString stringWithFormat:@"%@ %@,%@", category, [locationArray objectAtIndex:0], [locationArray objectAtIndex:1]];
    [TestFlight passCheckpoint:trackingString];
    [[Mixpanel sharedInstance] track:@"category_search" properties:postDictionary];
    [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"Category Search" withAction:trackingString withLabel:@"Category Search" withValue:@(0)];

    [[SVHTTPClient sharedClient] setSendParametersAsJSON:YES];
    [[SVHTTPClient sharedClient] POST:@"category" parameters:postDictionary completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error){
        if (error) {
            NSLog(@"category search error %@", error);
        }
        if ([response isKindOfClass:[NSArray class]] && [response count] > 0) {
            if ([[response objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
                NSMutableArray * placeArray = [NSMutableArray array];
                for (NSDictionary * placeDictionary in response) {
                    SGPlace * place = [SGPlace objectWithDictionary:placeDictionary];
                    [placeArray addObject:place];
                }
                success(placeArray);
                [self checkForDupes:placeArray];
            }
        }else{
            failure(error);
        }
    }];
}

-(void)checkForDupes:(NSArray*)placesArray{
    for (SGPlace * place in placesArray) {
        for (SGPlace * otherPlace in placesArray) {
            if (place == otherPlace) {
                return;
            }
            NSRange nameRange = [place.name rangeOfString:otherPlace.name options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound) {
              [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"Found Duplicate" withAction:place.name withLabel:@"Found Duplicate Name" withValue:@(0)];
            }
            if ([place.latitude isEqualToString: otherPlace.latitude] && [place.longitude isEqualToString: otherPlace.longitude]) {
              [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"Found Duplicate" withAction:place.name withLabel:@"Found Duplicate LatLon" withValue:@(0)];
            }
            if ([place.phone_number isEqualToString: otherPlace.phone_number]) {
[[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"Found Duplicate" withAction:place.name withLabel:@"Found Duplicate Phone" withValue:@(0)];
            }
        }
    }
}

@end
