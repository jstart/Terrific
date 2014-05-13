//
//  CTLocationDataManagerResult.m
//  LocationDataComparison
//
//  Created by Truman, Christopher on 2/27/12.
//  Copyright (c) 2014 Truman. All rights reserved.
//

#import "SGAnnotation.h"

@implementation SGAnnotation
@synthesize coordinate = _coordinate;
@synthesize title = _title, subtitle = _subtitle;

- (id) initWithTitle:(NSString *)title Coordinate:(CLLocationCoordinate2D)coordinate
{
    if (self = [super init])
    {
        _title = title;
        _coordinate = coordinate;
    }
    return self;
}

+ (SGAnnotation *) resultWithTitle:(NSString *)title Coordinate:(CLLocationCoordinate2D)coordinate
{
    return [[SGAnnotation alloc] initWithTitle:title Coordinate:coordinate];
}

@end
