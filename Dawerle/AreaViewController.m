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
#import <KinveyKit/KinveyKit.h>
#import "searchFlats.h"
#import "Popup.h"
#import <FlatUIKit.h>
#import "FeEqualize.h"
#import "ViewController.h"
#import <OpinionzAlertView/OpinionzAlertView.h>

@interface AreaViewController ()<UITableViewDelegate,UITableViewDataSource,PopupDelegate,UIAlertViewDelegate>
@property(nonatomic,strong)KCSAppdataStore* store;
@property (strong, nonatomic) FeEqualize *equalizer;
@end

@implementation AreaViewController
{
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
        for(int i = 0 ; i < [tableView indexPathsForSelectedRows].count ; i++)
        {
            [keywords addObject:[dataSource objectAtIndex:[[tableView.indexPathsForSelectedRows objectAtIndex:i] row]]];
        }
        [dst setType:type];
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
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(dataSource.count == 0)
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
    }

    _equalizer = [[FeEqualize alloc] initWithView:eqHolder title:@"جاري حفظ بحثك"];
    CGRect frame = CGRectMake(0, 0, 70, 70);
    [_equalizer setFrame:frame];
    [_equalizer setBackgroundColor:[UIColor clearColor]];
    [eqHolder setBackgroundColor:[UIColor clearColor]];
    [eqHolder addSubview:_equalizer];
    [eqHolder setAlpha:0.0];
    [_equalizer dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"إختر المناطق :";
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

    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0]];
    [header.textLabel setFont:[UIFont fontWithName:@"DroidArabicKufi" size:14.0]];
    [header.textLabel setTextAlignment:NSTextAlignmentRight];
}

- (IBAction)myFlatSearchClicked:(id)sender {
    [self performSegueWithIdentifier:@"showRecordedSearch" sender:self];
}

- (IBAction)submitClicked:(id)sender {
    if([type isEqualToString:@"stores"])
    {
        NSMutableArray* keywords = [[NSMutableArray alloc]init];
        for(int i = 0 ; i < [tableView indexPathsForSelectedRows].count ; i++)
        {
            [keywords addObject:[dataSource objectAtIndex:[[tableView.indexPathsForSelectedRows objectAtIndex:i] row]]];
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
                                            _store = [KCSAppdataStore storeWithOptions:@{ KCSStoreKeyCollectionName : @"searchFlats",
                                                                                          KCSStoreKeyCollectionTemplateClass : [searchFlats class]}];
                                            searchFlats* event = [[searchFlats alloc] init];
                                            NSMutableArray* rooms = [[NSMutableArray alloc]init];
                                            if(rooms.count == 0)
                                            {
                                                [rooms addObject:@"-1"];
                                            }
                                            event.keywords = keywords;
                                            event.rooms = rooms;
                                            
                                            if([maxPrice isEqualToString:@""])
                                            {
                                                maxPrice = @"-1";
                                            }
                                            event.price = [NSNumber numberWithInt:[maxPrice intValue]];
                                            event.type = @"store";
                                            [_store saveObject:event withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                                                if (errorOrNil != nil) {
                                                    //save failed
                                                    NSLog(@"Save failed, with error: %@", [errorOrNil localizedFailureReason]);
                                                } else {
                                                    //save was successful
                                                    NSString* ID = [objectsOrNil[0] kinveyObjectId];
                                                    NSMutableArray* searchFlats = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"storeSearch"]];
                                                    [searchFlats addObject:ID];
                                                    [[NSUserDefaults standardUserDefaults]setObject:searchFlats forKey:@"storeSearch"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    
                                                    
                                                    OpinionzAlertView *alert = [[OpinionzAlertView alloc] initWithTitle:@"Wohoo"
                                                                                                               message:@"الأن إستريح و دورلي سيقوم بالبحث بدلاً عنك ;)" cancelButtonTitle:@"(Y)"              otherButtonTitles:nil          usingBlockWhenTapButton:^(OpinionzAlertView *alertView, NSInteger buttonIndex) {
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
                                            } withProgressBlock:nil];
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
