//
//  MasterViewController.h
//  CityworksExample-iOS
//
//  Created by Dee Clawson on 1/24/15.
//  Copyright (c) 2015 Dee Clawson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController 

@property (strong, nonatomic) DetailViewController *detailViewController;

//Declare Cityworks Methods
-(void) loginCityworks;
-(void) getUserInfo;
-(void) getWorkOrderIndex;
-(void) getWorkOrderShow:(NSString*) woId;

@end

