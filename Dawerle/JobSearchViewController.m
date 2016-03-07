//
//  JobSearchViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 2/12/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "JobSearchViewController.h"
#import "SearchesViewController.h"
#import "JJMaterialTextfield.h"
#import <KinveyKit/KinveyKit.h>
#import "searchJobs.h"
#import <FlatUIKit.h>
#import "FeEqualize.h"
#import "ViewController.h"
#import <OpinionzAlertView/OpinionzAlertView.h>


@interface JobSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
@property(nonatomic,strong)KCSAppdataStore* store;
@property (strong, nonatomic) FeEqualize *equalizer;
@end

@implementation JobSearchViewController
{
    __weak IBOutlet JJMaterialTextfield *keyWordTextField;
    __weak IBOutlet UITableView *tableView;
    __weak IBOutlet FUIButton *roomesButton;
    __weak IBOutlet UIView *eqHolder;
    NSMutableArray* dataSource;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"showRecordedSearch"])
    {
        SearchesViewController* dst = (SearchesViewController*)[segue destinationViewController];
        [dst setDataID:@"jobs"];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:21]}];
    
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    self.title = @"الوظائف";
    
    UIImage *myImage = [UIImage imageNamed:@"sine-waves-analysis.png"];
    myImage = [myImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:myImage style:UIBarButtonItemStylePlain target:self action:@selector(mySearchClicked:)];
    self.navigationItem.rightBarButtonItem = menuButton;

    
    dataSource = [[NSMutableArray alloc] init];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [keyWordTextField setDelegate:self];
    
    keyWordTextField.textColor= [UIColor colorFromHexCode:@"34a853"];
    keyWordTextField.enableMaterialPlaceHolder = NO;
    keyWordTextField.errorColor=[UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]; // FLAT RED COLOR
    keyWordTextField.lineColor=[UIColor colorFromHexCode:@"1085C7"];
    keyWordTextField.tintColor=[UIColor colorFromHexCode:@"1085C7"];
    [keyWordTextField setTextAlignment:NSTextAlignmentRight];
    [keyWordTextField becomeFirstResponder];
    
    
    roomesButton.buttonColor = [UIColor colorFromHexCode:@"34a853"];
    roomesButton.shadowColor = [UIColor greenSeaColor];
    roomesButton.shadowHeight = 0.0f;
    roomesButton.cornerRadius = 0.0f;
    roomesButton.alpha = 0.0f;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _equalizer = [[FeEqualize alloc] initWithView:eqHolder title:@"جاري حفظ بحثك"];
    CGRect frame = CGRectMake(0, 0, 70, 70);
    [_equalizer setFrame:frame];
    [_equalizer setBackgroundColor:[UIColor clearColor]];
    [eqHolder setBackgroundColor:[UIColor clearColor]];
    [eqHolder addSubview:_equalizer];
    [eqHolder setAlpha:0.0];
    [_equalizer dismiss];
}


#pragma mark table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"الكلمات الدالة المضافة :";
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(UITableViewCell*)tableView:(UITableView *)tableVieww cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID = @"jobKeyCell";
    UITableViewCell* cell = [tableVieww dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [(UILabel*)[cell viewWithTag:1]setText:[dataSource objectAtIndex:indexPath.row]];
    
    [(UIButton*)[cell viewWithTag:2] addTarget:self
                                         action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
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

- (IBAction)submitClicked:(id)sender {
    [keyWordTextField resignFirstResponder];
    
    
    [UIView transitionWithView:eqHolder
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [eqHolder setAlpha:1.0];
                        [_equalizer show];
                    } completion:NULL];

    
    _store = [KCSAppdataStore storeWithOptions:@{ KCSStoreKeyCollectionName : @"searchJobs",
                                                  KCSStoreKeyCollectionTemplateClass : [searchJobs class]}];
    searchJobs* event = [[searchJobs alloc] init];
    event.keywords = dataSource;
    
    [_store saveObject:event withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        if (errorOrNil != nil) {
            //save failed
            NSLog(@"Save failed, with error: %@", [errorOrNil localizedFailureReason]);
        } else {
            //save was successful
            NSString* ID = [objectsOrNil[0] kinveyObjectId];
            NSMutableArray* searchFlats = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"jobSearch"]];
            [searchFlats addObject:ID];
            [[NSUserDefaults standardUserDefaults]setObject:searchFlats forKey:@"jobSearch"];
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
}
- (IBAction)addKeyWordClicked:(id)sender {
    if(keyWordTextField.text.length > 0)
    {
        [dataSource addObject:keyWordTextField.text];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:dataSource.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        if(roomesButton.alpha == 0)
        {
            [UIView transitionWithView:roomesButton
                              duration:0.2f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [roomesButton setAlpha:1.0f];
                            } completion:NULL];
        }
    }
}
- (IBAction)mySearchClicked:(id)sender {
    [self performSegueWithIdentifier:@"showRecordedSearch" sender:self];
}

#pragma mark textfield methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self addKeyWordClicked:nil];
    return YES;
}
- (void)deleteClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        [dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        if(dataSource.count == 0)
        {
            [UIView transitionWithView:roomesButton
                              duration:0.2f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [roomesButton setAlpha:0.0f];
                            } completion:NULL];
        }
    }
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


@end
