//
//  SGDetailCardView.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGDetailCardView.h"

@implementation SGDetailCardView
@synthesize view1, view2, view3, view4;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gplaypattern.png"]]];
      self.view1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 155, 95)];
      [self.view1 setTag:0];
      [self addSubview:view1];
      
      self.view2 = [[UIButton alloc] initWithFrame:CGRectMake(165, 0, 155, 95)];
      [self.view2 setTag:1];
      [self addSubview:view2];
      
      self.view3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 105, 155, 95)];
      [self.view3 setTag:2];
      [self addSubview:view3];
      
      self.view4 = [[UIButton alloc] initWithFrame:CGRectMake(165, 105, 155, 95)];
      [self.view4 setTag:3];
      [self addSubview:view4];
      
      for (UIButton * view in [self subviews]) {
        [view addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];

      }
      
        // Initialization code
    }
    return self;
}

-(void)selected:(id)sender{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"choice" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:((UIButton*)sender).tag ] forKey:@"choice"]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
