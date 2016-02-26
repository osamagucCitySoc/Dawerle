//
//  ExploreTableViewController.h
//  Dawerle
//
//  Created by Osama Rabie on 2/13/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ExploreTableViewController : UITableViewController


@property(nonatomic,strong) NSString* className;
@property(nonatomic,strong) PFObject* searchingParams;

@end
