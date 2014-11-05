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
#import "Constants.h"
#import "LocationSearchController.h"
#import "SearchTableViewController.h"
#import "Event.h"
#import "ETAController.h"
#import <MapKit/MapKit.h>

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
@property NSString *transportationType;

@property LocationInfo *locationInfo;

@property EventController *sharedEventController;
@property ETAController *etaController;

@property LocationSearchController *locationSearchController;

@end

@implementation NewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationSearchController = [LocationSearchController new];
    self.applicationDelegate = [UIApplication sharedApplication].delegate;
    self.datePicker.minimumDate = [NSDate date];
    self.sharedEventController = [EventController sharedEventController];
    self.etaController = [ETAController new];
}


- (IBAction)onSaveEventButtonPressed:(id)sender {

    Event *newEvent = [[Event alloc] initWithEventName:self.nameTextField.text
                                       startingAddress:self.applicationDelegate.userLocationManager.location.coordinate
                                         endingAddress:self.locationInfo.locationCoordinates
                                           arrivalTime:self.datePicker.date
                                    transportationType:self.transportationType];
    NSLog(@"Log %@",newEvent.transportationType);


    [self.etaController calculateETAforEvent:newEvent withCompletion:^(NSDictionary *result) {
        NSLog(@"Result: %@",result);
    }];

    __unsafe_unretained typeof(self) weakSelf = self; // Using this in the block to prevent a retain cycle
    [self.sharedEventController addEvent:newEvent withCompletion:
     ^{
         [weakSelf resetTextFields];
     }];

    [newEvent makeLocalNotificationWithCategoryIdentifier:kThirtyMinuteWarning];
}


- (void)resetTextFields
{
    self.nameTextField.text = @"";
    self.datePicker.date = [NSDate date];
}

- (IBAction)segmentedControl:(id)sender {

    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            self.transportationType = @"driving";
            break;
        case 1:
            self.transportationType = @"walking";
            break;
        case 2:
            self.transportationType = @"bicycling";
            break;
        case 3:
            self.transportationType = @"transit";
            break;

        default:
            break;
    }
}


-(IBAction)unwindFromSearchTableViewController:(UIStoryboardSegue *)segue{
    SearchTableViewController *viewController = segue.sourceViewController;
    self.locationInfo = viewController.locationInfo;
    [self.applicationDelegate.userLocationManager updateLocation];
}

@end
