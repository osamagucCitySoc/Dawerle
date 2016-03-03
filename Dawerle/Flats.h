//
//  Flats.h
//  Dawerle
//
//  Created by Osama Rabie on 3/1/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KinveyKit/KinveyKit.h>

@interface Flats : NSObject <KCSPersistable>


@property (nonatomic, copy) NSString* entityId; //Kinvey entity _id
@property (nonatomic, copy) NSNumber* price;
@property (nonatomic, copy) NSArray* locs;
@property (nonatomic, copy) NSString* img;
@property (nonatomic, copy) NSString* link;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* desc;
@property (nonatomic, copy) NSString* typee;
@property (nonatomic, copy) NSString* loc;
@property (nonatomic, copy) NSString* source;
@property (nonatomic, copy) NSArray* rooms;
@property (nonatomic, retain) KCSMetadata* metadata; //Kinvey metadata, optional

@end
