//
//  ShowSearchViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 1/27/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "ShowSearchViewController.h"
#import <FlatUIKit.h>
#import "FeEqualize.h"


@interface ShowSearchViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) FeEqualize *equalizer;
@end

@implementation ShowSearchViewController
{
    __weak IBOutlet UIWebView *webView;
    __weak IBOutlet UIView *eqHolder;
}

@synthesize searchItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.link)
    {
        NSURL* url = [NSURL URLWithString:[searchItem objectForKey:@"i"]];
        if(!url)
        {
            url = [NSURL URLWithString:[[searchItem objectForKey:@"i"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        NSURLRequest* req = [[NSURLRequest alloc]initWithURL:url];
        [webView loadRequest:req];

    }else
    {
        NSURLRequest* req = [[NSURLRequest alloc]initWithURL:self.link];
        [webView loadRequest:req];
    }
    
    
    [webView setDelegate:self];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:21]}];
    
    if(self.titlee)
    {
        [self setTitle:self.titlee];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_equalizer removeFromSuperview];
    _equalizer = [[FeEqualize alloc] initWithView:eqHolder title:@"جاري التحميل.."];
    CGRect frame = CGRectMake(0, 0, 70, 70);
    [_equalizer setFrame:frame];
    
    [_equalizer setBackgroundColor:[UIColor clearColor]];
    [eqHolder setBackgroundColor:[UIColor clearColor]];
    [eqHolder addSubview:_equalizer];
    [eqHolder setAlpha:1.0];
    [_equalizer show];

}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [eqHolder setAlpha:0.0];
    [_equalizer dismiss];
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
