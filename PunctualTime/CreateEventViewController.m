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
#import "RecurrenceViewController.h"
#import "Event.h"
#import "SIAlertView.h"
#import <MapKit/MapKit.h>
#import "ModesOfTransportationViewController.h"

@interface CreateEventViewController () <UISearchBarDelegate, UITextFieldDelegate, ModesOfTransportationDelegate, RemindersViewControllerDelegate, RecurrenceViewControllerDelegate>

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
@property (strong, nonatomic) IBOutlet UIButton *saveButton;


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
    self.datePicker.backgroundColor = [UIColor colorWithRed:1.000 green:0.486 blue:0.071 alpha:1.000];
    self.isDatePickerExpanded = NO;
    self.datePickerHeightConstraint.constant = 0;
    self.datePicker.alpha = 0;

    self.blackView = [[UIView alloc] initWithFrame: self.view.bounds];


    [self.view addSubview:self.blackView];


}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

    [self enableSaveButtonIfReady];

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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"the life");
        [self.titleTextField resignFirstResponder];
        [self.blackView removeFromSuperview];
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

                         [self.datePicker addTarget:self
                                    action:@selector(datePickerValueChanged:)
                          forControlEvents:UIControlEventValueChanged];
                     }];
}

- (void)datePickerValueChanged:(id)sender
{
    [self enableSaveButtonIfReady];

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                         dateFormatter.timeZone = [NSTimeZone localTimeZone];
                         dateFormatter.dateStyle = NSDateFormatterMediumStyle;
                         dateFormatter.timeStyle = NSDateFormatterShortStyle;
                         [self.datePickerButton setTitle:[dateFormatter stringFromDate:self.datePicker.date] forState:UIControlStateNormal];
                     }
                     completion:^(BOOL finished){
        
                     }];
}


- (void) expandMap
{
    [UIView animateWithDuration:0.5
                          delay:0.0
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
            [self performSegueWithIdentifier:@"UnwindFromCreateEventVC" sender:self];
        }
    }];
}

- (void)resetTextFields
{
    self.titleTextField.text = @"";
    self.datePicker.date = [NSDate date];
}

- (void)enableSaveButtonIfReady // Only enable Save button if user has finished creating Event
{
    if (![self.titleTextField.text isEqualToString:@""] &&
        self.datePicker.date.timeIntervalSince1970 > [NSDate date].timeIntervalSince1970 &&
        self.locationInfo != nil)
    {
        self.saveButton.enabled = YES;
    }
    else
    {
        self.saveButton.enabled = NO;
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
    [self.blackView removeFromSuperview];
    [self enableSaveButtonIfReady];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.view bringSubviewToFront:self.blackView];
}


#pragma mark - RemindersViewControllerDelegate

- (void)reminderSelected:(NSString *)reminderCategory
{
    self.initialNotificationCategory = reminderCategory;
}


#pragma mark - RecurrenceViewControllerDelegate

- (void)recurrenceSelected:(PTEventRecurrenceOption)recurrenceInterval
{
    self.recurrenceOption = recurrenceInterval;
}


#pragma mark - ModesOfTransportationDelegate

- (void)modeOfTransportationSelected:(NSString *)transportationType
{
    self.transportationType = transportationType;
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
    else if ([segue.identifier isEqualToString:@"RecurrenceVC"])
    {
        RecurrenceViewController* recurrenceVC = segue.destinationViewController;
        recurrenceVC.delegate = self;
    }

}

-(IBAction)unwindFromSearchTableViewController:(UIStoryboardSegue *)segue
{
    SearchTableViewController *viewController = segue.sourceViewController;
    self.locationInfo = viewController.locationInfo;
    [self.applicationDelegate.userLocationManager updateLocation];
    [self enableSaveButtonIfReady];
}

@end
