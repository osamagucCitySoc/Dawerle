//
//  RoomsViewController.h
//  Dawerle
//
//  Created by Osama Rabie on 1/25/16.
//  Copyright © 2016 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomsViewController : UIViewController

@property (nonatomic,strong)NSMutableArray* selectedAreas;
@property(nonatomic, strong)NSString* type;
@property(nonatomic, strong)NSString* countryType;
@property(nonatomic, strong)NSString* rentType;

@end
