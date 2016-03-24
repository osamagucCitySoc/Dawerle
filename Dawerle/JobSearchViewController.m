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
#import <FlatUIKit.h>
#import "FeEqualize.h"
#import "ViewController.h"
#import <OpinionzAlertView/OpinionzAlertView.h>
#import <AFNetworking/AFNetworking.h>

@interface JobSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
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
    
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:singleTap];
    [tableView addGestureRecognizer:singleTap];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:19]}];
    
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    self.title = @"الوظائف";
    
//    UIImage *myImage = [UIImage imageNamed:@"search-icon.png"];
//    myImage = [myImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:myImage style:UIBarButtonItemStylePlain target:self action:@selector(mySearchClicked:)];
//    self.navigationItem.rightBarButtonItem = menuButton;

    
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


- (void)resignOnTap:(id)sender {
    [keyWordTextField resignFirstResponder];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize size = [[userInfo objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect frame = CGRectMake(tableView.frame.origin.x,
                              tableView.frame.origin.y,
                              tableView.frame.size.width,
                              tableView.frame.size.height - size.height);
    tableView.frame = frame;
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize size = [[userInfo objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    tableView.frame = CGRectMake(tableView.frame.origin.x,
                                      tableView.frame.origin.y,
                                      tableView.frame.size.width,
                                      tableView.frame.size.height + size.height);
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
    
    if (dataSource.count == (indexPath.row+1))
    {
        [(UILabel*)[cell viewWithTag:4]setHidden:YES];
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
    [header.textLabel setTextColor:[UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0]];
    [header.textLabel setFont:[UIFont fontWithName:@"DroidArabicKufi" size:14.0]];
    [header.textLabel setTextAlignment:NSTextAlignmentRight];
}

- (IBAction)submitClicked:(id)sender {
    [keyWordTextField resignFirstResponder];
    UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"خيارات الدولة" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"الكويت",@"السعودية",nil];
    [sheet setTag:111];
    [sheet showInView:self.view];

}
- (IBAction)addKeyWordClicked:(id)sender {
    if(keyWordTextField.text.length > 0)
    {
        [dataSource addObject:keyWordTextField.text];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:dataSource.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        
        [NSTimer scheduledTimerWithTimeInterval: 0.5
                                         target: self
                                       selector:@selector(scrollTheTable:)
                                       userInfo: nil repeats:NO];
        
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

-(void)scrollTheTable:(NSTimer *)timer {
    [tableView scrollRectToVisible:CGRectMake(0.0,
                                              tableView.contentSize.height - 1.0,
                                              1.0,
                                              1.0)
                          animated:YES];
}

#pragma mark textfield methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //[self addKeyWordClicked:nil];
    [textField resignFirstResponder];
    return YES;
}
- (void)deleteClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        [dataSource removeObjectAtIndex:indexPath.row];
        
        if (indexPath.row == 0)
        {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        else
        {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
        
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




#pragma mark UIActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 111 && buttonIndex != actionSheet.cancelButtonIndex)
    {
        NSString* countryType = @"";
        if(buttonIndex == 0)
        {
            countryType = @"KW";
        }else
        {
            countryType = @"SA";
        }
        [UIView transitionWithView:eqHolder
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [eqHolder setAlpha:1.0];
                            [_equalizer show];
                        } completion:NULL];
        
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
        [dict setObject:dataSource forKey:@"keywords"];
        [dict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"] forKey:@"token"];
        [dict setObject:countryType forKey:@"country"];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager POST:@"http://almasdarapp.com/Dawerle/storeSearchJob.php" parameters:dict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
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
                NSMutableArray* searchFlats = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"jobSearch"]];
                [searchFlats addObject:ID];
                [[NSUserDefaults standardUserDefaults]setObject:searchFlats forKey:@"jobSearch"];
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
    }
}

@end
