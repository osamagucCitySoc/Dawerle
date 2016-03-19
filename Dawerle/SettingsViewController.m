//
//  SettingsViewController.m
//
//  Created by Housein Jouhar on 7/3/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import "SettingsViewController.h"
#import <MessageUI/MessageUI.h>

@interface SettingsViewController ()<MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) MFMailComposeViewController *globalMailComposer;
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.globalMailComposer = [[MFMailComposeViewController alloc] init];
    self.globalMailComposer.mailComposeDelegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi" size:14]
       }
     forState:UIControlStateNormal];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:19]}];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)return 3;
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger) section
{
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    lbl.textAlignment = NSTextAlignmentRight;
    
    if (section == 0)
    {
        lbl.text = @"  عام";
    }
    else
    {
        lbl.text = @"  المزيد";
    }
    
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setFont:[UIFont fontWithName:@"DroidArabicKufi" size:12.0]];
    [lbl setTextColor:[UIColor colorWithRed:157.0/255 green:157.0/255 blue:160.0/255 alpha:1.0]];
    
    return lbl;
}

-(UIView*)tableView:(UITableView *)tableView2 viewForFooterInSection:(NSInteger)section
{
    if (section == 0)return nil;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 50)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 50)];
    [label setTag:837];
    [label setFont:[UIFont fontWithName:@"DroidArabicKufi" size:8.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor colorWithRed:157.0/255 green:157.0/255 blue:160.0/255 alpha:1.0]];
    
    UIImageView *logoImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deal-logo.png"]];
    
    [view addSubview:logoImg];
    [view addSubview:label];
    
    [logoImg setFrame:CGRectMake(0, 0, 20.0f, 26.0f)];
    
    [label setCenter:view.center];
    
    [label setFrame:CGRectMake(label.frame.origin.x, self.tableView.frame.size.height/2, label.frame.size.width, label.frame.size.height)];
    
    if ([[UIScreen mainScreen] bounds].size.height < 668)
    {
        [label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y-label.frame.size.height*3, label.frame.size.width, label.frame.size.height)];
        
        [label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y+20, label.frame.size.width, label.frame.size.height)];
    }
    else
    {
        [label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y-label.frame.size.height*2, label.frame.size.width, label.frame.size.height)];
    }
    
    NSLog(@"%f",[[UIScreen mainScreen] bounds].size.height);
    
    [logoImg setCenter:label.center];
    
    [logoImg setFrame:CGRectMake(logoImg.frame.origin.x, logoImg.frame.origin.y-20, logoImg.frame.size.width, logoImg.frame.size.height)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"YYYY"];
    
    [label setText:[@"DEAL.COM " stringByAppendingFormat:@"%@ All Rights Reserved.",[dateFormatter stringFromDate:[NSDate date]]]];
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0)return 20;
    return 50;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 1)
    {
        if (indexPath.row == 0)
        {
            [self performSegueWithIdentifier:@"helpSeg" sender:self];
        }
        else if (indexPath.row == 1)
        {
            NSString *emailTitle = @"دورلي - الدعم الفني";
            NSArray *toRecipents = [NSArray arrayWithObject:@"dealcomq8@gmail.com"];
            [self.globalMailComposer setSubject:emailTitle];
            [self.globalMailComposer setMessageBody:@"" isHTML:NO];
            [self.globalMailComposer setToRecipients:toRecipents];
            [self presentViewController:self.globalMailComposer animated:YES completion:NULL];
        }
        else
        {
            NSString *templateReviewURLiOS8 = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=APP_ID&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software";
            
            NSString *reviewURL = [templateReviewURLiOS8 stringByReplacingOccurrencesOfString:@"APP_ID" withString:[NSString stringWithFormat:@"%d", 1094778160]];

            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: reviewURL]];
            
            NSLog(@"Rate the App!");
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    else
    {
        [self performSegueWithIdentifier:@"aboutSeg" sender:self];
    }
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
