//
//  CTLocationDataManagerResult.h
//  LocationDataComparison
//
//  Created by Truman, Christopher on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface CTLocationDataManagerResult : NSObject <MKAnnotation>{
  NSString *_groupTag;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
// Title and subtitle for use by selection UI.
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
- (NSString *)title;
- (void)setTitle:(NSString *)text;

- (NSString *)subtitle;
- (void)setSubtitle:(NSString *)text;
- (NSString *)groupTag;
- (void)setGroupTag:(NSString *)tag;
- (id) initWithTitle:(NSString*)title Coordinate:(CLLocationCoordinate2D)coordinate;
+ (CTLocationDataManagerResult*)resultWithTitle:(NSString*)title Coordinate:(CLLocationCoordinate2D)coordinate;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate NS_AVAILABLE(NA, 4_0);
@end
