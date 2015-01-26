//
//  DetailViewController.h
//  CityworksExample-iOS
//
//  Created by Dee Clawson on 1/24/15.
//  Copyright (c) 2015 Dee Clawson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>









@interface DetailViewController : UIViewController


@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
-(void)addPins:(NSDecimalNumber*) woX ycoord:(NSDecimalNumber*) woY desc:(NSString*)desc;

@end




