//
//  searchCars.h
//  Dawerle
//
//  Created by Osama Rabie on 3/2/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KinveyKit/KinveyKit.h>
#import "searchParent.h"

@interface searchCars : searchParent <KCSPersistable>

@property (nonatomic, copy) NSString* entityId; //Kinvey entity _id
@property (nonatomic, copy) NSNumber* price;
@property (nonatomic, copy) NSArray* sub;
@property (nonatomic, copy) NSArray* brands;
@property (nonatomic, copy) NSNumber* year;
@property (nonatomic, retain) KCSMetadata* metadata; //Kinvey metadata, optional



@end
