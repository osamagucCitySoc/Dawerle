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
#import "FlatSearchTableViewController.h"

@interface CarsBrandsViewController ()<UITableViewDataSource,UITableViewDelegate,PopupDelegate,UISearchBarDelegate>
@property(nonatomic,strong)KCSAppdataStore* store;
@end

@implementation CarsBrandsViewController
{
    IBOutlet UIView *headerView;
    __weak IBOutlet UITableView *tableVieww;
    NSMutableArray* dataSource;
    NSMutableArray* origDataSource;
    NSString* price;
    NSString* year;
    __weak IBOutlet UIButton *butt;
    __weak IBOutlet UISearchBar *searchBar;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"showRecordedSearch"])
    {
        FlatSearchTableViewController* dst = (FlatSearchTableViewController*)[segue destinationViewController];
        [dst setDataID:@"cars"];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"cars" ofType:@"json"];
    NSData *content1 = [[NSData alloc] initWithContentsOfFile:filePath1];
    dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:content1 options:kNilOptions error:nil]];
    
    
    
    for (int i = 0; i < dataSource.count; i++) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]initWithDictionary:[dataSource objectAtIndex:i]];
        NSMutableArray* arr = [[NSMutableArray alloc]initWithArray:[dict objectForKey:@"cats"]];
        NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sub" ascending:YES];
        [arr sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];
        [dict setObject:arr forKey:@"cats"];
        [dataSource replaceObjectAtIndex:i withObject:dict];
    }
    
    origDataSource = [NSMutableArray arrayWithArray:dataSource];
    
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
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableVieww.frame.size.width, 128)];
    [view setBackgroundColor:headerView.backgroundColor];
    
    UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 32, 64, 64)];
    [imageView setImage:[UIImage imageNamed:[[dataSource objectAtIndex:section] objectForKey:@"icon"]]];
    [view addSubview:imageView];
    
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(80, 54 , 344, 21)];
    [label setText:[[dataSource objectAtIndex:section] objectForKey:@"brand"]];
    [view addSubview:label];
    
    UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(tableVieww.frame.size.width-75, 90, 70, 25)];
    [button setTitle:@"Add all" forState:UIControlStateNormal];
    [button setTitleColor:[butt titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [view addSubview:button];
    
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 128.0f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID = @"brandCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSString* label = [[[[dataSource objectAtIndex:indexPath.section] objectForKey:@"cats"]objectAtIndex:indexPath.row] objectForKey:@"sub"];
    
    if([[tableView indexPathsForSelectedRows]containsObject:indexPath])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }

    
    [[cell textLabel]setText:label];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
}
- (IBAction)submitClicked:(id)sender {
    Popup *popup = [[Popup alloc] initWithTitle:@"Options" subTitle:@"Search Options" textFieldPlaceholders:@[@"Max Price",@"Min Year"] cancelTitle:@"Cancel" successTitle:@"Submit" cancelBlock:^{} successBlock:^{
        
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
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Wohoo" message:@"Relax and we will notify you.." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        } withProgressBlock:nil];
    }];
    [popup setKeyboardTypeForTextFields:@[@"NUMBER",@"NUMBER"]];
    [popup setBackgroundBlurType:PopupBackGroundBlurTypeDark];
    [popup setIncomingTransition:PopupIncomingTransitionTypeBounceFromCenter];
    [popup setOutgoingTransition:PopupOutgoingTransitionTypeBounceFromCenter];
    [popup setTapBackgroundToDismiss:YES];
    [popup setDelegate:self];
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
    
    [tableVieww reloadData];
    [tableVieww setNeedsDisplay];
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
