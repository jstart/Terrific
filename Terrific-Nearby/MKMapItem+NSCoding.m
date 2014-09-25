//
//  MKMapItem+NSCoding.m
//  Terrific
//
//  Created by Christopher Truman on 9/25/14.
//
//

#import "MKMapItem+NSCoding.h"

@implementation MKMapItem (NSCoding)

- (id)initWithCoder:(NSCoder *)aDecoder {
    MKPlacemark *placemark = [aDecoder decodeObjectForKey:@"placemark"];
    self = [self initWithPlacemark:placemark];
    if (self) {
        NSString *name = [aDecoder decodeObjectForKey:@"name"];
        self.name = name;
        
        NSString *phoneNumber = [aDecoder decodeObjectForKey:@"phoneNumber"];
        self.phoneNumber = phoneNumber;

        NSURL *url = [aDecoder decodeObjectForKey:@"url"];
        self.url = url;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject: self.placemark forKey:@"placemark"];
    
    [aCoder encodeObject: self.name forKey:@"name"];
    
    [aCoder encodeObject: self.phoneNumber forKey:@"phoneNumber"];
    
    [aCoder encodeObject: self.url forKey:@"url"];
}

@end
