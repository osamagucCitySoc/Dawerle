//
//  Jobs.h
//  Dawerle
//
//  Created by Osama Rabie on 3/7/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KinveyKit/KinveyKit.h>

@interface Jobs : NSObject <KCSPersistable>


@property (nonatomic, copy) NSString* entityId; //Kinvey entity _id
@property (nonatomic, copy) NSString* link;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* desc;
@property (nonatomic, copy) NSString* source;
@property (nonatomic, retain) KCSMetadata* metadata; //Kinvey metadata, optional


@end
