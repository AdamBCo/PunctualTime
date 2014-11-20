//
//  MaxDatePickerViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/19/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "MaxDatePickerViewController.h"
#import "UIButton+UIButton_Position.h"
#import "Constants.h"

@interface MaxDatePickerViewController ()

@property NSArray *months;

@property (strong, nonatomic) IBOutlet UIView *datePickerView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIButton *leftArrowButton;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
@property (strong, nonatomic) IBOutlet UIButton *rightArrowButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UILabel *monthLabel;

@end

@implementation MaxDatePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setupDatePickerView];

    [self datePickerValueChanged:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self drawOutlineOfDatePicker];
}

- (void)datePickerValueChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM YYYY"];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    self.monthLabel.text =[dateFormatter stringFromDate:self.datePicker.date];
}

-(void)setupDatePickerView
{
    // Date picker
    self.datePicker.date = self.selectedDate ?: [NSDate date];
    self.datePicker.minimumDate = [NSDate date];
    [self.datePicker addTarget:self
                        action:@selector(datePickerValueChanged:)
              forControlEvents:UIControlEventValueChanged];
    //    self.datePicker.layer.borderWidth = 2.0;
    self.datePicker.layer.borderColor = [UIColor whiteColor].CGColor;

    // Left arrow
//    [self.leftArrowButton centerButtonAndImageWithSpacing:15];
    UIImage *leftArrowImage = [[UIImage imageNamed:@"leftArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.leftArrowButton setImage:leftArrowImage forState:UIControlStateNormal];
    [self.leftArrowButton setTintColor:[UIColor whiteColor]];
    [self.leftArrowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.leftArrowButton addTarget:self action:@selector(onLeftArrowButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.leftArrowButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];

    // Right arrow
//    [self.rightArrowButton centerButtonAndImageWithSpacing:15];
    UIImage *rightArrowImage = [[UIImage imageNamed:@"rightArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.rightArrowButton setImage:rightArrowImage forState:UIControlStateNormal];
    [self.rightArrowButton setTintColor:[UIColor whiteColor]];
    [self.rightArrowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rightArrowButton addTarget:self action:@selector(onRightArrowButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.rightArrowButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];

    // Confirm button
    [self.confirmButton addTarget:self action:@selector(confirmDate) forControlEvents:UIControlEventTouchUpInside];

    // Close button
    [self.cancelButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)confirmDate
{
    self.selectedDate = self.datePicker.date;
    [self closeView];
}

- (void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"UnwindToCreateVC" sender:self];
}

- (void)onRightArrowButtonPressed
{

    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:1];

    NSDate *newDate = [calendar dateByAddingComponents:components toDate:self.datePicker.date options:0];

    self.datePicker.date = newDate;

    [self datePickerValueChanged:self];

}


-(void)onLeftArrowButtonPressed
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:-1];

    NSDate *newDate = [calendar dateByAddingComponents:components toDate:self.datePicker.date options:0];

    if (newDate < [NSDate date])
    {
        self.datePicker.date = [NSDate date];
        [self datePickerValueChanged:self];
    }
    else
    {
        self.datePicker.date = newDate;
        [self datePickerValueChanged:self];
    }
}



-(void)drawOutlineOfDatePicker
{
    // Outer border
    CAShapeLayer *outlineRectOval = [CAShapeLayer new];
    outlineRectOval.path = [UIBezierPath bezierPathWithRoundedRect:self.datePickerView.bounds
                                                 byRoundingCorners:UIRectCornerAllCorners
                                                       cornerRadii:CGSizeMake(20, 20)].CGPath;
    outlineRectOval.lineWidth = 2;
    outlineRectOval.strokeColor = [UIColor whiteColor].CGColor;
    outlineRectOval.fillColor = [UIColor clearColor].CGColor;
    //[outlineRectOval setAffineTransform:(CGAffineTransformMakeScale(0.95, 0.95))];
    [self.datePickerView.layer addSublayer:outlineRectOval];

    // Confirm/Close button separator
//    CAShapeLayer *lineSeperator = [CAShapeLayer new];
//    CGMutablePathRef line = CGPathCreateMutable();
//    CGPathMoveToPoint(line, nil,self.datePickerView.bounds.size.width/2, self.datePickerView.bounds.size.height);//Starting Point
//    CGPathAddLineToPoint(line, nil, self.datePickerView.bounds.size.width/2, self.confirmButton.bounds.origin.y);
//    lineSeperator.path = [UIBezierPath bezierPathWithCGPath:line].CGPath;
//    lineSeperator.lineWidth = 2;
//    lineSeperator.strokeColor = [UIColor whiteColor].CGColor;
//    lineSeperator.fillColor = [UIColor clearColor].CGColor;
//    [self.datePickerView.layer addSublayer:lineSeperator];
//
//    // Date picker top border line
//    CAShapeLayer* datePickerTop = [CAShapeLayer new];
//    CGMutablePathRef topLine = CGPathCreateMutable();
//    CGPathMoveToPoint(topLine, nil, self.datePicker.frame.origin.x, self.datePicker.frame.origin.y); // Starting point
//    CGPathAddLineToPoint(topLine, nil, SCREEN_WIDTH, self.datePicker.frame.origin.y); // Ending point
//    datePickerTop.path = [UIBezierPath bezierPathWithCGPath:topLine].CGPath;
//    datePickerTop.lineWidth = 2.0;
//    datePickerTop.strokeColor = [UIColor whiteColor].CGColor;
//    datePickerTop.fillColor = [UIColor clearColor].CGColor;
//    [self.datePickerView.layer addSublayer:datePickerTop];
//
//    // Date picker bottom border line
//    CAShapeLayer* datePickerBottom = [CAShapeLayer new];
//    CGMutablePathRef bottomLine = CGPathCreateMutable();
//    CGPathMoveToPoint(bottomLine, nil, self.datePicker.frame.origin.x, self.datePicker.frame.origin.y+self.datePicker.frame.size.height); // Starting point
//    CGPathAddLineToPoint(bottomLine, nil, SCREEN_WIDTH, self.datePicker.frame.origin.y+self.datePicker.frame.size.height); // Ending point
//    datePickerBottom.path = [UIBezierPath bezierPathWithCGPath:bottomLine].CGPath;
//    datePickerBottom.lineWidth = 2.0;
//    datePickerBottom.strokeColor = [UIColor whiteColor].CGColor;
//    datePickerBottom.fillColor = [UIColor clearColor].CGColor;
//    [self.datePickerView.layer addSublayer:datePickerBottom];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"UnwindToCreateVC"])
    {
        //
    }
}

@end

