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
#import "MaxDatePickerViewController.h"
#import "LocationSearchController.h"
#import "SearchViewController.h"
#import "RemindersViewController.h"
#import "RecurrenceViewController.h"
#import "Event.h"
#import "SIAlertView.h"
#import <MapKit/MapKit.h>
#import "ModesOfTransportationViewController.h"
#import "LiveFrost.h"

@interface CreateEventViewController () <UISearchBarDelegate, UITextFieldDelegate, ModesOfTransportationDelegate, RemindersViewControllerDelegate, RecurrenceViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
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
@property NSDate* selectedDate;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property MKPointAnnotation *mapAnnotation;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property UITextView *animatedTextView;
@property BOOL isMapExpanded;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *recurrenceContainerHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *transportationContainerHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *reminderContainerHeight;

@property UIView *blackView;
@property (weak, nonatomic) IBOutlet UIButton *datePickerButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *destinationButton;

@property LFGlassView* blurView;

@end


@implementation CreateEventViewController

#pragma mark - Private Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    //The arrow
    [self.navigationController.navigationBar.subviews.lastObject setTintColor:[UIColor whiteColor]];

    //Cancel
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    self.locationSearchController = [LocationSearchController new];
    self.applicationDelegate = [UIApplication sharedApplication].delegate;
    self.sharedEventManager = [EventManager sharedEventManager];
    self.titleTextField.delegate = self;

    self.blackView = [[UIView alloc] initWithFrame: self.view.bounds];

    [self.view addSubview:self.blackView];
}

-(void)viewWillAppear:(BOOL)animated
{
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

    self.datePickerButton.layer.borderColor = [self.datePickerButton.titleLabel.textColor CGColor];
    self.datePickerButton.layer.borderWidth = 1.0;
    self.destinationButton.layer.borderColor = [self.destinationButton.titleLabel.textColor CGColor];
    self.destinationButton.layer.borderWidth = 1.0;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.titleTextField resignFirstResponder];
    [self.blackView removeFromSuperview];
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
                             NSString *location = [NSString stringWithFormat:@" %@",self.locationInfo.name];
                             self.destinationButton.titleLabel.adjustsFontSizeToFitWidth = TRUE;
                             [self.destinationButton setTitle:location forState:UIControlStateNormal];
                         }
                         nil;
                     }];
}

- (IBAction)onSaveEventButtonPressed:(id)sender
{
    Event *newEvent = [[Event alloc] initWithEventName:self.titleTextField.text
                                         endingAddress:self.locationInfo.locationCoordinates
                                           arrivalTime:self.selectedDate
                                    transportationType:self.transportationType
                                  notificationCategory:self.initialNotificationCategory
                                            recurrence:self.recurrenceOption];

    [newEvent makeLocalNotificationWithCategoryIdentifier:self.initialNotificationCategory completion:^(NSError* error)
    {
        if (error)
        {
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
    [self.datePickerButton setTitle:@"Select date" forState:UIControlStateNormal];
    self.locationInfo = nil;
}

- (void)enableSaveButtonIfReady // Only enable Save button if user has finished creating Event
{
    if (![self.titleTextField.text isEqualToString:@""] &&
        self.selectedDate.timeIntervalSince1970 > [NSDate date].timeIntervalSince1970 &&
        self.locationInfo != nil)
    {
        self.saveButton.enabled = YES;
    }
    else
    {
        [self.saveButton setTitle:@"Need:" forState:UIControlStateDisabled];
        self.saveButton.enabled = NO;

        if ([self.titleTextField.text isEqualToString:@""])
        {
            [self.saveButton setTitle:[[self.saveButton titleForState:UIControlStateDisabled ] stringByAppendingString:@" Name"] forState:UIControlStateDisabled];
        }
        if (self.selectedDate.timeIntervalSince1970 < [NSDate date].timeIntervalSince1970)
        {
            [self.saveButton setTitle:[[self.saveButton titleForState:UIControlStateDisabled ] stringByAppendingString:@" Date"] forState:UIControlStateDisabled];
        }
        if (self.locationInfo == nil)
        {
            [self.saveButton setTitle:[[self.saveButton titleForState:UIControlStateDisabled ] stringByAppendingString:@" Destination"] forState:UIControlStateDisabled];
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
            alertMessage = @"Either we couldn't connect or there is no data for your destination via the selected transportation.";
            break;
    }

    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:alertTitle andMessage:alertMessage];
    alertView.backgroundStyle = SIAlertViewBackgroundStyleBlur;
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;

    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView show];
}


#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.blackView removeFromSuperview];
    [self enableSaveButtonIfReady];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.view bringSubviewToFront:self.blackView];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 15) ? NO : YES;
}


#pragma mark - RemindersViewControllerDelegate

- (void)reminderSelected:(NSString *)reminderCategory
{
    self.initialNotificationCategory = reminderCategory;
}

- (void)reminderButtonHeightWasSet:(CGFloat)height
{
    self.reminderContainerHeight.constant = height;
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

- (void)transportationButtonHeightWasSet:(CGFloat)height
{
    self.transportationContainerHeight.constant = height;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToSearchViewSegue"])
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
    else if ([segue.identifier isEqualToString:@"DatePickerVC"])
    {
        MaxDatePickerViewController* datePickerVC = segue.destinationViewController;
        [datePickerVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        datePickerVC.selectedDate = self.selectedDate ?: [NSDate date];

        self.blurView = [[LFGlassView alloc] initWithFrame:self.view.bounds];
        self.blurView.alpha = 0.0;
        [self.view addSubview:self.blurView];

        [UIView animateWithDuration:0.3 animations:^{
            self.blurView.alpha = 1.0;
        }];
    }
}

- (IBAction)unwindFromSearchViewController:(UIStoryboardSegue *)segue
{
    SearchViewController *viewController = segue.sourceViewController;
    self.locationInfo = viewController.locationInfo;
    [self enableSaveButtonIfReady];
}

- (IBAction)unwindeFromDatePickerViewController:(UIStoryboardSegue *)segue
{
    self.selectedDate = ((MaxDatePickerViewController*)segue.sourceViewController).selectedDate ?: self.selectedDate;

    if (self.selectedDate)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone localTimeZone];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        [self.datePickerButton setTitle:[dateFormatter stringFromDate:self.selectedDate] forState:UIControlStateNormal];
    }

    [self enableSaveButtonIfReady];

    [UIView animateWithDuration:0.3 animations:^{
        self.blurView.alpha = 0.0;
    }completion:^(BOOL finished) {
        [self.blurView removeFromSuperview];
    }];
}

@end
