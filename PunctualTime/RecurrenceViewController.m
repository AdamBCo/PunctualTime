//
//  RecurrenceViewController.m
//  PunctualTime
//
//  Created by Nathan Hosselton on 11/13/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "RecurrenceViewController.h"
#import <QuartzCore/QuartzCore.h>

static UIColor* initialTextColor;

@interface RecurrenceViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property PTEventRecurrenceOption selectedRecurrence;

@end

@implementation RecurrenceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    initialTextColor = [self.buttons.firstObject titleColorForState:UIControlStateNormal];
    self.selectedRecurrence = PTEventRecurrenceOptionNone;
    [self.delegate recurrenceSelected:PTEventRecurrenceOptionNone];

    for (UIButton* button in self.buttons)
    {
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = [initialTextColor CGColor];
    }
}

- (IBAction)onRecurrenceButtonPressed:(UIButton *)pressedButton
{
    UIColor* selectedTextColor = [UIColor colorWithRed:0.071 green:0.871 blue:1.000 alpha:1.000];

    for (UIButton* button in self.buttons)
    {
        if (![button isEqual:pressedButton])
        {
            [button setTitleColor:initialTextColor forState:UIControlStateNormal];
            button.layer.borderColor = [initialTextColor CGColor];
        }
    }
    
    if (pressedButton.tag == self.selectedRecurrence) // User is deselecting currently selected option
    {
        [self.delegate recurrenceSelected:PTEventRecurrenceOptionNone];
        self.selectedRecurrence = PTEventRecurrenceOptionNone;
        [pressedButton setTitleColor:initialTextColor forState:UIControlStateNormal];
        pressedButton.layer.borderColor = [initialTextColor CGColor];
    }
    else
    {
        switch (pressedButton.tag)
        {
            case 0:
                [self.delegate recurrenceSelected:PTEventRecurrenceOptionDaily];
                self.selectedRecurrence = PTEventRecurrenceOptionDaily;
                [pressedButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
                pressedButton.layer.borderColor = [selectedTextColor CGColor];
                break;
            case 1:
                [self.delegate recurrenceSelected:PTEventRecurrenceOptionWeekdays];
                self.selectedRecurrence = PTEventRecurrenceOptionWeekdays;
                [pressedButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
                pressedButton.layer.borderColor = [selectedTextColor CGColor];
                break;
            case 2:
                [self.delegate recurrenceSelected:PTEventRecurrenceOptionWeekly];
                self.selectedRecurrence = PTEventRecurrenceOptionWeekly;
                [pressedButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
                pressedButton.layer.borderColor = [selectedTextColor CGColor];
                break;
            default:
                self.selectedRecurrence = PTEventRecurrenceOptionNone;
                break;
        }
    }
}

@end
