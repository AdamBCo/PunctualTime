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
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITextView *directionsTextView;
@property MKPointAnnotation *userDestination;
@property NSArray *sourceLocations;
@property NSArray *destinationLocations;

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

    if(searchBar == self.startSearchBar){
        [self.locationSearchController searchLocations:self.startSearchBar.text withCompletion:^(NSArray *placemarks) {
            self.sourceLocations = [NSArray arrayWithArray:placemarks];
            [self.mapView addAnnotations:self.sourceLocations];
            [self.mapView showAnnotations:self.sourceLocations animated:YES];
            self.userDestination = self.sourceLocations.firstObject;
            [self.startSearchBar resignFirstResponder];
            [self getDirections];
            NSLog(@"%@",self.sourceLocations);
        }];
    }
    else if(searchBar == self.destinationSearchBar)
    {
        [self.locationSearchController searchLocations:self.destinationSearchBar.text withCompletion:^(NSArray *placemarks) {
            self.destinationLocations = [NSArray arrayWithArray:placemarks];
            [self.mapView addAnnotations:self.destinationLocations];
            [self.destinationSearchBar resignFirstResponder];
            [self.mapView showAnnotations:self.destinationLocations animated:YES];
            [self getDirectionsAuto];
            NSLog(@"%@",self.sourceLocations);
        }];
    }
    NSLog(@"Hello");
}

#pragma mark - Directions

-(void)getDirections{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:[MKMapItem mapItemForCurrentLocation]];
    MKPlacemark *mkDest = [[MKPlacemark alloc] initWithCoordinate:self.userDestination.coordinate addressDictionary:nil];
    [request setDestination:[[MKMapItem alloc] initWithPlacemark:mkDest]];
    [request setTransportType:MKDirectionsTransportTypeWalking];
    [request setRequestsAlternateRoutes:NO];
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if ( !error && [response routes] > 0) {
            MKRoute *route = [[response routes] objectAtIndex:0];
            NSString *text = [NSString stringWithFormat:@"It will take: %f hours",route.expectedTravelTime / 3600];
            self.directionsTextView.text = text;
        }
    }];
}

-(void)getDirectionsAuto{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:[MKMapItem mapItemForCurrentLocation]];
    MKPlacemark *mkDest = [[MKPlacemark alloc] initWithCoordinate:self.userDestination.coordinate addressDictionary:nil];
    [request setDestination:[[MKMapItem alloc] initWithPlacemark:mkDest]];
    [request setTransportType:MKDirectionsTransportTypeAutomobile];
    [request setRequestsAlternateRoutes:NO];
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if ( !error && [response routes] > 0) {
            MKRoute *route = [[response routes] objectAtIndex:0];
            NSLog(@"The route: %f",route.distance);
            NSString *text = [NSString stringWithFormat:@"It will take: %f hours",route.expectedTravelTime / 3600];
            self.directionsTextView.text = text;
        }
    }];
}


- (IBAction)segmentedControl:(id)sender {

    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self getDirections];
            break;
        case 1:
            [self getDirectionsAuto];
            break;

        default:
            break;
    }
}


@end
