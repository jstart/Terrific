//
//  SGMenuCollectionViewController.m
//  Terrific
//
//  Created by Christopher Truman on 6/30/14.
//
//

#import "SGMenuCollectionViewController.h"
#import "MPSkewedParallaxLayout.h"
#import "MPSkewedCell.h"
#import "SGMapViewController.h"
#import "UIView+Frame.h"
#import <MBLocationManager/MBLocationManager.h>

@interface SGMenuCollectionViewController ()

@property (nonatomic, strong) SGMapViewController *mapViewController;

@end

@implementation SGMenuCollectionViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.y = 0;
    self.collectionView.height += 20;
    
    UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
    [self.collectionView setBackgroundView:backgroundImageView];
    
    MPSkewedParallaxLayout *layout = [[MPSkewedParallaxLayout alloc] init];
    [self.collectionView setCollectionViewLayout:layout];
    [self.collectionView registerClass:[MPSkewedCell class] forCellWithReuseIdentifier:@"Cell"];
    
    self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"map"];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    MPSkewedCell *cell = (MPSkewedCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.image = [UIImage imageNamed:@"iTunesArtwork"];
    
    NSString *text;
    
    NSInteger index = indexPath.row % 5;
    
    switch (index)
    {
        case 0:
            text = @"EAT";
            break;
        case 1:
            text = @"SHOP";
            break;
        case 2:
            text = @"WATCH";
            break;
        case 3:
            text = @"PLAY";
            break;
        default:
            break;
    }
    
    cell.text = text;
    
    return cell;
}

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
    [self.navigationController pushViewController:self.mapViewController animated:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
