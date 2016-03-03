//
//  Cars.m
//  Dawerle
//
//  Created by Osama Rabie on 3/2/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "Cars.h"

@implementation Cars


- (NSDictionary*)hostToKinveyPropertyMapping
{
    return @{
             @"entityId" : KCSEntityKeyId, //the required _id field
             @"price" : @"price",
             @"walk" : @"walk",
             @"year" : @"year",
             @"color" : @"color",
             @"link" : @"link",
             @"brand" : @"brand",
             @"source" : @"source",
             @"img" : @"img",
             @"title" : @"title",
             @"desc" : @"desc",
             @"sub" : @"sub",
             @"metadata" : KCSEntityKeyMetadata //optional _metadata field
             };
}


@end
