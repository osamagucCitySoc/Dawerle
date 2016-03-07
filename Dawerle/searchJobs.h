//
//  searchJobs.h
//  Dawerle
//
//  Created by Osama Rabie on 3/7/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "searchParent.h"
#import <KinveyKit/KinveyKit.h>


@interface searchJobs : searchParent <KCSPersistable>

@property (nonatomic, copy) NSString* entityId; //Kinvey entity _id
@property (nonatomic, copy) NSArray* keywords;
@property (nonatomic, retain) KCSMetadata* metadata; //Kinvey metadata, optional



@end
