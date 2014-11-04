//
//  NewViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/4/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "NewViewController.h"
#import "EventController.h"
#import "AppDelegate.h"
#import "LocationSearchController.h"
#import "SearchTableViewController.h"
#import "Event.h"
#import <MapKit/MapKit.h>

NSString *const apiAccessKey = @"AIzaSyBB2Uc2kK0P3zDKwgyYlyC8ivdDCSyy4xg";

@interface NewViewController () <UISearchBarDelegate>
@property (nonatomic, strong) AppDelegate *applicationDelegate;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *directionsTextView;

@property MKPointAnnotation *userDestination;
@property NSArray *sourceLocations;
@property NSArray *destinationLocations;
@property Event *sampleEvent;
@property EventController *sharedEventController;

@property NSDictionary *eventDestination;

@property LocationSearchController *locationSearchController;

@end

@implementation NewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationSearchController = [LocationSearchController new];
    self.applicationDelegate = [UIApplication sharedApplication].delegate;
    self.datePicker.minimumDate = [NSDate date];
    self.sharedEventController = [EventController sharedEventController];
}

- (IBAction)onSaveEventButtonPressed:(id)sender
{
    CLLocationCoordinate2D saveLocation;
    saveLocation.latitude = [self.eventDestination[@"lat"] doubleValue];
    saveLocation.longitude = [self.eventDestination[@"long"] doubleValue];


    Event *newEvent = [[Event alloc] initWithEventName:self.nameTextField.text
                                       startingAddress:self.applicationDelegate.userLocationManager.location.coordinate
                                         endingAddress:saveLocation
                                           arrivalTime:self.datePicker.date];

    __unsafe_unretained typeof(self) weakSelf = self; // Using this in the block to prevent a retain cycle
    [self.sharedEventController addEvent:newEvent withCompletion:
     ^{
         [weakSelf resetTextFields];
     }];

    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.fireDate = newEvent.desiredArrivalTime;
    localNotification.alertBody = [NSString stringWithFormat:@"Alert Fired at %@", newEvent.desiredArrivalTime];
    localNotification.timeZone = [NSTimeZone localTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    NSLog(@"This local notification was created: %@", localNotification);
}


- (void)resetTextFields
{
    self.nameTextField.text = @"";
    self.datePicker.date = [NSDate date];
}


//#pragma mark - SearchBar
//
//-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//
//    if(searchBar == self.startSearchBar){
//        [self.locationSearchController searchLocations:self.startSearchBar.text withCompletion:^(NSArray *placemarks) {
//            self.sourceLocations = [NSArray arrayWithArray:placemarks];
//            [self.mapView addAnnotations:self.sourceLocations];
//            [self.mapView showAnnotations:self.sourceLocations animated:YES];
//            self.userDestination = self.sourceLocations.firstObject;
//            [self.startSearchBar resignFirstResponder];
//            [self getDirections];
//            NSLog(@"%@",self.sourceLocations);
//        }];
//    }
//    else if(searchBar == self.destinationSearchBar)
//    {
//        [self.locationSearchController searchLocations:self.destinationSearchBar.text withCompletion:^(NSArray *placemarks) {
//            self.destinationLocations = [NSArray arrayWithArray:placemarks];
//            [self.mapView addAnnotations:self.destinationLocations];
//            [self.destinationSearchBar resignFirstResponder];
//            [self.mapView showAnnotations:self.destinationLocations animated:YES];
//            [self getDirectionsAuto];
//            NSLog(@"%@",self.sourceLocations);
//        }];
//    }
//    NSLog(@"Hello");
//}

#pragma mark - Directions

//-(void)getDirections{
//    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
//    [request setSource:[MKMapItem mapItemForCurrentLocation]];
//    MKPlacemark *mkDest = [[MKPlacemark alloc] initWithCoordinate:self.userDestination.coordinate addressDictionary:nil];
//    [request setDestination:[[MKMapItem alloc] initWithPlacemark:mkDest]];
//    [request setTransportType:MKDirectionsTransportTypeWalking];
//    [request setRequestsAlternateRoutes:NO];
//    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
//    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
//        if ( !error && [response routes] > 0) {
//            MKRoute *route = [[response routes] objectAtIndex:0];
//            NSString *text = [NSString stringWithFormat:@"It will take: %f hours",route.expectedTravelTime / 3600];
//            self.directionsTextView.text = text;
//        }
//    }];
//}
//
//-(void)getDirectionsAuto{
//    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
//    [request setSource:[MKMapItem mapItemForCurrentLocation]];
//    MKPlacemark *mkDest = [[MKPlacemark alloc] initWithCoordinate:self.userDestination.coordinate addressDictionary:nil];
//    [request setDestination:[[MKMapItem alloc] initWithPlacemark:mkDest]];
//    [request setTransportType:MKDirectionsTransportTypeAutomobile];
//    [request setRequestsAlternateRoutes:NO];
//    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
//    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
//        if ( !error && [response routes] > 0) {
//            MKRoute *route = [[response routes] objectAtIndex:0];
//            NSLog(@"The route: %f",route.distance);
//            NSString *text = [NSString stringWithFormat:@"It will take: %f hours",route.expectedTravelTime / 3600];
//            self.directionsTextView.text = text;
//        }
//    }];
//}


- (IBAction)segmentedControl:(id)sender {

    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self calculateTheETAForTheEventBasedOnTransit:@"driving" withCompletion:^(NSDictionary *location) {
                NSLog(@"Location: %@", location);
            }];
            break;
        case 1:
            [self calculateTheETAForTheEventBasedOnTransit:@"walking" withCompletion:^(NSDictionary *location) {
                NSLog(@"Location: %@", location);
            }];
            break;
        case 2:
            [self calculateTheETAForTheEventBasedOnTransit:@"bicycling" withCompletion:^(NSDictionary *location) {
                NSLog(@"Location: %@", location);
            }];
            break;
        case 3:
            [self calculateTheETAForTheEventBasedOnTransit:@"transit" withCompletion:^(NSDictionary *location) {
                NSLog(@"Location: %@", location);
            }];
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
    [self calculateTheETAForTheEventBasedOnTransit:@"transit" withCompletion:^(NSDictionary *location) {
        NSLog(@"Location: %@", location);
//        self.directionsTextView.text = location objectForKey:<#(id)#>
    }];

}


-(void)calculateTheETAForTheEventBasedOnTransit:(NSString *)transit withCompletion:(void (^)(NSDictionary *))complete{

    CLLocation *userLocation = self.applicationDelegate.userLocationManager.location;
    NSString *google = @"https://maps.googleapis.com/maps/api/directions/json?origin=";
    NSString *currentLatitude = [NSString stringWithFormat:@"%f,",userLocation.coordinate.latitude];
    NSString *currentLongitude = [NSString stringWithFormat:@"%f",userLocation.coordinate.longitude];
    NSString *destination = [NSString stringWithFormat: @"&destination="];
    NSString *latitude = [NSString stringWithFormat:@"%@,",[self.eventDestination objectForKey:@"lat"]];
    NSString *longitude = [NSString stringWithFormat:@"%@",[self.eventDestination objectForKey:@"long"]];
    NSString *apiAccessKeyURL = [NSString stringWithFormat:@"&waypoints=optimize:true&key=%@",apiAccessKey];
    NSString *arrivalTime = [NSString stringWithFormat:@"&arrival_time=1415133552"];
    NSString *modeOfTransportation = [NSString stringWithFormat:@"&mode=%@",transit];

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
