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
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:21]}];
    
    dataSource = [[NSMutableArray alloc]init];
    
    [tableVieww setDelegate:self];
    [tableVieww setDataSource:self];
    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRect frame = aboutUsButton.frame;
    frame.size.height = 32;
    frame.size.width = 32;
    [aboutUsButton setFrame:frame];
    
    
    
    if(dataSource.count == 0)
    {
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"flatSeg",@"شقق",@"flats.png",@"من السوق المفتوح، أوليكس، الوسيط، مورجان."] forKeys:@[@"seg",@"title",@"img",@"desc"]]];
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"villaSeg",@"فلل",@"villas.png",@"من السوق المفتوح، أوليكس، الوسيط، مورجان."] forKeys:@[@"seg",@"title",@"img",@"desc"]]];
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"storeSeg",@"مكاتب",@"stores.png",@"من السوق المفتوح، أوليكس، الوسيط، مورجان."] forKeys:@[@"seg",@"title",@"img",@"desc"]]];
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"carsSeg",@"سيارات",@"cars.png",@"من السوق المفتوح، أوليكس، الوسيط، كويت كار."] forKeys:@[@"seg",@"title",@"img",@"desc"]]];
        [dataSource addObject:[NSDictionary dictionaryWithObjects:@[@"jobsSeg",@"وظائف",@"jobs.png",@"من السوق المفتوح، أوليكس، الوسيط، لينكد إن، بيت.كوم."] forKeys:@[@"seg",@"title",@"img",@"desc"]]];
        NSMutableArray* indecies = [[NSMutableArray alloc]init];
        
        for(int i = 0 ; i < dataSource.count ; i++)
        {
            [indecies addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [tableVieww insertRowsAtIndexPaths:indecies withRowAnimation:UITableViewRowAnimationLeft];
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
    return @"تريد عن أن تبحث عن :";
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
    
    
    NSDictionary* dict = [dataSource objectAtIndex:indexPath.row];
    
    [(UIImageView*)[cell viewWithTag:2]setImage:[UIImage imageNamed:[dict objectForKey:@"img"]]];
    [(UILabel*)[cell viewWithTag:1]setText:[dict objectForKey:@"title"]];
    [(UILabel*)[cell viewWithTag:3]setText:[dict objectForKey:@"desc"]];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:[[dataSource objectAtIndex:indexPath.row] objectForKey:@"seg"] sender:self];
}

- (IBAction)optionsClicked:(id)sender {
   
}
- (IBAction)aboutAppClicked:(id)sender {
}

@end
