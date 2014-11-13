//
//  RemindersViewController.m
//  PunctualTime
//
//  Created by Nathan Hosselton on 11/12/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "RemindersViewController.h"
#import "Constants.h"

static UIColor* initialTextColor;

@interface RemindersViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@end

@implementation RemindersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //
}

- (IBAction)onNotificationButtonPressed:(UIButton *)button
{
    initialTextColor = [UIColor blackColor];
    UIColor* selectedTextColor = [UIColor colorWithRed:0.071 green:0.871 blue:1.000 alpha:1.000];

    for (UIButton* button in self.buttons)
    {
        [button setTitleColor:initialTextColor forState:UIControlStateNormal];
    }

    //if ([[button titleColorForState:UIControlStateNormal] isEqual:selectedTextColor])
    //{
    //    selectedTextColor = initialTextColor;
    //}

    switch (button.tag)
    {
        case 0:
            [self.delegate reminderSelected:SIXTY_MINUTE_WARNING];
            [button setTitleColor:selectedTextColor forState:UIControlStateNormal];
            break;
        case 1:
            [self.delegate reminderSelected:THIRTY_MINUTE_WARNING];
            [button setTitleColor:selectedTextColor forState:UIControlStateNormal];
            break;
        case 2:
            [self.delegate reminderSelected:FIFTEEN_MINUTE_WARNING];
            [button setTitleColor:selectedTextColor forState:UIControlStateNormal];
            break;
        case 3:
            [self.delegate reminderSelected:TEN_MINUTE_WARNING];
            [button setTitleColor:selectedTextColor forState:UIControlStateNormal];
            break;
        case 4:
            [self.delegate reminderSelected:FIVE_MINUTE_WARNING];
            [button setTitleColor:selectedTextColor forState:UIControlStateNormal];
            break;
        default:
            [self.delegate reminderSelected:nil]; // Zero minute warning
            break;
    }
}

@end
