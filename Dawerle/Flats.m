//
//  Flats.m
//  Dawerle
//
//  Created by Osama Rabie on 3/1/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "Flats.h"

@implementation Flats


- (NSDictionary*)hostToKinveyPropertyMapping
{
    return @{
             @"entityId" : KCSEntityKeyId, //the required _id field
             @"price" : @"price",
             @"locs" : @"locs",
             @"typee" : @"typee",
             @"rooms" : @"rooms",
             @"link" : @"link",
             @"loc" : @"loc",
             @"source" : @"source",
             @"img" : @"img",
             @"title" : @"title",
             @"desc" : @"desc",
             @"metadata" : KCSEntityKeyMetadata //optional _metadata field
             };
}



@end
