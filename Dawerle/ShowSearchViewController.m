//
//  ShowSearchViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 1/27/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "ShowSearchViewController.h"

@interface ShowSearchViewController ()

@end

@implementation ShowSearchViewController
{
    __weak IBOutlet UIWebView *webView;
}

@synthesize searchItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.link)
    {
        NSString* className = @"";
        if([[searchItem objectForKey:@"c"]isEqualToString:@"1"])
        {
            className = @"Flats";
        }else if([[searchItem objectForKey:@"c"]isEqualToString:@"2"])
        {
            className = @"Cars";
        }else if([[searchItem objectForKey:@"c"]isEqualToString:@"3"])
        {
            className = @"Jobs";
        }
        
        PFQuery *query = [PFQuery queryWithClassName:className];
        [query getObjectInBackgroundWithId:[searchItem objectForKey:@"i"] block:^(PFObject *searchEntry, NSError *error) {
            dispatch_async( dispatch_get_main_queue(), ^{
                NSURL* url = [NSURL URLWithString:searchEntry[@"link"]];
                if(!url)
                {
                    url = [NSURL URLWithString:[searchEntry[@"link"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
                NSURLRequest* req = [[NSURLRequest alloc]initWithURL:url];
                [webView loadRequest:req];
            });
        }];

    }else
    {
        NSURLRequest* req = [[NSURLRequest alloc]initWithURL:self.link];
        [webView loadRequest:req];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
