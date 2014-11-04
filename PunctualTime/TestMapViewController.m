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
#import "SearchTableViewController.h"
#import "Event.h"
#import <MapKit/MapKit.h>

NSString *const apiAccessKey = @"AIzaSyBB2Uc2kK0P3zDKwgyYlyC8ivdDCSyy4xg";

@interface TestMapViewController ()<UISearchBarDelegate>
@property (nonatomic, strong) AppDelegate *applicationDelegate;
@property (weak, nonatomic) IBOutlet UISearchBar *startSearchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *destinationSearchBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITextView *directionsTextView;
@property MKPointAnnotation *userDestination;
@property NSArray *sourceLocations;
@property NSArray *destinationLocations;
@property Event *sampleEvent;

@property NSDictionary *eventDestination;

@property LocationSearchController *locationSearchController;

@end

@implementation TestMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startSearchBar.delegate = self;
    self.destinationSearchBar.delegate = self;
    self.locationSearchController = [LocationSearchController new];


    self.applicationDelegate = [UIApplication sharedApplication].delegate;


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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.eventDestination = @{@"Hello": @"People"};
    SearchTableViewController *viewController = segue.destinationViewController;
    viewController.chosenLocation = self.eventDestination;
    NSLog(@"Choices: %@", self.eventDestination);
}

-(IBAction)unwindFromSearchTableViewController:(UIStoryboardSegue *)segue{
    SearchTableViewController *viewController = segue.sourceViewController;
    self.eventDestination = viewController.chosenLocation;
    NSLog(@"Selected Event: %@",self.eventDestination);
    NSLog(@"Chosen Location: %@", viewController.chosenLocation);
    [self.applicationDelegate.userLocationManager updateLocation];
    [self calculateTheETAForTheEventwithCompletion:^(NSDictionary *location) {
        NSLog(@"HELLLLLLLLOOO");
        NSLog(@"Location: %@", location);
    }];

}


//Notes from this MORNING

//NSURL Components && NSURL components relative to url  (Absolute URL) Stringbyappendingpathcomponent
//Mapkit APi, acccesss to favorite
//Google locations contact list for API

//Contacts are in C - available ilbraries
//Carbonite API's


//If the user pauses for a certain amount of time, then send a request
//NSTimer reset each time the person, INVALIDATE
//NSCache - NShipster - if call was made 5 minutes ago, delete - automatically clears out
//NSURLSession Cacheing systems for Google API request.
//-1 on all rows, didselectrowat index patth if 0

//ns enum - list of integers, it can only be one
//ns-option 

-(void)calculateTheETAForTheEventwithCompletion:(void (^)(NSDictionary *))complete{


    CLLocation *userLocation = self.applicationDelegate.userLocationManager.location;
    NSString *google = @"https://maps.googleapis.com/maps/api/directions/json?origin=";
    NSString *currentLatitude = [NSString stringWithFormat:@"%f,",userLocation.coordinate.latitude];
    NSString *currentLongitude = [NSString stringWithFormat:@"%f",userLocation.coordinate.longitude];
    NSString *destination = [NSString stringWithFormat: @"&destination="];
    NSString *latitude = [NSString stringWithFormat:@"%@,",[self.eventDestination objectForKey:@"lat"]];
    NSString *longitude = [NSString stringWithFormat:@"%@",[self.eventDestination objectForKey:@"long"]];
    NSString *apiAccessKeyURL = [NSString stringWithFormat:@"&waypoints=optimize:true&key=%@",apiAccessKey];
    NSString *arrivalTime = [NSString stringWithFormat:@"&arrival_time=1415133552"];
    NSString *modeOfTransportation = [NSString stringWithFormat:@"&mode=transit"];



    NSArray *urlStrings = @[google, currentLatitude, currentLongitude, destination, latitude, longitude,apiAccessKeyURL, arrivalTime, modeOfTransportation];
    NSString *joinedString = [urlStrings componentsJoinedByString:@""];
    NSLog(@"%@",joinedString);

    NSURL *url = [NSURL URLWithString:joinedString];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];


        NSLog(@"JSON Result %@",jSONresult);
        complete(jSONresult);
        
    }];
    [task resume];


}




@end
