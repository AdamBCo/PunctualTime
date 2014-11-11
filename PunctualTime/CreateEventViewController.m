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
@property EventManager *sharedEventController;
@property LocationSearchController *locationSearchController;
@property NSString* initialNotificationCategory;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property MKPointAnnotation *mapAnnotation;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property UITextView *animatedTextView;
@property BOOL isMapExpanded;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@property UIView *blackView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;


@end


@implementation CreateEventViewController

#pragma mark - Private Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationSearchController = [LocationSearchController new];
    self.applicationDelegate = [UIApplication sharedApplication].delegate;
    self.datePicker.minimumDate = [NSDate date];
    self.sharedEventController = [EventManager sharedEventManager];
    self.textView.delegate = self;
    self.transportationType = SEG_ZERO;


    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];

    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:effect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:blurView.bounds];

    blurView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, ([[UIScreen mainScreen] applicationFrame].size.height)+400);
    [self.backgroundImage addSubview:blurView];
    [blurView.contentView addSubview:vibrancyEffectView];


    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];

    self.blackView = [[UIView alloc] init];
    self.blackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.blackView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, ([[UIScreen mainScreen] applicationFrame].size.height));
    [self.blackView addGestureRecognizer:tap];


    self.animatedTextView = [UITextView new];
    self.animatedTextView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, 96);
    [self.animatedTextView setFont:[UIFont systemFontOfSize:32]];
    self.animatedTextView.backgroundColor = [UIColor whiteColor];
    self.animatedTextView.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);

}



-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

    

//    self.backgroundImage.animationImages = [NSArray arrayWithObjects:
//                                            [UIImage imageNamed:@"frame_001"],
//                                            [UIImage imageNamed:@"frame_002"],
//                                            [UIImage imageNamed:@"frame_003"],
//                                            [UIImage imageNamed:@"frame_004"],
//                                            [UIImage imageNamed:@"frame_005"],
//                                            [UIImage imageNamed:@"frame_006"],
//                                            [UIImage imageNamed:@"frame_007"],
//                                            [UIImage imageNamed:@"frame_008"],
//                                            [UIImage imageNamed:@"frame_009"],
//                                            [UIImage imageNamed:@"frame_010"],
//                                            [UIImage imageNamed:@"frame_011"],
//                                            [UIImage imageNamed:@"frame_012"],
//                                            [UIImage imageNamed:@"frame_013"],
//                                            [UIImage imageNamed:@"frame_014"],
//                                            [UIImage imageNamed:@"frame_015"],
//                                            [UIImage imageNamed:@"frame_016"],
//                                            [UIImage imageNamed:@"frame_017"],
//                                            [UIImage imageNamed:@"frame_018"],
//                                            [UIImage imageNamed:@"frame_019"],
//                                            [UIImage imageNamed:@"frame_020"],
//                                            [UIImage imageNamed:@"frame_021"],
//                                            [UIImage imageNamed:@"frame_022"],
//                                            [UIImage imageNamed:@"frame_023"],
//                                            [UIImage imageNamed:@"frame_024"],
//                                            [UIImage imageNamed:@"frame_025"],
//                                            [UIImage imageNamed:@"frame_026"],
//                                            [UIImage imageNamed:@"frame_027"],
//                                            [UIImage imageNamed:@"frame_028"],
//                                            [UIImage imageNamed:@"frame_029"],
//                                            [UIImage imageNamed:@"frame_030"],
//                                            [UIImage imageNamed:@"frame_031"],
//                                            [UIImage imageNamed:@"frame_032"],
//                                            [UIImage imageNamed:@"frame_033"],
//                                            [UIImage imageNamed:@"frame_034"],
//                                            [UIImage imageNamed:@"frame_035"],
//                                            [UIImage imageNamed:@"frame_036"],
//                                            [UIImage imageNamed:@"frame_037"],
//                                            [UIImage imageNamed:@"frame_038"],
//                                            [UIImage imageNamed:@"frame_039"],
//                                            [UIImage imageNamed:@"frame_040"],
//                                            [UIImage imageNamed:@"frame_041"],
//                                            [UIImage imageNamed:@"frame_042"],
//                                            [UIImage imageNamed:@"frame_043"],
//                                            [UIImage imageNamed:@"frame_044"],
//                                            [UIImage imageNamed:@"frame_045"],
//                                            [UIImage imageNamed:@"frame_046"],
//                                            [UIImage imageNamed:@"frame_047"],
//                                            [UIImage imageNamed:@"frame_048"],
//                                            [UIImage imageNamed:@"frame_049"],
//                                            [UIImage imageNamed:@"frame_050"],
//                                            [UIImage imageNamed:@"frame_051"],
//                                            [UIImage imageNamed:@"frame_052"],
//                                            [UIImage imageNamed:@"frame_053"],
//                                            [UIImage imageNamed:@"frame_054"],
//                                            [UIImage imageNamed:@"frame_055"],
//                                            [UIImage imageNamed:@"frame_056"],
//                                            [UIImage imageNamed:@"frame_057"],
//                                            [UIImage imageNamed:@"frame_058"],
//                                            [UIImage imageNamed:@"frame_059"],
//                                            [UIImage imageNamed:@"frame_060"],
//                                            [UIImage imageNamed:@"frame_061"],
//                                            [UIImage imageNamed:@"frame_062"],
//                                            [UIImage imageNamed:@"frame_063"],
//                                            [UIImage imageNamed:@"frame_064"],
//                                            [UIImage imageNamed:@"frame_065"],
//                                            [UIImage imageNamed:@"frame_066"],
//                                            [UIImage imageNamed:@"frame_067"],
//                                            [UIImage imageNamed:@"frame_068"],
//                                            [UIImage imageNamed:@"frame_069"],
//                                            [UIImage imageNamed:@"frame_070"],
//                                            nil];
//    self.backgroundImage.animationDuration = 1.0f;
//    self.backgroundImage.animationRepeatCount = 0;
//    [self.backgroundImage startAnimating];



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
                     completion:^(BOOL finished){
                         if(self.isMapExpanded == YES){
                             MKPointAnnotation *point = [MKPointAnnotation new];
                             point.coordinate = self.locationInfo.locationCoordinates;
                             [self.mapView addAnnotation:point];
                         }
                         nil;
                     }];
}



-(void)textViewDidBeginEditing:(UITextView *)textView{

    self.animatedTextView.alpha = 0;

        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.scrollView addSubview:self.blackView];
                             [self.blackView addSubview:self.animatedTextView];
                             self.animatedTextView.text = self.textView.text;
                             self.animatedTextView.textAlignment = NSTextAlignmentCenter;
                             self.animatedTextView.alpha = 1;
                             self.blackView.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             NSLog(@"GOOGLE");
                         }];
}

-(void)dismissKeyboard {
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.textView resignFirstResponder];
                         self.blackView.alpha = 0;
                         self.navigationController.navigationBar.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         [self.blackView removeFromSuperview];
                     }];

}


- (IBAction)onSaveEventButtonPressed:(id)sender
{
    Event *newEvent = [[Event alloc] initWithEventName:self.nameTextField.text
                                       startingAddress:self.applicationDelegate.userLocationManager.location.coordinate
                                         endingAddress:self.locationInfo.locationCoordinates
                                           arrivalTime:self.datePicker.date
                                    transportationType:self.transportationType];

    [newEvent makeLocalNotificationWithCategoryIdentifier:self.initialNotificationCategory completion:^(NSError* error)
    {
        if (error)
        {
            NSLog(@"Error making notification: %@", error.userInfo);
            [self makeAlert];
        }
        else
        {
            [self.sharedEventController addEvent:newEvent];
            [self resetTextFields];
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
