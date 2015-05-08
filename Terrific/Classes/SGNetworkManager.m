//
//  SGNetworkManager.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 9/1/12.
//
//

#import "SGNetworkManager.h"
@import MapKit;

static SGNetworkManager *sharedManager;

@interface SGNetworkManager ()

@end

@implementation SGNetworkManager

+ (SGNetworkManager *)sharedManager {
    if (sharedManager == nil) {
        sharedManager = [[SGNetworkManager alloc] init];
    }
    return sharedManager;
}

- (void)categorySearchWithCategory:(NSString *)category locationArray:(NSArray *)locationArray resultCount:(int)resultCount success:(void (^)(NSArray *placeArray))success failure:(void (^)(NSError *error))failure {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.truman.Terrific"];
    NSDictionary *configDictionary = [defaults objectForKey:category];
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = configDictionary[@"tag_name"];
    
    MKCoordinateRegion region;
    region.center.latitude = [locationArray[0] floatValue];
    region.center.longitude = [locationArray[1] floatValue];
    double spanAmount = [configDictionary[@"radius"] doubleValue] / 69.0;
    region.span = MKCoordinateSpanMake(spanAmount, spanAmount);
    request.region = region;
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler: ^(MKLocalSearchResponse *response, NSError *error) {
        if (response.mapItems.count > (NSUInteger)resultCount) {
            NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, resultCount)];
            success([response.mapItems objectsAtIndexes:indexSet]);
        }
        else if (response.mapItems.count) {
            success(response.mapItems);
        }
        else {
            failure(nil);
        }
    }];
}

@end
