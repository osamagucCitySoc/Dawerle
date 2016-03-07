//
//  RoomsViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 1/25/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "RoomsViewController.h"
#import <KinveyKit/KinveyKit.h>
#import "searchFlats.h"
#import "Popup.h"
#import <FlatUIKit.h>
#import "FeEqualize.h"
#import "ViewController.h"
#import <OpinionzAlertView/OpinionzAlertView.h>

@interface RoomsViewController ()<UITableViewDelegate,UITableViewDataSource,PopupDelegate,UIAlertViewDelegate>
@property(nonatomic,strong)KCSAppdataStore* store;
@property (strong, nonatomic) FeEqualize *equalizer;
@end

@implementation RoomsViewController
{
    __weak IBOutlet UITableView *tableView;
    NSMutableArray* dataSource;
    NSString* maxPrice;
    __weak IBOutlet FUIButton *roomesButton;
    __weak IBOutlet UIView *eqHolder;
}

@synthesize selectedAreas,type;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:21]}];
    
    
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
    
}

-(void)viewDidAppear:(BOOL)animated
{
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
        [dataSource addObject:@"غير محدد"];
        [dataSource addObject:@"ستوديو"];
        for(int i = 1 ; i <= 10 ; i++)
        {
            [dataSource addObject:[NSString stringWithFormat:@"%i",i]];
        }
        NSMutableArray* indices = [[NSMutableArray alloc]init];
        
        for(int i = 0 ; i < dataSource.count ; i++)
        {
            [indices addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [tableView insertRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark button methods

- (IBAction)myFlatSearchClicked:(id)sender {
    [self performSegueWithIdentifier:@"myFlatSearchSeg" sender:self];
}

- (IBAction)submitClicked:(id)sender {
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
                                        for(int i = 0 ; i < [tableView indexPathsForSelectedRows].count ; i++)
                                        {
                                            [rooms addObject:[dataSource objectAtIndex:[[tableView.indexPathsForSelectedRows objectAtIndex:i] row]]];
                                        }
                                        if(rooms.count == 0)
                                        {
                                            [rooms addObject:@"-1"];
                                        }
                                        event.rooms = rooms;
                                        event.keywords = selectedAreas;
                                        
                                        if([maxPrice isEqualToString:@""])
                                        {
                                            maxPrice = @"-1";
                                        }
                                        event.price = [NSNumber numberWithInt:[maxPrice intValue]];
                                        if([type isEqualToString:@"flats"])
                                        {
                                            event.type = @"flat";
                                        }else
                                        {
                                            event.type = @"villas";
                                        }
                                        [_store saveObject:event withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                                            if (errorOrNil != nil) {
                                                //save failed
                                                NSLog(@"Save failed, with error: %@", [errorOrNil localizedFailureReason]);
                                            } else {
                                                //save was successful
                                                if([type isEqualToString:@"flats"])
                                                {
                                                    NSString* ID = [objectsOrNil[0] kinveyObjectId];
                                                    NSMutableArray* searchFlats = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"flatSearch"]];
                                                    [searchFlats addObject:ID];
                                                    [[NSUserDefaults standardUserDefaults]setObject:searchFlats forKey:@"flatSearch"];
                                                }else
                                                {
                                                    NSString* ID = [objectsOrNil[0] kinveyObjectId];
                                                    NSMutableArray* searchFlats = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"villaSearch"]];
                                                    [searchFlats addObject:ID];
                                                    [[NSUserDefaults standardUserDefaults]setObject:searchFlats forKey:@"villaSearch"];
                                                }
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
}

#pragma mark table methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"إختر الغرف :";
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
    
    [(UILabel*)[cell viewWithTag:1]setText:[dataSource objectAtIndex:indexPath.row]];
    [(UIImageView*)[cell viewWithTag:2]setImage:[UIImage imageNamed:@"circle.png"]];
    
    if([[tableView indexPathsForSelectedRows]containsObject:indexPath])
    {
        [UIView transitionWithView:(UIImageView*)[cell viewWithTag:2]
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [(UIImageView*)[cell viewWithTag:2]setImage:[UIImage imageNamed:@"circlef.png"]];
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
                        [(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]setImage:[UIImage imageNamed:@"circle.png"]];
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
                        [(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]setImage:[UIImage imageNamed:@"circlef.png"]];
                        if(roomesButton.alpha == 0.0f)
                        {
                            [roomesButton setAlpha:1.0f];
                        }
                    } completion:NULL];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor groupTableViewBackgroundColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor blackColor]];
    [header.textLabel setFont:[UIFont fontWithName:@"DroidArabicKufi" size:20.0]];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
