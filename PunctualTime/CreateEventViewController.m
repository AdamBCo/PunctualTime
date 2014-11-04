//
//  CreateEventViewController.m
//  PunctualTime
//
//  Created by Nathan Hosselton on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "CreateEventViewController.h"
#import "EventController.h"
#import "Event.h"

@interface CreateEventViewController ()

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *startingLocationTextField;
@property (strong, nonatomic) IBOutlet UITextField *endingLocationTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property EventController *sharedEventController;

@end

@implementation CreateEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.datePicker.minimumDate = [NSDate date];
    self.sharedEventController = [EventController sharedEventController];
}

- (IBAction)onSaveEventButtonPressed:(id)sender
{
    Event *newEvent = [[Event alloc] initWithEventName:self.nameTextField.text
                                       startingAddress:self.startingLocationTextField.text
                                         endingAddress:self.endingLocationTextField.text
                                           arrivalTime:self.datePicker.date];

    __unsafe_unretained typeof(self) weakSelf = self; // Using this in the block to prevent a retain cycle
    [self.sharedEventController addEvent:newEvent withCompletion:
    ^{
        [weakSelf resetTextFields];
    }];

    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.fireDate = newEvent.desiredArrivalTime;
    localNotification.alertBody = [NSString stringWithFormat:@"Alert Fired at %@", newEvent.desiredArrivalTime];
    localNotification.timeZone = [NSTimeZone localTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    NSLog(@"This local notification was created: %@", localNotification);
}

- (void)resetTextFields
{
    self.nameTextField.text = @"";
    self.startingLocationTextField.text = @"";
    self.endingLocationTextField.text = @"";
    self.datePicker.date = [NSDate date];
}


#pragma mark - UILocalNotifications



@end
