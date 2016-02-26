//
//  FlatSearchTableViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 1/27/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "FlatSearchTableViewController.h"
#import <Parse/Parse.h>
#import "ExploreTableViewController.h"

@interface FlatSearchTableViewController ()

@end

@implementation FlatSearchTableViewController
{
    NSMutableArray* dataSource;
    NSString* localID;
    NSString* parseID;
}

@synthesize dataID;


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"exploreSeg"])
    {
        ExploreTableViewController* dst = (ExploreTableViewController*)[segue destinationViewController];
        [dst setClassName:dataID];
        [dst setSearchingParams:[dataSource objectAtIndex:self.tableView.indexPathForSelectedRow.row]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if([dataID isEqualToString:@"flats"])
    {
        localID = @"flatSearch";
        parseID = @"searchFlats";
    }else if([dataID isEqualToString:@"villas"])
    {
        localID = @"villaSearch";
        parseID = @"searchFlats";
    }else if([dataID isEqualToString:@"stores"])
    {
        localID = @"storeSearch";
        parseID = @"searchFlats";
    }else if([dataID isEqualToString:@"cars"])
    {
        localID = @"carSearch";
        parseID = @"searchCars";
    }else if([dataID isEqualToString:@"jobs"])
    {
        localID = @"jobSearch";
        parseID = @"searchJobs";
    }
    
    PFQuery *query = [PFQuery queryWithClassName:parseID];
    [query whereKey:@"objectId" containedIn:[[NSUserDefaults standardUserDefaults] objectForKey:localID]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        dataSource = [[NSMutableArray alloc] initWithArray:results];
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView setNeedsDisplay];
        });
    }];
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
    return [dataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellID = @"searchCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    PFObject* object = [dataSource objectAtIndex:indexPath.row];
    if([dataID isEqualToString:@"flats"])
    {
        NSString* keywords = [object[@"keywords"] componentsJoinedByString:@" "];
        int maxPrice  = [(NSNumber*)object[@"price"] intValue];
        NSString* rooms = [object[@"rooms"] componentsJoinedByString:@" "];
    
    
        NSString* string = [NSString stringWithFormat:@"%@\n%i\n%@",keywords,maxPrice,rooms];
    
    
        [(UITextView*)[cell viewWithTag:1] setText:string];
    }else if([dataID isEqualToString:@"villas"] || [dataID isEqualToString:@"stores"])
    {
        NSString* keywords = [object[@"keywords"] componentsJoinedByString:@" "];
        int maxPrice  = [(NSNumber*)object[@"price"] intValue];
        
        NSString* string = [NSString stringWithFormat:@"%@\n%i",keywords,maxPrice];
        
        
        [(UITextView*)[cell viewWithTag:1] setText:string];
    }else if([dataID isEqualToString:@"cars"])
    {
        NSString* brands = [object[@"brands"] componentsJoinedByString:@" "];
        NSString* sub = [object[@"sub"] componentsJoinedByString:@" "];
        int maxPrice  = [(NSNumber*)object[@"price"] intValue];
        int year  = [(NSNumber*)object[@"year"] intValue];
        
        NSString* string = [NSString stringWithFormat:@"%@\n%@\n%i\n%i",brands,sub,maxPrice,year];
        
        
        [(UITextView*)[cell viewWithTag:1] setText:string];
    }else if([dataID isEqualToString:@"jobs"])
    {
        [(UITextView*)[cell viewWithTag:1] setText:[object[@"keywords"] componentsJoinedByString:@" - "]];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 119.0f;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        PFObject* object = [dataSource objectAtIndex:indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError* error)
         {
             if(succeeded)
             {
                 dispatch_async( dispatch_get_main_queue(), ^{
                     [dataSource removeObjectAtIndex:indexPath.row];
                     [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                 });
             }
         }];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"exploreSeg" sender:self];
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
