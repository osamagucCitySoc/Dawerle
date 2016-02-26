//
//  DownloaderClass.m
//  Task
//
//  Created by Osama Rabie on 2/11/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "DownloaderClass.h"

@implementation DownloaderClass
{
    float maximumCacheSizeInKB; // variable to control the maximum cache size in KB
    NSMutableArray* downloadingSessions; // variable to hold the current running downloads. This will be used to detect when a resource is being downloaded but also being requsted from another user so we do not download it twice in parallel.
}

#pragma mark init methods

+ (DownloaderClass *)sharedInstance {
    static dispatch_once_t once;
    static DownloaderClass *instance;
    dispatch_once(&once, ^{
        instance = [[DownloaderClass alloc] init];
        [instance initDownloader];
    });
    return instance;
}


// This method is used upon creating the singleton instance by filling the attributes with their default values

-(void)initDownloader
{
    // Setting the default cache size to 6 MB
    maximumCacheSizeInKB = 6000;
    
    // This array will contain information about current running downloads. It will record the URl being downloading and all blocks (i.e users) should be notified at the end of this download. This had been done to avoid downloading the same file twice at the same time.
    downloadingSessions = [[NSMutableArray alloc] init];
    
}


#pragma mark downloading and cashing methods

// This method is used to initiate a downloading session for the given URL
-(void)downloadFileAtUrl:(NSURL*)url downloadingBlock:(downloadForEndedForFileAtUrl) downloadingBlock
{
    
    
    // First check if it is already in cache
    
    NSString* localPath = [self getLocalPathForAFileIfExists:url];
    if(localPath)
    {
        // It is cached and still valid.
        downloadingBlock(YES,localPath,nil,@"Cache");
    }else
    {
        // If we reach here, then whether it was cached and not existing anymore in the cache because of unknown deletion from the iOS itself. Or it is not existing in the cached list before.
        
        // Second check is, if the same URL is being downloaded by another block already. If it is, then we add the current block to the list of observers to be notified when the running downloading session had been finished.
        BOOL beingDownloaded = [self isURLBeingDownloaded:url downloadingBlock:downloadingBlock];
        
        if(!beingDownloaded)
        {
            // Now, the URL is not in the cache and not currently being downloaded. The next step is to initiate a downloading request
            
            
            //Before, downloading, let us check that the needed file to be cached and can fit in the maximum size of the cache
            
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"HEAD"];
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       if(([response expectedContentLength]/1000.0f) <= maximumCacheSizeInKB) // It can fit as a whole in the cache, so we will download it
                                       {
                                           
                                           
                                           NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                                           [NSURLConnection sendAsynchronousRequest:request
                                                                              queue:[NSOperationQueue mainQueue]
                                                                  completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                                                      
                                                                      // Now, we need to respond to the current user and to all other observers (which called the same file while downloading the file) if any.
                                                                      NSMutableArray* observers = [self observersForUrl:url];
                                                                      // Finally, let us delete the download session for this URL as it has finished.
                                                                      [self removeDownloadingSessionWithURL:url];
                                                                      if(error)
                                                                      {
                                                                          for(downloadForEndedForFileAtUrl block in observers)
                                                                          {
                                                                              @try {
                                                                                   block(NO,@"",[error localizedDescription],@"");
                                                                              }
                                                                              @catch (NSException *exception) {
                                                                                  continue;
                                                                              }
                                                                             
                                                                          }
                                                                      }else
                                                                      {
                                                                          NSString* localPath = [self downloadFinished:url mimeType:[response MIMEType] fileSize:[response expectedContentLength] downloadedData:data];
                                                                          for(int i = 0 ; i < observers.count ; i++)
                                                                          {
                                                                              downloadForEndedForFileAtUrl block = [observers objectAtIndex:i];
                                                                              @try {
                                                                                  if(i == 0)
                                                                                  {
                                                                                      // This is the first user to ask to download this file. Hence, for him, the file was brought online
                                                                                      block(YES,localPath,nil,@"Online");
                                                                                  }else
                                                                                  {
                                                                                      // Any other user was only an observer for a previously running downloading session fro the requested file. Hence, the file is brought to him by waiting for a previous download
                                                                                      block(YES,localPath,nil,@"Previous Parallel Download Session");
                                                                                  }
                                                                              }
                                                                              @catch (NSException *exception) {
                                                                                  continue;
                                                                              }
                                                                          }
                                                                      }
                                                                  }];
                                           
                                       }else // It is bigger than the current cache size
                                       {
                                           NSMutableArray* observers = [self observersForUrl:url];
                                           for(downloadForEndedForFileAtUrl block in observers)
                                           {
                                               @try {
                                                    block(NO,@"",[NSString stringWithFormat:@"The file requested at %@ is greater than the maximum size defined for the cahce.",[url absoluteString]],@"");
                                               }
                                               @catch (NSException *exception) {
                                                   continue;
                                               }
                                              
                                           }
                                           // Finally, let us delete the download session for this URL as it has finished.
                                           [self removeDownloadingSessionWithURL:url];
                                       }
                                   }];
        }
    }
}


// This method checks if a given remote URL had been already downloaded and still active in the cache, if yes the method returns the local path for that file and updates its last recently used field.
-(NSString*)getLocalPathForAFileIfExists:(NSURL*)url
{
    NSFileManager *_manager = [NSFileManager defaultManager];
    NSMutableArray* alreadyCachedURLS = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"cachedURLS"]];
    for(int i = 0 ; i < alreadyCachedURLS.count ; i++)
    {
        NSMutableDictionary* alreadyCachedURL = [[NSMutableDictionary alloc]initWithDictionary:[alreadyCachedURLS objectAtIndex:i]];
        if([[alreadyCachedURL objectForKey:@"remoteURL"]isEqualToString:[url absoluteString]])
        {
            // We need to check if it is still in the cache and not removed by the iOS system itself for any reason
            NSString* localPath = [self getFilePath:[alreadyCachedURL objectForKey:@"localURL"]];
            
            if([_manager fileExistsAtPath:localPath])
            {
                //The file is cached and still exists. We need to update its last used time and then return the local path for the file
                [alreadyCachedURL setObject:[NSNumber numberWithFloat:[[NSDate date] timeIntervalSince1970]] forKey:@"lastUsed"];
                [alreadyCachedURLS replaceObjectAtIndex:i withObject:alreadyCachedURL];
                [[NSUserDefaults standardUserDefaults]setObject:alreadyCachedURLS forKey:@"cachedURLS"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                
                return localPath;
            }else
            {
                // The file was cached by the app but the iOS itself removed it for any reason. So we need to sync our cached list and remove this object from it.
                [alreadyCachedURLS removeObjectAtIndex:i];
                [[NSUserDefaults standardUserDefaults]setObject:alreadyCachedURLS forKey:@"cachedURLS"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
        }
    }
    
    
    // If we reached here, then there is no local path for the given URL.
    return nil;
    
}

// This method is used to check if a newly requested file is already being downloaded by another older request, so the new user is added as an observer to the already initiated downloading request. This is to save downloading the same file more than one time in parallel.

-(BOOL)isURLBeingDownloaded:(NSURL*)url downloadingBlock:(downloadForEndedForFileAtUrl) downloadingBlock
{
    for(int i = 0 ; i < downloadingSessions.count ; i++)
    {
        NSMutableDictionary* downloadingSession = [[NSMutableDictionary alloc]initWithDictionary:[downloadingSessions objectAtIndex:i]];
        
        if([[downloadingSession objectForKey:@"remoteURL"]isEqualToString:[url absoluteString]])
        {
            // The newly requested file is already being downloaded from another user, so we just need to add the new user as an observer for the download event.
            NSMutableArray* observers = [[NSMutableArray alloc] initWithArray:[downloadingSession objectForKey:@"observers"]];
            [observers addObject:downloadingBlock];
            [downloadingSession setObject:observers forKey:@"observers"];
            [downloadingSessions replaceObjectAtIndex:i withObject:downloadingSession];
            return YES;
        }
    }
    
    // If we reached here, then no running download session is downloading the same file.
    // So we create a new downloading session for that URL
    NSMutableDictionary* newDownloadSession = [[NSMutableDictionary alloc]init];
    [newDownloadSession setObject:[url absoluteString] forKey:@"remoteURL"];
    [newDownloadSession setObject:@[downloadingBlock] forKey:@"observers"];
    [downloadingSessions addObject:newDownloadSession];
    
    return NO;
}


// This method is used to delete a downloading session after it had been finished.
-(void)removeDownloadingSessionWithURL:(NSURL*)url
{
    for(int i = 0 ; i < downloadingSessions.count ; i++)
    {
        NSMutableDictionary* downloadingSession = [[NSMutableDictionary alloc]initWithDictionary:[downloadingSessions objectAtIndex:i]];
        
        if([[downloadingSession objectForKey:@"remoteURL"]isEqualToString:[url absoluteString]])
        {
            [downloadingSessions removeObjectAtIndex:i];
            break;
        }
    }
}


// This method is used to get the list of observers for a certain URL. Those observers will get the status updates about downloading this specific url
-(NSMutableArray*)observersForUrl:(NSURL*)url
{
    NSMutableArray* observers;
    for(int i = 0 ; i < downloadingSessions.count ; i++)
    {
        NSMutableDictionary* downloadingSession = [[NSMutableDictionary alloc]initWithDictionary:[downloadingSessions objectAtIndex:i]];
        
        if([[downloadingSession objectForKey:@"remoteURL"]isEqualToString:[url absoluteString]])
        {
            observers = [[NSMutableArray alloc] initWithArray:[downloadingSession objectForKey:@"observers"]];
            break;
        }
    }
    return observers;
}

// This method is used  to calculate the current size of the used cache folder in order to decide what to do when adding a new file to the cache pool.
- (unsigned long long) cacheFolderSize {
    NSFileManager *_manager = [NSFileManager defaultManager];
    NSArray *_cacheFileList;
    NSEnumerator *_cacheEnumerator;
    NSString *_cacheFilePath;
    unsigned long long _cacheFolderSize = 0;
    
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath    = [myPathList  objectAtIndex:0];
    myPath = [myPath stringByAppendingPathComponent:@"TaskCache"];
    
    if(![_manager fileExistsAtPath:myPath])
    {
        [_manager createDirectoryAtPath:myPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    _cacheFileList = [_manager subpathsAtPath:myPath];
    _cacheEnumerator = [_cacheFileList objectEnumerator];
    while (_cacheFilePath = [_cacheEnumerator nextObject]) {
        NSDictionary *_cacheFileAttributes = [_manager attributesOfItemAtPath:[myPath stringByAppendingPathComponent:_cacheFilePath] error:nil];
        _cacheFolderSize += [_cacheFileAttributes fileSize];
    }
    
    return _cacheFolderSize;
}


- (NSString*) downloadFinished:(NSURL*)remoteURL mimeType:(NSString*)mimeType fileSize:(float)fileSize downloadedData:(NSData *)downloadedData
{
    float currentCacheSize = [self cacheFolderSize];
    float totalSizeNeededInKB = ((fileSize+currentCacheSize)/1000.0);
    
    NSString* fileName = [NSString stringWithFormat:@"%f.%@",[[NSDate date] timeIntervalSince1970],[[mimeType componentsSeparatedByString:@"/"] lastObject]]; // This salting technique is used to avoid collisions and overwrittig. For example x.com/1.jpg will not overwrite y.com/1.jpg
    NSString* path = [self getFilePath:fileName];
    
    if(totalSizeNeededInKB <= maximumCacheSizeInKB) // It is OK to store in the cache
    {
        
        // Write the data into a file into the cahce directory
        NSError *error = nil;
        [downloadedData writeToFile:path options:NSDataWritingAtomic error:&error];
        
        // Store the key-object value to indicate that this URL is cached at a certain local path, so whenever it is requested again it is grapped from cache directly
        NSMutableArray* alreadyCachedURLS = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"cachedURLS"]];
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
        [dict setObject:fileName forKey:@"localURL"]; // The file name only is stored and not the whole local path as the Cache Directory changes everytime the app opens nearly
        [dict setObject:[remoteURL absoluteString] forKey:@"remoteURL"];
        [dict setObject:[NSNumber numberWithFloat:[[NSDate date] timeIntervalSince1970]] forKey:@"lastUsed"];
        [alreadyCachedURLS addObject:dict];
        [[NSUserDefaults standardUserDefaults]setObject:alreadyCachedURLS forKey:@"cachedURLS"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }else // We need to remove files based on last recenlty used technique until it is possible to store the new object
    {
        //First, we get the files in the cache by this moment and sort them ASC based on their last usage time
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUsed"  ascending:YES];
        NSMutableArray* cachedItemsArray = [[NSMutableArray alloc]initWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"cachedURLS"] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
        
        //Second, we calculate the minimum needed space to be freed to be able to insert the new file.
        float neededSpace = ((totalSizeNeededInKB+currentCacheSize)/1000)-maximumCacheSizeInKB;
        
        // Second, we keep on deleting old used items until the size of the new file can be inserted without exceeding the maximum limit for the cache
        NSFileManager *_manager = [NSFileManager defaultManager];
        
        for(NSDictionary* cachedItem in cachedItemsArray)
        {
            NSLog(@"File with URL %@ had been deleted to free space",[cachedItem objectForKey:@"remoteURL"]);
            [cachedItemsArray removeObject:cachedItem];
            NSString* cachedItemPath = [self getFilePath:[cachedItem objectForKey:@"localURL"]];
            NSDictionary *_cacheFileAttributes = [_manager attributesOfItemAtPath:cachedItemPath error:nil];
            neededSpace -= [_cacheFileAttributes fileSize];
            [_manager removeItemAtPath:cachedItemPath error:nil];
            
            if(neededSpace <= 0)
            {
                // We have deleted the needed amount to insert the new file
                NSError *error = nil;
                [downloadedData writeToFile:path options:NSDataWritingAtomic error:&error];
                NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
                [dict setObject:fileName forKey:@"localURL"]; // The file name only is stored and not the whole local path as the Cache Directory changes everytime the app opens nearly
                [dict setObject:[remoteURL absoluteString] forKey:@"remoteURL"];
                [dict setObject:[NSNumber numberWithFloat:[[NSDate date] timeIntervalSince1970]] forKey:@"lastUsed"];
                [cachedItemsArray addObject:dict];
                [[NSUserDefaults standardUserDefaults]setObject:cachedItemsArray forKey:@"cachedURLS"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                break;
            }
        }
        
    }
    
    return path;
}


- (NSString *)getFilePath: (NSString *)fileDirPath
{
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath    = [myPathList  objectAtIndex:0];
    
    myPath = [myPath stringByAppendingPathComponent:@"TaskCache"];
    myPath = [myPath stringByAppendingPathComponent:fileDirPath];
    
    return myPath;
}

#pragma mark setters and getters
-(void)setMaximumCacheSizeInKB:(float)maximumSize
{
    maximumCacheSizeInKB = maximumSize;
}


@end
