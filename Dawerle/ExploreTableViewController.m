//
//  ExploreTableViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 2/13/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "ExploreTableViewController.h"
#import "DownloaderClass.h"
#import "ShowSearchViewController.h"
#import "Flats.h"
#import "Jobs.h"
#import <FlatUIKit.h>
#import "Cars.h"
#import "FeEqualize.h"

@interface ExploreTableViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)KCSAppdataStore* store;
@property (strong, nonatomic) FeEqualize *equalizer;
@end

@implementation ExploreTableViewController
{
    NSMutableArray* dataSource;
    DownloaderClass* class;
     __weak IBOutlet UIView *eqHolder;
    NSIndexPath* selected;
}

@synthesize className,searchingParams;


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"searchWebSeg"])
    {
        NSURL* url;
        NSString* titlee;
        if([className isEqualToString:@"cars"])
        {
            Cars* cars = [dataSource objectAtIndex:selected.section];
            url = [NSURL URLWithString:cars.link];
            if(!url)
            {
                url = [NSURL URLWithString:[cars.link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
            titlee = [NSString stringWithFormat:@"%@ : %@",@"إعلان من موقع",cars.source];
        }else if([className isEqualToString:@"flats"] || [className isEqualToString:@"villas"] || [className isEqualToString:@"stores"])
        {
            Flats* flats = [dataSource objectAtIndex:selected.section];
            url = [NSURL URLWithString:flats.link];
            if(!url)
            {
                url = [NSURL URLWithString:[flats.link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
            titlee = [NSString stringWithFormat:@"%@ : %@",@"إعلان من موقع",flats.source];
        }else if([className isEqualToString:@"jobs"])
        {
            Jobs* cars = [dataSource objectAtIndex:selected.section];
            url = [NSURL URLWithString:cars.link];
            if(!url)
            {
                url = [NSURL URLWithString:[cars.link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
            titlee = [NSString stringWithFormat:@"%@ : %@",@"إعلان من موقع",cars.source];
        }
        
        ShowSearchViewController* dst = (ShowSearchViewController*)[segue destinationViewController];
        [dst setLink:url];
        [dst setTitlee:titlee];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataSource = [[NSMutableArray alloc] init];
    class = [DownloaderClass sharedInstance];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(dataSource.count == 0)
    {
        [self loadItems];
    }
}

-(void)loadItems
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
                        [_equalizer show];
                    } completion:nil];

    
    if([className isEqualToString:@"cars"])
    {
        NSArray* brands = ((searchCars*)searchingParams).brands;
        NSArray* subs =((searchCars*)searchingParams).sub;
        
        KCSQuery* nameQuery1 = [KCSQuery queryOnField:@"brand" usingConditional:kKCSIn forValue:brands];
        KCSQuery* nameQuery2 = [KCSQuery queryOnField:@"sub" usingConditional:kKCSIn forValue:subs];
        KCSQuery* nameQuery3 = [KCSQuery queryOnField:@"year" usingConditional:kKCSGreaterThanOrEqual forValue:((searchCars*)searchingParams).year];
        KCSQuery* nameQuery4;
        NSNumber* num = ((searchCars*)searchingParams).price;
        if([num intValue] != -1)
        {
            nameQuery4 = [KCSQuery queryOnField:@"price" usingConditional:kKCSLessThanOrEqual forValue:num];
        }

        KCSQuerySortModifier* dateSort = [[KCSQuerySortModifier alloc] initWithField:KCSMetadataFieldLastModifiedTime inDirection:kKCSDescending];
        KCSQuery* compoundQuery;
        if(nameQuery4)
        {
            compoundQuery = [KCSQuery queryForJoiningOperator:kKCSAnd onQueries:nameQuery1,nameQuery2,nameQuery3,nameQuery4, nil];
        }else
        {
            compoundQuery = [KCSQuery queryForJoiningOperator:kKCSAnd onQueries:nameQuery1,nameQuery2,nameQuery3,nil];
        }
        [compoundQuery addSortModifier:dateSort];
        compoundQuery.limitModifer = [[KCSQueryLimitModifier alloc] initWithLimit:500];
        _store = [KCSAppdataStore storeWithOptions:@{ KCSStoreKeyCollectionName : @"Cars",
                                                      KCSStoreKeyCollectionTemplateClass : [Cars class]}];
        
        [_store queryWithQuery:compoundQuery withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
            if (errorOrNil != nil) {
                //An error happened, just log for now
                NSLog(@"An error occurred on fetch: %@", errorOrNil);
            } else {
                if(objectsOrNil)
                {
                    dataSource = [[NSMutableArray alloc] initWithArray:objectsOrNil];
                }else
                {
                    dataSource = [[NSMutableArray alloc]init];
                }
                dispatch_async( dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.tableView setNeedsDisplay];
                });
            }
            [UIView transitionWithView:eqHolder
                              duration:0.2f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [eqHolder setAlpha:0.0];
                                [_equalizer dismiss];
                            } completion:nil];

        } withProgressBlock:nil];
    }else if([className isEqualToString:@"flats"] || [className isEqualToString:@"villas"] || [className isEqualToString:@"stores"])
    {
        NSMutableArray* rooms = [[NSMutableArray alloc]initWithArray:((searchFlats*)searchingParams).rooms];
        [rooms addObject:@"-1"];
        NSMutableArray* keywords = [[NSMutableArray alloc]initWithArray:((searchFlats*)searchingParams).keywords];
        [keywords addObject:@"-1"];
        
        KCSQuery* nameQuery1 = [KCSQuery queryOnField:@"rooms" usingConditional:kKCSIn forValue:rooms];
        KCSQuery* nameQuery2 = [KCSQuery queryOnField:@"locs" usingConditional:kKCSIn forValue:keywords];
        KCSQuery* nameQuery3;
        KCSQuery* nameQuery4;
        
        if([className isEqualToString:@"flats"])
        {
            nameQuery3 = [KCSQuery queryOnField:@"typee" withExactMatchForValue:@"flat"];
        }else if([className isEqualToString:@"villas"])
        {
            nameQuery3 = [KCSQuery queryOnField:@"typee" withExactMatchForValue:@"villa"];
        }else
        {
            nameQuery3 = [KCSQuery queryOnField:@"typee" withExactMatchForValue:@"store"];
        }
        
        NSNumber* num = ((searchFlats*)searchingParams).price;
        if([num intValue] != -1)
        {
            nameQuery4 = [KCSQuery queryOnField:@"price" usingConditional:kKCSLessThanOrEqual forValue:num];
        }
        KCSQuerySortModifier* dateSort = [[KCSQuerySortModifier alloc] initWithField:KCSMetadataFieldLastModifiedTime inDirection:kKCSDescending];
        
        KCSQuery* compoundQuery;
        if(nameQuery4)
        {
            compoundQuery = [KCSQuery queryForJoiningOperator:kKCSAnd onQueries:nameQuery1,nameQuery2,nameQuery3,nameQuery4, nil];
        }else
        {
            compoundQuery = [KCSQuery queryForJoiningOperator:kKCSAnd onQueries:nameQuery1,nameQuery2,nameQuery3,nil];
        }
        [compoundQuery addSortModifier:dateSort];
        compoundQuery.limitModifer = [[KCSQueryLimitModifier alloc] initWithLimit:500];
        
        _store = [KCSAppdataStore storeWithOptions:@{ KCSStoreKeyCollectionName : @"Flats",
                                                      KCSStoreKeyCollectionTemplateClass : [Flats class]}];
        
        [_store queryWithQuery:compoundQuery withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
            if (errorOrNil != nil) {
                //An error happened, just log for now
                NSLog(@"An error occurred on fetch: %@", errorOrNil);
            } else {
                if(objectsOrNil)
                {
                    dataSource = [[NSMutableArray alloc] initWithArray:objectsOrNil];
                }else
                {
                    dataSource = [[NSMutableArray alloc]init];
                }
                dispatch_async( dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.tableView setNeedsDisplay];
                });
            }
            [UIView transitionWithView:eqHolder
                              duration:0.2f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [eqHolder setAlpha:0.0];
                                [_equalizer dismiss];
                            } completion:nil];

        } withProgressBlock:nil];
    }else if([className isEqualToString:@"jobs"])
    {
        NSArray* keywords = ((searchJobs*)searchingParams).keywords;
        KCSQuery* nameQuery1 = [KCSQuery queryOnField:@"keywords" usingConditional:kKCSIn forValue:keywords];
        KCSQuerySortModifier* dateSort = [[KCSQuerySortModifier alloc] initWithField:KCSMetadataFieldLastModifiedTime inDirection:kKCSDescending];
        [nameQuery1 addSortModifier:dateSort];
        nameQuery1.limitModifer = [[KCSQueryLimitModifier alloc] initWithLimit:500];
        
        _store = [KCSAppdataStore storeWithOptions:@{ KCSStoreKeyCollectionName : @"Jobs",
                                                      KCSStoreKeyCollectionTemplateClass : [Jobs class]}];
        
        [_store queryWithQuery:nameQuery1 withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
            if (errorOrNil != nil) {
                //An error happened, just log for now
                NSLog(@"An error occurred on fetch: %@", errorOrNil);
            } else {
                if(objectsOrNil)
                {
                    dataSource = [[NSMutableArray alloc] initWithArray:objectsOrNil];
                }else
                {
                    dataSource = [[NSMutableArray alloc]init];
                }
                dispatch_async( dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.tableView setNeedsDisplay];
                });
            }
            [UIView transitionWithView:eqHolder
                              duration:0.2f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [eqHolder setAlpha:0.0];
                                [_equalizer dismiss];
                            } completion:nil];
            
        } withProgressBlock:nil];
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
    if([className isEqualToString:@"villas"] || [className isEqualToString:@"flats"] || [className isEqualToString:@"stores"])
    {
        return 6;
    }else if([className isEqualToString:@"cars"])
    {
        return 6;
    }else if([className isEqualToString:@"jobs"])
    {
        return 3;
    }
    return 2;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"exploreCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    ((FUIButton*)[cell viewWithTag:2]).alpha = 0.0f;
    
    if([className isEqualToString:@"cars"])
    {
        Cars* object = [dataSource objectAtIndex:indexPath.section];
        
        if(indexPath.row == 0)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@ - %@",@"الماركة",object.brand,object.sub]];
        }else if(indexPath.row == 1)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %i",@"سنة الصنع",object.year.intValue]];
        }else if(indexPath.row == 2)
        {
            if(object.price.intValue <= 0)
            {
                [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"السعر",@"غير محدد"]];
            }else
            {
                [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %i",@"السعر",object.price.intValue]];
            }
        }else if(indexPath.row == 3)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"العنوان",object.title]];
        }else if(indexPath.row == 4)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"الوصف",object.desc]];
        }else if(indexPath.row == 5)
        {
            ((FUIButton*)[cell viewWithTag:2]).buttonColor = [UIColor colorFromHexCode:@"34a853"];
            ((FUIButton*)[cell viewWithTag:2]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:2]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).cornerRadius = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).alpha = 1.0f;
            [(FUIButton*)[cell viewWithTag:2] addTarget:self
                                                 action:@selector(exploreClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }else if([className isEqualToString:@"flats"] || [className isEqualToString:@"villas"] || [className isEqualToString:@"stores"])
    {
        Flats* object = [dataSource objectAtIndex:indexPath.section];
        if(indexPath.row == 0)
        {
            if([object.loc isEqualToString:@"-1"])
            {
                [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"العنوان",@"غير محدد"]];
            }else
            {
                [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"العنوان",object.loc]];
            }
        }else if(indexPath.row == 1)
        {
            if([object.rooms.firstObject isEqualToString:@"-1"] || [object.rooms.firstObject isEqualToString:@"0"])
            {
                [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"عدد الغرف",@"غير محدد"]];
            }else
            {
                [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"عدد الغرف",object.rooms.firstObject]];
            }
        }else if(indexPath.row == 2)
        {
            if(object.price.intValue <= 0)
            {
                [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"السعر",@"غير محدد"]];
            }else
            {
                [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %i",@"السعر",object.price.intValue]];
            }
        }else if(indexPath.row == 3)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"العنوان",object.title]];
        }else if(indexPath.row == 4)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"الوصف",object.desc]];
        }else if(indexPath.row == 5)
        {
            ((FUIButton*)[cell viewWithTag:2]).buttonColor = [UIColor colorFromHexCode:@"34a853"];
            ((FUIButton*)[cell viewWithTag:2]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:2]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).cornerRadius = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).alpha = 1.0f;
            [(FUIButton*)[cell viewWithTag:2] addTarget:self
                                                 action:@selector(exploreClicked:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }else if([className isEqualToString:@"jobs"])
    {
        Jobs* object = [dataSource objectAtIndex:indexPath.section];
        
        if(indexPath.row == 0)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"العنوان",object.title]];
        }else if(indexPath.row == 1)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@ : %@",@"الوصف",object.desc]];
        }else if(indexPath.row == 2)
        {
            ((FUIButton*)[cell viewWithTag:2]).buttonColor = [UIColor colorFromHexCode:@"34a853"];
            ((FUIButton*)[cell viewWithTag:2]).shadowColor = [UIColor greenSeaColor];
            ((FUIButton*)[cell viewWithTag:2]).shadowHeight = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).cornerRadius = 0.0f;
            ((FUIButton*)[cell viewWithTag:2]).alpha = 1.0f;
            [(FUIButton*)[cell viewWithTag:2] addTarget:self
                                                 action:@selector(exploreClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50.0f;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [[header contentView]setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [header.textLabel setTextColor:[UIColor blackColor]];
    [header.textLabel setFont:[UIFont fontWithName:@"DroidArabicKufi" size:20.0]];
    [header.textLabel setTextAlignment:NSTextAlignmentRight];
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd/MM"];
    
    if([className isEqualToString:@"villas"] || [className isEqualToString:@"flats"] || [className isEqualToString:@"stores"])
    {
        Flats* object = [dataSource  objectAtIndex:section];
        return [NSString stringWithFormat:@"%@ : %@. في %@",@"إعلان من موقع",object.source,[formatter stringFromDate:object.metadata.lastModifiedTime]];
    }else if([className isEqualToString:@"cars"])
    {
        Cars* object = [dataSource  objectAtIndex:section];
        return [NSString stringWithFormat:@"%@ : %@. في %@",@"إعلان من موقع",object.source,[formatter stringFromDate:object.metadata.lastModifiedTime]];
    }else if([className isEqualToString:@"jobs"])
    {
        Jobs* object = [dataSource  objectAtIndex:section];
        return [NSString stringWithFormat:@"%@ : %@. في %@",@"إعلان من موقع",object.source,[formatter stringFromDate:object.metadata.lastModifiedTime]];
    }

    return @"";
}


- (void)exploreClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        selected = indexPath;
        [self performSegueWithIdentifier:@"searchWebSeg" sender:self];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
