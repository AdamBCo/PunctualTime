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
#import "Event.h"
#import "SIAlertView.h"
#import "LiveFrost.h"


#import "RepeatTableViewController.h"
#import "AlertTableViewController.h"
#import "TransportationTableViewController.h"

@interface CreateEventViewController () <UISearchBarDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

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

@property UITextView *animatedTextView;
@property BOOL isMapExpanded;



@property LFGlassView* blurView;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

typedef NS_ENUM(NSUInteger, TableViewSection){
    TableViewEventTitleSection,
    TableViewDateSection,
    TableViewTransportationSection,
    TableViewSectionCount
};


@implementation CreateEventViewController

#pragma mark - Private Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recurrenceOption = PTEventRecurrenceOptionNone;
    self.initialNotificationCategory = FIVE_MINUTE_WARNING;
    self.transportationType = TRANSPO_DRIVING;
    self.selectedDate = [NSDate date];

    //The arrow
    [self.navigationController.navigationBar.subviews.lastObject setTintColor:[UIColor whiteColor]];

    //Cancel
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    self.locationSearchController = [LocationSearchController new];
    self.applicationDelegate = [UIApplication sharedApplication].delegate;
    self.sharedEventManager = [EventManager sharedEventManager];
    self.titleTextField.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return TableViewSectionCount;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case TableViewEventTitleSection:
            return 2;
            break;
        case TableViewDateSection:
            return 3;
            break;
        case TableViewTransportationSection:
            return 1;
            break;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case TableViewEventTitleSection:
            if ([indexPath row] == 1) {
                [self performSegueWithIdentifier:@"ToSearchViewSegue" sender:self];
            }
            break;
        case TableViewDateSection:
            if ([indexPath row] == 1) {
                [self performSegueWithIdentifier:@"RepeatTableViewSegue" sender:self];
            } else if ([indexPath row] == 2) {
                [self performSegueWithIdentifier:@"AlertTableViewSegue" sender:self];
            }
            break;
        case TableViewTransportationSection:
            [self performSegueWithIdentifier:@"TransporationTableViewSegue" sender:self];
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    switch (indexPath.section) {
        case TableViewEventTitleSection: {
            if ([indexPath row] == 0) {
                UITextField *titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width*.05, 0, self.tableView.frame.size.width*.95, cell.contentView.frame.size.height)];
                titleTextField.placeholder = @"Title";
                [cell.contentView addSubview:titleTextField];
            } else {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
                cell.textLabel.text = @"Location";
                cell.detailTextLabel.text = @"Address";
            }
            break;
        }
        case TableViewDateSection:{
            if ([indexPath row] == 0) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
                cell.textLabel.text = @"Starts";
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.timeZone = [NSTimeZone localTimeZone];
                dateFormatter.dateStyle = NSDateFormatterMediumStyle;
                dateFormatter.timeStyle = NSDateFormatterShortStyle;
                cell.detailTextLabel.text = [dateFormatter stringFromDate:self.selectedDate];
                
            } else if ([indexPath row] == 1) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
                cell.textLabel.text = @"Repeat";
                
                if (self.recurrenceOption == PTEventRecurrenceOptionNone) {
                    cell.detailTextLabel.text = @"None";
                } else if (self.recurrenceOption == PTEventRecurrenceOptionDaily){
                    cell.detailTextLabel.text = @"Daily";
                } else if (self.recurrenceOption == PTEventRecurrenceOptionWeekly){
                    cell.detailTextLabel.text = @"Weekly";
                } else if (self.recurrenceOption == PTEventRecurrenceOptionWeekdays){
                    cell.detailTextLabel.text = @"Weekdays";
                }
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if ([indexPath row] == 2){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
                cell.textLabel.text = @"Alert";
                
                if ([self.initialNotificationCategory isEqualToString:FIVE_MINUTE_WARNING]) {
                    cell.detailTextLabel.text = @"5 minutes before";
                } else if ([self.initialNotificationCategory isEqualToString:TEN_MINUTE_WARNING]){
                    cell.detailTextLabel.text = @"10 minutes before";
                } else if ([self.initialNotificationCategory isEqualToString:FIFTEEN_MINUTE_WARNING]){
                    cell.detailTextLabel.text = @"15 minutes before";
                } else if ([self.initialNotificationCategory isEqualToString:THIRTY_MINUTE_WARNING]){
                    cell.detailTextLabel.text = @"30 minutes before";
                }else if ([self.initialNotificationCategory isEqualToString:SIXTY_MINUTE_WARNING]){
                    cell.detailTextLabel.text = @"60 minutes before";
                }
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        case TableViewTransportationSection:{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
            cell.textLabel.text = @"Transport Type";
            if ([self.transportationType isEqualToString:TRANSPO_WALKING]) {
                cell.detailTextLabel.text = @"Walk";
            } else if ([self.transportationType isEqualToString:TRANSPO_DRIVING]){
                cell.detailTextLabel.text = @"Drive";
            } else if ([self.transportationType isEqualToString:TRANSPO_BIKING]){
                cell.detailTextLabel.text = @"Bike";
            } else if ([self.transportationType isEqualToString:TRANSPO_TRANSIT]){
                cell.detailTextLabel.text = @"Transit";
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        }
    }
    return cell;
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.titleTextField resignFirstResponder];
}

- (IBAction)onCloseButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
            [self performSegueWithIdentifier:@"UnwindFromCreateEventVC" sender:self];
        }
    }];
}

//- (void)enableSaveButtonIfReady // Only enable Save button if user has finished creating Event
//{
//    if (![self.titleTextField.text isEqualToString:@""] &&
//        self.selectedDate.timeIntervalSince1970 > [NSDate date].timeIntervalSince1970 &&
//        self.locationInfo != nil)
//    {
//        self.saveButton.enabled = YES;
//    }
//    else
//    {
//        [self.saveButton setTitle:@"Need:" forState:UIControlStateDisabled];
//        self.saveButton.enabled = NO;
//
//        if ([self.titleTextField.text isEqualToString:@""])
//        {
//            [self.saveButton setTitle:[[self.saveButton titleForState:UIControlStateDisabled ] stringByAppendingString:@" Name"] forState:UIControlStateDisabled];
//        }
//        if (self.selectedDate.timeIntervalSince1970 < [NSDate date].timeIntervalSince1970)
//        {
//            [self.saveButton setTitle:[[self.saveButton titleForState:UIControlStateDisabled ] stringByAppendingString:@" Date"] forState:UIControlStateDisabled];
//        }
//        if (self.locationInfo == nil)
//        {
//            [self.saveButton setTitle:[[self.saveButton titleForState:UIControlStateDisabled ] stringByAppendingString:@" Destination"] forState:UIControlStateDisabled];
//        }
//    }
//}

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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 15) ? NO : YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToSearchViewSegue"])
    {
        [self.titleTextField resignFirstResponder];
    }
    else if ([segue.identifier isEqualToString:@"DatePickerVC"])
    {
        MaxDatePickerViewController* datePickerVC = segue.destinationViewController;
        [datePickerVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        datePickerVC.selectedDate = self.selectedDate ?: datePickerVC.selectedDate;

        self.blurView = [[LFGlassView alloc] initWithFrame:self.view.bounds];
        self.blurView.alpha = 0.0;
        [self.view addSubview:self.blurView];

        [UIView animateWithDuration:0.3 animations:^{
            self.blurView.alpha = 1.0;
        }];
    } else if ([segue.identifier isEqualToString:@"RepeatTableViewSegue"]){
        RepeatTableViewController *viewController = segue.destinationViewController;
        viewController.selectedRecurrenceOption = self.recurrenceOption;
    } else if ([segue.identifier isEqualToString:@"AlertTableViewSegue"]){
        AlertTableViewController *viewController = segue.destinationViewController;
        viewController.reminderSelected = self.initialNotificationCategory;
    } else if ([segue.identifier isEqualToString:@"TransporationTableViewSegue"]){
        TransportationTableViewController *viewController = segue.destinationViewController;
        viewController.selectedMethodOfTransportation = self.transportationType;
    }
}

- (IBAction)unwindFromSearchViewController:(UIStoryboardSegue *)segue
{
    SearchViewController *viewController = segue.sourceViewController;
    self.locationInfo = viewController.locationInfo;
    
    NSIndexPath *locationCell = [NSIndexPath indexPathForRow:1 inSection:TableViewEventTitleSection];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:locationCell];
    cell.textLabel.text = self.locationInfo.name;
    cell.detailTextLabel.text = self.locationInfo.address;
}

- (IBAction)unwindFromRepeatTableViewController:(UIStoryboardSegue *)segue
{
    RepeatTableViewController *viewController = segue.sourceViewController;
    self.recurrenceOption = viewController.selectedRecurrenceOption;
    [self.tableView reloadData];
}

#pragma mark - AlertTableViewController
- (IBAction)unwindFromAlertTableViewController:(UIStoryboardSegue *)segue
{
    AlertTableViewController *viewController = segue.sourceViewController;
    self.initialNotificationCategory = viewController.reminderSelected;
    [self.tableView reloadData];
}

- (IBAction)unwindFromTransportationTypeTableViewController:(UIStoryboardSegue *)segue
{
    TransportationTableViewController *viewController = segue.sourceViewController;
    self.transportationType = viewController.selectedMethodOfTransportation;
    [self.tableView reloadData];
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
    }

    [UIView animateWithDuration:0.3 animations:^{
        self.blurView.alpha = 0.0;
    }completion:^(BOOL finished) {
        [self.blurView removeFromSuperview];
    }];
}

@end
