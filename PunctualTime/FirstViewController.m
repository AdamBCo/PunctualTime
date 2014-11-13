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

@interface FirstViewController () <EventTableViewDelegate>
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


@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.eventNameLabel.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 100);
    self.timeTillEvent.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height + 100);
    self.cirularTimer.center =  CGPointMake(self.view.frame.size.width - 100, self.view.frame.size.height/2);

    self.navigationItem.title = @"Cancel"; // For the back button on CreateEventVC

    // Remove shadow on transparent toolbar:
    [self.addButtonToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.addButtonToolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.hidden = YES;
    INITIAL_CONTAINER_LOC = self.containerViewHeightConstraint.constant;

    self.sharedEventManager = [EventManager sharedEventManager];
    [self.sharedEventManager refreshEvents];
    self.selectedEvent = self.sharedEventManager.events.firstObject;


    [UIView animateWithDuration:3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.03 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.eventNameLabel.center = CGPointMake(self.view.frame.size.width/2, 300);
        self.timeTillEvent.center = self.view.center;
        self.cirularTimer.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height/2) - 20);
    } completion:^(BOOL finished) {
    }];

    int radius = 120;
    CAShapeLayer *circle = [CAShapeLayer layer];
//     Make a circular shape
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                             cornerRadius:radius].CGPath;

    // Center the shape in self.view
    circle.position = CGPointMake(CGRectGetMidX(self.view.frame)-radius,
                                  CGRectGetMidY(self.view.frame)-radius-25);

    // Configure the apperence of the circle
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor whiteColor].CGColor;
    circle.lineWidth = 5;

    // Add to parent layer
    [self.view.layer addSublayer:circle];

    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = 3.0; // "animate over 10 seconds or so.."
    drawAnimation.repeatCount         = 1.0;  // Animate only once..

    // Animate from no part of the stroke being drawn to the entire stroke being drawn
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];

    // Experiment with timing to get the appearence to look the way you want
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    // Add the animation to the circle
    [circle addAnimation:drawAnimation forKey:@"drawCircleAnimation"];

    [self.view.layer insertSublayer:circle below:self.containerView.layer];


    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateCounter)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)updateCounter{

    NSDate *startDate = [NSDate date];
    NSDate *destinationDate = self.selectedEvent.desiredArrivalTime;
    int seconds = [destinationDate timeIntervalSinceDate: startDate];

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


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EventTableVC"])
    {
        EventTableViewController* eventTableVC = segue.destinationViewController;
        eventTableVC.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"CreateEventVC"])
    {
        self.navigationController.navigationBar.hidden = NO;
    }
}

- (IBAction)unwindFromCreateEventVC:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue: %@", segue);
    NSLog(@"sender: %@", sender);
}

@end
