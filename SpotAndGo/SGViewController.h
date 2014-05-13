//
//  SGViewController.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2014 Truman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGMapViewController.h"

@interface SGViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (nonatomic, retain)IBOutletCollection(UIButton) NSArray * categoryButtons;
@property (nonatomic, retain) SGMapViewController *mapViewController;

- (IBAction) buttonSelected:(id)sender;

@end
