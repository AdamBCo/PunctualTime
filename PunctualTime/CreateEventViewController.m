//
//  NewViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/4/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "CreateEventViewController.h"
#import "EventController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "LocationSearchController.h"
#import "SearchTableViewController.h"
#import "Event.h"
#import <MapKit/MapKit.h>

static NSString* SEG_ZERO = @"driving";
static NSString* SEG_ONE = @"walking";
static NSString* SEG_TW0 = @"bicycling";
static NSString* SEG_THREE = @"transit";

@interface CreateEventViewController () <UISearchBarDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property AppDelegate *applicationDelegate;
@property MKPointAnnotation *userDestination;
@property NSArray *sourceLocations;
@property NSArray *destinationLocations;
@property NSString *transportationType;
@property LocationInfo *locationInfo;
@property EventController *sharedEventController;
@property LocationSearchController *locationSearchController;

@end


@implementation CreateEventViewController

#pragma mark - Private Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationSearchController = [LocationSearchController new];
    self.applicationDelegate = [UIApplication sharedApplication].delegate;
    self.datePicker.minimumDate = [NSDate date];
    self.sharedEventController = [EventController sharedEventController];
    self.nameTextField.delegate = self;
    self.transportationType = SEG_ZERO;
}

- (IBAction)onSaveEventButtonPressed:(id)sender
{
    Event *newEvent = [[Event alloc] initWithEventName:self.nameTextField.text
                                       startingAddress:self.applicationDelegate.userLocationManager.location.coordinate
                                         endingAddress:self.locationInfo.locationCoordinates
                                           arrivalTime:self.datePicker.date
                                    transportationType:self.transportationType];

    __unsafe_unretained typeof(self) weakSelf = self;
    [newEvent makeLocalNotificationWithCategoryIdentifier:kThirtyMinuteWarning completion:^(NSError* error)
    {
        if (error)
        {
            NSLog(@"Error making notification: %@", error.userInfo);
            [self makeAlert];
        }
        else
        {
            [weakSelf.sharedEventController addEvent:newEvent];
            [weakSelf resetTextFields];
        }
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
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

    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
            self.transportationType = SEG_ZERO;
            break;
        case 1:
            self.transportationType = SEG_ONE;
            break;
        case 2:
            self.transportationType = SEG_TW0;
            break;
        case 3:
            self.transportationType = SEG_THREE;
            break;

        default:
            break;
    }
}

- (void)makeAlert
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Event not created, sorry!"
                                                                       message:@"There was a network problem or the selected destination and transportation are incompatible. Please try again."
                                                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            self.locationInfo = nil;
                                                            self.locationNameLabel.text = @"";
                                                            self.addressLabel.text = @"";
                                                        }];
    [alertView addAction:alertAction];
    [self presentViewController:alertView animated:YES completion:^{}];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.nameTextField resignFirstResponder];
}

-(IBAction)unwindFromSearchTableViewController:(UIStoryboardSegue *)segue
{
    SearchTableViewController *viewController = segue.sourceViewController;
    self.locationInfo = viewController.locationInfo;
    [self.applicationDelegate.userLocationManager updateLocation];
    self.locationNameLabel.text = self.locationInfo.name;
    self.addressLabel.text = self.locationInfo.address;
}

@end
