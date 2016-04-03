//
//  AppDelegate.m
//  Dawerle
//
//  Created by Osama Rabie on 1/25/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "AppDelegate.h"
#import "ShowSearchViewController.h"
#import <OpinionzAlertView/OpinionzAlertView.h>
#import <Google/Analytics.h>

@interface AppDelegate ()<UIAlertViewDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |
     UIUserNotificationTypeBadge |
     UIUserNotificationTypeSound
                                      categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"sound"])
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"sound"];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"numberOfNumbers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (launchOptions != nil) {
        // Launched from push notification
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        [self performSelector:@selector(searchNotification:) withObject:userInfo afterDelay:1.0];
        [self searchNotification:userInfo];
        
    }
    
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    
    
    return YES;
}

-(void)searchNotification:(NSDictionary*)userInfo
{
    
    OpinionzAlertView *alert = [[OpinionzAlertView alloc] initWithTitle:@"إعلان جديد"
                                                                message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] cancelButtonTitle:@"إلغاء"              otherButtonTitles:@[@"مشاهدة"]          usingBlockWhenTapButton:^(OpinionzAlertView *alertView, NSInteger buttonIndex) {
                                                                    if(buttonIndex == 1)
                                                                    {
                                                                        dispatch_async( dispatch_get_main_queue(), ^{
                                                                            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
                                                                            ShowSearchViewController *dst = [storyboard instantiateViewControllerWithIdentifier:@"ShowSearchViewController"];
                                                                            [dst setSearchItem:userInfo];
                                                                            UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
                                                                            [navigationController pushViewController:dst animated:YES];
                                                                        });
                                                                    }
                                                                }];
    alert.iconType = OpinionzAlertIconInfo;
    alert.color = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1];
    [alert show];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{}
#endif


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* deviceTokenn = [[[[deviceToken description]
                               stringByReplacingOccurrencesOfString: @"<" withString: @""]
                              stringByReplacingOccurrencesOfString: @">" withString: @""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    [[NSUserDefaults standardUserDefaults]setObject:deviceTokenn forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults]synchronize];

}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if([[[userInfo objectForKey:@"aps"] allKeys] containsObject:@"i"])
    {
        /*[[NSNotificationCenter defaultCenter]
         postNotificationName:@"NewOrderNotification"
         object:userInfo];*/
        [self searchNotification:userInfo];
    }else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Dawerle" message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    // Additional push notification handling code should be performed here
}
- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


@end
