//
//  searchFlat.h
//  Dawerle
//
//  Created by Osama Rabie on 3/1/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KinveyKit/KinveyKit.h>
#import "searchParent.h"

@interface searchFlats : searchParent <KCSPersistable>


@property (nonatomic, copy) NSString* entityId; //Kinvey entity _id
@property (nonatomic, copy) NSNumber* price;
@property (nonatomic, copy) NSArray* keywords;
@property (nonatomic, copy) NSString* type;
@property (nonatomic, copy) NSArray* rooms;
@property (nonatomic, retain) KCSMetadata* metadata; //Kinvey metadata, optional


@end
