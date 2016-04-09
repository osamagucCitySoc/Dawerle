//
//  CarsSubBrandsViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 3/29/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "CarsSubBrandsViewController.h"
@import GoogleMobileAds;
#import <Google/Analytics.h>
#import "FUIButton.h"
#import <FlatUIKit.h>

@interface CarsSubBrandsViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@end

@implementation CarsSubBrandsViewController
{
    IBOutlet UIView *headerView;
    __weak IBOutlet UITableView *tableVieww;
    NSMutableArray* dataSource;
    NSMutableArray* origDataSource;
    NSString* price;
    NSString* year;
    __weak IBOutlet UISearchBar *searchBar;
    NSMutableArray* indexSet;
    NSMutableArray* brandsSet;
    id<GAITracker> tracker;
    __weak IBOutlet FUIButton *submitButton;
    int selected;
}

@synthesize selectedCarBrand,sectionIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:[selectedCarBrand objectForKey:@"brand"]];
    
    
    indexSet = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedCars"]];
    brandsSet = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedCarsString"]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:19]}];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];

    
    dataSource = [[NSMutableArray alloc]init];
    origDataSource = [[NSMutableArray alloc]init];
    
    [searchBar setDelegate:self];
    
    [tableVieww setAllowsMultipleSelection:YES];
    [tableVieww setDelegate:self];
    [tableVieww setDataSource:self];
    
    [tableVieww reloadData];
    [tableVieww setNeedsDisplay];
    
    tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"SubBrandsViewController"];
    
    
    submitButton.buttonColor = [UIColor colorFromHexCode:@"34a853"];
    submitButton.shadowColor = [UIColor greenSeaColor];
    submitButton.shadowHeight = 0.0f;
    submitButton.cornerRadius = 0.0f;
    submitButton.alpha = 0.0f;

    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"submitCar"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    selected = 0;
}

-(void)dismissKeyboard {
    [searchBar resignFirstResponder];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    dataSource = [[NSMutableArray alloc]initWithObjects:selectedCarBrand, nil];
    origDataSource = [[NSMutableArray alloc]initWithObjects:selectedCarBrand, nil];

    NSMutableIndexSet* indices = [[NSMutableIndexSet alloc]init];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]initWithDictionary:[dataSource objectAtIndex:0]];
    NSMutableArray* arr = [[NSMutableArray alloc]initWithArray:[dict objectForKey:@"cats"]];
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sub" ascending:YES];
    [arr sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];
    [dict setObject:arr forKey:@"cats"];
    [dataSource replaceObjectAtIndex:0 withObject:dict];
    origDataSource = [[NSMutableArray alloc]initWithArray:dataSource];
    [indices addIndex:0];
    [tableVieww insertSections:indices withRowAnimation:UITableViewRowAnimationTop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if([brandsSet containsObject:label])
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
    NSString* label = [[[[dataSource objectAtIndex:indexPath.section] objectForKey:@"cats"]objectAtIndex:indexPath.row] objectForKey:@"sub"];
    
    for(int i = 0 ; i < [[[origDataSource objectAtIndex:indexPath.section] objectForKey:@"cats"] count] ; i++)
    {
        NSDictionary* dict = [[[origDataSource objectAtIndex:indexPath.section] objectForKey:@"cats"] objectAtIndex:i];
        if([[dict objectForKey:@"sub"]isEqualToString:label])
        {
            NSIndexPath* realIndex = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
            for(int i = 0 ; i < indexSet.count ; i++)
            {
                NSDictionary* path = [indexSet objectAtIndex:i];
                
                if([[path objectForKey:@"section"] intValue] == realIndex.section && [[path objectForKey:@"row"] intValue] == realIndex.row)
                {
                    [indexSet removeObjectAtIndex:i];
                    break;
                }
            }
            break;
        }
    }

    
    for(int i = 0 ; i < brandsSet.count ; i++)
    {
        if([[brandsSet objectAtIndex:i]isEqualToString:label])
        {
            [brandsSet removeObjectAtIndex:i];
            break;
        }
    }
    
    [UIView transitionWithView:(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]setImage:[UIImage imageNamed:@"mark-off.png"]];
                    } completion:NULL];
    
    
    selected--;
    if(selected <= 0 && submitButton.alpha == 1)
    {
        [UIView transitionWithView:submitButton
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [submitButton setAlpha:0.0f];
                        } completion:NULL];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    selected++;
    
    NSString* label = [[[[dataSource objectAtIndex:indexPath.section] objectForKey:@"cats"]objectAtIndex:indexPath.row] objectForKey:@"sub"];

    for(int i = 0 ; i < [[[origDataSource objectAtIndex:indexPath.section] objectForKey:@"cats"] count] ; i++)
    {
        NSDictionary* dict = [[[origDataSource objectAtIndex:indexPath.section] objectForKey:@"cats"] objectAtIndex:i];
        if([[dict objectForKey:@"sub"]isEqualToString:label])
        {
            NSDictionary* realIndex = [[NSDictionary alloc]initWithObjects:@[@(sectionIndex),@(i)] forKeys:@[@"section",@"row"]];
            [indexSet addObject:realIndex];
            break;
        }
    }
    
    [brandsSet addObject:label];
    
    [UIView transitionWithView:(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]setImage:[UIImage imageNamed:@"mark-on.png"]];
                    } completion:NULL];
    
    if(selected > 0 && submitButton.alpha == 0)
    {
        [UIView transitionWithView:submitButton
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [submitButton setAlpha:1.0f];
                        } completion:NULL];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:indexSet forKey:@"selectedCars"];
    [[NSUserDefaults standardUserDefaults] setObject:brandsSet forKey:@"selectedCarsString"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


#pragma mark search delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length == 0)
    {
        dataSource = [[NSMutableArray alloc]initWithArray:origDataSource];
    }else
    {
        dataSource = [[NSMutableArray alloc]initWithArray:origDataSource];
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]initWithDictionary:[dataSource objectAtIndex:0]];
        NSMutableArray* arr = [[NSMutableArray alloc]initWithArray:[dict objectForKey:@"cats"]];
        NSMutableArray* arr2 = [[NSMutableArray alloc]init];
        for(NSDictionary* dict in arr)
        {
            if([[[dict objectForKey:@"sub"] lowercaseString]containsString:[searchText lowercaseString]])
            {
                [arr2 addObject:dict];
            }else
            {
                for(NSString* string in [dict objectForKey:@"all"])
                {
                    if([[string lowercaseString] containsString:[searchText lowercaseString]])
                    {
                        [arr2 addObject:dict];
                        break;
                    }
                }
            }
        }
        [dict setObject:arr2 forKey:@"cats"];
        [dataSource replaceObjectAtIndex:0 withObject:dict];
    }
    
    [tableVieww reloadData];
    [tableVieww setNeedsDisplay];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBarr
{
    [searchBarr resignFirstResponder];
}

- (IBAction)submitClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"submitCar"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
