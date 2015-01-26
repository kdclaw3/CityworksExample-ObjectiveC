//
//  DetailViewController.m
//  CityworksExample-iOS
//
//  Created by Dee Clawson on 1/24/15.
//  Copyright (c) 2015 Dee Clawson. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

#define METERS_PER_MILE 1609.344


@implementation DetailViewController
@synthesize mapView;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
 
    CLLocationCoordinate2D zoomLocation;
    //Winston-Salem, North Carolina - using userlocation woould probably be more appropriate.
    zoomLocation.latitude = 36.099860;
    zoomLocation.longitude= -80.244216;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [self.mapView setRegion:viewRegion animated:YES];
    
}

-(void)zoomInOnLocation:(CLLocationCoordinate2D)location
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 200, 200);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

-(void)addPins:(NSDecimalNumber*)woX ycoord:(NSDecimalNumber*)woY desc:(NSString*)desc {

    CLLocationCoordinate2D coordinate;
    coordinate.latitude = woY.doubleValue;
    coordinate.longitude = woX.doubleValue;
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coordinate];
    [annotation setTitle:desc]; //You can set the subtitle too
    [self.mapView addAnnotation:annotation];
    
    
}

@end
