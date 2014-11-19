//
//  MaxDatePickerViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/19/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "MaxDatePickerViewController.h"
#import "UIButton+UIButton_Position.h"

@interface MaxDatePickerViewController ()
@property UIView *datePickerView;
@property UIDatePicker *datePicker;
@property UILabel *monthLabel;
@property UIButton *rightArrowButton;
@property UIButton *leftArrowButton;
@property UIButton *confirmDateButton;
@property UIButton *closeViewButton;
@property NSArray *months;


@end

@implementation MaxDatePickerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.frame];
    [self.view addSubview:blurEffectView];
    [self createDatePickerView];

    [self datePickerValueChanged:self];


}

- (void)datePickerValueChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM YYYY"];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    self.monthLabel.text =[dateFormatter stringFromDate:self.datePicker.date];

}

-(void)createDatePickerView{
    self.datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*.2, self.view.frame.size.width, self.view.frame.size.height*.6)];
    self.datePickerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.datePickerView];

    [self drawOutlineOfDatePicker];


    self.monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.datePickerView.frame.size.width*.25, 0, self.datePickerView.frame.size.width*.5, self.datePickerView.frame.size.height*.2)];
    self.monthLabel.text = @"Hello World";
    self.monthLabel.textAlignment = NSTextAlignmentCenter;
    self.monthLabel.textColor = [UIColor whiteColor];
    self.monthLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:22.0];
    [self.datePickerView addSubview:self.monthLabel];

    self.leftArrowButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.datePickerView.frame.size.width*.25, self.datePickerView.frame.size.height*.2)];
    [self.leftArrowButton centerButtonAndImageWithSpacing:15];
    UIImage *leftArrowImage = [[UIImage imageNamed:@"leftArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.leftArrowButton setImage:leftArrowImage forState:UIControlStateNormal];
    [self.leftArrowButton setTintColor:[UIColor whiteColor]];
    [self.leftArrowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.leftArrowButton addTarget:self action:@selector(onLeftArrowButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.leftArrowButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];
    [self.datePickerView addSubview:self.leftArrowButton];



    self.rightArrowButton = [[UIButton alloc] initWithFrame:CGRectMake(self.datePickerView.frame.size.width*.75, 0, self.datePickerView.frame.size.width*.25, self.datePickerView.frame.size.height*.2)];
    [self.rightArrowButton centerButtonAndImageWithSpacing:15];
    UIImage *rightArrowImage = [[UIImage imageNamed:@"rightArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.rightArrowButton setImage:rightArrowImage forState:UIControlStateNormal];
    [self.rightArrowButton setTintColor:[UIColor whiteColor]];

    [self.rightArrowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rightArrowButton addTarget:self action:@selector(onRightArrowButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.rightArrowButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];
    [self.datePickerView addSubview:self.rightArrowButton];



    self.confirmDateButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.datePickerView.frame.size.height*.8, self.datePickerView.frame.size.width*.5, self.datePickerView.frame.size.height*.2)];
    [self.confirmDateButton setTitle:@"Confirm Date" forState:UIControlStateNormal];
    self.confirmDateButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0];
    [self.confirmDateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.datePickerView addSubview:self.confirmDateButton];



    self.closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(self.datePickerView.frame.size.width*.5, self.datePickerView.frame.size.height*.8, self.datePickerView.frame.size.width*.5, self.datePickerView.frame.size.height*.2)];
    [self.closeViewButton setTitle:@"Close" forState:UIControlStateNormal];
    [self.closeViewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.closeViewButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    self.closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0];
    [self.datePickerView addSubview:self.closeViewButton];

    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.datePickerView.frame.size.height*.20, self.datePickerView.frame.size.width, 0)];

    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.date = [NSDate date];
    self.datePicker.minimumDate = [NSDate date];
    [self.datePicker addTarget:self
                        action:@selector(datePickerValueChanged:)
              forControlEvents:UIControlEventValueChanged];
    self.datePicker.layer.borderWidth = 2;
    self.datePicker.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.datePickerView addSubview:self.datePicker];

}


-(void)closeView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onRightArrowButtonPressed{

    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:1];

    NSDate *newDate = [calendar dateByAddingComponents:components toDate:self.datePicker.date options:0];

    self.datePicker.date = newDate;

    [self datePickerValueChanged:self];

}


-(void)onLeftArrowButtonPressed{

    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:-1];

    NSDate *newDate = [calendar dateByAddingComponents:components toDate:self.datePicker.date options:0];

    if (newDate < [NSDate date]) {
        self.datePicker.date = [NSDate date];
        [self datePickerValueChanged:self];

    } else {
        self.datePicker.date = newDate;
        [self datePickerValueChanged:self];
    }
    
}



-(void)drawOutlineOfDatePicker{

    CAShapeLayer *outlineRectOval = [CAShapeLayer new];
    outlineRectOval.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.datePickerView.frame.size.width, self.datePickerView.frame.size.height)
                                                 byRoundingCorners:UIRectCornerAllCorners
                                                       cornerRadii:CGSizeMake(20, 20)].CGPath;
    outlineRectOval.lineWidth = 2;
    outlineRectOval.strokeColor = [UIColor whiteColor].CGColor;
    outlineRectOval.fillColor = [UIColor clearColor].CGColor;
    [self.datePickerView.layer addSublayer:outlineRectOval];


    CAShapeLayer *lineSeperator = [CAShapeLayer new];
    CGMutablePathRef line = CGPathCreateMutable();
    CGPathMoveToPoint(line, nil,self.datePickerView.frame.size.width*.5, self.datePickerView.frame.size.height*.83);//Starting Point
    CGPathAddLineToPoint(line, nil, self.datePickerView.frame.size.width*.5, self.datePickerView.frame.size.height);
    lineSeperator.path = [UIBezierPath bezierPathWithCGPath:line].CGPath;
    lineSeperator.lineWidth = 1;
    lineSeperator.strokeColor = [UIColor whiteColor].CGColor;
    lineSeperator.fillColor = [UIColor clearColor].CGColor;
    [self.datePickerView.layer addSublayer:lineSeperator];

}



@end

