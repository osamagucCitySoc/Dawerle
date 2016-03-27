//
//  ViewController.h
//  Dawerle
//
//  Created by Osama Rabie on 1/25/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SADAHBlurView.h"

@interface ViewController : UIViewController
{
    NSInteger savedInd,theTag;
}


@property (strong, nonatomic) IBOutlet UIView *optionsView;
@property (strong, nonatomic) IBOutlet UIButton *firstOptionsButton;

@property (strong, nonatomic) IBOutlet UIButton *secondOptionsButton;
@property (strong, nonatomic) IBOutlet UIImageView *optionsBackImg;
@property (strong, nonatomic) IBOutlet UIButton *optionsBackButton;
@property (strong, nonatomic) IBOutlet UILabel *firstOptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondOptionLabel;

@end

