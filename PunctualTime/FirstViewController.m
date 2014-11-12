//
//  FirstViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/5/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "FirstViewController.h"
#import "EventTableViewController.h"
#import "EventManager.h"
#import "Event.h"
#import "CircularTimer.h"

@interface FirstViewController () <EventTableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTillEvent;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property EventManager *sharedEventManager;
@property Event *selectedEvent;
@property NSNumber *timeTillEventTimer;
@property CircularTimer *cirularTimer;
@property BOOL tableViewIsExpanded;


@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.sharedEventManager = [EventManager sharedEventManager];
    [self.sharedEventManager refreshEvents];
    self.selectedEvent = self.sharedEventManager.events.firstObject;

    self.cirularTimer = [[CircularTimer alloc]initWithPosition:CGPointMake(60.0f, 130.0f)
                                                        radius:100.0
                                                internalRadius:90.0
                                             circleStrokeColor:[UIColor greenColor]
                                       activeCircleStrokeColor:[UIColor redColor]
                                                   initialDate:[NSDate date]
                                                     finalDate:self.selectedEvent.desiredArrivalTime
                                                 startCallback:^{
                                                     NSLog(@"We are good!");
                                                 } endCallback:^{
                                                     NSLog(@"Hello Chicago");
                                                 }];

    [self.view addSubview:self.cirularTimer];


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
        if (self.containerViewHeightConstraint.constant == 50)
        {
            self.tableViewIsExpanded = NO;
        }
        else
        {
            self.tableViewIsExpanded = YES;
        }
    }
    else if (UIGestureRecognizerStateChanged == gesture.state)
    {
        CGPoint translation = [gesture translationInView:gesture.view];
        self.containerViewHeightConstraint.constant -= translation.y;
        [gesture setTranslation:CGPointMake(0, 0) inView:gesture.view];
    }
    else if (UIGestureRecognizerStateEnded == gesture.state) // Gesture has ended so animate to desired location
    {
        if (self.tableViewIsExpanded) // Close it
        {
            self.containerViewHeightConstraint.constant = 50;
        }
        else
        {
            self.containerViewHeightConstraint.constant = self.view.frame.size.height;
        }
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    else // Gesture was cancelled or failed so animate back to original location
    {
        self.containerViewHeightConstraint.constant = 50;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
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
}

@end
