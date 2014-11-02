//
//  TestMapViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/1/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "TestMapViewController.h"
#import "AppDelegate.h"
#import "LocationSearchController.h"
#import <MapKit/MapKit.h>

@interface TestMapViewController ()<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *startSearchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *destinationSearchBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property MKPointAnnotation *userDestination;
@property CLLocation *userLocation;
@property NSArray *searchLocations;

@property LocationSearchController *locationSearchController;

@end

@implementation TestMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startSearchBar.delegate = self;
        self.destinationSearchBar.delegate = self;
    self.locationSearchController = [LocationSearchController new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SearchBar

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"text: %@",self.startSearchBar.text);
    [self.locationSearchController searchLocations:self.startSearchBar.text withCompletion:^(NSArray *placemarks) {
        self.searchLocations = [NSArray arrayWithArray:placemarks];
        NSLog(@"%@",self.searchLocations);
    }];
    NSLog(@"Hello");
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
