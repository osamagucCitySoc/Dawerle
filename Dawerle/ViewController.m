//
//  ViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 1/25/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "ViewController.h"
#import "ShowSearchViewController.h"
#import "AreaViewController.h"
#import "SearchesViewController.h"
#import <OpinionzAlertView/OpinionzAlertView.h>
#import <Google/Analytics.h>
#import "CarsBrandsViewController.h"
#import "JobSearchViewController.h"

@import GoogleMobileAds;

@interface ViewController ()<UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation ViewController
{
    __weak IBOutlet UIView *bannerAdHolder;
    GADBannerView* bannerView;
    __weak IBOutlet UITableView *tableVieww;
    NSMutableArray* dataSource;
    id<GAITracker> tracker;
    NSString* countryType;
    NSString* rentType;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"flatSeg"] || [[segue identifier] isEqualToString:@"villaSeg"] || [[segue identifier] isEqualToString:@"storeSeg"])
    {
        AreaViewController* dst = (AreaViewController*)[segue destinationViewController];
        if([[segue identifier]isEqualToString:@"flatSeg"])
        {
            [dst setType:@"flats"];
        }else if([[segue identifier]isEqualToString:@"storeSeg"])
        {
            [dst setType:@"stores"];
        }else
        {
            [dst setType:@"villas"];
        }
        [dst setCountryType:countryType];
        [dst setRentType:rentType];
        NSDictionary *dataToSendGoogleAnalytics = [[NSDictionary alloc]initWithObjects:@[[dst type]] forKeys:@[@"message"]];
        [tracker send:dataToSendGoogleAnalytics];
    }else if([[segue identifier]isEqualToString:@"carsSeg"])
    {
        CarsBrandsViewController* dst = (CarsBrandsViewController*)[segue destinationViewController];
        [dst setCountryType:countryType];
    }else if([[segue identifier]isEqualToString:@"jobsSeg"])
    {
        JobSearchViewController* dst = (JobSearchViewController*)[segue destinationViewController];
        [dst setCountryType:countryType];
    }
    else if([[segue identifier]isEqualToString:@"showRecordedSearch"])
    {
        SearchesViewController* dst = (SearchesViewController*)[segue destinationViewController];
        [dst setDataID:[[dataSource objectAtIndex:savedInd] objectForKey:@"dataID"]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi" size:14]
       }
     forState:UIControlStateNormal];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:19]}];
    
    dataSource = [[NSMutableArray alloc]init];
    
    [tableVieww setDelegate:self];
    [tableVieww setDataSource:self];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"helpDone"])
    {
        [NSTimer scheduledTimerWithTimeInterval: 1.0
                                         target: self
                                       selector:@selector(showHelp:)
                                       userInfo: nil repeats:NO];
    }
    
    bannerView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeBanner];
    bannerView.adUnitID = @"ca-app-pub-3916999996422088/5493912657";
    bannerView.rootViewController = self;
    GADRequest* request = [[GADRequest alloc]init];
    request.testDevices = @[ @"c89d60e378a6e6f767031c551ca757a7" ];
    [bannerView loadRequest:request];
    [bannerAdHolder addSubview:bannerView];
    tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"ViewController"];
    
}

-(void)showHelp:(NSTimer *)timer {
    [self performSegueWithIdentifier:@"theHelpSeg" sender:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [tableVieww deselectRowAtIndexPath:tableVieww.indexPathForSelectedRow animated:animated];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (IBAction)openSettings:(id)sender {
    [self performSegueWithIdentifier:@"settingsSeg" sender:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    CGRect frame1 = bannerView.frame;
    CGRect frame2 = bannerAdHolder.frame;
    frame1.origin.x = (frame2.size.width/2)-160;
    [bannerView setFrame:frame1];
    
    if(dataSource.count == 0)
    {
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"flatSeg",@"flats",@"flatSearch",@"شقق",@"flats.png",@"من السوق المفتوح، أوليكس، الوسيط، مورجان."] forKeys:@[@"seg",@"dataID",@"localID",@"title",@"img",@"desc"]]];
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"villaSeg",@"villas",@"villaSearch",@"فلل",@"villas.png",@"من السوق المفتوح، أوليكس، الوسيط، مورجان."] forKeys:@[@"seg",@"dataID",@"localID",@"title",@"img",@"desc"]]];
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"storeSeg",@"stores",@"storeSearch",@"مكاتب",@"stores.png",@"من السوق المفتوح، أوليكس، الوسيط، مورجان."] forKeys:@[@"seg",@"dataID",@"localID",@"title",@"img",@"desc"]]];
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"carsSeg",@"cars",@"carSearch",@"سيارات",@"cars.png",@"من السوق المفتوح، أوليكس، الوسيط، كويت كار."] forKeys:@[@"seg",@"dataID",@"localID",@"title",@"img",@"desc"]]];
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"jobsSeg",@"jobs",@"jobSearch",@"وظائف",@"jobs.png",@"من السوق المفتوح، أوليكس، الوسيط، لينكد إن، بيت.كوم."] forKeys:@[@"seg",@"dataID",@"localID",@"title",@"img",@"desc"]]];
        NSMutableArray* indecies = [[NSMutableArray alloc]init];
        
        for(int i = 0 ; i < dataSource.count ; i++)
        {
            [indecies addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [tableVieww insertRowsAtIndexPaths:indecies withRowAnimation:UITableViewRowAnimationTop];
        NSDictionary *dataToSendGoogleAnalytics = [[NSDictionary alloc]initWithObjects:@[@"items loaded"] forKeys:@[@"message"]];
        [tracker send:dataToSendGoogleAnalytics];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark table view delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"تريد عن أن تبحث عن:";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
     view.tintColor = [UIColor groupTableViewBackgroundColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0]];
    [header.textLabel setFont:[UIFont fontWithName:@"DroidArabicKufi" size:14.0]];
    [header.textLabel setTextAlignment:NSTextAlignmentRight];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"catCell" forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"catCell"];
    }
    
    if (dataSource.count == (indexPath.row+1))
    {
        [(UILabel*)[cell viewWithTag:4]setHidden:YES];
    }
    
    NSDictionary* dict = [dataSource objectAtIndex:indexPath.row];
    
    [(UIImageView*)[cell viewWithTag:2]setImage:[UIImage imageNamed:[dict objectForKey:@"img"]]];
    [(UILabel*)[cell viewWithTag:1]setText:[dict objectForKey:@"title"]];
    //[(UILabel*)[cell viewWithTag:3]setText:[dict objectForKey:@"desc"]];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    savedInd = indexPath.row;
    
    BOOL isSearches = NO;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:[[dataSource objectAtIndex:indexPath.row] objectForKey:@"localID"]] && [[[NSUserDefaults standardUserDefaults] objectForKey:[[dataSource objectAtIndex:indexPath.row] objectForKey:@"localID"]] count]>0)
    {
        isSearches = YES;
    }
    
    
    if (isSearches)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"بحث جديد",@"تصفح عمليات البحث المحفوظة",nil];
        [actionSheet setTag:11];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    else
    {
        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"خيارات الدولة" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"الكويت",@"السعودية",nil];
        [sheet setTag:111];
        [sheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex  {
    [tableVieww deselectRowAtIndexPath:tableVieww.indexPathForSelectedRow animated:YES];
    
    
    if(actionSheet.tag == 111 && actionSheet.cancelButtonIndex != buttonIndex)
    {
        countryType = @"";
        if(buttonIndex == 0)
        {
            countryType = @"KW";
        }else
        {
            countryType = @"SA";
        }
        if(savedInd < 3)
        {
            UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"خيارات العقارات" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"بيع",@"إيجار",nil];
            [sheet setTag:222];
            [sheet showInView:self.view];
   
        }else
        {
            [self performSegueWithIdentifier:[[dataSource objectAtIndex:savedInd] objectForKey:@"seg"] sender:self];
        }
        return;
    }else if(actionSheet.tag == 222 && actionSheet.cancelButtonIndex != buttonIndex)
    {
        rentType = @"";
        if(buttonIndex == 0)
        {
            rentType = @"1";
        }else
        {
            rentType = @"0";
        }
        
        [self performSegueWithIdentifier:[[dataSource objectAtIndex:savedInd] objectForKey:@"seg"] sender:self];
        return;
    }

    
    switch (buttonIndex) {
        case 0:
        {
            if (actionSheet.tag == 11)
            {
                if(YES || [[UIApplication sharedApplication] isRegisteredForRemoteNotifications])
                {
                    UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"خيارات الدولة" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"الكويت",@"السعودية",nil];
                    [sheet setTag:111];
                    [sheet showInView:self.view];
                }else
                {
                    OpinionzAlertView *alert = [[OpinionzAlertView alloc] initWithTitle:@"خطأ"
                                                                                message:@"للأسف لم تسمح لنا بإرسال إشعارات لك:( يجب تفعيلها لكي نستطيع تبيلغك عند وجود إعلان يهمك"
                                                                      cancelButtonTitle:@"إلغاء"              otherButtonTitles:@[@"تفعيل"]          usingBlockWhenTapButton:^(OpinionzAlertView *alertView, NSInteger buttonIndex) {
                                                                                    if(buttonIndex == 1)
                                                                                    {
                                                                                        NSURL* settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                                        [[UIApplication sharedApplication] openURL:settingsURL];
                                                                                    }
                                                                                }];
                    alert.iconType = OpinionzAlertIconWarning;
                    alert.color = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1];
                    [alert show];
                }
            }
        }
            break;
            case 1:
        {
            if (actionSheet.tag == 11)
            {
                [self performSegueWithIdentifier:@"showRecordedSearch" sender:self];
            }
        }
    }
}

@end
