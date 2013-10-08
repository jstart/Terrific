//
//  SGNetworkManager.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 9/1/12.
//
//

#import "SGNetworkManager.h"
#import "SGPlace.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>

static SGNetworkManager * sharedManager;

@interface SGNetworkManager ()

@property (nonatomic, strong) AFHTTPRequestOperationManager * requestOperationManager;

@end

@implementation SGNetworkManager

static NSString * PUBLISHER_ID = @"test";
static NSString * HOST = @"http://api.citygridmedia.com";
static NSString * LATLON_PATH = @"/content/places/v2/search/latlon";

+(SGNetworkManager*)sharedManager{
    if (sharedManager == nil) {
        sharedManager = [[SGNetworkManager alloc] init];
        sharedManager.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:HOST]];
        sharedManager.requestOperationManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        sharedManager.requestOperationManager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return sharedManager;
}

-(void)categorySearchWithCategory:(NSString*)category locationArray:(NSArray*)locationArray resultCount:(int)resultCount success:(void (^)(NSArray * placeArray))success failure:(void (^)(NSError * error))failure {
    NSDictionary * configDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:category];
    NSDictionary * postDictionary =  @{@"what": configDictionary[@"tag_name"], @"lat": locationArray[0], @"lon" : locationArray[1], @"rpp":@(resultCount), @"radius" : configDictionary[@"radius"], @"publisher":PUBLISHER_ID, @"format":@"json"};
    NSString * trackingString = [NSString stringWithFormat:@"%@ %@,%@", category, [locationArray objectAtIndex:0], [locationArray objectAtIndex:1]];
    [TestFlight passCheckpoint:trackingString];
    [[Mixpanel sharedInstance] track:@"category_search" properties:postDictionary];

    [self.requestOperationManager POST:LATLON_PATH parameters:postDictionary success:^(AFHTTPRequestOperation *urlResponse, id responseObject){
        responseObject = responseObject[@"results"][@"locations"];
        if ([responseObject isKindOfClass:[NSArray class]] && [responseObject count] > 0) {
            if ([[responseObject objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
                NSMutableArray * placeArray = [NSMutableArray array];
                for (NSDictionary * placeDictionary in responseObject) {
                    SGPlace * place = [SGPlace objectWithDictionary:placeDictionary];
                    [placeArray addObject:place];
                }
//                placeArray = [[self arrayByRemovingDupesFromArray:placeArray] mutableCopy];

                success(placeArray);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        failure(error);
    }];
}

-(NSArray *)arrayByRemovingDupesFromArray:(NSArray*)placesArray{
    NSMutableArray * dedupedArray = [NSMutableArray array];
    for (SGPlace * place in placesArray) {
        for (SGPlace * otherPlace in placesArray) {
            if (place == otherPlace) {
                break;
            }
            NSRange nameRange = [place.name rangeOfString:otherPlace.name options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound) {
                break;
            }
            if (place.latitude == otherPlace.latitude && place.longitude == otherPlace.longitude) {
                break;
            }
            if ([place.phone_number isEqualToString: otherPlace.phone_number]) {
                break;
            }
        }
        [dedupedArray addObject:place];
    }
    return [dedupedArray copy];
}

@end
