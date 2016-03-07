//
//  Jobs.m
//  Dawerle
//
//  Created by Osama Rabie on 3/7/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "Jobs.h"

@implementation Jobs


- (NSDictionary*)hostToKinveyPropertyMapping
{
    return @{
             @"entityId" : KCSEntityKeyId, //the required _id field
             @"link" : @"link",
             @"source" : @"source",
             @"title" : @"title",
             @"desc" : @"desc",
             @"metadata" : KCSEntityKeyMetadata //optional _metadata field
             };
}


@end
