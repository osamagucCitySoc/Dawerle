//
//  RoomsViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 1/25/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "RoomsViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "Popup.h"
#import <FlatUIKit.h>
#import "FeEqualize.h"
#import "ViewController.h"
#import <Google/Analytics.h>
#import <OpinionzAlertView/OpinionzAlertView.h>
#import <KSToastView/KSToastView.h>
#import "SearchesViewController.h"

@import GoogleMobileAds;

@interface RoomsViewController ()<UITableViewDelegate,UITableViewDataSource,PopupDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) FeEqualize *equalizer;
@end

@implementation RoomsViewController
{
    __weak IBOutlet UIView *bannerAdHolder;
    GADBannerView* bannerView;
    __weak IBOutlet UITableView *tableView;
    NSMutableArray* dataSource;
    NSString* maxPrice;
    __weak IBOutlet FUIButton *roomesButton;
    __weak IBOutlet UIView *eqHolder;
    id<GAITracker> tracker;
}

@synthesize selectedAreas,type;


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"exploreSeg"])
    {
        SearchesViewController* dst = (SearchesViewController*)[segue destinationViewController];
        [dst setDataID:type];
        [dst setNormalBack:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:19]}];
    
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    
    if([type isEqualToString:@"villas"])
    {
        self.title = @"فلل و قصور";
    }else if([type isEqualToString:@"flats"])
    {
        self.title = @"شقق";
    }else if([type isEqualToString:@"stores"])
    {
        self.title = @"مكاتب";
    }
    
    self.title = [self.title stringByAppendingString:@" - الغرف"];

    
    roomesButton.buttonColor = [UIColor colorFromHexCode:@"34a853"];
    roomesButton.shadowColor = [UIColor greenSeaColor];
    roomesButton.shadowHeight = 0.0f;
    roomesButton.cornerRadius = 0.0f;
    roomesButton.alpha = 0.0f;

    
    
    maxPrice = @"";
    
    dataSource = [[NSMutableArray alloc]init];
    [tableView setAllowsMultipleSelection:YES];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    
    bannerView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeBanner];
    bannerView.adUnitID = @"ca-app-pub-3916999996422088/5493912657";
    bannerView.rootViewController = self;
    GADRequest* request = [[GADRequest alloc]init];
    request.testDevices = @[ @"c89d60e378a6e6f767031c551ca757a7" ];
    [bannerView loadRequest:request];
    [bannerAdHolder addSubview:bannerView];
    
    
    
    tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"RoomsViewController"];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    _equalizer = [[FeEqualize alloc] initWithView:eqHolder title:@"جاري حفظ بحثك"];
    CGRect frame = CGRectMake(0, 0, 70, 70);
    [_equalizer setFrame:frame];
    [_equalizer setBackgroundColor:[UIColor clearColor]];
    [eqHolder setBackgroundColor:[UIColor clearColor]];
    [eqHolder addSubview:_equalizer];
    [eqHolder setAlpha:0.0];
    [_equalizer dismiss];

    
    [super viewDidAppear:animated];
    if(dataSource.count == 0)
    {
        for(int i = 0 ; i <= 10 ; i++)
        {
            [dataSource addObject:[NSString stringWithFormat:@"%i",i]];
        }
        NSMutableArray* indices = [[NSMutableArray alloc]init];
        
        for(int i = 0 ; i < dataSource.count ; i++)
        {
            [indices addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [tableView insertRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationTop];
    }
    
    CGRect frame1 = bannerView.frame;
    CGRect frame2 = bannerAdHolder.frame;
    frame1.origin.x = (frame2.size.width/2)-160;
    [bannerView setFrame:frame1];
    
    [KSToastView ks_showToast:@"تنبيه : سيتم أيضاً تنبيهك بالإعلانات التي لم تضمن عدد الغرف لحصولك على أكبر فرصة ممكنه لتجد ما تريده."];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark button methods

- (IBAction)submitClicked:(id)sender {
    Popup *popup = [[Popup alloc] initWithTitle:@"تحديد السعر"
                                       subTitle:@"قم بإدخال الحد الأعلى للسعر أو أتركه فارغاً ليتم تنبيهك بكل الأسعار. سيتم تنبيهك أيضاً بالإعلانات التي لم تضمن السعر لحصولك على أكبر فرصة ممكنه لتجد ما تريده"
                          textFieldPlaceholders:@[@""]
                                    cancelTitle:@"إلغاء"
                                   successTitle:@"دورلي ;)"
                                    cancelBlock:^{} successBlock:^{
                                        [UIView transitionWithView:eqHolder
                                                          duration:0.2f
                                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                                        animations:^{
                                                            [eqHolder setAlpha:1.0];
                                                            [_equalizer show];
                                                        } completion:NULL];
                                        
                                        NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
                                        
                                        NSMutableArray* rooms = [[NSMutableArray alloc]init];
                                        for(int i = 0 ; i < [tableView indexPathsForSelectedRows].count ; i++)
                                        {
                                            [rooms addObject:[dataSource objectAtIndex:[[tableView.indexPathsForSelectedRows objectAtIndex:i] row]]];
                                        }
                                        [rooms addObject:@"-1"];
                                        if(rooms.count == 0)
                                        {
                                            [rooms addObject:@"-1"];
                                        }
                                        [dict setObject:rooms forKey:@"rooms"];
                                        [dict setObject:selectedAreas forKey:@"keywords"];
                                        [dict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"] forKey:@"token"];
                                        [dict setObject:_countryType forKey:@"country"];
                                        [dict setObject:_rentType forKey:@"rent"];
                                        
                                        if([maxPrice isEqualToString:@""])
                                        {
                                            maxPrice = @"-1";
                                        }
                                        [dict setObject:[NSNumber numberWithInt:[maxPrice intValue]] forKey:@"price"];
                                        if([type isEqualToString:@"flats"])
                                        {
                                            [dict setObject:@"flat" forKey:@"type"];
                                        }else
                                        {
                                            [dict setObject:@"villa" forKey:@"type"];
                                        }
                                        
                                        
                                        
                                        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                                        [manager POST:@"http://almasdarapp.com/Dawerle/storeSearchFlat.php" parameters:dict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                                            NSString* ID = responseObject[@"res"];
                                            if([ID containsString:@"ERROR"])
                                            {
                                                OpinionzAlertView *alert = [[OpinionzAlertView alloc]initWithTitle:@"حدث خلل" message:@"يرجى المحاولة مرة أحرى" cancelButtonTitle:@"OK" otherButtonTitles:@[]];
                                                alert.iconType = OpinionzAlertIconWarning;
                                                alert.color = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1];
                                                
                                                [UIView transitionWithView:eqHolder
                                                                  duration:0.2f
                                                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                                                animations:^{
                                                                    [eqHolder setAlpha:0.0];
                                                                    [_equalizer dismiss];
                                                                } completion:^(BOOL finished){
                                                                    [alert show];
                                                                }];
                                            }else
                                            {
                                                if([type isEqualToString:@"flats"])
                                                {
                                                    NSMutableArray* searchFlats = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"flatSearch"]];
                                                    [searchFlats addObject:ID];
                                                    [[NSUserDefaults standardUserDefaults]setObject:searchFlats forKey:@"flatSearch"];
                                                }else
                                                {
                                                    NSMutableArray* searchFlats = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"villaSearch"]];
                                                    [searchFlats addObject:ID];
                                                    [[NSUserDefaults standardUserDefaults]setObject:searchFlats forKey:@"villaSearch"];
                                                }
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                
                                                OpinionzAlertView *alert = [[OpinionzAlertView alloc] initWithTitle:@"Wohoo"
                                                                                                            message:@"الأن إستريح و دورلي سيقوم بالبحث بدلاً عنك و يبلغك فور نزول أي إعلان على أي موقع يلبي طلبك" cancelButtonTitle:@"(Y)"              otherButtonTitles:@[@"تصفح النتائج؟"]          usingBlockWhenTapButton:^(OpinionzAlertView *alertView, NSInteger buttonIndex) {
                                                                                                                if(buttonIndex == 0)
                                                                                                                {
                                                                                                                    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                                                                                                                    for (UIViewController *aViewController in allViewControllers) {
                                                                                                                        if ([aViewController isKindOfClass:[ViewController class]]) {
                                                                                                                            [self.navigationController popToViewController:aViewController animated:YES];
                                                                                                                        }
                                                                                                                    }
                                                                                                                }else
                                                                                                                {
                                                                                                                    [self performSegueWithIdentifier:@"exploreSeg" sender:self];
                                                                                                                }
                                                                                                            }];
                                                alert.iconType = OpinionzAlertIconSuccess;
                                                alert.color = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1];
                                                
                                                
                                                [UIView transitionWithView:eqHolder
                                                                  duration:0.2f
                                                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                                                animations:^{
                                                                    [eqHolder setAlpha:0.0];
                                                                    [_equalizer dismiss];
                                                                } completion:^(BOOL finished){
                                                                    [alert show];
                                                                }];
                                            }
                                        } failure:^(NSURLSessionTask *operation, NSError *error) {
                                            OpinionzAlertView *alert = [[OpinionzAlertView alloc]initWithTitle:@"حدث خلل" message:@"يرجى المحاولة مرة أحرى" cancelButtonTitle:@"OK" otherButtonTitles:@[]];
                                            alert.iconType = OpinionzAlertIconWarning;
                                            alert.color = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1];
                                            
                                            [UIView transitionWithView:eqHolder
                                                              duration:0.2f
                                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                                            animations:^{
                                                                [eqHolder setAlpha:0.0];
                                                                [_equalizer dismiss];
                                                            } completion:^(BOOL finished){
                                                                [alert show];
                                                            }];
                                        }];
                                    }];
    [popup setKeyboardTypeForTextFields:@[@"NUMBER"]];
    [popup setBackgroundBlurType:PopupBackGroundBlurTypeDark];
    [popup setIncomingTransition:PopupIncomingTransitionTypeBounceFromCenter];
    [popup setOutgoingTransition:PopupOutgoingTransitionTypeBounceFromCenter];
    [popup setTapBackgroundToDismiss:YES];
    [popup setDelegate:self];
    [popup setBackgroundColor:[UIColor colorFromHexCode:@"1085C7"]];
    [popup setSuccessBtnColor:[UIColor colorFromHexCode:@"34a853"]];
    [popup setSuccessTitleColor:[UIColor whiteColor]];
    [popup setCancelTitleColor:[UIColor whiteColor]];
    [popup setTitleColor:[UIColor whiteColor]];
    [popup setSubTitleColor:[UIColor whiteColor]];
    [popup showPopup];
}

#pragma mark table methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"إختر عدد الغرف:";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableVieww cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID = @"roomCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if (dataSource.count == (indexPath.row+1))
    {
        [(UILabel*)[cell viewWithTag:4]setHidden:YES];
    }
    
    [(UILabel*)[cell viewWithTag:1]setText:[dataSource objectAtIndex:indexPath.row]];
    [(UIImageView*)[cell viewWithTag:2]setImage:[UIImage imageNamed:@"mark-off.png"]];
    
    if([[tableView indexPathsForSelectedRows]containsObject:indexPath])
    {
        [UIView transitionWithView:(UIImageView*)[cell viewWithTag:2]
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [(UIImageView*)[cell viewWithTag:2]setImage:[UIImage imageNamed:@"mark-on.png"]];
                        } completion:NULL];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableVieww didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [UIView transitionWithView:(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]setImage:[UIImage imageNamed:@"mark-off.png"]];
                        if(tableVieww.indexPathsForSelectedRows.count == 0)
                        {
                            [roomesButton setAlpha:0.0f];
                        }
                    } completion:NULL];
    
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
}
-(void)tableView:(UITableView *)tableVieww didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [UIView transitionWithView:(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]setImage:[UIImage imageNamed:@"mark-on.png"]];
                        if(roomesButton.alpha == 0.0f)
                        {
                            [roomesButton setAlpha:1.0f];
                        }
                    } completion:NULL];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
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

- (void)dictionary:(NSMutableDictionary *)dictionary forpopup:(Popup *)popup stringsFromTextFields:(NSArray *)stringArray {
    
    NSString *textFromBox1 = [stringArray objectAtIndex:0];
    maxPrice = textFromBox1;
}

#pragma mark alert view methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1)
    {
        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
        for (UIViewController *aViewController in allViewControllers) {
            if ([aViewController isKindOfClass:[ViewController class]]) {
                [self.navigationController popToViewController:aViewController animated:YES];
            }
        }
    }
}

@end
