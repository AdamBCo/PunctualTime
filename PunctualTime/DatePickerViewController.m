//
//  DatePickerViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/8/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "DatePickerViewController.h"
#import "MinutesViewController.h"
#import "HourViewController.h"

#define DOTTED_LINE_HEIGHT 1.

@interface DatePickerViewController () <UIGestureRecognizerDelegate, MinuteViewDelegate>

@property NSString *theValue;
@property MinutesViewController *minutesViewController;


@end

@implementation DatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.minutesViewController = [MinutesViewController new];
    self.minutesViewController.delegate = self;


}


-(void)minuteSelected:(NSString *)string{
    self.theValue = string;
    NSLog(@"We got it: %@",self.theValue);
}


@end
