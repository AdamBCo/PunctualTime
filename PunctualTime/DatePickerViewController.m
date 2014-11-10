//
//  DatePickerViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/8/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "DatePickerViewController.h"

@interface DatePickerViewController () <UIGestureRecognizerDelegate>

@end

@implementation DatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint firstTouch = [touch locationInView:self.view];

    NSLog(@" CHECKING CGPOINT %@", NSStringFromCGPoint(firstTouch));
}


-(IBAction)pan:(UIPanGestureRecognizer *)gesture {


    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture translationInView:gesture.view];
        NSLog(@"The Point: %f, %f",point.x,point.y);
//        NSLog(@"You toched here: %@",point);
//        NSLog(@"At this speed: %@",yVelocity);

    } else if (gesture.state == UIGestureRecognizerStateChanged){

    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateFailed ||
               gesture.state == UIGestureRecognizerStateCancelled){

    }
}


@end
