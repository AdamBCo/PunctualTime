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
#import <MapKit/MapKit.h>

@interface NewViewController () <UISearchBarDelegate, UITextFieldDelegate>
@property (nonatomic, strong) AppDelegate *applicationDelegate;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;


@property MKPointAnnotation *userDestination;
@property NSArray *sourceLocations;
@property NSArray *destinationLocations;
@property NSString *transportationType;

@property LocationInfo *locationInfo;

@property EventController *sharedEventController;

@property LocationSearchController *locationSearchController;

@end

@implementation NewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationSearchController = [LocationSearchController new];
    self.applicationDelegate = [UIApplication sharedApplication].delegate;
    self.datePicker.minimumDate = [NSDate date];
    self.sharedEventController = [EventController sharedEventController];
    self.nameTextField.delegate = self;
}



- (IBAction)onSaveEventButtonPressed:(id)sender {

    Event *newEvent = [[Event alloc] initWithEventName:self.nameTextField.text
                                       startingAddress:self.applicationDelegate.userLocationManager.location.coordinate
                                         endingAddress:self.locationInfo.locationCoordinates
                                           arrivalTime:self.datePicker.date
                                    transportationType:self.transportationType];

    __unsafe_unretained typeof(self) weakSelf = self; // Using this in the block to prevent a retain cycle
    [self.sharedEventController addEvent:newEvent withCompletion:
     ^{
         [weakSelf resetTextFields];
     }];

    [newEvent makeLocalNotificationWithCategoryIdentifier:kThirtyMinuteWarning];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)resetTextFields
{
    self.nameTextField.text = @"";
    self.datePicker.date = [NSDate date];
    self.locationNameLabel.text = @"";
    self.addressLabel.text = @"";
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
    self.locationNameLabel.text = self.locationInfo.name;
    self.addressLabel.text = self.locationInfo.address;
}

@end
