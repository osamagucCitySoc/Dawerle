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
    
    _logoImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);

    [UIView animateWithDuration:0.2 delay:0.2 options:0
                     animations:^{
                         _logoImageView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
                         //[_logoImageView setAlpha:0.0];
                     }
                     completion:^(BOOL finished) {
                         _logoImageView.transform = CGAffineTransformMakeScale(0.0, 0.0);
                         [self hoba];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
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
