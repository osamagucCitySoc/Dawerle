//
//  CarsBrandsViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 1/28/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "CarsBrandsViewController.h"
#import "Popup.h"
#import <Parse/Parse.h>
#import "searchCars.h"
#import "SearchesViewController.h"
#import <FlatUIKit.h>
#import "FeEqualize.h"
#import "ViewController.h"
#import <OpinionzAlertView/OpinionzAlertView.h>

@interface CarsBrandsViewController ()<UITableViewDataSource,UITableViewDelegate,PopupDelegate,UISearchBarDelegate,UIAlertViewDelegate>
@property(nonatomic,strong)KCSAppdataStore* store;
@property (strong, nonatomic) FeEqualize *equalizer;
@end

@implementation CarsBrandsViewController
{
    __weak IBOutlet FUIButton *roomesButton;
    IBOutlet UIView *headerView;
    __weak IBOutlet UITableView *tableVieww;
    NSMutableArray* dataSource;
    NSMutableArray* origDataSource;
    NSString* price;
    NSString* year;
    __weak IBOutlet UISearchBar *searchBar;
    __weak IBOutlet UIView *eqHolder;
    NSMutableArray* indexLetters;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"showRecordedSearch"])
    {
        SearchesViewController* dst = (SearchesViewController*)[segue destinationViewController];
        [dst setDataID:@"cars"];
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
//    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:myImage style:UIBarButtonItemStylePlain target:self action:@selector(myCarSearchClicked:)];
//    self.navigationItem.rightBarButtonItem = menuButton;
    
    roomesButton.buttonColor = [UIColor colorFromHexCode:@"34a853"];
    roomesButton.shadowColor = [UIColor greenSeaColor];
    roomesButton.shadowHeight = 0.0f;
    roomesButton.cornerRadius = 0.0f;
    roomesButton.alpha = 0.0f;

    self.title = @"السيارات";
    
    
    dataSource = [[NSMutableArray alloc]init];
    origDataSource = [[NSMutableArray alloc]init];
    indexLetters = [[NSMutableArray alloc]init];
    
    [searchBar setDelegate:self];
    
    [tableVieww setAllowsMultipleSelection:YES];
    [tableVieww setDelegate:self];
    [tableVieww setDataSource:self];
    
    [tableVieww reloadData];
    [tableVieww setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated
{
    if(dataSource.count == 0)
    {
        NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"cars" ofType:@"json"];
        NSData *content1 = [[NSData alloc] initWithContentsOfFile:filePath1];
        dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:content1 options:kNilOptions error:nil]];
        
        NSMutableIndexSet* indices = [[NSMutableIndexSet alloc]init];
        
        for (int i = 0; i < dataSource.count; i++) {
            NSMutableDictionary* dict = [[NSMutableDictionary alloc]initWithDictionary:[dataSource objectAtIndex:i]];
            NSMutableArray* arr = [[NSMutableArray alloc]initWithArray:[dict objectForKey:@"cats"]];
            NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sub" ascending:YES];
            [arr sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];
            [dict setObject:arr forKey:@"cats"];
            [dataSource replaceObjectAtIndex:i withObject:dict];
            if(![indexLetters containsObject:[[dict objectForKey:@"brand"] substringToIndex:1]])
            {
                [indexLetters addObject:[[dict objectForKey:@"brand"] substringToIndex:1]];
            }
            [indices addIndex:i];
        }
        
        origDataSource = [NSMutableArray arrayWithArray:dataSource];
        [tableVieww insertSections:indices withRowAnimation:UITableViewRowAnimationTop];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataSource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[dataSource objectAtIndex:section] objectForKey:@"cats"] count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[dataSource objectAtIndex:section] objectForKey:@"brand"];
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableVieww.frame.size.width, 60)];
    [view setBackgroundColor:headerView.backgroundColor];
    
    UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 50, 60)];
    imageView.contentMode = UIViewContentModeCenter;
    if (imageView.bounds.size.width > ((UIImage*)[UIImage imageNamed:[[dataSource objectAtIndex:section] objectForKey:@"icon"]]).size.width && imageView.bounds.size.height > ((UIImage*)[UIImage imageNamed:[[dataSource objectAtIndex:section] objectForKey:@"icon"]]).size.height) {
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    [imageView setImage:[UIImage imageNamed:[[dataSource objectAtIndex:section] objectForKey:@"icon"]]];
    [view addSubview:imageView];
    
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(70, 0 , 300, 60)];
    [label setText:[[dataSource objectAtIndex:section] objectForKey:@"brand"]];
    [label setFont: [UIFont fontWithName:@"Courier-bold" size:19.0]];
    [view addSubview:label];
    
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID = @"brandsCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if (dataSource.count == (indexPath.row+1))
    {
        [(UILabel*)[cell viewWithTag:4]setHidden:YES];
    }
    
    NSString* label = [[[[dataSource objectAtIndex:indexPath.section] objectForKey:@"cats"]objectAtIndex:indexPath.row] objectForKey:@"sub"];
    
    
    [(UILabel*)[cell viewWithTag:1]setText:label];
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

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
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
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return indexLetters;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    for(int i = 0 ; i < dataSource.count ; i++)
    {
        NSDictionary* dict = [dataSource objectAtIndex:i];
        if([[dict objectForKey:@"brand"] hasPrefix:title])
        {
            return i;
        }
    }
    return 0;
}

- (IBAction)submitClicked:(id)sender {

    
    
    Popup *popup = [[Popup alloc] initWithTitle:@"خيارات إضافية" subTitle:@"من فضلك، قم بكتابة الحد الأقصى للسعر و الحد الأدنى لسنة الصنع أو أتركهم فارغين للحصول على كل النتائج." textFieldPlaceholders:@[@"السعر",@"السنة"] cancelTitle:@"إلغاء" successTitle:@"دورلي ;)" cancelBlock:^{} successBlock:^{
        
        
        [UIView transitionWithView:eqHolder
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [eqHolder setAlpha:1.0];
                            [_equalizer show];
                        } completion:NULL];
        
        NSMutableArray* brands = [[NSMutableArray alloc]init];
        NSMutableArray* subBrands = [[NSMutableArray alloc]init];
        
        
        for(NSIndexPath* index in [tableVieww indexPathsForSelectedRows])
        {
            [brands addObjectsFromArray:[[dataSource objectAtIndex:index.section] objectForKey:@"all"]];
            [subBrands addObjectsFromArray:[[[[dataSource objectAtIndex:index.section] objectForKey:@"cats"] objectAtIndex:index.row] objectForKey:@"all"]];
        }
        
        [brands setArray:[[NSSet setWithArray:brands] allObjects]];
        [subBrands setArray:[[NSSet setWithArray:subBrands] allObjects]];
        
        NSNumber* pr = [NSNumber numberWithInt:[price intValue]];
        NSNumber* yr = [NSNumber numberWithInt:[year intValue]];
        
        _store = [KCSAppdataStore storeWithOptions:@{ KCSStoreKeyCollectionName : @"searchCars",
                                                      KCSStoreKeyCollectionTemplateClass : [searchCars class]}];
        searchCars* event = [[searchCars alloc] init];
        event.brands = brands;
        event.sub = subBrands;
        event.price = pr;
        event.year = yr;
        
        [_store saveObject:event withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
            if (errorOrNil != nil) {
                //save failed
                NSLog(@"Save failed, with error: %@", [errorOrNil localizedFailureReason]);
            } else {
                //save was successful
                NSString* ID = [objectsOrNil[0] kinveyObjectId];
                NSMutableArray* searchFlats = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"carSearch"]];
                [searchFlats addObject:ID];
                [[NSUserDefaults standardUserDefaults]setObject:searchFlats forKey:@"carSearch"];
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
    [popup setKeyboardTypeForTextFields:@[@"NUMBER",@"NUMBER"]];
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

- (void)dictionary:(NSMutableDictionary *)dictionary forpopup:(Popup *)popup stringsFromTextFields:(NSArray *)stringArray {
    
    NSString *textFromBox1 = [stringArray objectAtIndex:0];
    price = textFromBox1;
    if([price isEqualToString:@""])
    {
        price = @"-1";
    }
    
    NSString *textFromBox2 = [stringArray objectAtIndex:1];
    year = textFromBox2;
    if([year isEqualToString:@""])
    {
        year = @"-1";
    }
}
- (IBAction)myCarSearchClicked:(id)sender {
    [self performSegueWithIdentifier:@"showRecordedSearch" sender:self];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length == 0)
    {
        dataSource = [NSMutableArray arrayWithArray:origDataSource];
    }else
    {
        NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];

        dataSource = [[NSMutableArray alloc]initWithArray:[origDataSource filteredArrayUsingPredicate:predicate]];
    }
    
    indexLetters = [[NSMutableArray alloc]init];
    for(NSDictionary* dict in dataSource)
    {
        if(![indexLetters containsObject:[[dict objectForKey:@"brand"] substringToIndex:1]])
        {
            [indexLetters addObject:[[dict objectForKey:@"brand"] substringToIndex:1]];
        }
    }
    
    [tableVieww reloadData];
    [tableVieww setNeedsDisplay];
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
