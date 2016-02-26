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

@interface ViewController ()

@end

@implementation ViewController

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
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
