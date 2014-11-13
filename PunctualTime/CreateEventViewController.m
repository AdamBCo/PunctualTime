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
#import "Event.h"
#import "SIAlertView.h"
#import <MapKit/MapKit.h>
#import "ModesOfTransportationViewController.h"

@interface CreateEventViewController () <UISearchBarDelegate, UITextFieldDelegate, ModesOfTransportationDelegate>

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
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
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.recurrenceOption = PTEventRecurrenceOptionNone;
    self.isDatePickerExpanded = NO;
    self.datePickerHeightConstraint.constant = 0;
    self.datePicker.alpha = 0;

    self.blackView = [[UIView alloc] initWithFrame: self.view.bounds];


    [self.view addSubview:self.blackView];


}

- (void)viewDidLayoutSubviews {

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

-(void)expandDatePicker {

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         if (self.isDatePickerExpanded == YES) {
                             self.datePickerHeightConstraint.constant = 162;
                             self.datePicker.alpha = 1.0;
                             [self.view layoutIfNeeded];
                             
                         } else {
                             self.datePickerHeightConstraint.constant = 0;
                             self.datePicker.alpha = 0.0;
                            [self.view layoutIfNeeded];
                         }
                     }
                     completion:^(BOOL finished){

                         [self.datePicker addTarget:self
                                    action:@selector(datePickerValueChanged:)
                          forControlEvents:UIControlEventValueChanged];
                     }];

}

- (void)datePickerValueChanged:(id)sender{

    [UIView animateWithDuration:0.5
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
    self.titleTextField.text = @"Event Title";
    self.datePicker.date = [NSDate date];
    self.locationNameLabel.text = @"";
}


#warning hook up notification buttons from storyboard and set tags appropriately
- (IBAction)onNotificationButtonPressed:(UIButton *)button
{
    switch (button.tag)
    {
        case 0:
            self.initialNotificationCategory = SIXTY_MINUTE_WARNING;
            break;
        case 1:
            self.initialNotificationCategory = THIRTY_MINUTE_WARNING;
            break;
        case 2:
            self.initialNotificationCategory = FIFTEEN_MINUTE_WARNING;
            break;
        case 3:
            self.initialNotificationCategory = TEN_MINUTE_WARNING;
            break;
        case 4:
            self.initialNotificationCategory = FIVE_MINUTE_WARNING;
            break;
        default:
            self.initialNotificationCategory = nil; // Zero minute warning
            break;
    }
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
                              self.locationNameLabel.text = @"";
                              self.addressLabel.text = @"";
                          }];
    [alertView show];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.blackView removeFromSuperview];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.view bringSubviewToFront:self.blackView];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"BackToTheMapSegue"]) {

        [self.titleTextField resignFirstResponder];

    } else if ([segue.identifier isEqualToString:@"ModesOfTransportSegue"]){

        ModesOfTransportationViewController *viewController = segue.destinationViewController;
        viewController.delegate = self;
    }

}

-(IBAction)unwindFromSearchTableViewController:(UIStoryboardSegue *)segue
{
    SearchTableViewController *viewController = segue.sourceViewController;
    self.locationInfo = viewController.locationInfo;
    [self.applicationDelegate.userLocationManager updateLocation];
    self.locationNameLabel.text = self.locationInfo.name;
    self.addressLabel.text = self.locationInfo.address;
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
