//
//  SplashScreenViewController.m
//  Dawerle
//
//  Created by Osama Rabie on 3/6/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import "SplashScreenViewController.h"
#import <FBGlowLabel/FBGlowLabel.h>
#import <FlatUIKit.h>

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController
{
    __weak IBOutlet FBGlowLabel *v;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    v.textAlignment = NSTextAlignmentCenter;
    v.clipsToBounds = YES;
    v.backgroundColor = [UIColor clearColor];
    v.alpha = 1.0;
    v.textColor = UIColor.whiteColor;
    v.glowSize = 10;
    v.glowColor = [UIColor whiteColor];
    v.innerGlowSize = 2;
    v.innerGlowColor = [UIColor whiteColor];
    [self performSelector:@selector(hoba) withObject:nil afterDelay:2.0];
}

-(void)hoba
{
    [self performSegueWithIdentifier:@"launchSeg" sender:self];
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
