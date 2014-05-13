//
//  CTLocationDataManagerResult.h
//  LocationDataComparison
//
//  Created by Truman, Christopher on 2/27/12.
//  Copyright (c) 2014 Truman. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
@import CoreLocation;

@interface SGAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
// Title and subtitle for use by selection UI.
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

+ (SGAnnotation *) resultWithTitle:(NSString *)title Coordinate:(CLLocationCoordinate2D)coordinate;

@end
