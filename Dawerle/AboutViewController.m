//
//  AboutViewController.m
//  twitterExampleIII
//
//  Created by Housein Jouhar on 6/15/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "AboutViewController.h"
#import <MessageUI/MessageUI.h>
#import <OpinionzAlertView/OpinionzAlertView.h>
#import <DZNWebViewController/DZNWebViewController.h>

@interface AboutViewController ()<MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) MFMailComposeViewController *globalMailComposer;
@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.globalMailComposer = [[MFMailComposeViewController alloc] init];
    self.globalMailComposer.mailComposeDelegate = self;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"YYYY"];
    
    _rightsLabel.text = [@"DEAL.COM " stringByAppendingFormat:@"%@ All Rights Reserved.",[dateFormatter stringFromDate:[NSDate date]]];
    
    float appVer = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
    
    _verLabel.text = [@"الإصدار:" stringByAppendingFormat:@" %.1f",appVer];
}

- (IBAction)contactUs:(id)sender {
    
    NSString *emailTitle = @"دورلي - الدعم الفني";
    NSArray *toRecipents = [NSArray arrayWithObject:@"dealcomq8@gmail.com"];
    [self.globalMailComposer setSubject:emailTitle];
    [self.globalMailComposer setMessageBody:@"" isHTML:NO];
    [self.globalMailComposer setToRecipients:toRecipents];
    [self presentViewController:self.globalMailComposer animated:YES completion:NULL];
}

- (IBAction)visitUs:(id)sender {

    OpinionzAlertView *alert = [[OpinionzAlertView alloc] initWithTitle:@"شركه ديل كوم لاداره المشاريع"
                                                                message:@"شرق - قطعة 6 - قسيمة 6 - الدور 2 - وحدة 13 - الرقم الآلي للعنوان 20215316" cancelButtonTitle:@"إلغاء"              otherButtonTitles:@[@"Google Maps"]          usingBlockWhenTapButton:^(OpinionzAlertView *alertView, NSInteger buttonIndex) {
                                                                    if(buttonIndex == 1)
                                                                    {
                                                                        NSURL* URL = [NSURL URLWithString: @"https://goo.gl/yd2aAL"];
                                                                        
                                                                        DZNWebViewController *WVC = [[DZNWebViewController alloc] initWithURL:URL];
                                                                        //UINavigationController *NC = [[UINavigationController alloc] initWithRootViewController:WVC];
                                                                        
                                                                        WVC.supportedWebNavigationTools = DZNWebNavigationToolNone;
                                                                        WVC.supportedWebActions = DZNWebActionNone;
                                                                        WVC.showLoadingProgress = YES;
                                                                        WVC.allowHistory = NO;
                                                                        WVC.hideBarsWithGestures = YES;
                                                                        [WVC setTitle:@"DEAL.COM"];
                                                                        [self.navigationController pushViewController:WVC animated:YES];
                                                                    }
                                                                }];
    alert.iconType = OpinionzAlertIconInfo;
    alert.color = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark mail delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result
                       error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:^
     {
         self.globalMailComposer = [[MFMailComposeViewController alloc] init];
         self.globalMailComposer.mailComposeDelegate = self;
     }];
}

@end
