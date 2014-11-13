//
//  NewViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/4/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "CreateEventViewController.h"
#import "EventManager.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "LocationSearchController.h"
#import "SearchTableViewController.h"
#import "RemindersViewController.h"
#import "Event.h"
#import "SIAlertView.h"
#import <MapKit/MapKit.h>
#import "ModesOfTransportationViewController.h"

@interface CreateEventViewController () <UISearchBarDelegate, UITextFieldDelegate, ModesOfTransportationDelegate, RemindersViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property AppDelegate *applicationDelegate;
@property MKPointAnnotation *userDestination;
@property NSArray *sourceLocations;
@property NSArray *destinationLocations;
@property NSString *transportationType;
@property LocationInfo *locationInfo;
@property EventManager *sharedEventManager;
@property LocationSearchController *locationSearchController;
@property NSString* initialNotificationCategory;
@property PTEventRecurrenceOption recurrenceOption;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property MKPointAnnotation *mapAnnotation;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property UITextView *animatedTextView;
@property BOOL isMapExpanded;
@property BOOL isDatePickerExpanded;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@property UIView *blackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *datePickerButton;


@end


@implementation CreateEventViewController

#pragma mark - Private Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationSearchController = [LocationSearchController new];
    self.applicationDelegate = [UIApplication sharedApplication].delegate;
    self.datePicker.minimumDate = [NSDate date];
    self.sharedEventManager = [EventManager sharedEventManager];
    self.titleTextField.delegate = self;
    self.transportationType = TRANSPO_DRIVING;
    self.datePicker.backgroundColor = [UIColor colorWithRed:1.000 green:0.486 blue:0.071 alpha:1.000];
    self.recurrenceOption = PTEventRecurrenceOptionNone;
    self.isDatePickerExpanded = NO;
    self.datePickerHeightConstraint.constant = 0;
    self.datePicker.alpha = 0;

}


-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];


    if (self.locationInfo.name.length > 0) {
        MKCoordinateRegion mapRegion;
        mapRegion.center = self.locationInfo.locationCoordinates;
        mapRegion.span = MKCoordinateSpanMake(0.005, 0.005);
        
        [self.mapView setRegion:mapRegion animated: NO];
        self.isMapExpanded = YES;
        [self expandMap];
    } else if (self.locationInfo.name.length == 0) {
        self.isMapExpanded = NO;
        [self expandMap];
    }

}

- (IBAction)onTImeButtonPressed:(id)sender {
    self.isDatePickerExpanded = !self.isDatePickerExpanded;
    [self expandDatePicker];


}

-(void)expandDatePicker
{
    if (self.isDatePickerExpanded == YES) {
        self.datePickerHeightConstraint.constant = 162;
        self.datePicker.alpha = 1.0;
    } else {
        self.datePickerHeightConstraint.constant = 0;
        self.datePicker.alpha = 0.0;
    }

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                         dateFormatter.timeZone = [NSTimeZone localTimeZone];
                         [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm"];
                         [self.datePickerButton setTitle:[dateFormatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
                         [self.datePickerButton setTintColor:[UIColor redColor]];
                     }];


}

- (void) expandMap{
    [UIView animateWithDuration:1.0
                          delay:0.2
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         if(self.isMapExpanded == YES){
                             self.mapViewHeightConstraint.constant = 115;
                             [self.view layoutIfNeeded];

                         }
                         else if(self.isMapExpanded == NO){
                             self.mapViewHeightConstraint.constant = 0;

                         }
                     }
                     completion:^(BOOL finished){
                         if(self.isMapExpanded == YES){
                             MKPointAnnotation *point = [MKPointAnnotation new];
                             point.coordinate = self.locationInfo.locationCoordinates;
                             [self.mapView addAnnotation:point];
                         }
                         nil;
                     }];
}

- (IBAction)onSaveEventButtonPressed:(id)sender
{
    Event *newEvent = [[Event alloc] initWithEventName:self.titleTextField.text
                                       startingAddress:self.applicationDelegate.userLocationManager.location.coordinate
                                         endingAddress:self.locationInfo.locationCoordinates
                                           arrivalTime:self.datePicker.date
                                    transportationType:self.transportationType
                                  notificationCategory:self.initialNotificationCategory
                                            recurrence:self.recurrenceOption];

    [newEvent makeLocalNotificationWithCategoryIdentifier:self.initialNotificationCategory completion:^(NSError* error)
    {
        if (error)
        {
            NSLog(@"Error making notification: %@", error.userInfo);
            [self makeAlertForErrorCode:error.code errorUserInfo:error.userInfo];
        }
        else
        {
            [self.sharedEventManager addEvent:newEvent];
            [self resetTextFields];
        }
    }];
}



- (void)resetTextFields
{
    self.titleTextField.text = @"";
    self.datePicker.date = [NSDate date];
}

#warning hook up recurrence buttons from storyboard and set tags appropriately
- (IBAction)onRecurrenceButtonPressed:(UIButton *)button
{
    if (button.tag == self.recurrenceOption) // User is deselecting currently selected option
    {
        self.recurrenceOption = PTEventRecurrenceOptionNone;
        //TODO: revert button image to deselected state
    }
    else
    {
        switch (button.tag)
        {
            case 0:
                self.recurrenceOption = PTEventRecurrenceOptionDaily;
                // Set image to selected state
                break;
            case 1:
                self.recurrenceOption = PTEventRecurrenceOptionWeekdays;
                // Set image to selected state
                break;
            case 2:
                self.recurrenceOption = PTEventRecurrenceOptionWeekly;
                // Set image to selected state
                break;
            default:
                self.recurrenceOption = PTEventRecurrenceOptionNone;
                break;
        }
    }
}

- (void)makeAlertForErrorCode:(PTEventCreationErrorCode)errorCode errorUserInfo:(NSDictionary *)userInfo
{
    NSString* alertTitle;
    NSString* alertMessage;

    switch (errorCode)
    {
        case PTEventCreationErrorCodeImpossibleEvent:
            alertTitle = @"You're late!";
            alertMessage = [NSString stringWithFormat:@"You needed to leave %@ minutes ago. Get going!", userInfo[@"overdue_amount"]];
            break;
        default:
            alertTitle = @"Dangit...";
            alertMessage = @"There was a network problem or the selected destination and transportation are incompatible. Please try again.";
            break;
    }

    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:alertTitle andMessage:alertMessage];
    alertView.backgroundStyle = SIAlertViewBackgroundStyleBlur;
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;

    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              self.locationInfo = nil;
                          }];
    [alertView show];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - RemindersViewControllerDelegate

- (void)reminderSelected:(NSString *)reminderCategory
{
    self.initialNotificationCategory = reminderCategory;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"BackToTheMapSegue"])
    {
        [self.titleTextField resignFirstResponder];
    }
    else if ([segue.identifier isEqualToString:@"ModesOfTransportSegue"])
    {
        ModesOfTransportationViewController *viewController = segue.destinationViewController;
        viewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"RemindersVC"])
    {
        RemindersViewController* remindersVC = segue.destinationViewController;
        remindersVC.delegate = self;
    }

}

-(IBAction)unwindFromSearchTableViewController:(UIStoryboardSegue *)segue
{
    SearchTableViewController *viewController = segue.sourceViewController;
    self.locationInfo = viewController.locationInfo;
    [self.applicationDelegate.userLocationManager updateLocation];
}

#pragma mark - Modes of Transportation


-(void)modeOfTransportationSelected:(NSString *)transportationType
{
    self.transportationType = transportationType;
    NSLog(@"Transportation Type: %@",self.transportationType);
    NSLog(@"The Date: %@",self.datePicker.date);
    NSLog(@"The Locations: %@", self.locationInfo);
}

@end
