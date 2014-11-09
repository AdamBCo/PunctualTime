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

@interface CreateEventViewController () <UISearchBarDelegate, UITextViewDelegate>

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

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property MKPointAnnotation *mapAnnotation;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property BOOL isMapExpanded;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@property UIView *blackView;


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
    self.textView.delegate = self;
    self.transportationType = SEG_ZERO;


    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
    blurView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, ([[UIScreen mainScreen] applicationFrame].size.height)+400);
    [self.view addSubview:blurView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];

    self.blackView = [[UIView alloc] init];
    self.blackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.blackView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, ([[UIScreen mainScreen] applicationFrame].size.height));
    [self.blackView addGestureRecognizer:tap];

}



-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

    if (self.locationInfo.name.length > 0) {
        MKPointAnnotation *point = [MKPointAnnotation new];
        point.coordinate = self.locationInfo.locationCoordinates;
        [self.mapView addAnnotation:point];

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

    self.view.backgroundColor = [UIColor redColor];
    [UIView animateWithDuration:100
                          delay:0.5
                        options: UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.view.backgroundColor = [UIColor greenColor];
    } completion:^(BOOL finished)
     {
         NSLog(@"Hello");
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
                     completion:nil];
}



-(void)textViewDidBeginEditing:(UITextView *)textView{
        [UIView animateWithDuration:1.0
                              delay:0.2
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{

                                [self.scrollView addSubview:self.blackView];
                                [self.blackView addSubview:self.textView];
                                self.textView.backgroundColor = [UIColor whiteColor];
                                 self.scrollView.scrollEnabled = NO;
                                [self.view layoutIfNeeded];

                         }
                         completion:nil];
}

-(void)dismissKeyboard {
    [self.textView resignFirstResponder];
    [self.blackView removeFromSuperview];
    [self.view layoutIfNeeded];

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
