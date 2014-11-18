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
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *buttonSizeConstraints;


@end

@implementation RemindersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    initialTextColor = [self.buttons.firstObject titleColorForState:UIControlStateNormal];

    CGFloat buttonSize = (SCREEN_WIDTH-48)/5.0;
    [self.delegate reminderButtonHeightWasSet:buttonSize];

    for (NSLayoutConstraint* constraint in self.buttonSizeConstraints)
    {
        constraint.constant = buttonSize;
    }

    for (UIButton* button in self.buttons)
    {
        button.layer.borderWidth = 1.0;
        button.layer.cornerRadius = (buttonSize)/2.0;
        button.layer.borderColor = [initialTextColor CGColor];
    }

}

- (IBAction)onNotificationButtonPressed:(UIButton *)pressedButton
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

    if ([[pressedButton titleColorForState:UIControlStateNormal] isEqual:selectedTextColor])
    {
        [pressedButton setTitleColor:initialTextColor forState:UIControlStateNormal];
        pressedButton.layer.borderColor = [initialTextColor CGColor];
        [self.delegate reminderSelected:nil];
    }
    else
    {
        switch (pressedButton.tag)
        {
            case 0:
                [self.delegate reminderSelected:SIXTY_MINUTE_WARNING];
                [pressedButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
                pressedButton.layer.borderColor = [selectedTextColor CGColor];
                break;
            case 1:
                [self.delegate reminderSelected:THIRTY_MINUTE_WARNING];
                [pressedButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
                pressedButton.layer.borderColor = [selectedTextColor CGColor];
                break;
            case 2:
                [self.delegate reminderSelected:FIFTEEN_MINUTE_WARNING];
                [pressedButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
                pressedButton.layer.borderColor = [selectedTextColor CGColor];
                break;
            case 3:
                [self.delegate reminderSelected:TEN_MINUTE_WARNING];
                [pressedButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
                pressedButton.layer.borderColor = [selectedTextColor CGColor];
                break;
            case 4:
                [self.delegate reminderSelected:FIVE_MINUTE_WARNING];
                [pressedButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
                pressedButton.layer.borderColor = [selectedTextColor CGColor];
                break;
            default:
                [self.delegate reminderSelected:nil]; // Zero minute warning
                break;
        }
    }
}

@end
