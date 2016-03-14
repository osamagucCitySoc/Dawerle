//
//  SearchesViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 3/6/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "SearchesViewController.h"
#import <KinveyKit/KinveyKit.h>
#import "searchFlats.h"
#import "searchCars.h"
#import "searchJobs.h"
#import "ExploreTableViewController.h"
#import <FlatUIKit.h>
#import "FeEqualize.h"
#import <OpinionzAlertView/OpinionzAlertView.h>

@interface SearchesViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)KCSAppdataStore* store;
@property (strong, nonatomic) FeEqualize *equalizer;
@end

@implementation SearchesViewController
{
    NSMutableArray* dataSource;
    NSString* localID;
    NSString* parseID;
    __weak IBOutlet UIView *eqHolder;
    __weak IBOutlet UITableView *tableView;
    NSIndexPath* selected;
}

@synthesize dataID;


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"exploreSeg"])
    {
        ExploreTableViewController* dst = (ExploreTableViewController*)[segue destinationViewController];
        [dst setClassName:dataID];
        [dst setSearchingParams:[dataSource objectAtIndex:selected.section]];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(dataSource.count == 0)
    {
        [_equalizer removeFromSuperview];
        _equalizer = [[FeEqualize alloc] initWithView:eqHolder title:@"جاري التحميل.."];
        CGRect frame = CGRectMake(0, 0, 70, 70);
        [_equalizer setFrame:frame];

        [_equalizer setBackgroundColor:[UIColor clearColor]];
        [eqHolder setBackgroundColor:[UIColor clearColor]];
        [eqHolder addSubview:_equalizer];
        [eqHolder setAlpha:0.0];
        [_equalizer dismiss];
        
        [UIView transitionWithView:eqHolder
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [eqHolder setAlpha:1.0];
                            [_resView setHidden:YES];
                            [_equalizer show];
                        } completion:nil];
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:localID] || [[[NSUserDefaults standardUserDefaults] objectForKey:localID] count] == 0)
        {
            OpinionzAlertView *alert = [[OpinionzAlertView alloc] initWithTitle:@"عفواً"
                                                                        message:@"لا يوجد أي عمليات بحث مسجلة من قبل."
                                                              cancelButtonTitle:@"OK"              otherButtonTitles:nil          usingBlockWhenTapButton:^(OpinionzAlertView *alertView, NSInteger buttonIndex) {
                                                                  [self.navigationController popViewControllerAnimated:YES];
                                                                        }];
            alert.iconType = OpinionzAlertIconInfo;
            alert.color = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1];
            [alert show];
        }
        
        [_store loadObjectWithID:[[NSUserDefaults standardUserDefaults] objectForKey:localID] withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
            if (errorOrNil == nil) {
                if(objectsOrNil)
                {
                    dataSource = [[NSMutableArray alloc] initWithArray:objectsOrNil];
                }else
                {
                    dataSource = [[NSMutableArray alloc]init];
                }
                dispatch_async( dispatch_get_main_queue(), ^{
                    NSMutableIndexSet* indices = [[NSMutableIndexSet alloc]init];
                    
                    for(int i = 0 ; i < dataSource.count ; i++)
                    {
                        [indices addIndex:i];
                    }
                    
                    [tableView insertSections:indices withRowAnimation:UITableViewRowAnimationTop];
                });
            } else {
                NSLog(@"error occurred: %@", errorOrNil);
            }
            
            [UIView transitionWithView:eqHolder
                              duration:0.2f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [eqHolder setAlpha:0.0];
                                [_resView setHidden:NO];
                                [_equalizer dismiss];
                            } completion:nil];
        } withProgressBlock:nil];
    }
    
    
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if([dataID isEqualToString:@"flats"])
    {
        localID = @"flatSearch";
        parseID = @"searchFlats";
        _store = [KCSAppdataStore storeWithOptions:@{ KCSStoreKeyCollectionName : parseID,
                                                      KCSStoreKeyCollectionTemplateClass : [searchFlats class]}];
    }else if([dataID isEqualToString:@"villas"])
    {
        localID = @"villaSearch";
        parseID = @"searchFlats";
        _store = [KCSAppdataStore storeWithOptions:@{ KCSStoreKeyCollectionName : parseID,
                                                      KCSStoreKeyCollectionTemplateClass : [searchFlats class]}];
    }else if([dataID isEqualToString:@"stores"])
    {
        localID = @"storeSearch";
        parseID = @"searchFlats";
        _store = [KCSAppdataStore storeWithOptions:@{ KCSStoreKeyCollectionName : parseID,
                                                      KCSStoreKeyCollectionTemplateClass : [searchFlats class]}];
    }else if([dataID isEqualToString:@"cars"])
    {
        localID = @"carSearch";
        parseID = @"searchCars";
        _store = [KCSAppdataStore storeWithOptions:@{ KCSStoreKeyCollectionName : parseID,
                                                      KCSStoreKeyCollectionTemplateClass : [searchCars class]}];
    }else if([dataID isEqualToString:@"jobs"])
    {
        localID = @"jobSearch";
        parseID = @"searchJobs";
        _store = [KCSAppdataStore storeWithOptions:@{ KCSStoreKeyCollectionName : parseID,
                                                      KCSStoreKeyCollectionTemplateClass : [searchJobs class]}];
    }
    
    
    
    dataSource = [[NSMutableArray alloc]init];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:19]}];
    
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    
    if([dataID isEqualToString:@"villas"])
    {
        self.title = @"فلل و قصور";
    }else if([dataID isEqualToString:@"flats"])
    {
        self.title = @"شقق";
    }else if([dataID isEqualToString:@"stores"])
    {
        self.title = @"مكاتب";
    }else if([dataID isEqualToString:@"cars"])
    {
        self.title = @"سيارات";
    }else if([dataID isEqualToString:@"jobs"])
    {
        self.title = @"وظائف";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([dataID isEqualToString:@"villas"] || [dataID isEqualToString:@"flats"])
    {
        return 4;
    }else if([dataID isEqualToString:@"stores"])
    {
        return 3;
    }else if([dataID isEqualToString:@"cars"])
    {
        return 5;
    }else if([dataID isEqualToString:@"jobs"])
    {
        return 2;
    }
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableVieww cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellID = @"searchCell";
    
    UITableViewCell *cell = [tableVieww dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
//    if (dataSource.count == (indexPath.row+1))
//    {
//        [(UILabel*)[cell viewWithTag:4]setHidden:YES];
//    }
    
    ((FUIButton*)[cell viewWithTag:2]).alpha = 0.0f;
    ((FUIButton*)[cell viewWithTag:4]).alpha = 0.0f;
    ((UIView*)[cell viewWithTag:3]).alpha = 0.0f;
    
    if([dataID isEqualToString:@"villas"] || [dataID isEqualToString:@"flats"])
    {
        searchFlats* object = [dataSource objectAtIndex:indexPath.section];
        NSString* keywords = [object.keywords componentsJoinedByString:@" ، "];
        int maxPrice  = [object.price intValue];
        NSString* rooms = [object.rooms componentsJoinedByString:@" ، "];
        
        
        NSString* string = @"";
        if(indexPath.row == 0)
        {
            string = [NSString stringWithFormat:@"المناطق: %@",keywords];
        }else if(indexPath.row == 1)
        {
            string = [NSString stringWithFormat:@"الغرف: %@",rooms];
        }else if(indexPath.row == 2)
        {
            if(maxPrice == -1)
            {
                string = [NSString stringWithFormat:@"السعر : %@",@"غير محدد"];
            }else
            {
                string = [NSString stringWithFormat:@"السعر : %i KD",maxPrice];
            }
        }else
        {
            ((FUIButton*)[cell viewWithTag:2]).buttonColor = [UIColor colorFromHexCode:@"39C73C"];
            ((FUIButton*)[cell viewWithTag:2]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:2]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).cornerRadius = 0.0f;
            
            ((FUIButton*)[cell viewWithTag:4]).buttonColor = [UIColor colorFromHexCode:@"FF2C26"];
            ((FUIButton*)[cell viewWithTag:4]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:4]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:4]).cornerRadius = 0.0f;
            
            ((FUIButton*)[cell viewWithTag:2]).alpha = 1.0f;
            ((UIView*)[cell viewWithTag:3]).alpha = 1.0f;
            ((FUIButton*)[cell viewWithTag:4]).alpha = 1.0f;
            
            [(FUIButton*)[cell viewWithTag:2] addTarget:self
                                                 action:@selector(exploreClicked:) forControlEvents:UIControlEventTouchUpInside];
            [(FUIButton*)[cell viewWithTag:4] addTarget:self
                                                 action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [(UILabel*)[cell viewWithTag:1] setText:string];
    }else if([dataID isEqualToString:@"stores"])
    {
        searchFlats* object = [dataSource objectAtIndex:indexPath.section];
        NSString* keywords = [object.keywords componentsJoinedByString:@" ، "];
        int maxPrice  = [object.price intValue];
        
        NSString* string = @"";
        if(indexPath.row == 0)
        {
            string = [NSString stringWithFormat:@"المناطق: %@",keywords];
        }else if(indexPath.row == 1)
        {
            if(maxPrice == -1)
            {
                string = [NSString stringWithFormat:@"السعر : %@",@"غير محدد"];
            }else
            {
                string = [NSString stringWithFormat:@"السعر : %i KD",maxPrice];
            }
        }else
        {
            ((FUIButton*)[cell viewWithTag:2]).buttonColor = [UIColor colorFromHexCode:@"39C73C"];
            ((FUIButton*)[cell viewWithTag:2]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:2]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).cornerRadius = 0.0f;
        
            ((FUIButton*)[cell viewWithTag:4]).buttonColor = [UIColor colorFromHexCode:@"FF2C26"];
            ((FUIButton*)[cell viewWithTag:4]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:4]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:4]).cornerRadius = 0.0f;
            
            ((FUIButton*)[cell viewWithTag:2]).alpha = 1.0f;
            ((UIView*)[cell viewWithTag:3]).alpha = 1.0f;
            ((FUIButton*)[cell viewWithTag:4]).alpha = 1.0f;
            
            [(FUIButton*)[cell viewWithTag:2] addTarget:self
                                                 action:@selector(exploreClicked:) forControlEvents:UIControlEventTouchUpInside];

            [(FUIButton*)[cell viewWithTag:4] addTarget:self
                                                 action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [(UILabel*)[cell viewWithTag:1] setText:string];
    }else if([dataID isEqualToString:@"cars"])
    {
        searchCars* object = [dataSource objectAtIndex:indexPath.section];
        NSString* brands = [object.brands componentsJoinedByString:@" ، "];
        NSString* sub = [object.sub componentsJoinedByString:@" ، "];
        int maxPrice  = [object.price intValue];
        int year  = [object.year intValue];
        
        NSString* string = @"";
        if(indexPath.row == 0)
        {
            string = [NSString stringWithFormat:@"الماركات الرئيسية: %@",brands];
        }else if(indexPath.row == 1)
        {
            string = [NSString stringWithFormat:@"الماركات الفرعية: %@",sub];
        }else if(indexPath.row == 2)
        {
            if(maxPrice == -1)
            {
                string = [NSString stringWithFormat:@"السعر : %@",@"غير محدد"];
            }else
            {
                string = [NSString stringWithFormat:@"السعر : %i KD",maxPrice];
            }
        }else if(indexPath.row == 3)
        {
            if(year == -1)
            {
                string = [NSString stringWithFormat:@"السنة : %@",@"غير محدد"];
            }else
            {
                string = [NSString stringWithFormat:@"السنة : %i",year];
            }
        }else
        {
           ((FUIButton*)[cell viewWithTag:2]).buttonColor = [UIColor colorFromHexCode:@"39C73C"];
            ((FUIButton*)[cell viewWithTag:2]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:2]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).cornerRadius = 0.0f;
            
           ((FUIButton*)[cell viewWithTag:4]).buttonColor = [UIColor colorFromHexCode:@"FF2C26"];
            ((FUIButton*)[cell viewWithTag:4]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:4]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:4]).cornerRadius = 0.0f;
            
            ((FUIButton*)[cell viewWithTag:2]).alpha = 1.0f;
            ((UIView*)[cell viewWithTag:3]).alpha = 1.0f;
            ((FUIButton*)[cell viewWithTag:4]).alpha = 1.0f;
            
            [(FUIButton*)[cell viewWithTag:2] addTarget:self
                                                 action:@selector(exploreClicked:) forControlEvents:UIControlEventTouchUpInside];

            [(FUIButton*)[cell viewWithTag:4] addTarget:self
                                                 action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [(UILabel*)[cell viewWithTag:1] setText:string];
    }else if([dataID isEqualToString:@"jobs"])
      {
          searchJobs* object = [dataSource objectAtIndex:indexPath.section];
          NSString* string = @"";
          if(indexPath.row == 0)
          {
              string = [NSString stringWithFormat:@"%@ : %@",@"الكلمات الدالة",[object.keywords componentsJoinedByString:@" ، "]];
          }else
          {
             ((FUIButton*)[cell viewWithTag:2]).buttonColor = [UIColor colorFromHexCode:@"39C73C"];
              ((FUIButton*)[cell viewWithTag:2]).shadowColor = [UIColor greenSeaColor];
              ((FUIButton*)[cell viewWithTag:2]).shadowHeight = 0.0f;
              ((FUIButton*)[cell viewWithTag:2]).cornerRadius = 0.0f;
              
             ((FUIButton*)[cell viewWithTag:4]).buttonColor = [UIColor colorFromHexCode:@"FF2C26"];
              ((FUIButton*)[cell viewWithTag:4]).shadowColor = [UIColor greenSeaColor];
              ((FUIButton*)[cell viewWithTag:4]).shadowHeight = 0.0f;
              ((FUIButton*)[cell viewWithTag:4]).cornerRadius = 0.0f;
              
              ((FUIButton*)[cell viewWithTag:2]).alpha = 1.0f;
              ((FUIButton*)[cell viewWithTag:4]).alpha = 1.0f;
              
              [(FUIButton*)[cell viewWithTag:2] addTarget:self
                                                   action:@selector(exploreClicked:) forControlEvents:UIControlEventTouchUpInside];

              [(FUIButton*)[cell viewWithTag:4] addTarget:self
                                                   action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
          }
          [(UILabel*)[cell viewWithTag:1] setText:string];
      }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)exploreClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        selected = indexPath;
        [self performSegueWithIdentifier:@"exploreSeg" sender:self];
    }
}

- (void)deleteClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        [UIView transitionWithView:eqHolder
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [eqHolder setAlpha:1.0];
                            [_resView setHidden:YES];
                            [_equalizer show];
                        } completion:nil];

        [_store removeObject:[dataSource objectAtIndex:indexPath.section] withDeletionBlock:^(NSDictionary* deletionDictOrNil, NSError *errorOrNil) {
            if (errorOrNil) {
            } else {
                NSMutableArray* array = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:localID]];
                [array removeObjectAtIndex:indexPath.section];
                [[NSUserDefaults standardUserDefaults]setObject:array forKey:localID];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [UIView transitionWithView:eqHolder
                                  duration:0.2f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    [eqHolder setAlpha:0.0];
                                    [_resView setHidden:NO];
                                    [_equalizer dismiss];
                                } completion:^(BOOL finished){
                                    dispatch_async( dispatch_get_main_queue(), ^{
                                        [dataSource removeObjectAtIndex:indexPath.section];
                                        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];
                                        [tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
                                    });
                                }];
            }
        } withProgressBlock:nil];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [[header contentView]setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [header.textLabel setTextColor:[UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0]];
    [header.textLabel setFont:[UIFont fontWithName:@"DroidArabicKufi" size:14.0]];
    [header.textLabel setTextAlignment:NSTextAlignmentRight];
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%@ : %li",@"بحث رقم",(long)section+1];
}
/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

