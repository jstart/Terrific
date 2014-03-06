//
//  SGViewController.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGMapViewController.h"

@interface SGViewController : GAITrackedViewController {
    NSArray * categoryButtons;
}

@property (strong, nonatomic) IBOutlet UIImageView * logoImageView;
@property (nonatomic, retain)IBOutletCollection(UIButton) NSArray * categoryButtons;
@property (nonatomic, retain) SGMapViewController * mapViewController;

- (IBAction) buttonSelected:(id)sender;

@end
