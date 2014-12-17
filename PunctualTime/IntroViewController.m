//
//  IntroViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/18/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property UIView *holeView;
@property UIView *circleView;

@end

@implementation IntroViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    [self createHoleView];
    [self createCircle];
    [self createViewOne];
    [self createViewTwo];
    [self createViewThree];
    [self createViewFour];

    self.pageControl.numberOfPages = 4;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width*4, self.scrollView.frame.size.height);

    //This is the starting point of the ScrollView
    CGPoint scrollPoint = CGPointMake(0, 0);
    [self.scrollView setContentOffset:scrollPoint animated:YES];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (IBAction)onFinishedIntroButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Intro Dismissed");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat pageWidth = CGRectGetWidth(self.view.bounds);
    CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = roundf(pageFraction);
    
}


-(void)createViewOne{

    CGFloat originWidth = self.view.frame.size.width;
    CGFloat originHeight = self.view.frame.size.height;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, originWidth, originHeight)];
    CGRect myFrame = CGRectMake(originWidth*.1, 0 , originWidth*.8, originHeight*.3);
    view.backgroundColor = [UIColor orangeColor];

    UILabel *myLabel = [[UILabel alloc] initWithFrame:myFrame];
    myLabel.text = [NSString stringWithFormat:@"Welcome"];
    myLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:42.0];
    myLabel.textColor = [UIColor whiteColor];
    myLabel.textAlignment =  NSTextAlignmentCenter;
    [view addSubview:myLabel];

    CGRect textFrame = CGRectMake(originWidth*.1, originHeight*.3 , originWidth*.8, originHeight*.4);
    UITextView *textView = [[UITextView alloc] initWithFrame:textFrame];
    textView.text = [NSString stringWithFormat:@"Before we get started, we have to ask for a couple permissions from your device.These permissions are solely for your benefit, as they allow the application to accurately calculate travel times based on current locations. We would never share this information publicly."];
    textView.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    textView.textAlignment =  NSTextAlignmentCenter;
    textView.scrollEnabled = NO;
    textView.editable = NO;
    [textView sizeToFit];

    [view addSubview:textView];


    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}


-(void)createViewTwo{

    CGFloat originWidth = self.view.frame.size.width;
    CGFloat originHeight = self.view.frame.size.height;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originWidth, 0, originWidth, originHeight)];
    CGRect myFrame = CGRectMake(originWidth*.1, 0 , originWidth*.8, originHeight*.3);
    view.backgroundColor = [UIColor orangeColor];

    UILabel *myLabel = [[UILabel alloc] initWithFrame:myFrame];
    myLabel.text = [NSString stringWithFormat:@"Permissions"];
    myLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:42.0];
    myLabel.textColor = [UIColor whiteColor];
    myLabel.textAlignment =  NSTextAlignmentCenter;
    [view addSubview:myLabel];

    CGRect textFrame = CGRectMake(originWidth*.1, originHeight*.3 , originWidth*.8, originHeight*.4);
    UITextView *textView = [[UITextView alloc] initWithFrame:textFrame];
    textView.text = [NSString stringWithFormat:@"Before we get started, we have to ask for a couple permissions from your device.These permissions are solely for your benefit, as they allow the application to accurately calculate travel times based on current locations. We would never share this information publicly."];
    textView.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    textView.textAlignment =  NSTextAlignmentCenter;
    textView.scrollEnabled = NO;
    textView.editable = NO;
    [textView sizeToFit];

    [view addSubview:textView];


    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];

}

-(void)createViewThree{

    CGFloat originWidth = self.view.frame.size.width;
    CGFloat originHeight = self.view.frame.size.height;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originWidth*2, 0, originWidth, originHeight)];
    CGRect myFrame = CGRectMake(originWidth*.1, 0 , originWidth*.8, originHeight*.3);
    view.backgroundColor = [UIColor orangeColor];

    UILabel *myLabel = [[UILabel alloc] initWithFrame:myFrame];
    myLabel.text = [NSString stringWithFormat:@"Permissions"];
    myLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:42.0];
    myLabel.textColor = [UIColor whiteColor];
    myLabel.textAlignment =  NSTextAlignmentCenter;
    [view addSubview:myLabel];


    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}



-(void)createViewFour{

    CGFloat originWidth = self.view.frame.size.width;
    CGFloat originHeight = self.view.frame.size.height;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originWidth*3, 0, originWidth, originHeight)];
    CGRect myFrame = CGRectMake(originWidth*.1, 0 , originWidth*.8, originHeight*.3);

    [view addSubview:self.holeView];
    [view addSubview:self.circleView];

    UILabel *myLabel = [[UILabel alloc] initWithFrame:myFrame];
    myLabel.text = [NSString stringWithFormat:@"Page Four"];
    myLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:42.0];
    myLabel.textColor = [UIColor whiteColor];
    myLabel.textAlignment =  NSTextAlignmentCenter;
    [view addSubview:myLabel];


    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}




#pragma mark - Helper

-(void)createHoleView{

    CGRect frame = self.view.frame;
    CGFloat originWidth = self.view.frame.size.width;
    CGFloat originHeight = self.view.frame.size.height;

    self.holeView = [[UIView alloc] initWithFrame:frame];
    self.holeView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];

    int radius = originWidth*.23;
    CAShapeLayer *circle = [[CAShapeLayer alloc]initWithLayer:self.holeView.layer];
    circle.position = CGPointMake(0, 0);
    CGRect const circleRect = CGRectMake(originWidth/2-radius,originHeight/8 + radius, 2 * radius, 2 * radius);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [path appendPath:[UIBezierPath bezierPathWithRect:frame]];
    circle.path = path.CGPath;
    circle.fillRule = kCAFillRuleEvenOdd;

    self.holeView.layer.mask = circle;
}

-(void)createCircle{

    CGRect frame = self.view.frame;
    CGFloat originWidth = self.view.frame.size.width;
    CGFloat originHeight = self.view.frame.size.height;
    self.circleView = [[UIView alloc] initWithFrame:frame];

    int radius = originWidth*.23;
    CAShapeLayer *circle = [[CAShapeLayer alloc]initWithLayer:self.circleView.layer];
    circle.position = CGPointMake(0, 0);
    CGRect const circleRect = CGRectMake(originWidth/2-radius,originHeight/8 + radius, 2 * radius, 2 * radius);
    circle.path = [UIBezierPath bezierPathWithOvalInRect:circleRect].CGPath;
    circle.fillColor = [UIColor orangeColor].CGColor;
    circle.fillRule = kCAFillRuleEvenOdd;

//    [self.circleView.layer addSublayer:circle];

}



@end
