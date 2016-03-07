//
//  AppDelegate.m
//  Dawerle
//
//  Created by Osama Rabie on 1/25/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "AppDelegate.h"
#import <KinveyKit/KinveyKit.h>
#import "ShowSearchViewController.h"

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
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"numberOfNumbers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

    
    BOOL remoteNotificationsEnabled = false, noneEnabled,alertsEnabled, badgesEnabled, soundsEnabled;
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // iOS8+
        remoteNotificationsEnabled = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
        
        UIUserNotificationSettings *userNotificationSettings = [UIApplication sharedApplication].currentUserNotificationSettings;
        
        noneEnabled = userNotificationSettings.types == UIUserNotificationTypeNone;
        alertsEnabled = userNotificationSettings.types & UIUserNotificationTypeAlert;
        badgesEnabled = userNotificationSettings.types & UIUserNotificationTypeBadge;
        soundsEnabled = userNotificationSettings.types & UIUserNotificationTypeSound;
        
    }
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        NSLog(@"Remote notifications enabled: %@", remoteNotificationsEnabled ? @"YES" : @"NO");
    }
    
    [[KCSClient sharedClient] initializeKinveyServiceForAppKey:@"kid_ZJvA_drjRl"
                                                 withAppSecret:@"c8de97222bf0428db2f93c87a94811a0"
                                                  usingOptions:nil];
    
    
    [KCSPing pingKinveyWithBlock:^(KCSPingResult *result) {
        if (result.pingWasSuccessful) {
            if ([KCSUser activeUser] == nil) {
                [KCSUser createAutogeneratedUser:@{KCSUserAttributeEmail : @"kinvey@kinvey.com", KCSUserAttributeGivenname : @"Arnold", KCSUserAttributeSurname : @"Kinvey"} completion:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
                    //do something
                    [KCSPush registerForPush];
                }];
            } else {
                //otherwise user is set and do something
                [KCSPush registerForPush];
            }
        } else {
            NSLog(@"Kinvey Ping Failed");
        }
    }];
    
    if (launchOptions != nil) {
        // Launched from push notification
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        [self performSelector:@selector(searchNotification:) withObject:userInfo afterDelay:1.0];
        [self searchNotification:userInfo];
        
    }
    return YES;
}

-(void)searchNotification:(NSDictionary*)userInfo
{

    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"New Item"
                                          message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   dispatch_async( dispatch_get_main_queue(), ^{
                                       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
                                       ShowSearchViewController *dst = [storyboard instantiateViewControllerWithIdentifier:@"ShowSearchViewController"];
                                       [dst setSearchItem:userInfo];
                                       UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
                                       [navigationController pushViewController:dst animated:YES];
                                   });
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
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
{
    [PFPush handlePush:userInfo];
}
#endif


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[KCSPush sharedPush] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken completionBlock:^(BOOL success, NSError *error) {
        //if there is an error, try again later
        NSLog(@"%@",@"HERE");
    }];
    // Additional registration goes here (if needed)
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if([[userInfo allKeys] containsObject:@"i"])
    {
        /*[[NSNotificationCenter defaultCenter]
         postNotificationName:@"NewOrderNotification"
         object:userInfo];*/
        [self searchNotification:userInfo];
    }else
    {
        [[KCSPush sharedPush] application:application didReceiveRemoteNotification:userInfo];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Dawerle" message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    // Additional push notification handling code should be performed here
}
- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[KCSPush sharedPush] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[KCSPush sharedPush] registerForRemoteNotifications];
    //Additional become active actions
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[KCSPush sharedPush] onUnloadHelper];
    // Additional termination actions
}


@end
