//
//  MinutesViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/10/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "MinutesViewController.h"

@interface MinutesViewController ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *draggableLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *minuteLabels;


@end

@implementation MinutesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [super touchesBegan:touches withEvent:event];
//
//    UITouch *touch = [touches anyObject];
//    CGPoint firstTouch = [touch locationInView:self.view];
//
//    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
//
//    } completion:^(BOOL finished) {
//        NSLog(@" CHECKING CGPOINT %@", NSStringFromCGPoint(firstTouch));
//
//    }];
//}


-(IBAction)pan:(UIPanGestureRecognizer *)gesture {

    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {

        CGPoint point = [gesture locationInView:self.draggableLabel.superview];
        self.draggableLabel.center = CGPointMake(self.draggableLabel.center.x, point.y);

        for (UILabel *minuteLabel in self.minuteLabels) {
            if (CGRectContainsPoint(minuteLabel.frame, self.draggableLabel.center)){
                [self.delegate minuteSelected:minuteLabel.text];
            }
        }

    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateFailed ||
               gesture.state == UIGestureRecognizerStateCancelled){
        
    }
}

@end
