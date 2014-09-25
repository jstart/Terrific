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
@import MapKit;

static SGNetworkManager *sharedManager;

@interface SGNetworkManager ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *requestOperationManager;

@end

@implementation SGNetworkManager

static NSString *PUBLISHER_ID = @"test";
static NSString *HOST = @"http://api.citygridmedia.com";
static NSString *LATLON_PATH = @"/content/places/v2/search/latlon";

+ (SGNetworkManager *) sharedManager
{
    if (sharedManager == nil)
    {
        sharedManager = [[SGNetworkManager alloc] init];
        sharedManager.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:HOST]];
        sharedManager.requestOperationManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        sharedManager.requestOperationManager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return sharedManager;
}

- (void) categorySearchWithCategory:(NSString *)category locationArray:(NSArray *)locationArray resultCount:(int)resultCount success:(void (^)(NSArray *placeArray))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *configDictionary = [[[NSUserDefaults alloc] initWithSuiteName:@"group.truman.Terrific"] objectForKey:category];
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = configDictionary[@"tag_name"];
    
    MKCoordinateRegion region;
    region.center.latitude = [locationArray[0] floatValue];
    region.center.longitude = [locationArray[1] floatValue];
    double spanAmount = [configDictionary[@"radius"] doubleValue] / 69.0;
    region.span = MKCoordinateSpanMake(spanAmount, spanAmount);
    request.region = region;
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response.mapItems.count > (NSUInteger)resultCount)
        {
            NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, resultCount)];
            success([response.mapItems objectsAtIndexes:indexSet]);
        }
        else if (response.mapItems.count)
        {
            success(response.mapItems);
        }else{
            failure(nil);
        }
    }];
}

@end
