//
//  CarsSubBrandsViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 3/29/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "CarsSubBrandsViewController.h"
@import GoogleMobileAds;

@interface CarsSubBrandsViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@end

@implementation CarsSubBrandsViewController
{
    __weak IBOutlet UIView *bannerAdHolder;
    GADBannerView* bannerView;
    IBOutlet UIView *headerView;
    __weak IBOutlet UITableView *tableVieww;
    NSMutableArray* dataSource;
    NSMutableArray* origDataSource;
    NSString* price;
    NSString* year;
    __weak IBOutlet UISearchBar *searchBar;
    NSMutableArray* indexSet;
}

@synthesize selectedCarBrand,sectionIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:[selectedCarBrand objectForKey:@"brand"]];
    
    
    indexSet = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedCars"]];
    
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
    dataSource = [[NSMutableArray alloc]initWithObjects:selectedCarBrand, nil];
    origDataSource = [[NSMutableArray alloc]initWithObjects:selectedCarBrand, nil];

    NSMutableIndexSet* indices = [[NSMutableIndexSet alloc]init];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]initWithDictionary:[dataSource objectAtIndex:0]];
    NSMutableArray* arr = [[NSMutableArray alloc]initWithArray:[dict objectForKey:@"cats"]];
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sub" ascending:YES];
    [arr sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];
    [dict setObject:arr forKey:@"cats"];
    [dataSource replaceObjectAtIndex:0 withObject:dict];
    [indices addIndex:0];
    [tableVieww insertSections:indices withRowAnimation:UITableViewRowAnimationTop];
    
    CGRect frame1 = bannerView.frame;
    CGRect frame2 = bannerAdHolder.frame;
    frame1.origin.x = (frame2.size.width/2)-160;
    [bannerView setFrame:frame1];
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
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandler:)];
    //[singleTapRecognizer setDelegate:self];
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.numberOfTapsRequired = 1;
    view.tag = section;
    [view addGestureRecognizer:singleTapRecognizer];
    
    
    
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0f;
}

-(void) gestureHandler:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog (@"%ld",[gestureRecognizer.view tag]);
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
    
    NSIndexPath* realIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:sectionIndex];
    
    for(NSDictionary* path in indexSet)
    {
        if([[path objectForKey:@"section"] intValue] == realIndex.section && [[path objectForKey:@"row"] intValue] == realIndex.row)
        {
            [UIView transitionWithView:(UIImageView*)[cell viewWithTag:2]
                              duration:0.2f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [(UIImageView*)[cell viewWithTag:2]setImage:[UIImage imageNamed:@"mark-on.png"]];
                            } completion:NULL];
            break;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* realIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:sectionIndex];
    for(int i = 0 ; i < indexSet.count ; i++)
    {
        NSDictionary* path = [indexSet objectAtIndex:i];
        
        if([[path objectForKey:@"section"] intValue] == realIndex.section && [[path objectForKey:@"row"] intValue] == realIndex.row)
        {
            [indexSet removeObjectAtIndex:i];
            break;
        }
    }

    [UIView transitionWithView:(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]setImage:[UIImage imageNamed:@"mark-off.png"]];
                    } completion:NULL];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* realIndex = [[NSDictionary alloc]initWithObjects:@[@(sectionIndex),@(indexPath.row)] forKeys:@[@"section",@"row"]];
    [indexSet addObject:realIndex];
    
    [UIView transitionWithView:(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [(UIImageView*)[[tableVieww cellForRowAtIndexPath:indexPath] viewWithTag:2]setImage:[UIImage imageNamed:@"mark-on.png"]];
                    } completion:NULL];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:indexSet forKey:@"selectedCars"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
