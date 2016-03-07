//
//  searchJobs.m
//  Dawerle
//
//  Created by Osama Rabie on 3/7/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "searchJobs.h"

@implementation searchJobs


- (NSDictionary*)hostToKinveyPropertyMapping
{
    return @{
             @"entityId" : KCSEntityKeyId, //the required _id field
             @"keywords" : @"keywords",
             @"metadata" : KCSEntityKeyMetadata //optional _metadata field
             };
}




@end
