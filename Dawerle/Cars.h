//
//  Cars.h
//  Dawerle
//
//  Created by Osama Rabie on 3/2/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KinveyKit/KinveyKit.h>

@interface Cars : NSObject <KCSPersistable>

@property (nonatomic, copy) NSString* entityId; //Kinvey entity _id
@property (nonatomic, copy) NSNumber* price;
@property (nonatomic, copy) NSString* sub;
@property (nonatomic, copy) NSString* img;
@property (nonatomic, copy) NSString* link;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* desc;
@property (nonatomic, copy) NSString* color;
@property (nonatomic, copy) NSString* brand;
@property (nonatomic, copy) NSString* source;
@property (nonatomic, copy) NSNumber* walk;
@property (nonatomic, copy) NSNumber* year;
@property (nonatomic, retain) KCSMetadata* metadata; //Kinvey metadata, optional

@end
