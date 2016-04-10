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
#import <Google/Analytics.h>
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
    IBOutlet UIView *headerView;
    __weak IBOutlet UIView *bannerAdHolder;
    GADBannerView* bannerView;
    __weak IBOutlet FUIButton *roomesButton;
    __weak IBOutlet UITableView *tableView;
    NSMutableArray* dataSource;
    NSString* maxPrice;
    __weak IBOutlet UIView *eqHolder;
    id<GAITracker> tracker;
    NSMutableArray* openedSections;
    NSMutableArray* selectedCities;
}

@synthesize type;

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"roomSeg"])
    {
        RoomsViewController* dst = (RoomsViewController*)[segue destinationViewController];
        NSMutableArray* keywords = [[NSMutableArray alloc]init];
        for(int i = 0 ; i < selectedCities.count ; i++)
            {
                NSArray* arr = [[selectedCities objectAtIndex:i] componentsSeparatedByString:@"-"];
                [keywords addObject:[[[dataSource objectAtIndex:[[arr objectAtIndex:0] intValue]] objectForKey:@"cities"] objectAtIndex:[[arr objectAtIndex:1] intValue]]];
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
    }else if([[segue identifier] isEqualToString:@"exploreSeg"])
    {
        SearchesViewController* dst = (SearchesViewController*)[segue destinationViewController];
        [dst setDataID:@"stores"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:19]}];
    
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];

    
    openedSections = [[NSMutableArray alloc]init];
    selectedCities = [[NSMutableArray alloc]init];
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
    
    tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"AreaViewController"];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    if(dataSource.count == 0)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"combinedAreas" ofType:@"json"];
        if([_countryType isEqualToString:@"KW"])
        {
            filePath = [[NSBundle mainBundle] pathForResource:@"combinedAreas" ofType:@"json"];
            /*NSData *content = [[NSData alloc] initWithContentsOfFile:filePath];
            dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:nil]];
            NSMutableArray* indices = [[NSMutableArray alloc]init];
            
            for(int i = 0 ; i < dataSource.count ; i++)
            {
                [indices addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            [tableView insertRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationTop];*/
        }else
        {
           filePath = [[NSBundle mainBundle] pathForResource:@"combinedAreasSA" ofType:@"json"];
            /*NSData *content = [[NSData alloc] initWithContentsOfFile:filePath];
            dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:nil]];
            NSMutableIndexSet* set = [[NSMutableIndexSet alloc]init];
            
            for(int i = 0 ; i < dataSource.count ; i++)
            {
                [set addIndex:i];
            }
            [tableView insertSections:set withRowAnimation:UITableViewRowAnimationTop];*/
        }
        
        NSData *content = [[NSData alloc] initWithContentsOfFile:filePath];
        dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:nil]];
        NSMutableIndexSet* set = [[NSMutableIndexSet alloc]init];
        
        for(int i = 0 ; i < dataSource.count ; i++)
        {
            [set addIndex:i];
        }
        [tableView insertSections:set withRowAnimation:UITableViewRowAnimationTop];
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
    return  dataSource.count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString* string = [NSString stringWithFormat:@"%i",(int)section];
    if([openedSections containsObject:string])
    {
        return  [[[dataSource objectAtIndex:section] objectForKey:@"cities"] count];
    }else
    {
        return 0;
    }
}


-(UITableViewCell*)tableView:(UITableView *)tableVieww cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID = @"areaCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [(UILabel*)[cell viewWithTag:1]setText:[[[dataSource objectAtIndex:indexPath.section] objectForKey:@"cities"] objectAtIndex:indexPath.row]];
    [(UIImageView*)[cell viewWithTag:2]setImage:[UIImage imageNamed:@"mark-off.png"]];
    
    NSString* cellIndex = [NSString stringWithFormat:@"%i-%i",(int)indexPath.section,(int)indexPath.row];
    

    if([selectedCities containsObject:cellIndex])
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
    NSString* toBeRemoved = [NSString stringWithFormat:@"%i-%i",(int)indexPath.section,(int)indexPath.row];
    for(int i = 0 ; i < selectedCities.count ; i++)
    {
        if([[selectedCities objectAtIndex:i]isEqualToString:toBeRemoved])
        {
            [selectedCities removeObjectAtIndex:i];
            break;
        }
    }
    
    [selectedCities removeObject:toBeRemoved];
    [UIView transitionWithView:(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]setImage:[UIImage imageNamed:@"mark-off.png"]];
                        if(selectedCities.count == 0)
                        {
                            [roomesButton setAlpha:0.0f];
                        }
                    } completion:NULL];

    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
}
-(void)tableView:(UITableView *)tableVieww didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [selectedCities addObject:[NSString stringWithFormat:@"%i-%i",(int)indexPath.section,(int)indexPath.row]];
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
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0f;
}
-(UIView*)tableView:(UITableView *)tableVieww viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableVieww.frame.size.width, 60)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 14, 32, 32)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    NSString* string = [NSString stringWithFormat:@"%i",(int)section];
    
    
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(70, 0 , 300, 60)];
    [label setText:[[dataSource objectAtIndex:section] objectForKey:@"title"]];
    [label setTextColor:[UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0]];
    [label setFont:[UIFont fontWithName:@"DroidArabicKufi" size:19.0]];
    [label setTextAlignment:NSTextAlignmentRight];
    
    if([openedSections containsObject:string])
    {
        [imageView setImage:[UIImage imageNamed:@"collapse.png"]];
    }else
    {
        [imageView setImage:[UIImage imageNamed:@"expand.png"]];
    }
    
    [view addSubview:imageView];
    [view addSubview:label];
    
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandler:)];
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.numberOfTapsRequired = 1;
    view.tag = section;
    [view addGestureRecognizer:singleTapRecognizer];

    
    return view;
}

-(void) gestureHandler:(UIGestureRecognizer *)gestureRecognizer
{
    int sectionClicked = (int)[gestureRecognizer.view tag];
    NSString* string = [NSString stringWithFormat:@"%i",(int)sectionClicked];
    if([openedSections containsObject:string])
    {
        [openedSections removeObject:string];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionClicked] withRowAnimation:UITableViewRowAnimationFade];
    }else
    {
        [openedSections addObject:string];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionClicked] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (IBAction)submitClicked:(id)sender {
    if([type isEqualToString:@"stores"])
    {
        NSMutableArray* keywords = [[NSMutableArray alloc]init];
        for(int i = 0 ; i < selectedCities.count ; i++)
        {
            NSArray* arr = [[selectedCities objectAtIndex:i] componentsSeparatedByString:@"-"];
            [keywords addObject:[[[dataSource objectAtIndex:[[arr objectAtIndex:0] intValue]] objectForKey:@"cities"] objectAtIndex:[[arr objectAtIndex:1] intValue]]];
        }
        Popup *popup = [[Popup alloc] initWithTitle:@"تحديد السعر"
                                           subTitle:@"قم بإدخال الحد الأعلى للسعر أو أتركه فارغاً ليتم تنبيهك بكل الأسعار. سيتم تنبيهك أيضاً بالإعلانات التي لم تضمن السعر لحصولك على أكبر فرصة ممكنه لتجد ما تريده"
                              textFieldPlaceholders:@[@""]
                                        cancelTitle:@"إلغاء"
                                       successTitle:@"دورلي ;)"
                                        cancelBlock:^{} successBlock:^{
                                            [eqHolder setAlpha:1.0];                                       [_equalizer show];
                                            
                                            
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
                                                    
                                                    [eqHolder setAlpha:0.0];                                       [_equalizer dismiss];                                                            [alert show];
                                                }else
                                                {
                                                    NSMutableArray* searchFlats = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"storeSearch"]];
                                                    [searchFlats addObject:ID];
                                                    [[NSUserDefaults standardUserDefaults]setObject:searchFlats forKey:@"storeSearch"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    
                                                    
                                                    OpinionzAlertView *alert = [[OpinionzAlertView alloc] initWithTitle:@"Wohoo"
                                                                                                                message:@"الأن إستريح و دورلي سيقوم بالبحث بدلاً عنك و يبلغك فور نزول أي إعلان على أي موقع يلبي طلبك" cancelButtonTitle:@"بحث جديد"              otherButtonTitles:@[@"تصفح النتائج؟"]          usingBlockWhenTapButton:^(OpinionzAlertView *alertView, NSInteger buttonIndex) {
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
                                                    
                                                   [eqHolder setAlpha:0.0];                                       [_equalizer dismiss];                                                            [alert show];                                                }
                                            } failure:^(NSURLSessionTask *operation, NSError *error) {
                                                OpinionzAlertView *alert = [[OpinionzAlertView alloc]initWithTitle:@"حدث خلل" message:@"يرجى المحاولة مرة أحرى" cancelButtonTitle:@"OK" otherButtonTitles:@[]];
                                                alert.iconType = OpinionzAlertIconWarning;
                                                alert.color = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1];
                                                [eqHolder setAlpha:0.0];                                       [_equalizer dismiss];                                                            [alert show];                                            }];
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
