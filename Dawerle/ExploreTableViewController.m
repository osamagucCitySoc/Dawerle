//
//  ExploreTableViewController.m
//
//
//  Created by Osama Rabie on 2/13/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "ExploreTableViewController.h"
#import "DownloaderClass.h"
#import "ShowSearchViewController.h"
#import <FlatUIKit.h>
#import "FeEqualize.h"
#import <AFNetworking/AFNetworking.h>
#import <OpinionzAlertView/OpinionzAlertView.h>
#import <Google/Analytics.h>

@interface ExploreTableViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FeEqualize *equalizer;
@end

@implementation ExploreTableViewController
{
    NSMutableArray* dataSource;
    DownloaderClass* class;
     __weak IBOutlet UIView *eqHolder;
    NSIndexPath* selected;
    id<GAITracker> tracker;
    __weak IBOutlet FUIButton *moreButton;
}

@synthesize className,searchingParams;


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"searchWebSeg"])
    {
        NSDictionary* dict = [dataSource objectAtIndex:selected.section];
        
        NSURL* url = [NSURL URLWithString:[dict objectForKey:@"link"]];
        if(!url)
        {
            url = [NSURL URLWithString:[[dict objectForKey:@"link"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        NSString* titlee = [NSString stringWithFormat:@"%@ : %@",@"إعلان من موقع",[dict objectForKey:@"source"]];
        ShowSearchViewController* dst = (ShowSearchViewController*)[segue destinationViewController];
        [dst setLink:url];
        [dst setTitlee:titlee];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataSource = [[NSMutableArray alloc] init];
    class = [DownloaderClass sharedInstance];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    
    tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"ExploreViewController"];
    
    
    moreButton.buttonColor = [UIColor colorFromHexCode:@"34a853"];
    moreButton.shadowColor = [UIColor greenSeaColor];
    moreButton.shadowHeight = 0.0f;
    moreButton.cornerRadius = 0.0f;
    moreButton.alpha = 0.0f;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(dataSource.count == 0)
    {
        [self loadItems];
    }
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)loadItems
{
    [_equalizer removeFromSuperview];
    _equalizer = [[FeEqualize alloc] initWithView:eqHolder title:@"جاري التحميل.."];
    CGRect frame = CGRectMake(0, 0, 70, 70);
    [_equalizer setFrame:frame];
    
    [_equalizer setBackgroundColor:[UIColor clearColor]];
    [eqHolder setBackgroundColor:[UIColor clearColor]];
    [eqHolder addSubview:_equalizer];
    [eqHolder setAlpha:0.0];
    [_equalizer dismiss];
    
    [UIView transitionWithView:eqHolder
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [eqHolder setAlpha:1.0];
                        [_equalizer show];
                    } completion:nil];

    NSString* url;
    if([className isEqualToString:@"cars"])
    {
        url = @"http://almasdarapp.com/Dawerle/getCarsForSearch.php";
    }else if([className isEqualToString:@"flats"] || [className isEqualToString:@"villas"] || [className isEqualToString:@"stores"])
    {
        url = @"http://almasdarapp.com/Dawerle/getFlatsForSearch.php";
    }else if([className isEqualToString:@"jobs"])
    {
       url = @"http://almasdarapp.com/Dawerle/getJobsForSearch.php";
    }

    
    NSMutableDictionary* params = [[NSMutableDictionary alloc]initWithDictionary:searchingParams];
    [params setObject:[NSString stringWithFormat:@"%ld",dataSource.count] forKey:@"limit"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        @try {
            if(dataSource.count == 0)
            {
                dataSource = [[NSMutableArray alloc]initWithArray:responseObject copyItems:NO];
            }else
            {
                [dataSource addObjectsFromArray:responseObject];
            }
        }
        @catch (NSException *exception) {
            dataSource = nil;
        }

        if(!dataSource)
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
             dispatch_async( dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
                 [self.tableView setNeedsDisplay];
                 [UIView transitionWithView:eqHolder
                                   duration:0.2f
                                    options:UIViewAnimationOptionTransitionCrossDissolve
                                 animations:^{
                                     [eqHolder setAlpha:0.0];
                                     [_equalizer dismiss];
                                 } completion:nil];
             });
            
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
    if([className isEqualToString:@"villas"] || [className isEqualToString:@"flats"] || [className isEqualToString:@"stores"])
    {
        return 6;
    }else if([className isEqualToString:@"cars"])
    {
        return 6;
    }else if([className isEqualToString:@"jobs"])
    {
        return 3;
    }
    return 2;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"exploreCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if (dataSource.count == (indexPath.row+1))
    {
        [(UILabel*)[cell viewWithTag:4]setHidden:YES];
    }
    
    ((FUIButton*)[cell viewWithTag:2]).alpha = 0.0f;
    ((FUIButton*)[cell viewWithTag:3]).alpha = 0.0f;
    
    NSDictionary* dict = [dataSource objectAtIndex:indexPath.section];
    
    if([className isEqualToString:@"cars"])
    {
        if(indexPath.row == 0)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@ - %@",@"الماركة",[dict objectForKey:@"brand"],[dict objectForKey:@"sub"]]];
        }else if(indexPath.row == 1)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %i",@"سنة الصنع",[[dict objectForKey:@"year"] intValue]]];
        }else if(indexPath.row == 2)
        {
            if([[dict objectForKey:@"price"] intValue] <= 0)
            {
                [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"السعر",@"غير محدد"]];
            }else
            {
                [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %i",@"السعر",[[dict objectForKey:@"price"] intValue]]];
            }
        }else if(indexPath.row == 3)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"العنوان",[dict objectForKey:@"title"]]];
        }else if(indexPath.row == 4)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"الوصف",[dict objectForKey:@"descc"]]];
        }else if(indexPath.row == 5)
        {
            ((FUIButton*)[cell viewWithTag:2]).buttonColor = [UIColor colorFromHexCode:@"34a853"];
            ((FUIButton*)[cell viewWithTag:2]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:2]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).cornerRadius = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).alpha = 1.0f;
            [(FUIButton*)[cell viewWithTag:2] addTarget:self
                                                 action:@selector(exploreClicked:) forControlEvents:UIControlEventTouchUpInside];
            ((FUIButton*)[cell viewWithTag:3]).alpha = 1.0f;
            [(FUIButton*)[cell viewWithTag:3] addTarget:self
                                                 action:@selector(shareClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }else if([className isEqualToString:@"flats"] || [className isEqualToString:@"villas"] || [className isEqualToString:@"stores"])
    {
        if(indexPath.row == 0)
        {
            if([[dict objectForKey:@"loc"] isEqualToString:@"-1"])
            {
                [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"العنوان",@"غير محدد"]];
            }else
            {
                [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"العنوان",[dict objectForKey:@"loc"]]];
            }
        }else if(indexPath.row == 1)
        {
            NSArray* rooms = [[dict objectForKey:@"rooms"] componentsSeparatedByString:@" ، "];
                if([rooms.firstObject isEqualToString:@"-1"] || [rooms.firstObject isEqualToString:@"0"])
                {
                    [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"عدد الغرف",@"غير محدد"]];
                }else
                {
                    [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"عدد الغرف",rooms.firstObject]];
                }
           
        }else if(indexPath.row == 2)
        {
            if([[dict objectForKey:@"price"] intValue] <= 0)
            {
                [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"السعر",@"غير محدد"]];
            }else
            {
                [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %i",@"السعر",[[dict objectForKey:@"price"] intValue]]];
            }
        }else if(indexPath.row == 3)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"العنوان",[dict objectForKey:@"title"]]];
        }else if(indexPath.row == 4)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"الوصف",[dict objectForKey:@"descc"]]];
        }else if(indexPath.row == 5)
        {
            ((FUIButton*)[cell viewWithTag:2]).buttonColor = [UIColor colorFromHexCode:@"34a853"];
            ((FUIButton*)[cell viewWithTag:2]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:2]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).cornerRadius = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).alpha = 1.0f;
            [(FUIButton*)[cell viewWithTag:2] addTarget:self
                                                 action:@selector(exploreClicked:) forControlEvents:UIControlEventTouchUpInside];
            ((FUIButton*)[cell viewWithTag:3]).alpha = 1.0f;
            [(FUIButton*)[cell viewWithTag:3] addTarget:self
                                                 action:@selector(shareClicked:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }else if([className isEqualToString:@"jobs"])
    {
        if(indexPath.row == 0)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"العنوان",[dict objectForKey:@"title"]]];
        }else if(indexPath.row == 1)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"الوصف",[dict objectForKey:@"descc"]]];
        }else if(indexPath.row == 2)
        {
            ((FUIButton*)[cell viewWithTag:2]).buttonColor = [UIColor colorFromHexCode:@"34a853"];
            ((FUIButton*)[cell viewWithTag:2]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:2]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).cornerRadius = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).alpha = 1.0f;
            [(FUIButton*)[cell viewWithTag:2] addTarget:self
                                                 action:@selector(exploreClicked:) forControlEvents:UIControlEventTouchUpInside];
            ((FUIButton*)[cell viewWithTag:3]).alpha = 1.0f;
            [(FUIButton*)[cell viewWithTag:3] addTarget:self
                                                 action:@selector(shareClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    if(indexPath.section >= dataSource.count-5)
    {
       [moreButton setAlpha:1.0f];
    }else
    {
        [moreButton setAlpha:0.0f];
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
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:SS"];
    
    NSDictionary* dict = [dataSource objectAtIndex:section];
    NSDate* date = [formatter dateFromString:[dict objectForKey:@"addedOn"]];
    NSTimeInterval secondsInOneHour = 1 * 60 * 60;
    NSDate *dateOnetHourAhead = [date dateByAddingTimeInterval:secondsInOneHour];
    return [NSString stringWithFormat:@"في %@",[formatter stringFromDate:dateOnetHourAhead]];
}


- (void)exploreClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        selected = indexPath;
        [self performSegueWithIdentifier:@"searchWebSeg" sender:self];
    }
}
- (void)shareClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        NSString *textToShare = @"";
        if([className isEqualToString:@"cars"])
        {
            textToShare = @"إعلان سيارة للبيع :";
        }else if([className isEqualToString:@"flats"])
        {
            textToShare = @"إعلان شقة للإيجار :";
        }else if([className isEqualToString:@"villas"])
        {
            textToShare = @"إعلان فيلا للإيجار :";
        }else if([className isEqualToString:@"stores"])
        {
            textToShare = @"إعلان محل للإيجار";
        }else if([className isEqualToString:@"jobs"])
        {
            textToShare = @"إعلان وظيفة :";
        }
        NSDictionary* dict = [dataSource objectAtIndex:indexPath.section];
        textToShare = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n. تابع كل إعلانات الكويت في مكان واحد من خلال تطبيق دورلي للأيفون : %@",textToShare,[dict objectForKey:@"title"],[dict objectForKey:@"descc"],[dict objectForKey:@"link"],@"https://goo.gl/G4qzzk"];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[textToShare] applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll]; //Exclude whichever aren't relevant
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}
- (IBAction)moreButtonClicked:(id)sender {
    [self loadItems];
}
@end
