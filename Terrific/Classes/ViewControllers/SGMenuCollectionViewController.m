//
//  SGMenuCollectionViewController.m
//  Terrific
//
//  Created by Christopher Truman on 6/30/14.
//
//

#import "SGMenuCollectionViewController.h"
#import <MBLocationManager/MBLocationManager.h>

@interface SGMenuCollectionViewController ()

@end

@implementation SGMenuCollectionViewController

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[MBLocationManager sharedManager] startLocationUpdates:kMBLocationManagerModeStandard
                                             distanceFilter:kCLDistanceFilterNone
                                                   accuracy:kCLLocationAccuracyNearestTenMeters];
    NSString *chosenCategory;
    switch (indexPath.row)
    {
        case 0:
            chosenCategory = @"eat";
            break;
            
        case 1:
            chosenCategory = @"shop";
            break;
            
        case 2:
            chosenCategory = @"watch";
            break;
            
        case 3:
            chosenCategory = @"play";
            break;
            
        default:
            chosenCategory = @"eat";
            break;
    }
    [[Mixpanel sharedInstance] track:@"chose" properties:[NSDictionary dictionaryWithObject:chosenCategory forKey:@"category"]];
    [[[NSUserDefaults alloc] initWithSuiteName:@"group.truman.Terrific"] setObject:chosenCategory forKey:@"category"];
}

@end
