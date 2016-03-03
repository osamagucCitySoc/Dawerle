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

@interface RoomsViewController ()<UITableViewDelegate,UITableViewDataSource,PopupDelegate>
@property(nonatomic,strong)KCSAppdataStore* store;
@end

@implementation RoomsViewController
{
    __weak IBOutlet UITableView *tableView;
    NSMutableArray* dataSource;
    NSString* maxPrice;
}

@synthesize selectedAreas;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    maxPrice = @"";
    
    dataSource = [[NSMutableArray alloc]init];
    
    [dataSource addObject:@"غير محدد"];
    [dataSource addObject:@"ستوديو"];
    for(int i = 1 ; i <= 10 ; i++)
    {
        [dataSource addObject:[NSString stringWithFormat:@"%i",i]];
    }
    
    [tableView setAllowsMultipleSelection:YES];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
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
    Popup *popup = [[Popup alloc] initWithTitle:@"Price"
                                       subTitle:@"Enter your maximum price or leave it blank ;)"
                          textFieldPlaceholders:@[@"Maximum price in KWD"]
                                    cancelTitle:@"Cancel"
                                   successTitle:@"Success"
                                    cancelBlock:^{} successBlock:^{
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
                                        event.type = @"flat";
                                        [_store saveObject:event withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                                            if (errorOrNil != nil) {
                                                //save failed
                                                NSLog(@"Save failed, with error: %@", [errorOrNil localizedFailureReason]);
                                            } else {
                                                //save was successful
                                                NSString* ID = [objectsOrNil[0] kinveyObjectId];
                                                NSMutableArray* searchFlats = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"flatSearch"]];
                                                [searchFlats addObject:ID];
                                                [[NSUserDefaults standardUserDefaults]setObject:searchFlats forKey:@"flatSearch"];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Wohoo" message:@"Relax and we will notify you.." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                [alert show];
                                            }
                                        } withProgressBlock:nil];
                                    }];
    [popup setKeyboardTypeForTextFields:@[@"NUMBER"]];
    [popup setBackgroundBlurType:PopupBackGroundBlurTypeDark];
    [popup setIncomingTransition:PopupIncomingTransitionTypeBounceFromCenter];
    [popup setOutgoingTransition:PopupOutgoingTransitionTypeBounceFromCenter];
    [popup setTapBackgroundToDismiss:YES];
    [popup setDelegate:self];
    [popup showPopup];
}

#pragma mark table methods

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
