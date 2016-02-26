//
//  DownloaderClass.h
//  Task
//
//  Created by Osama Rabie on 2/11/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloaderClass : NSObject

typedef void(^downloadForEndedForFileAtUrl)(BOOL Succedded,NSString* locallySavedPath, NSString* errorMessage, NSString* loadedFrom);

// Creates a singleton instance of the downloading manager through out the application lifecycle.
// The need for a singleton is to be able to serve similar parallel requests.
+ (DownloaderClass *)sharedInstance;


// Sets the maximum cahce size for the downloader. Default is 6000 KB
-(void)setMaximumCacheSizeInKB:(float)maximumSize;


// This method is used to initiate a downloading session for the given URL
-(void)downloadFileAtUrl:(NSURL*)url downloadingBlock:(downloadForEndedForFileAtUrl) downloadingBlock;


// This method is used  to calculate the current size of the used cache folder in order to decide what to do when adding a new file to the cache pool.
- (unsigned long long) cacheFolderSize;

@end
