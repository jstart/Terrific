//
//  SGPlace.m
//  SpotAndGo
//
//  Created by Truman, Christopher on 9/1/12.
//
//

#import "SGPlace.h"

@implementation SGPlace

+(SGPlace*)objectWithDictionary:(NSDictionary*)dictionary{
    SGPlace * place = [[SGPlace alloc] init];
    [place unpackDictionary:dictionary];
    return place;
}


-(void)unpackDictionary:(NSDictionary*) dictionary{
    NSDictionary* addressDictionary = [dictionary objectForKey:@"address"];
    self.city = [addressDictionary objectForKey:@"city"];
    self.postal_code = [addressDictionary objectForKey:@"postal_code"];
    self.state = [addressDictionary objectForKey:@"state"];
    self.street = [addressDictionary objectForKey:@"street"];
    self.factual_id = [dictionary objectForKey:@"factual_id"];
    self.latitude = [dictionary objectForKey:@"latitude"];
    self.longitude = [dictionary objectForKey:@"longitude"];
    self.name = [dictionary objectForKey:@"name"];
    self.phone_number = [dictionary objectForKey:@"phone_number"];
    self.website = [dictionary objectForKey:@"website"];
}

@end
