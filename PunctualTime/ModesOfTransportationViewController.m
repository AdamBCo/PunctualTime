//
//  ModesOfTransportationViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/11/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "ModesOfTransportationViewController.h"
#import "Constants.h"

static UIColor* initialTextColor;
static UIColor* selectedTextColor;

@interface ModesOfTransportationViewController ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *buttonSizeConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *buttonSpaceConstraints;


@end

@implementation ModesOfTransportationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    initialTextColor = [self.buttons.firstObject titleColorForState:UIControlStateNormal];
    selectedTextColor = [UIColor colorWithRed:0.071 green:0.871 blue:1.000 alpha:1.000];

    CGFloat buttonSize = (SCREEN_WIDTH-40.0)/4.0;
    CGFloat buttonSpacing = (SCREEN_WIDTH - buttonSize*4 - 16)/3;
    [self.delegate transportationButtonHeightWasSet:buttonSize];

    for (NSLayoutConstraint* constraint in self.buttonSizeConstraints)
    {
        constraint.constant = buttonSize;
    }

    for (NSLayoutConstraint* constraint in self.buttonSpaceConstraints)
    {
        constraint.constant = buttonSpacing;
    }

    for (UIButton* button in self.buttons)
    {
        button.layer.borderWidth = 1.0;
        button.layer.cornerRadius = buttonSize/2.0;
        button.layer.borderColor = [initialTextColor CGColor];
    }

    [self.buttons.firstObject setTitleColor:selectedTextColor forState:UIControlStateNormal];
    ((UIButton*)self.buttons.firstObject).layer.borderColor = [selectedTextColor CGColor];
    [self.delegate modeOfTransportationSelected:TRANSPO_DRIVING];
}

- (IBAction)onTransportationButtonPressed:(UIButton *)pressedButton
{
    for (UIButton* button in self.buttons)
    {
        [button setTitleColor:initialTextColor forState:UIControlStateNormal];
        button.layer.borderColor = [initialTextColor CGColor];
    }

    switch (pressedButton.tag)
    {
        case 0:
            [self.delegate modeOfTransportationSelected:TRANSPO_DRIVING];
            [pressedButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
            pressedButton.layer.borderColor = [selectedTextColor CGColor];
            break;
        case 1:
            [self.delegate modeOfTransportationSelected:TRANSPO_WALKING];
            [pressedButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
            pressedButton.layer.borderColor = [selectedTextColor CGColor];
            break;
        case 2:
            [self.delegate modeOfTransportationSelected:TRANSPO_BIKING];
            [pressedButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
            pressedButton.layer.borderColor = [selectedTextColor CGColor];
            break;
        case 3:
            [self.delegate modeOfTransportationSelected:TRANSPO_TRANSIT];
            [pressedButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
            pressedButton.layer.borderColor = [selectedTextColor CGColor];
            break;

        default:
            break;
    }
}


@end
