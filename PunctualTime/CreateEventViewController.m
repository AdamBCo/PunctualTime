//
//  CreateEventViewController.m
//  PunctualTime
//
//  Created by Nathan Hosselton on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "CreateEventViewController.h"
#import "Event.h"

@interface CreateEventViewController ()

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *startingLocationTextField;
@property (strong, nonatomic) IBOutlet UITextField *endingLocationTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation CreateEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.datePicker.minimumDate = [NSDate date];
}

- (IBAction)onSaveEventButtonPressed:(id)sender
{
    Event *newEvent = [[Event alloc] initWithEventName:self.nameTextField.text
                                       startingAddress:self.startingLocationTextField.text
                                         endingAddress:self.endingLocationTextField.text
                                           arrivalTime:self.datePicker.date];
    // Pass event back to rootVC
}

@end
