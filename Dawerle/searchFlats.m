//
//  searchFlat.m
//  Dawerle
//
//  Created by Osama Rabie on 3/1/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "searchFlats.h"

@implementation searchFlats


- (NSDictionary*)hostToKinveyPropertyMapping
{
    return @{
             @"entityId" : KCSEntityKeyId, //the required _id field
             @"price" : @"price",
             @"keywords" : @"keywords",
             @"type" : @"type",
             @"rooms" : @"rooms",
             @"metadata" : KCSEntityKeyMetadata //optional _metadata field
             };
}


@end
