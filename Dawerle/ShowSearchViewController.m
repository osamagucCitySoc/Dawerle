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
#import <Google/Analytics.h>
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"

@interface ShowSearchViewController ()<UIWebViewDelegate,NJKWebViewProgressDelegate>
@property (strong, nonatomic) FeEqualize *equalizer;
@end

@implementation ShowSearchViewController
{
    __weak IBOutlet UIWebView *webView;
    __weak IBOutlet UIView *eqHolder;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    BOOL open;
    id<GAITracker> tracker;
}

@synthesize searchItem;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    open = YES;
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"mozilla/5.0 (iphone; cpu iphone os 7_0_2 like mac os x) applewebkit/537.51.1 (khtml, like gecko) version/7.0 mobile/11a501 safari/9537.53", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    //[webView setDelegate:self];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 6.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    
    if(!self.link)
    {
        if([[[searchItem objectForKey:@"aps"] objectForKey:@"c"] isEqualToString:@"223"])
        {
            open = NO;
        }
        NSURL* url = [NSURL URLWithString:[[searchItem objectForKey:@"aps"] objectForKey:@"i"]];
        if(!url)
        {
            url = [NSURL URLWithString:[[[searchItem objectForKey:@"aps"] objectForKey:@"i"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            self.link = url;
        }
        NSURLRequest* req = [[NSURLRequest alloc]initWithURL:url];
        [webView loadRequest:req];

    }else
    {
        NSURLRequest* req = [[NSURLRequest alloc]initWithURL:self.link];
        

        [webView loadRequest:req];
    }
    
    
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:19]}];
    
    if(self.titlee)
    {
        [self setTitle:self.titlee];
    }
    
    tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"ShowSearchViewController"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webVieww
{
    if([[self.link absoluteString]containsString:@"q8car"] || [[self.link absoluteString]containsString:@"q84sale"] || !open)
    {
        [[UIApplication sharedApplication] openURL:self.link];
        [self.navigationController popViewControllerAnimated:YES];
    }else
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
}

- (void)webViewDidFinishLoad:(UIWebView *)webVieww
{
    
    if([webVieww.request.URL.absoluteString containsString:@"opensooq"])
    {
        NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", (long)90];
        [webVieww stringByEvaluatingJavaScriptFromString:javascript];
    }
    [eqHolder setAlpha:0.0];
    [_equalizer dismiss];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@",[error description]);
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
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
