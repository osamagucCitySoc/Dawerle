//
//  AreaSelectionViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 1/25/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "AreaViewController.h"
#import "RoomsViewController.h"
#import "FlatSearchTableViewController.h"
#import <Parse/Parse.h>
#import "Popup.h"

@interface AreaViewController ()<UITableViewDelegate,UITableViewDataSource,PopupDelegate>

@end

@implementation AreaViewController
{
    __weak IBOutlet UIButton *roomesButton;
    __weak IBOutlet UITableView *tableView;
    NSMutableArray* dataSource;
    NSString* maxPrice;
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
        [dst setSelectedAreas:keywords];
    }else if([[segue identifier]isEqualToString:@"showRecordedSearch"])
    {
        FlatSearchTableViewController* dst = (FlatSearchTableViewController*)[segue destinationViewController];
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
    
    if([type isEqualToString:@"villas"] || [type isEqualToString:@"stores"])
    {
        [roomesButton setTitle:@"Done" forState:UIControlStateNormal];
    }
    
    dataSource = [[NSMutableArray alloc]init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"combinedAreas" ofType:@"json"];
    NSData *content = [[NSData alloc] initWithContentsOfFile:filePath];
    dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:nil]];
    
    [tableView setAllowsMultipleSelection:YES];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)submitClicked:(id)sender {
    if([type isEqualToString:@"villas"] || [type isEqualToString:@"stores"])
    {
        NSMutableArray* keywords = [[NSMutableArray alloc]init];
        for(int i = 0 ; i < [tableView indexPathsForSelectedRows].count ; i++)
        {
            [keywords addObject:[dataSource objectAtIndex:[[tableView.indexPathsForSelectedRows objectAtIndex:i] row]]];
        }

        Popup *popup = [[Popup alloc] initWithTitle:@"Price"
                                           subTitle:@"Enter your maximum price or leave it blank ;)"
                              textFieldPlaceholders:@[@"Maximum price in KWD"]
                                        cancelTitle:@"Cancel"
                                       successTitle:@"Success"
                                        cancelBlock:^{} successBlock:^{
                                            PFObject *order = [PFObject objectWithClassName:@"searchFlats"];
                                            PFInstallation *installation = [PFInstallation currentInstallation];
                                            NSMutableArray* rooms = [[NSMutableArray alloc]init];
                                            if(rooms.count == 0)
                                            {
                                                [rooms addObject:@"-1"];
                                            }
                                            [order addUniqueObjectsFromArray:keywords forKey:@"keywords"];
                                            [order addUniqueObjectsFromArray:rooms forKey:@"rooms"];
                                            if([maxPrice isEqualToString:@""])
                                            {
                                                maxPrice = @"-1";
                                            }
                                            [order setObject:[NSNumber numberWithInt:[maxPrice intValue]] forKey:@"price"];
                                            if([type isEqualToString:@"villas"])
                                            {
                                                [order setObject:@"villa" forKey:@"type"];
                                            }else
                                            {
                                                [order setObject:@"store" forKey:@"type"];
                                            }
                                            [order saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                if (succeeded) {
                                                    NSMutableArray* channels = [[NSMutableArray alloc] initWithArray:[installation channels] copyItems:YES];
                                                    [channels addObject:[NSString stringWithFormat:@"c%@",[order objectId]]];
                                                    if([type isEqualToString:@"villas"])
                                                    {
                                                        NSMutableArray* searchFlats = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"villaSearch"]];
                                                        [searchFlats addObject:[order objectId]];
                                                        [[NSUserDefaults standardUserDefaults]setObject:searchFlats forKey:@"villaSearch"];
                                                    }else
                                                    {
                                                        NSMutableArray* searchFlats = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"storeSearch"]];
                                                        [searchFlats addObject:[order objectId]];
                                                        [[NSUserDefaults standardUserDefaults]setObject:searchFlats forKey:@"storeSearch"];
                                                    }
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    [installation setChannels:channels];
                                                    [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                        if(succeeded)
                                                        {
                                                            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Wohoo" message:@"Relax and we will notify you.." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                            [alert show];
                                                        }
                                                    }];
                                                }
                                            }];
                                        }];
        [popup setKeyboardTypeForTextFields:@[@"NUMBER"]];
        [popup setBackgroundBlurType:PopupBackGroundBlurTypeDark];
        [popup setIncomingTransition:PopupIncomingTransitionTypeBounceFromCenter];
        [popup setOutgoingTransition:PopupOutgoingTransitionTypeBounceFromCenter];
        [popup setTapBackgroundToDismiss:YES];
        [popup setDelegate:self];
        [popup showPopup];
        
    }else
    {
        [self performSegueWithIdentifier:@"roomSeg" sender:self];
    }
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
    
    [[cell textLabel]setText:[dataSource objectAtIndex:indexPath.row]];
    
    if([[tableView indexPathsForSelectedRows]containsObject:indexPath])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableVieww didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
}
-(void)tableView:(UITableView *)tableVieww didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
}

- (IBAction)myFlatSearchClicked:(id)sender {
    [self performSegueWithIdentifier:@"showRecordedSearch" sender:self];
}

- (void)dictionary:(NSMutableDictionary *)dictionary forpopup:(Popup *)popup stringsFromTextFields:(NSArray *)stringArray {
    
    NSString *textFromBox1 = [stringArray objectAtIndex:0];
    maxPrice = textFromBox1;
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
