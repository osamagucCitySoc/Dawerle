//
//  SearchesViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 3/6/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "SearchesViewController.h"
#import "ExploreTableViewController.h"
#import <FlatUIKit.h>
#import "FeEqualize.h"
#import "ViewController.h"
#import <OpinionzAlertView/OpinionzAlertView.h>
#import <AFNetworking/AFNetworking.h>
@import GoogleMobileAds;
#import <Google/Analytics.h>
#import "Popup.h"

@interface SearchesViewController ()<UITableViewDataSource,UITableViewDelegate,PopupDelegate>
@property (strong, nonatomic) FeEqualize *equalizer;
@end

@implementation SearchesViewController
{
    __weak IBOutlet UIView *bannerAdHolder;
    GADBannerView* bannerView;
    NSMutableArray* dataSource;
    NSString* localID;
    NSString* parseID;
    NSString* deleteID;
    __weak IBOutlet UIView *eqHolder;
    __weak IBOutlet UITableView *tableView;
    NSIndexPath* selected;
    id<GAITracker> tracker;
    NSString* maxPricee;
    NSString* minYearr;
    UIButton *transparentButton;
}

@synthesize dataID,normalBack;


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"exploreSeg"])
    {
        ExploreTableViewController* dst = (ExploreTableViewController*)[segue destinationViewController];
        [dst setClassName:dataID];
        [dst setSearchingParams:[dataSource objectAtIndex:selected.section]];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [transparentButton removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    if(normalBack)
    {
        transparentButton = [[UIButton alloc] init];
        [transparentButton setFrame:CGRectMake(0,0, 50, 40)];
        [transparentButton setBackgroundColor:[UIColor clearColor]];
        [transparentButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addSubview:transparentButton];
    }
    if(dataSource.count == 0)
    {
        [_equalizer removeFromSuperview];
        _equalizer = [[FeEqualize alloc] initWithView:eqHolder title:@"جاري التحميل.."];
        CGRect frame = CGRectMake(0, 0, 70, 70);
        [_equalizer setFrame:frame];
        
        [_equalizer setBackgroundColor:[UIColor clearColor]];
        [eqHolder setBackgroundColor:[UIColor clearColor]];
        [eqHolder addSubview:_equalizer];
        [eqHolder setAlpha:1.0];
        [_resView setHidden:YES];
        [_equalizer show];
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:localID] || [[[NSUserDefaults standardUserDefaults] objectForKey:localID] count] == 0)
        {
            OpinionzAlertView *alert = [[OpinionzAlertView alloc] initWithTitle:@"عفواً"
                                                                        message:@"لا يوجد أي عمليات بحث مسجلة من قبل."
                                                              cancelButtonTitle:@"OK"              otherButtonTitles:nil          usingBlockWhenTapButton:^(OpinionzAlertView *alertView, NSInteger buttonIndex) {
                                                                  [self.navigationController popViewControllerAnimated:YES];
                                                              }];
            alert.iconType = OpinionzAlertIconInfo;
            alert.color = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1];
            [alert show];
        }else
        {
            NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
            [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:localID] forKey:@"ids"];
            
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
            [manager POST:parseID parameters:dict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                dataSource = [[NSMutableArray alloc]initWithArray:responseObject copyItems:YES];
                dispatch_async( dispatch_get_main_queue(), ^{
                    NSMutableIndexSet* indices = [[NSMutableIndexSet alloc]init];
                    
                    for(int i = 0 ; i < dataSource.count ; i++)
                    {
                        [indices addIndex:i];
                    }
                    

                    
                    [tableView insertSections:indices withRowAnimation:UITableViewRowAnimationTop];
                });
                [eqHolder setAlpha:0.0];
                [_resView setHidden:NO];
                [_equalizer dismiss];
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"%@",[operation response]);
                OpinionzAlertView *alert = [[OpinionzAlertView alloc] initWithTitle:@"خطأ"
                                                                            message:@"حدث خطأ. يرجى المحاولة بعد قليل"
                                                                  cancelButtonTitle:@"OK"              otherButtonTitles:@[]          usingBlockWhenTapButton:^(OpinionzAlertView *alertView, NSInteger buttonIndex) {
                                                                      [self.navigationController popViewControllerAnimated:YES];
                                                                  }];
                alert.iconType = OpinionzAlertIconWarning;
                alert.color = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1];
                [alert show];
                
                [eqHolder setAlpha:0.0];
                [_resView setHidden:NO];
                [_equalizer dismiss];

                
            }];
        }
    }
    
    CGRect frame1 = bannerView.frame;
    CGRect frame2 = bannerAdHolder.frame;
    frame1.origin.x = (frame2.size.width/2)-160;
    [bannerView setFrame:frame1];
}


-(void)backAction:(UIBarButtonItem *)sender {
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[ViewController class]]) {
            [self.navigationController popToViewController:aViewController animated:YES];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if([dataID isEqualToString:@"flats"])
    {
        localID = @"flatSearch";
        parseID = @"http://almasdarapp.com/Dawerle/getSearchFlat.php";
        deleteID = @"http://almasdarapp.com/Dawerle/deleteSearchFlat.php";
    }else if([dataID isEqualToString:@"villas"])
    {
        localID = @"villaSearch";
        parseID = @"http://almasdarapp.com/Dawerle/getSearchFlat.php";
        deleteID = @"http://almasdarapp.com/Dawerle/deleteSearchFlat.php";
    }else if([dataID isEqualToString:@"stores"])
    {
        localID = @"storeSearch";
        parseID = @"http://almasdarapp.com/Dawerle/getSearchFlat.php";
        deleteID = @"http://almasdarapp.com/Dawerle/deleteSearchFlat.php";
    }else if([dataID isEqualToString:@"cars"])
    {
        localID = @"carSearch";
        parseID = @"http://almasdarapp.com/Dawerle/getSearchCar.php";
        deleteID = @"http://almasdarapp.com/Dawerle/deleteSearchCar.php";
    }else if([dataID isEqualToString:@"jobs"])
    {
        localID = @"jobSearch";
        parseID = @"http://almasdarapp.com/Dawerle/getSearchJob.php";
        deleteID = @"http://almasdarapp.com/Dawerle/deleteSearchJob.php";
    }
    
    
    
    dataSource = [[NSMutableArray alloc]init];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:19]}];
    
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    
    if([dataID isEqualToString:@"villas"])
    {
        self.title = @"فلل و قصور";
    }else if([dataID isEqualToString:@"flats"])
    {
        self.title = @"شقق";
    }else if([dataID isEqualToString:@"stores"])
    {
        self.title = @"مكاتب";
    }else if([dataID isEqualToString:@"cars"])
    {
        self.title = @"سيارات";
    }else if([dataID isEqualToString:@"jobs"])
    {
        self.title = @"وظائف";
    }
    
    bannerView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeBanner];
    bannerView.adUnitID = @"ca-app-pub-3916999996422088/5493912657";
    bannerView.rootViewController = self;
    GADRequest* request = [[GADRequest alloc]init];
    request.testDevices = @[ @"c89d60e378a6e6f767031c551ca757a7" ];
    [bannerView loadRequest:request];
    [bannerAdHolder addSubview:bannerView];
    
    tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"SearchesViewController"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([dataID isEqualToString:@"villas"] || [dataID isEqualToString:@"flats"])
    {
        return 4;
    }else if([dataID isEqualToString:@"stores"])
    {
        return 3;
    }else if([dataID isEqualToString:@"cars"])
    {
        return 5;
    }else if([dataID isEqualToString:@"jobs"])
    {
        return 2;
    }
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableVieww cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellID = @"searchCell";
    
    UITableViewCell *cell = [tableVieww dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    //    if (dataSource.count == (indexPath.row+1))
    //    {
    //        [(UILabel*)[cell viewWithTag:4]setHidden:YES];
    //    }
    
    ((FUIButton*)[cell viewWithTag:2]).alpha = 0.0f;
    ((FUIButton*)[cell viewWithTag:4]).alpha = 0.0f;
    ((UIView*)[cell viewWithTag:3]).alpha = 0.0f;
    ((UILabel*)[cell viewWithTag:1]).alpha = 1.0f;
    ((UIButton*)[cell viewWithTag:7]).alpha = 0.0f;
    NSDictionary* dict = [dataSource objectAtIndex:indexPath.section];
    
    if([dataID isEqualToString:@"villas"] || [dataID isEqualToString:@"flats"])
    {
        NSString* keywords = [dict objectForKey:@"locs"];
        int maxPrice  = [[dict objectForKey:@"price"] intValue];
        NSString* rooms = [dict objectForKey:@"rooms"];
        
        
        NSString* string = @"";
        if(indexPath.row == 0)
        {
            string = [NSString stringWithFormat:@"المناطق: %@",keywords];
        }else if(indexPath.row == 1)
        {
            string = [NSString stringWithFormat:@"الغرف: %@",rooms];
        }else if(indexPath.row == 2)
        {
            ((UIButton*)[cell viewWithTag:7]).alpha = 1.0f;
            [(UIButton*)[cell viewWithTag:7] addTarget:self
                                                action:@selector(editPriceClicked:) forControlEvents:UIControlEventTouchUpInside];
            if(maxPrice == -1)
            {
                string = [NSString stringWithFormat:@"السعر : %@",@"غير محدد"];
            }else
            {
                string = [NSString stringWithFormat:@"السعر : %i KD",maxPrice];
            }
        }else
        {
            ((UIButton*)[cell viewWithTag:7]).alpha = 0.0f;
            ((UILabel*)[cell viewWithTag:1]).alpha = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).buttonColor = [UIColor colorFromHexCode:@"39C73C"];
            ((FUIButton*)[cell viewWithTag:2]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:2]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).cornerRadius = 0.0f;
            
            ((FUIButton*)[cell viewWithTag:4]).buttonColor = [UIColor colorFromHexCode:@"FF2C26"];
            ((FUIButton*)[cell viewWithTag:4]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:4]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:4]).cornerRadius = 0.0f;
            
            ((FUIButton*)[cell viewWithTag:2]).alpha = 1.0f;
            ((UIView*)[cell viewWithTag:3]).alpha = 1.0f;
            ((FUIButton*)[cell viewWithTag:4]).alpha = 1.0f;
            
            [(FUIButton*)[cell viewWithTag:2] addTarget:self
                                                 action:@selector(exploreClicked:) forControlEvents:UIControlEventTouchUpInside];
            [(FUIButton*)[cell viewWithTag:4] addTarget:self
                                                 action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [(UILabel*)[cell viewWithTag:1] setText:string];
    }else if([dataID isEqualToString:@"stores"])
    {
        NSString* keywords = [dict objectForKey:@"locs"];
        int maxPrice  = [[dict objectForKey:@"price"] intValue];
        
        NSString* string = @"";
        if(indexPath.row == 0)
        {
            string = [NSString stringWithFormat:@"المناطق: %@",keywords];
        }else if(indexPath.row == 1)
        {
            ((UIButton*)[cell viewWithTag:7]).alpha = 1.0f;
            [(UIButton*)[cell viewWithTag:7] addTarget:self
                                                action:@selector(editPriceClicked:) forControlEvents:UIControlEventTouchUpInside];
            if(maxPrice == -1)
            {
                string = [NSString stringWithFormat:@"السعر : %@",@"غير محدد"];
            }else
            {
                string = [NSString stringWithFormat:@"السعر : %i KD",maxPrice];
            }
        }else
        {
            ((UIButton*)[cell viewWithTag:7]).alpha = 0.0f;
            ((UILabel*)[cell viewWithTag:1]).alpha = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).buttonColor = [UIColor colorFromHexCode:@"39C73C"];
            ((FUIButton*)[cell viewWithTag:2]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:2]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).cornerRadius = 0.0f;
            
            ((FUIButton*)[cell viewWithTag:4]).buttonColor = [UIColor colorFromHexCode:@"FF2C26"];
            ((FUIButton*)[cell viewWithTag:4]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:4]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:4]).cornerRadius = 0.0f;
            
            ((FUIButton*)[cell viewWithTag:2]).alpha = 1.0f;
            ((UIView*)[cell viewWithTag:3]).alpha = 1.0f;
            ((FUIButton*)[cell viewWithTag:4]).alpha = 1.0f;
            
            [(FUIButton*)[cell viewWithTag:2] addTarget:self
                                                 action:@selector(exploreClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [(FUIButton*)[cell viewWithTag:4] addTarget:self
                                                 action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [(UILabel*)[cell viewWithTag:1] setText:string];
    }else if([dataID isEqualToString:@"cars"])
    {
        NSString* brands = [dict objectForKey:@"brands"];
        NSString* sub = [dict objectForKey:@"subsHeaders"];
        int maxPrice  = [[dict objectForKey:@"price"] intValue];
        int year  = [[dict objectForKey:@"year"] intValue];
        
        NSString* string = @"";
        if(indexPath.row == 0)
        {
            string = [NSString stringWithFormat:@"الماركات الرئيسية: %@",brands];
        }else if(indexPath.row == 1)
        {
            string = [NSString stringWithFormat:@"الماركات الفرعية: %@",sub];
        }else if(indexPath.row == 2)
        {
            ((UIButton*)[cell viewWithTag:7]).alpha = 1.0f;
            [(UIButton*)[cell viewWithTag:7] addTarget:self
                                                action:@selector(editPriceClicked:) forControlEvents:UIControlEventTouchUpInside];
            if(maxPrice == -1)
            {
                string = [NSString stringWithFormat:@"السعر : %@",@"غير محدد"];
            }else
            {
                string = [NSString stringWithFormat:@"السعر : %i KD",maxPrice];
            }
        }else if(indexPath.row == 3)
        {
            ((UIButton*)[cell viewWithTag:7]).alpha = 1.0f;
            [(UIButton*)[cell viewWithTag:7] addTarget:self
                                                 action:@selector(editYearClicked:) forControlEvents:UIControlEventTouchUpInside];
            if(year == -1)
            {
                string = [NSString stringWithFormat:@"السنة : %@",@"غير محدد"];
            }else
            {
                string = [NSString stringWithFormat:@"السنة : %i",year];
            }
        }else
        {
            ((UIButton*)[cell viewWithTag:7]).alpha = 0.0f;
            ((UILabel*)[cell viewWithTag:1]).alpha = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).buttonColor = [UIColor colorFromHexCode:@"39C73C"];
            ((FUIButton*)[cell viewWithTag:2]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:2]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).cornerRadius = 0.0f;
            
            ((FUIButton*)[cell viewWithTag:4]).buttonColor = [UIColor colorFromHexCode:@"FF2C26"];
            ((FUIButton*)[cell viewWithTag:4]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:4]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:4]).cornerRadius = 0.0f;
            
            ((FUIButton*)[cell viewWithTag:2]).alpha = 1.0f;
            ((UIView*)[cell viewWithTag:3]).alpha = 1.0f;
            ((FUIButton*)[cell viewWithTag:4]).alpha = 1.0f;
            
            [(FUIButton*)[cell viewWithTag:2] addTarget:self
                                                 action:@selector(exploreClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [(FUIButton*)[cell viewWithTag:4] addTarget:self
                                                 action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [(UILabel*)[cell viewWithTag:1] setText:string];
    }else if([dataID isEqualToString:@"jobs"])
    {
        NSString* string = @"";
        if(indexPath.row == 0)
        {
            string = [NSString stringWithFormat:@"%@ : %@",@"الكلمات الدالة",[dict objectForKey:@"keywords"]];
        }else
        {
            ((UIButton*)[cell viewWithTag:7]).alpha = 0.0f;
            ((UILabel*)[cell viewWithTag:1]).alpha = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).buttonColor = [UIColor colorFromHexCode:@"39C73C"];
            ((FUIButton*)[cell viewWithTag:2]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:2]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).cornerRadius = 0.0f;
            
            ((FUIButton*)[cell viewWithTag:4]).buttonColor = [UIColor colorFromHexCode:@"FF2C26"];
            ((FUIButton*)[cell viewWithTag:4]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:4]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:4]).cornerRadius = 0.0f;
            
            ((FUIButton*)[cell viewWithTag:2]).alpha = 1.0f;
            ((FUIButton*)[cell viewWithTag:4]).alpha = 1.0f;
            
            [(FUIButton*)[cell viewWithTag:2] addTarget:self
                                                 action:@selector(exploreClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [(FUIButton*)[cell viewWithTag:4] addTarget:self
                                                 action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [(UILabel*)[cell viewWithTag:1] setText:string];
    }
    
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)exploreClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        selected = indexPath;
        [self performSegueWithIdentifier:@"exploreSeg" sender:self];
    }
}

- (void)editPriceClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        selected = indexPath;
        Popup *popup = [[Popup alloc] initWithTitle:@"تحديد السعر"
                                           subTitle:@"قم بإدخال الحد الأعلى للسعر أو أتركه فارغاً ليتم تنبيهك بكل الأسعار. سيتم تنبيهك أيضاً بالإعلانات التي لم تضمن السعر لحصولك على أكبر فرصة ممكنه لتجد ما تريده"
                              textFieldPlaceholders:@[@""]
                                        cancelTitle:@"إلغاء"
                                       successTitle:@"تعديل"
                                        cancelBlock:^{} successBlock:^{
                                            [eqHolder setAlpha:1.0];
                                            [_equalizer show];
                                            
                                            
                                            NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
                                            [dict setObject:[[dataSource objectAtIndex:selected.section] objectForKey:@"idd"] forKey:@"idd"];
                                            if([maxPricee isEqualToString:@""])
                                            {
                                                maxPricee = @"-1";
                                            }
                                            [dict setObject:maxPricee forKey:@"value"];
                                            
                                            if([dataID isEqualToString:@"villas"] || [dataID isEqualToString:@"flats"] || [dataID isEqualToString:@"stores"])
                                            {
                                                [dict setObject:@"searchFlats" forKey:@"table"];
                                            }else if([dataID isEqualToString:@"cars"])
                                            {
                                                [dict setObject:@"searchCars" forKey:@"table"];
                                            }
                                            [dict setObject:@"price" forKey:@"field"];
                                            [self updateMe:dict];
                                        }];
        [popup setTag:1];
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
}

- (void)editYearClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        selected = indexPath;
        Popup *popup = [[Popup alloc] initWithTitle:@"تحديد السنة"
                                           subTitle:@"قم بإدخال الحد الأدنى للسنة. سيتم تنبيهك أيضاً بالإعلانات التي لم تضمن السنة لحصولك على أكبر فرصة ممكنه لتجد ما تريده"
                              textFieldPlaceholders:@[@""]
                                        cancelTitle:@"إلغاء"
                                       successTitle:@"تعديل"
                                        cancelBlock:^{} successBlock:^{
                                            [eqHolder setAlpha:1.0];
                                            [_equalizer show];
                                            
                                            
                                            NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
                                            [dict setObject:[[dataSource objectAtIndex:selected.section] objectForKey:@"idd"] forKey:@"idd"];
                                            if([minYearr isEqualToString:@""])
                                            {
                                                minYearr = @"-1";
                                            }
                                            [dict setObject:minYearr forKey:@"value"];
                                            
                                            if([dataID isEqualToString:@"villas"] || [dataID isEqualToString:@"flats"] || [dataID isEqualToString:@"stores"])
                                            {
                                                [dict setObject:@"searchFlats" forKey:@"table"];
                                            }else if([dataID isEqualToString:@"cars"])
                                            {
                                                [dict setObject:@"searchCars" forKey:@"table"];
                                            }
                                            [dict setObject:@"year" forKey:@"field"];
                                            [self updateMe:dict];
                                        }];
        [popup setTag:2];
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
}

-(void)updateMe:(NSDictionary*)dict2
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:@"http://almasdarapp.com/Dawerle/updateSearch.php" parameters:dict2 progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSString* ID = responseObject[@"res"];
        if([ID containsString:@"ERROR"])
        {
            OpinionzAlertView *alert = [[OpinionzAlertView alloc]initWithTitle:@"حدث خلل" message:@"يرجى المحاولة مرة أحرى" cancelButtonTitle:@"OK" otherButtonTitles:@[]];
            alert.iconType = OpinionzAlertIconWarning;
            alert.color = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1];
            
            [eqHolder setAlpha:0.0];
            [_equalizer dismiss];
            [alert show];
        }else
        {
            [eqHolder setAlpha:0.0];
            [_equalizer dismiss];
            NSMutableDictionary* dict = [[NSMutableDictionary alloc]initWithDictionary:[dataSource objectAtIndex:selected.section]];
            if([[dict2 objectForKey:@"field"]isEqualToString:@"price"])
            {
                [dict setObject:maxPricee forKey:@"price"];
            }else
            {
                [dict setObject:minYearr forKey:@"year"];
            }
            [dataSource replaceObjectAtIndex:selected.section withObject:dict];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:selected.section] withRowAnimation:UITableViewRowAnimationFade];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        OpinionzAlertView *alert = [[OpinionzAlertView alloc]initWithTitle:@"حدث خلل" message:@"يرجى المحاولة مرة أحرى" cancelButtonTitle:@"OK" otherButtonTitles:@[]];
        alert.iconType = OpinionzAlertIconWarning;
        alert.color = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1];
        [eqHolder setAlpha:0.0];
        [_equalizer dismiss];
        [alert show];
    }];
}

- (void)deleteClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        OpinionzAlertView *alert = [[OpinionzAlertView alloc] initWithTitle:@"أكيد؟"
                                                                    message:@"لن تستطيع الحصول على إشعارات عند نزول إعلانات جديدة؟"
                                                          cancelButtonTitle:@"إلغاء"              otherButtonTitles:@[@"مسح"]          usingBlockWhenTapButton:^(OpinionzAlertView *alertView, NSInteger buttonIndex) {
                                                              if(buttonIndex == 1)
                                                              {
                                                                  [eqHolder setAlpha:1.0];
                                                                  [_resView setHidden:YES];
                                                                  [_equalizer show];
                                                                  
                                                                  
                                                                  
                                                                  
                                                                  NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
                                                                  [dict setObject:[[dataSource objectAtIndex:indexPath.section] objectForKey:@"idd"] forKey:@"id"];
                                                                  
                                                                  
                                                                  
                                                                  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                                                                  [manager POST:deleteID parameters:dict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                                                                      NSMutableArray* array = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:localID]];
                                                                      [array removeObjectAtIndex:indexPath.section];
                                                                      [[NSUserDefaults standardUserDefaults]setObject:array forKey:localID];
                                                                      [[NSUserDefaults standardUserDefaults]synchronize];
                                                                      [UIView transitionWithView:eqHolder
                                                                                        duration:0.2f
                                                                                         options:UIViewAnimationOptionTransitionCrossDissolve
                                                                                      animations:^{
                                                                                          [eqHolder setAlpha:0.0];
                                                                                          [_resView setHidden:NO];
                                                                                          [_equalizer dismiss];
                                                                                      } completion:^(BOOL finished){
                                                                                          dispatch_async( dispatch_get_main_queue(), ^{
                                                                                              [dataSource removeObjectAtIndex:indexPath.section];
                                                                                              NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];
                                                                                              [tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
                                                                                          });
                                                                                      }];
                                                                  } failure:^(NSURLSessionTask *operation, NSError *error) {
                                                                      OpinionzAlertView *alert = [[OpinionzAlertView alloc]initWithTitle:@"حدث خلل" message:@"يرجى المحاولة مرة أحرى" cancelButtonTitle:@"OK" otherButtonTitles:@[]];
                                                                      alert.iconType = OpinionzAlertIconWarning;
                                                                      alert.color = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1];
                                                                      
                                                                      [eqHolder setAlpha:0.0];
                                                                      [_equalizer dismiss];
                                                                      [alert show];
                                                                  }];

                                                              }
                                                          }];
        alert.iconType = OpinionzAlertIconInfo;
        alert.color = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1];
        [alert show];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [[header contentView]setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [header.textLabel setTextColor:[UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0]];
    [header.textLabel setFont:[UIFont fontWithName:@"DroidArabicKufi" size:14.0]];
    [header.textLabel setTextAlignment:NSTextAlignmentRight];
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%@ : %li",@"بحث رقم",(long)section+1];
}

#pragma mark pop up delegate
- (void)dictionary:(NSMutableDictionary *)dictionary forpopup:(Popup *)popup stringsFromTextFields:(NSArray *)stringArray {
    
    NSString *textFromBox1 = [stringArray objectAtIndex:0];
    if(popup.tag == 1)
    {
        maxPricee = textFromBox1;
    }else if(popup.tag == 2)
    {
        minYearr = textFromBox1;
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

