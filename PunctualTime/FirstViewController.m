
//
//  FirstViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/5/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "FirstViewController.h"
#import "EventTableViewController.h"
#import "LiveFrost.h"
#import "EventManager.h"
#import "Event.h"
#import "CircularTimer.h"

static CGFloat INITIAL_CONTAINER_LOC;

@interface FirstViewController () <EventTableViewDelegate, EventManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTillEvent;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UIToolbar *addButtonToolbar;
@property EventManager *sharedEventManager;
@property Event *selectedEvent;
@property NSNumber *timeTillEventTimer;
@property CircularTimer *cirularTimer;
@property CGFloat lastYTranslation;
@property LFGlassView* blurView;
@property UIView *animationShapeView;

@property BOOL animating;

@end

@implementation FirstViewController

- (void)viewDidLoad
{

    [super viewDidLoad];

//    UIView *test = [[UIView alloc] initWithFrame:self.view.bounds];
//    test.backgroundColor = [UIColor purpleColor];
//
//    [self.view addSubview:test];
//
//
//    UIBezierPath *myClippingPath = [UIBezierPath bezierPath];
//    [myClippingPath moveToPoint:CGPointMake(100, 100)];
//    [myClippingPath addCurveToPoint:CGPointMake(200, 200) controlPoint1:CGPointMake(self.view.frame.size.width, 0) controlPoint2:CGPointMake(self.self.view.frame.size.width, 50)];
//    [myClippingPath closePath];
//
//    CAShapeLayer *mask = [CAShapeLayer layer];
//    mask.path = myClippingPath.CGPath;
//
//    self.view.layer.mask = mask;



    self.sharedEventManager = [EventManager sharedEventManager];
    self.selectedEvent = self.sharedEventManager.events.firstObject;
    self.sharedEventManager.delegate = self;

    self.eventNameLabel.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 100);
    self.timeTillEvent.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height + 100);

    self.animationShapeView = [[UIView alloc]initWithFrame:CGRectMake(0 ,self.view.bounds.size.height/6, self.view.bounds.size.width, self.view.bounds.size.width)];

    self.navigationItem.title = @"Cancel"; // For the back button on CreateEventVC

    // Remove shadow on transparent toolbar:

    [self.addButtonToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.addButtonToolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];


    [UIView animateWithDuration:3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.03 options:UIViewAnimationOptionAllowUserInteraction animations:^{

        self.eventNameLabel.center = CGPointMake(self.view.frame.size.width/2, 300);

        self.timeTillEvent.center = self.view.center;

    } completion:^(BOOL finished) {

    }];



    //Circle Drawing

    int radius = 120;

    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.position = CGPointMake(CGRectGetMidX(self.animationShapeView.frame)-radius,
                                  CGRectGetMidY(self.animationShapeView.frame)-radius-25);
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                             cornerRadius:radius].CGPath;
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor whiteColor].CGColor;
    circle.lineWidth = 5;

    //Star Drawing

    CAShapeLayer *star = [CAShapeLayer layer];
    CGPoint offset = CGPointMake(self.animationShapeView.frame.size.width/2, self.animationShapeView.frame.size.height/2);
    int r1 = self.animationShapeView.frame.size.width/2;
    int r2 = r1 - 20;
    int numberOfPoints =    60;//60
    float TWOPI = 2 * M_PI;
    CGMutablePathRef drawStarPath = CGPathCreateMutable();
    for (float n=0; n < numberOfPoints; n+=3)
    {
        int x1 = offset.x + sin((TWOPI/numberOfPoints) * n) * r2;
        int y1 = offset.y + cos((TWOPI/numberOfPoints) * n) * r2;
        if (n==0){

            CGPathMoveToPoint(drawStarPath, NULL, x1, y1);
        }else {
            CGPathAddLineToPoint(drawStarPath, NULL, x1, y1);
            int x2 = offset.x + sin((TWOPI/numberOfPoints) * n+1) * r1;
            int y2 = offset.y + cos((TWOPI/numberOfPoints) * n+1) * r1;
            CGPathAddLineToPoint(drawStarPath, NULL, x2, y2);
            int x3 = offset.x + sin((TWOPI/numberOfPoints) * n+2) * r2;
            int y3 = offset.y + cos((TWOPI/numberOfPoints) * n+2) * r2;
            CGPathAddLineToPoint(drawStarPath, NULL, x3, y3);
        }
    }
    CGPathCloseSubpath(drawStarPath);

    star.path = [UIBezierPath bezierPathWithCGPath:drawStarPath].CGPath;
    star.fillColor = [UIColor clearColor].CGColor;
    star.strokeColor = [UIColor whiteColor].CGColor;
    star.lineWidth = 5;

    // Configure animation

    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = 4.0; // "animate over 10 seconds or so.."
    drawAnimation.repeatCount         = 1.0;  // Animate only once..
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [circle addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    [star addAnimation:drawAnimation forKey:@"drawCircleAnimation"];

    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 10;
    rotationAnimation.repeatCount = INFINITY;
//    [star addAnimation:rotationAnimation forKey:@"rotationAnimation"];

    //Add layers to Animation View

    [self.animationShapeView.layer addSublayer:star];
    [self.view insertSubview:self.animationShapeView aboveSubview:self.containerView];
    [self runSpinAnimationOnView:self.animationShapeView duration:5 rotations:1 repeat:1];

}

- (void)runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat
{

    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;

    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];

}

-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];

    self.navigationController.navigationBar.hidden = YES;
    INITIAL_CONTAINER_LOC = self.containerViewHeightConstraint.constant;

    [self eventManagerHasBeenUpdated];

    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateCounter)
                                   userInfo:nil
                                    repeats:YES];
}


- (void)updateCounter

{
    int seconds = -[[NSDate date] timeIntervalSinceDate:self.selectedEvent.lastLeaveTime];

    if(seconds > 0 ){
        seconds -- ;
        int hours = (seconds / 3600);
        int minutes = (seconds % 3600) / 60;
        seconds = (seconds %3600) % 60;
        self.eventNameLabel.text = self.selectedEvent.eventName;
        self.timeTillEvent.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
}


#pragma mark - EventTableViewControllerDelegate

- (void)panGestureDetected:(UIPanGestureRecognizer *)gesture
{
    if (UIGestureRecognizerStateBegan == gesture.state)
    {
        if (self.containerViewHeightConstraint.constant == INITIAL_CONTAINER_LOC) // Container is being moved up
        {
            // Create blur view to animate
            self.blurView = [[LFGlassView alloc] initWithFrame:self.view.frame];;
            self.blurView.alpha = 0.0;
            self.blurView.frame = self.view.frame;
            [self.view insertSubview:self.blurView belowSubview:self.containerView];
        }
    }
    else if (UIGestureRecognizerStateChanged == gesture.state)
    {
        CGPoint translation = [gesture translationInView:gesture.view];
        self.containerViewHeightConstraint.constant -= translation.y;
        [gesture setTranslation:CGPointMake(0, 0) inView:gesture.view];
        self.lastYTranslation = translation.y;

        // Set blurView alpha
        CGPoint location = [gesture locationInView:self.view];
        self.blurView.alpha = 1.06 - (location.y/self.view.frame.size.height);

    }

    else if (UIGestureRecognizerStateEnded == gesture.state)
    {
        if (self.lastYTranslation > 0) // User was panning down so finish closing
        {
            self.containerViewHeightConstraint.constant = INITIAL_CONTAINER_LOC;
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
                self.blurView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.blurView removeFromSuperview];
            }];
        }
        else // User was panning up so finish opening
        {

            self.containerViewHeightConstraint.constant = self.view.frame.size.height;
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
                self.blurView.alpha = 1.0;
                
            }];
            
        }
        
    }
    
    else // Gesture was cancelled or failed so animate back to original location
    {
        self.containerViewHeightConstraint.constant = INITIAL_CONTAINER_LOC;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
            self.blurView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.blurView removeFromSuperview];
        }];
    }
}


#pragma mark - EventManagerDelegate

-(void)eventManagerHasBeenUpdated
{
    self.selectedEvent = self.sharedEventManager.events.firstObject;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EventTableVC"]){
        
        EventTableViewController* eventTableVC = segue.destinationViewController;
        eventTableVC.delegate = self;
        
    }
    if ([segue.identifier isEqualToString:@"CreateEventVC"]){

        self.navigationController.navigationBar.hidden = NO;
    }
}

- (IBAction)unwindFromCreateEventVC:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSLog(@"segue: %@", segue);
    NSLog(@"sender: %@", sender);
    
}

@end

