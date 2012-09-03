//
//  SGPlace.h
//  SpotAndGo
//
//  Created by Truman, Christopher on 9/1/12.
//
//

#import <Foundation/Foundation.h>

@interface SGPlace : NSObject

@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * postal_code;
@property (nonatomic, strong) NSString * street;

@property (nonatomic, strong) NSString * factual_id;
@property (nonatomic, strong) NSString * latitude;
@property (nonatomic, strong) NSString * longitude;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * phone_number;
@property (nonatomic, strong) NSString * website;

+(SGPlace*)objectWithDictionary:(NSDictionary*)dictionary;
-(void)unpackDictionary:(NSDictionary*)dictionary;

@end
