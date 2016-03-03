//
//  searchCars.m
//  Dawerle
//
//  Created by Osama Rabie on 3/2/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "searchCars.h"

@implementation searchCars



- (NSDictionary*)hostToKinveyPropertyMapping
{
    return @{
             @"entityId" : KCSEntityKeyId, //the required _id field
             @"price" : @"price",
             @"year" : @"year",
             @"brands" : @"brands",
             @"sub" : @"sub",
             @"metadata" : KCSEntityKeyMetadata //optional _metadata field
             };
}



@end
