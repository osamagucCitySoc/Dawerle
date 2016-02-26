//
//  JobSearchViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 2/12/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "JobSearchViewController.h"
#import <Parse/Parse.h>
#import "FlatSearchTableViewController.h"

@interface JobSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@end

@implementation JobSearchViewController
{
    __weak IBOutlet UITextField *keyWordTextField;
    __weak IBOutlet UITableView *tableView;
    NSMutableArray* dataSource;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"showRecordedSearch"])
    {
        FlatSearchTableViewController* dst = (FlatSearchTableViewController*)[segue destinationViewController];
        [dst setDataID:@"jobs"];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    dataSource = [[NSMutableArray alloc] init];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [keyWordTextField setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark table view methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(UITableViewCell*)tableView:(UITableView *)tableVieww cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID = @"jobKeyCell";
    UITableViewCell* cell = [tableVieww dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [[cell textLabel]setText:[dataSource objectAtIndex:indexPath.row]];
    
    return cell;
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableVieww commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [dataSource removeObjectAtIndex:indexPath.row];
        [tableVieww deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}

- (IBAction)submitClicked:(id)sender {
    [keyWordTextField resignFirstResponder];
    PFObject *order = [PFObject objectWithClassName:@"searchJobs"];
    PFInstallation *installation = [PFInstallation currentInstallation];
    [order addUniqueObjectsFromArray:dataSource forKey:@"keywords"];
    [order saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSMutableArray* channels = [[NSMutableArray alloc] initWithArray:[installation channels] copyItems:YES];
            [channels addObject:[NSString stringWithFormat:@"c%@",[order objectId]]];
            NSMutableArray* searchFlats = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"jobSearch"]];
            [searchFlats addObject:[order objectId]];
            [[NSUserDefaults standardUserDefaults]setObject:searchFlats forKey:@"jobSearch"];
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
}
- (IBAction)addKeyWordClicked:(id)sender {
    if(keyWordTextField.text.length > 0)
    {
        [dataSource addObject:keyWordTextField.text];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:dataSource.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    }
}
- (IBAction)mySearchClicked:(id)sender {
    [self performSegueWithIdentifier:@"showRecordedSearch" sender:self];
}

#pragma mark textfield methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self addKeyWordClicked:nil];
    return YES;
}

@end
