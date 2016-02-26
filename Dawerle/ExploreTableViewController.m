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

@interface ExploreTableViewController ()

@end

@implementation ExploreTableViewController
{
    NSMutableArray* dataSource;
    DownloaderClass* class;
}

@synthesize className,searchingParams;


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"searchWebSeg"])
    {
        PFObject* searchEntry = [dataSource objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        NSURL* url = [NSURL URLWithString:searchEntry[@"link"]];
        if(!url)
        {
            url = [NSURL URLWithString:[searchEntry[@"link"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        ShowSearchViewController* dst = (ShowSearchViewController*)[segue destinationViewController];
        [dst setLink:url];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataSource = [[NSMutableArray alloc] init];
    class = [DownloaderClass sharedInstance];
    
    [self loadItems];
    
}

-(void)loadItems
{
    if([className isEqualToString:@"cars"])
    {
        PFQuery *query = [PFQuery queryWithClassName:@"Cars"];
        [query whereKey:@"brand" containedIn:searchingParams[@"brands"]];
        [query whereKey:@"sub" containedIn:searchingParams[@"sub"]];
        [query whereKey:@"year" lessThanOrEqualTo:searchingParams[@"year"]];
        [query orderByDescending:@"updatedAt"];
        NSNumber* num = searchingParams[@"price"];
        if([num intValue] != -1)
        {
            [query whereKey:@"price" lessThanOrEqualTo:num];
        }
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            [dataSource addObjectsFromArray:results];
            [self.tableView reloadData];
            [self.tableView setNeedsDisplay];
        }];
    }else if([className isEqualToString:@"flats"] || [className isEqualToString:@"villas"] || [className isEqualToString:@"stores"])
    {
        NSMutableArray* rooms = searchingParams[@"rooms"];
        [rooms addObject:@"-1"];
        NSMutableArray* keywords = searchingParams[@"keywords"];
        [keywords addObject:@"-1"];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Flats"];
        [query whereKey:@"locs" containedIn:keywords];
        [query whereKey:@"rooms" containedIn:rooms];
        if([className isEqualToString:@"flats"])
        {
            [query whereKey:@"typee" equalTo:@"flat"];
        }else if([className isEqualToString:@"villas"])
        {
            [query whereKey:@"typee" equalTo:@"villa"];
        }else
        {
            [query whereKey:@"typee" equalTo:@"store"];
        }
        [query orderByDescending:@"updatedAt"];
        NSNumber* num = searchingParams[@"price"];
        if([num intValue] != -1)
        {
            [query whereKey:@"price" lessThanOrEqualTo:num];
        }
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            [dataSource addObjectsFromArray:results];
            [self.tableView reloadData];
            [self.tableView setNeedsDisplay];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"exploreCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    
    
    PFObject* object = [dataSource objectAtIndex:indexPath.row]; 
    

    NSURL* url = [NSURL URLWithString:object[@"img"]];
    if(!url)
    {
        url = [NSURL URLWithString:[object[@"img"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    if([className isEqualToString:@"cars"])
    {
        [(UIImageView*)[cell viewWithTag:1] setImage:nil];
        [class downloadFileAtUrl:url downloadingBlock:^(BOOL Succedded,NSString* locallySavedPath, NSString* error, NSString* loadedFrom)
         {
             if(Succedded)
             {
                 UIImage * myImage = [UIImage imageWithContentsOfFile: locallySavedPath];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [(UIImageView*)[cell viewWithTag:1] setImage:myImage];
                 });
             }
         }];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd-MM-YYYY"];
        
        [(UILabel*)[cell viewWithTag:2] setText:object[@"title"]];
        [(UITextView*)[cell viewWithTag:3] setText:object[@"desc"]];
        [(UILabel*)[cell viewWithTag:4] setText:[formatter stringFromDate:[object updatedAt]]];
        [(UILabel*)[cell viewWithTag:5] setText:object[@"source"]];
    }else if([className isEqualToString:@"flats"])
    {
        [(UIImageView*)[cell viewWithTag:1] setImage:nil];
        [class downloadFileAtUrl:url downloadingBlock:^(BOOL Succedded,NSString* locallySavedPath, NSString* error, NSString* loadedFrom)
         {
             if(Succedded)
             {
                 UIImage * myImage = [UIImage imageWithContentsOfFile: locallySavedPath];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [(UIImageView*)[cell viewWithTag:1] setImage:myImage];
                 });
             }
         }];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd-MM-YYYY"];
        
        NSString* locs = [object[@"locs"] componentsJoinedByString:@" - "];
        if([locs isEqualToString:@"-1"])
        {
            locs = @"المكان غير محدد";
        }
        NSNumber* price = object[@"price"];
        NSString* priceStr = @"";
        if([price intValue] == -1)
        {
            priceStr = @"0 KD";
        }else
        {
            priceStr = [NSString stringWithFormat:@"%i KD",[price intValue]];
        }
        [(UILabel*)[cell viewWithTag:2] setText:locs];
        [(UITextView*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"%@\n%@\n%@",object[@"title"],object[@"desc"],priceStr]];
        [(UILabel*)[cell viewWithTag:4] setText:[formatter stringFromDate:[object updatedAt]]];
        [(UILabel*)[cell viewWithTag:5] setText:object[@"source"]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"searchWebSeg" sender:self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0f;
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
