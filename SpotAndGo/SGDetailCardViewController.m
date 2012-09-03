//
//  SGDetailCardView.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGDetailCardViewController.h"
#import "SGPlaceImageViewController.h"
#import "SGPlaceDetailsViewController.h"

@implementation SGDetailCardViewController

- (id)init
{
    if (self = [super init]) {
        self.flipViewControllerArray = [NSMutableArray array];
    }
    return self;
}

-(void)didMoveToParentViewController:(UIViewController *)parent{
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gplaypattern.png"]]];
    for (int i = 0; i < 4; i++ ){
        MPFlipViewController * flipViewController = [[MPFlipViewController alloc] initWithOrientation:[self flipViewController:nil orientationForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation]];
        [flipViewController addObserver:self forKeyPath:@"view.frame" options:NSKeyValueObservingOptionNew context:NULL];
        flipViewController.delegate = self;
        flipViewController.dataSource = self;
        
        CGRect viewFrame;
        
        switch (i) {
            case 0:
                viewFrame = CGRectMake(0, 0, 155, 95);
                break;
            case 1:
                viewFrame = CGRectMake(165, 0, 155, 95);
                break;
            case 2:
                viewFrame = CGRectMake(0, 105, 155, 95);
                break;
            case 3:
                viewFrame = CGRectMake(165, 105, 155, 95);
                break;
                
            default:
                break;
        }
        flipViewController.view.frame = viewFrame;
        [self addChildViewController:flipViewController];
        [self.view addSubview:flipViewController.view];
        [flipViewController didMoveToParentViewController:self];
        [self.flipViewControllerArray addObject:flipViewController];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"view.frame"]) {
        CGRect oldFrame = CGRectNull;
        CGRect newFrame = CGRectNull;
        if([change objectForKey:@"old"] != [NSNull null]) {
            oldFrame = [[change objectForKey:@"old"] CGRectValue];
        }
        if([object valueForKeyPath:keyPath] != [NSNull null]) {
            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
            if (newFrame.size.height != 95){
                CGRect frame = ((UIViewController *) object).view.frame;
                frame.size.height = 95;
                [((UIViewController *) object).view setFrame:frame];
            }
        }

    }
}


#pragma mark - MPFlipViewControllerDataSource

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    if ([viewController isKindOfClass:[SGPlaceDetailsViewController class]]) {
        return [SGPlaceImageViewController placeImageViewControllerWithPlace:((SGPlaceDetailsViewController *)viewController).place];
    }
    return nil;
}// get previous page, or nil for none

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerAfterViewController:(UIViewController *)viewController{
    if ([viewController isKindOfClass:[SGPlaceImageViewController class]]) {
        return [SGPlaceDetailsViewController placeDetailsViewControllerWithPlace:((SGPlaceDetailsViewController *)viewController).place];
    }
    return nil;
}// get next page, or nil for none

#pragma mark - MPFlipViewControllerDelegate

// handle this to be notified when page flip animations have finished
- (void)flipViewController:(MPFlipViewController *)flipViewController didFinishAnimating:(BOOL)finished previousViewController:(UIViewController *)previousViewController transitionCompleted:(BOOL)completed{
    if ([previousViewController isKindOfClass:[SGPlaceImageViewController class]]) {
        if (self.delegate) {
            SGPlace * place = ((SGPlaceImageViewController*)previousViewController).place;
            [self.delegate placeSelected:place];
        }
    }
}

// handle this and return the desired orientation (horizontal or vertical) for the new interface orientation
// called when MPFlipViewController handles willRotateToInterfaceOrientation:duration: callback
- (MPFlipViewControllerOrientation)flipViewController:(MPFlipViewController *)flipViewController orientationForInterfaceOrientation:(UIInterfaceOrientation)orientation{
    return MPFlipViewControllerOrientationVertical;
}

@end
