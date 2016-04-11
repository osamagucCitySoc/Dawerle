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
#import <KSToastView/KSToastView.h>

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

- (IBAction)closeOptions:(id)sender {
    [self closeOptionsView];
}

-(void)openOptionsWithFirstLabel:(NSString*)firstLabel andSecondLabel:(NSString*)secondlabel andFirstImg:(NSString*)firstImg andSecondImg:(NSString*)SecondImg
{
    SADAHBlurView *blurView = [[SADAHBlurView alloc] initWithFrame:_optionsView.frame];
    
    blurView.blurRadius = 30;
    
    [blurView setTag:837];
    
    [self.navigationController.view addSubview:_optionsView];
    
    [_optionsView insertSubview:blurView belowSubview:_optionsBackButton];
    
    [_optionsView setAlpha:0.0];
    
    [_optionsView setHidden:NO];
    
    _firstOptionLabel.text = firstLabel;
    _secondOptionLabel.text = secondlabel;
    
    [_firstOptionsButton setImage:[UIImage imageNamed:firstImg] forState:UIControlStateNormal];
    
    [_secondOptionsButton setImage:[UIImage imageNamed:SecondImg] forState:UIControlStateNormal];
    
    for (UIView* view in _optionsView.subviews)
    {
        if (view.tag != 999)
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+500, view.frame.size.width, view.frame.size.height)];
        }
    }
    
    [UIView animateWithDuration:0.4 delay:0.0 options:0
                     animations:^{
                         [_optionsView setAlpha:1.0];
                         
                         for (UIView* view in _optionsView.subviews)
                         {
                             if (view.tag != 999)
                             {
                                 [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-500, view.frame.size.width, view.frame.size.height)];
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
    [UIView commitAnimations];
}

-(void)closeOptionsView
{
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         [_optionsView setAlpha:0.0];
                         
                         [[_optionsView viewWithTag:837] removeFromSuperview];
                         
                         for (UIView* view in _optionsView.subviews)
                         {
                             if (view.tag != 999)
                             {
                                 [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+500, view.frame.size.width, view.frame.size.height)];
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         for (UIView* view in _optionsView.subviews)
                         {
                             if (view.tag != 999)
                             {
                                 [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-500, view.frame.size.width, view.frame.size.height)];
                             }
                         }
                         
                         [_optionsView removeFromSuperview];
                         
                         [tableVieww deselectRowAtIndexPath:tableVieww.indexPathForSelectedRow animated:YES];
                     }];
    [UIView commitAnimations];
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
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"historySeg",@"history",@"historySearch",@"تصفح نتائج عمليات البحث المسجلة",@"history.png",@"من السوق المفتوح، أوليكس، الوسيط، لينكد إن، بيت.كوم."] forKeys:@[@"seg",@"dataID",@"localID",@"title",@"img",@"desc"]]];
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
    if(indexPath.row == dataSource.count-1)
    {
        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"قسم البحث المسجل" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"شقق",@"فلل",@"مكاتب",@"سيارات",@"وظائف",nil];
        sheet.tag = 1212;
        [sheet showInView:self.view];
    }else
    {
        
        BOOL isSearches = NO;
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:[[dataSource objectAtIndex:indexPath.row] objectForKey:@"localID"]] && [[[NSUserDefaults standardUserDefaults] objectForKey:[[dataSource objectAtIndex:indexPath.row] objectForKey:@"localID"]] count]>0)
        {
            isSearches = YES;
        }
        
        
        if (isSearches)
        {
            //        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"بحث جديد",@"تصفح عمليات البحث المحفوظة",nil];
            //        [actionSheet setTag:11];
            //        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
            
            [_firstOptionsButton setTag:5];
            [_secondOptionsButton setTag:6];
            
            [self openOptionsWithFirstLabel:@"بحث جديد" andSecondLabel:@"عمليات البحث المحفوظة" andFirstImg:@"search-options-icon.png" andSecondImg:@"archive-icon.png"];
        }
        else
        {
            //        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"خيارات الدولة" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"الكويت",@"السعودية",nil];
            //        [sheet setTag:111];
            //        [sheet showInView:self.view];
            
            [_firstOptionsButton setTag:1];
            [_secondOptionsButton setTag:2];
            
            [self openOptionsWithFirstLabel:@"الكويت" andSecondLabel:@"السعودية" andFirstImg:@"kw-icon.png" andSecondImg:@"sa-icon.png"];
        }
    }
}

-(void)doRent
{
    rentType = @"0";
    
    [self performSegueWithIdentifier:[[dataSource objectAtIndex:savedInd] objectForKey:@"seg"] sender:self];
}

-(void)doSell
{
    rentType = @"1";
    
    [self performSegueWithIdentifier:[[dataSource objectAtIndex:savedInd] objectForKey:@"seg"] sender:self];
}

- (IBAction)optionsOptions:(id)sender {
    [self closeOptionsView];
    
    theTag = [sender tag];
    
    [self performSelector:@selector(doOptions) withObject:nil afterDelay:0.5];
}

-(void)doOptions
{
    if (theTag == 1)
    {
        [self doAction:0];
    }
    else if (theTag == 2)
    {
        [self doAction:1];
    }
    else if (theTag == 3)
    {
        [self doSell];
    }
    else if (theTag == 4)
    {
        [self doRent];
    }
    else if (theTag == 5)
    {
        [_firstOptionsButton setTag:1];
        [_secondOptionsButton setTag:2];
        
        [self openOptionsWithFirstLabel:@"الكويت" andSecondLabel:@"السعودية" andFirstImg:@"kw-icon.png" andSecondImg:@"sa-icon.png"];
    }
    else if (theTag == 6)
    {
        [self performSegueWithIdentifier:@"showRecordedSearch" sender:self];
    }
}

-(void)doAction:(NSInteger)theCase
{
    if (theCase == 0)
    {
        countryType = @"KW";
    }
    else
    {
        countryType = @"SA";
    }
    
    if(savedInd < 3)
    {
        [_firstOptionsButton setTag:3];
        [_secondOptionsButton setTag:4];
        
        [self openOptionsWithFirstLabel:@"بيع" andSecondLabel:@"إيجار" andFirstImg:@"sell-icon.png" andSecondImg:@"rent-icon.png"];
        
    }else
    {
        [self performSegueWithIdentifier:[[dataSource objectAtIndex:savedInd] objectForKey:@"seg"] sender:self];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex  {
    [tableVieww deselectRowAtIndexPath:tableVieww.indexPathForSelectedRow animated:YES];
    
    if(actionSheet.tag == 1212)
    {
        savedInd = buttonIndex;
        BOOL isSearches = NO;
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:[[dataSource objectAtIndex:savedInd] objectForKey:@"localID"]] && [[[NSUserDefaults standardUserDefaults] objectForKey:[[dataSource objectAtIndex:savedInd] objectForKey:@"localID"]] count]>0)
        {
            isSearches = YES;
        }else
        {
            isSearches = NO;
            [KSToastView ks_showToast:@"لا يوجد بحث مسجل في هذا القسم من قبل." delay:1];

        }
        
        if (isSearches)
        {
            [self performSegueWithIdentifier:@"showRecordedSearch" sender:self];
        }
    }else if(actionSheet.tag == 111 && actionSheet.cancelButtonIndex != buttonIndex)
    {
        countryType = @"";
        
        if(buttonIndex == 0)
        {
            countryType = @"KW";
        }
        else
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
                UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"خيارات الدولة" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"الكويت",@"السعودية",nil];
                [sheet setTag:111];
                [sheet showInView:self.view];

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
- (IBAction)closeOptionViewClicked:(id)sender {
    [self closeOptionsView];
}

@end
