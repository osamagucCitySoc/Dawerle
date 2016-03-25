//
//  AreaSelectionViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 1/25/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "AreaViewController.h"
#import "RoomsViewController.h"
#import "SearchesViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "Popup.h"
#import <FlatUIKit.h>
#import "FeEqualize.h"
#import "ViewController.h"
#import <OpinionzAlertView/OpinionzAlertView.h>
@import GoogleMobileAds;

@interface AreaViewController ()<UITableViewDelegate,UITableViewDataSource,PopupDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) FeEqualize *equalizer;
@end

@implementation AreaViewController
{
    __weak IBOutlet UIView *bannerAdHolder;
    GADBannerView* bannerView;
    __weak IBOutlet FUIButton *roomesButton;
    __weak IBOutlet UITableView *tableView;
    NSMutableArray* dataSource;
    NSString* maxPrice;
    __weak IBOutlet UIView *eqHolder;    
}

@synthesize type;

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"roomSeg"])
    {
        RoomsViewController* dst = (RoomsViewController*)[segue destinationViewController];
        NSMutableArray* keywords = [[NSMutableArray alloc]init];
        if([_countryType isEqualToString:@"KW"])
        {
            for(int i = 0 ; i < [tableView indexPathsForSelectedRows].count ; i++)
            {
                [keywords addObject:[dataSource objectAtIndex:[[tableView.indexPathsForSelectedRows objectAtIndex:i] row]]];
            }
        }else
        {
            for(int i = 0 ; i < [tableView indexPathsForSelectedRows].count ; i++)
            {
                NSIndexPath* index = [tableView.indexPathsForSelectedRows objectAtIndex:i];
                [keywords addObject:[[[dataSource objectAtIndex:index.section] objectForKey:@"cities"] objectAtIndex:index.row]];
            }
        }
        [dst setType:type];
        [dst setCountryType:_countryType];
        [dst setRentType:_rentType];
        [dst setSelectedAreas:keywords];
    }else if([[segue identifier]isEqualToString:@"showRecordedSearch"])
    {
        SearchesViewController* dst = (SearchesViewController*)[segue destinationViewController];
        if([type isEqualToString:@"villas"])
        {
            [dst setDataID:@"villas"];
        }else if([type isEqualToString:@"stores"])
        {
            [dst setDataID:@"stores"];
        }else
        {
            [dst setDataID:@"flats"];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:19]}];
    
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];

    
//    UIImage *myImage = [UIImage imageNamed:@"search-icon.png"];
//    myImage = [myImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:myImage style:UIBarButtonItemStylePlain target:self action:@selector(myFlatSearchClicked:)];
//    self.navigationItem.rightBarButtonItem = menuButton;

    
    
    roomesButton.buttonColor = [UIColor colorFromHexCode:@"34a853"];
    roomesButton.shadowColor = [UIColor greenSeaColor];
    roomesButton.shadowHeight = 0.0f;
    roomesButton.cornerRadius = 0.0f;
    roomesButton.alpha = 0.0f;
   // roomesButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    //[roomesButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    //[roomesButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    
    if([type isEqualToString:@"stores"])
    {
        [roomesButton setTitle:@"دورلي !" forState:UIControlStateNormal];
    }
    
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
    
    self.title = [self.title stringByAppendingString:@" - المناطق"];
    
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

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(dataSource.count == 0)
    {
        if([_countryType isEqualToString:@"KW"])
        {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"combinedAreas" ofType:@"json"];
            NSData *content = [[NSData alloc] initWithContentsOfFile:filePath];
            dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:nil]];
            NSMutableArray* indices = [[NSMutableArray alloc]init];
            
            for(int i = 0 ; i < dataSource.count ; i++)
            {
                [indices addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            [tableView insertRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationTop];
        }else
        {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"combinedAreasSA" ofType:@"json"];
            NSData *content = [[NSData alloc] initWithContentsOfFile:filePath];
            dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:nil]];
            NSMutableIndexSet* set = [[NSMutableIndexSet alloc]init];
            
            for(int i = 0 ; i < dataSource.count ; i++)
            {
                [set addIndex:i];
            }
            [tableView insertSections:set withRowAnimation:UITableViewRowAnimationTop];
        }
    }

    _equalizer = [[FeEqualize alloc] initWithView:eqHolder title:@"جاري حفظ بحثك"];
    CGRect frame = CGRectMake(0, 0, 70, 70);
    [_equalizer setFrame:frame];
    [_equalizer setBackgroundColor:[UIColor clearColor]];
    [eqHolder setBackgroundColor:[UIColor clearColor]];
    [eqHolder addSubview:_equalizer];
    [eqHolder setAlpha:0.0];
    [_equalizer dismiss];
    
    CGRect frame1 = bannerView.frame;
    CGRect frame2 = bannerAdHolder.frame;
    frame1.origin.x = (frame2.size.width/2)-160;
    [bannerView setFrame:frame1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([_countryType isEqualToString:@"KW"])
    {
        return 1;
    }else
    {
        return  dataSource.count;
    }
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([_countryType isEqualToString:@"KW"])
    {
        return @"إختر المناطق :";
    }else
    {
        return  [[dataSource objectAtIndex:section] objectForKey:@"title"];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableVieww cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID = @"areaCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    /*if([_countryType isEqualToString:@"KW"])
    {
        if (dataSource.count == (indexPath.row+1))
        {
            [(UILabel*)[cell viewWithTag:4]setHidden:YES];
        }
    }else
    {
        
    }*/
    
    
    
    if([_countryType isEqualToString:@"KW"])
    {
        [(UILabel*)[cell viewWithTag:1]setText:[dataSource objectAtIndex:indexPath.row]];
    }else
    {
        [(UILabel*)[cell viewWithTag:1]setText:[[[dataSource objectAtIndex:indexPath.section] objectForKey:@"cities"] objectAtIndex:indexPath.row]];
    }
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

    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0]];
    [header.textLabel setFont:[UIFont fontWithName:@"DroidArabicKufi" size:14.0]];
    [header.textLabel setTextAlignment:NSTextAlignmentRight];
}

- (IBAction)submitClicked:(id)sender {
    if([type isEqualToString:@"stores"])
    {
        NSMutableArray* keywords = [[NSMutableArray alloc]init];
        if([_countryType isEqualToString:@"KW"])
        {
            for(int i = 0 ; i < [tableView indexPathsForSelectedRows].count ; i++)
            {
                [keywords addObject:[dataSource objectAtIndex:[[tableView.indexPathsForSelectedRows objectAtIndex:i] row]]];
            }
        }else
        {
            for(int i = 0 ; i < [tableView indexPathsForSelectedRows].count ; i++)
            {
                NSIndexPath* index = [tableView.indexPathsForSelectedRows objectAtIndex:i];
                [keywords addObject:[[[dataSource objectAtIndex:index.section] objectForKey:@"cities"] objectAtIndex:index.row]];
            }
        }
        
        Popup *popup = [[Popup alloc] initWithTitle:@"تحديد السعر"
                                           subTitle:@"قم بإدخال الحد الأعلى للسعر أو أتركه فارغاً ليتم تنبيهك بكل الأسعار"
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
                                            if(rooms.count == 0)
                                            {
                                                [rooms addObject:@"-1"];
                                            }
                                            [dict setObject:keywords forKey:@"keywords"];
                                            [dict setObject:rooms forKey:@"rooms"];
                                            
                                            if([maxPrice isEqualToString:@""])
                                            {
                                                maxPrice = @"-1";
                                            }
                                            [dict setObject:[NSNumber numberWithInt:[maxPrice intValue]] forKey:@"price"];
                                            [dict setObject:@"store" forKey:@"type"];
                                            [dict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"] forKey:@"token"];
                                            [dict setObject:_countryType forKey:@"country"];
                                            [dict setObject:_rentType forKey:@"rent"];
                                            
                                            
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
                                                    NSMutableArray* searchFlats = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"storeSearch"]];
                                                    [searchFlats addObject:ID];
                                                    [[NSUserDefaults standardUserDefaults]setObject:searchFlats forKey:@"storeSearch"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    
                                                    
                                                    OpinionzAlertView *alert = [[OpinionzAlertView alloc] initWithTitle:@"Wohoo"
                                                                                                                message:@"الأن إستريح و دورلي سيقوم بالبحث بدلاً عنك و يبلغك فور نزول أي إعلان على أي موقع يلبي طلبك" cancelButtonTitle:@"(Y)"              otherButtonTitles:nil          usingBlockWhenTapButton:^(OpinionzAlertView *alertView, NSInteger buttonIndex) {
                                                                                                                    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                                                                                                                    for (UIViewController *aViewController in allViewControllers) {
                                                                                                                        if ([aViewController isKindOfClass:[ViewController class]]) {
                                                                                                                            [self.navigationController popToViewController:aViewController animated:YES];
                                                                                                                        }
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
    }else
    {
        [self performSegueWithIdentifier:@"roomSeg" sender:self];
    }
}

- (void)dictionary:(NSMutableDictionary *)dictionary forpopup:(Popup *)popup stringsFromTextFields:(NSArray *)stringArray {
    
    NSString *textFromBox1 = [stringArray objectAtIndex:0];
    maxPrice = textFromBox1;
}


#pragma mark aert view methods
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


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
