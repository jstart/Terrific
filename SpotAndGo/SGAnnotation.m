//
//  CTLocationDataManagerResult.m
//  LocationDataComparison
//
//  Created by Truman, Christopher on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGAnnotation.h"

@implementation SGAnnotation
@synthesize coordinate = _coordinate;
@synthesize title = _title, subtitle = _subtitle;

- (id) initWithTitle:(NSString*)title Coordinate:(CLLocationCoordinate2D)coordinate {
  if (self = [super init]) {
    _title = title;
    _coordinate = coordinate;
  }
  return self;
}

+ (SGAnnotation*)resultWithTitle:(NSString*)title Coordinate:(CLLocationCoordinate2D)coordinate {
  return [[SGAnnotation alloc] initWithTitle:title Coordinate:coordinate];
}

// Properties
- (NSString *)title {
  return _title;
}

- (void)setTitle:(NSString *)text {
  _title = text;
}

- (NSString *)subtitle {
  return _subtitle;
}

- (void)setSubtitle:(NSString *)text {

  _subtitle = text;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
  _coordinate = newCoordinate;
}

- (NSString*) description {
  return [NSString stringWithFormat:@"LocationResult Name: %@ Coordinate: %f, %f", self.title, self.coordinate.latitude, self.coordinate.longitude];
}

@end
