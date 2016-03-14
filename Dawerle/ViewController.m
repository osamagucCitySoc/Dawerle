//
//  ViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 1/25/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "ViewController.h"
#import "ShowSearchViewController.h"
#import "AreaViewController.h"
#import "SearchesViewController.h"

@interface ViewController ()<UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation ViewController
{
    __weak IBOutlet UITableView *tableVieww;
    NSMutableArray* dataSource;
    __weak IBOutlet UIButton *aboutUsButton;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"flatSeg"] || [[segue identifier] isEqualToString:@"villaSeg"] || [[segue identifier] isEqualToString:@"storeSeg"])
    {
        AreaViewController* dst = (AreaViewController*)[segue destinationViewController];
        if([[segue identifier]isEqualToString:@"flatSeg"])
        {
            [dst setType:@"flats"];
        }else if([[segue identifier]isEqualToString:@"storeSeg"])
        {
            [dst setType:@"stores"];
        }else
        {
            [dst setType:@"villas"];
        }
    }else if([[segue identifier]isEqualToString:@"showRecordedSearch"])
    {
        SearchesViewController* dst = (SearchesViewController*)[segue destinationViewController];
        [dst setDataID:[[dataSource objectAtIndex:savedInd] objectForKey:@"dataID"]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi" size:14]
       }
     forState:UIControlStateNormal];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:19]}];
    
    dataSource = [[NSMutableArray alloc]init];
    
    [tableVieww setDelegate:self];
    [tableVieww setDataSource:self];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"helpDone"])
    {
        [NSTimer scheduledTimerWithTimeInterval: 1.0
                                         target: self
                                       selector:@selector(showHelp:)
                                       userInfo: nil repeats:NO];
    }
}

-(void)showHelp:(NSTimer *)timer {
#warning Osama the app will crash here and i don't know why !! only if you call this from didLoad or didAppear:
    NSLog(@"SHOW HELP!!");
    [self performSegueWithIdentifier:@"theHelpSeg" sender:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [tableVieww deselectRowAtIndexPath:tableVieww.indexPathForSelectedRow animated:animated];
}

- (IBAction)openSettings:(id)sender {
    [self performSegueWithIdentifier:@"settingsSeg" sender:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(dataSource.count == 0)
    {
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"flatSeg",@"flats",@"flatSearch",@"شقق",@"flats.png",@"من السوق المفتوح، أوليكس، الوسيط، مورجان."] forKeys:@[@"seg",@"dataID",@"localID",@"title",@"img",@"desc"]]];
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"villaSeg",@"villas",@"villaSearch",@"فلل",@"villas.png",@"من السوق المفتوح، أوليكس، الوسيط، مورجان."] forKeys:@[@"seg",@"dataID",@"localID",@"title",@"img",@"desc"]]];
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"storeSeg",@"stores",@"storeSearch",@"مكاتب",@"stores.png",@"من السوق المفتوح، أوليكس، الوسيط، مورجان."] forKeys:@[@"seg",@"dataID",@"localID",@"title",@"img",@"desc"]]];
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"carsSeg",@"cars",@"carSearch",@"سيارات",@"cars.png",@"من السوق المفتوح، أوليكس، الوسيط، كويت كار."] forKeys:@[@"seg",@"dataID",@"localID",@"title",@"img",@"desc"]]];
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"jobsSeg",@"jobs",@"jobSearch",@"وظائف",@"jobs.png",@"من السوق المفتوح، أوليكس، الوسيط، لينكد إن، بيت.كوم."] forKeys:@[@"seg",@"dataID",@"localID",@"title",@"img",@"desc"]]];
        NSMutableArray* indecies = [[NSMutableArray alloc]init];
        
        for(int i = 0 ; i < dataSource.count ; i++)
        {
            [indecies addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [tableVieww insertRowsAtIndexPaths:indecies withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark table view delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"تريد عن أن تبحث عن:";
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"catCell" forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"catCell"];
    }
    
    if (dataSource.count == (indexPath.row+1))
    {
        [(UILabel*)[cell viewWithTag:4]setHidden:YES];
    }
    
    NSDictionary* dict = [dataSource objectAtIndex:indexPath.row];
    
    [(UIImageView*)[cell viewWithTag:2]setImage:[UIImage imageNamed:[dict objectForKey:@"img"]]];
    [(UILabel*)[cell viewWithTag:1]setText:[dict objectForKey:@"title"]];
    //[(UILabel*)[cell viewWithTag:3]setText:[dict objectForKey:@"desc"]];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    savedInd = indexPath.row;
    
    BOOL isSearches = NO;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:[[dataSource objectAtIndex:indexPath.row] objectForKey:@"localID"]] && [[[NSUserDefaults standardUserDefaults] objectForKey:[[dataSource objectAtIndex:indexPath.row] objectForKey:@"localID"]] count]>0)
    {
        isSearches = YES;
    }
    
    
    if (isSearches)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"بحث جديد",@"تصفح عمليات البحث المحفوظة",nil];
        [actionSheet setTag:11];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    else
    {
        [self performSegueWithIdentifier:[[dataSource objectAtIndex:indexPath.row] objectForKey:@"seg"] sender:self];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex  {
    [tableVieww deselectRowAtIndexPath:tableVieww.indexPathForSelectedRow animated:YES];
    
    switch (buttonIndex) {
        case 0:
        {
            if (actionSheet.tag == 11)
            {
                [self performSegueWithIdentifier:[[dataSource objectAtIndex:savedInd] objectForKey:@"seg"] sender:self];
            }
        }
            break;
            case 1:
        {
            if (actionSheet.tag == 11)
            {
                [self performSegueWithIdentifier:@"showRecordedSearch" sender:self];
            }
        }
    }
}

- (IBAction)optionsClicked:(id)sender {
   
}
- (IBAction)aboutAppClicked:(id)sender {
}

@end
