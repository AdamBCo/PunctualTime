//
//  FirstViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/5/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "FirstViewController.h"
#import "EventManager.h"
#import "Event.h"
#import "CircularTimer.h"

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTillEvent;
@property EventManager *sharedEventController;
@property Event *selectedEvent;
@property NSNumber *timeTillEventTimer;
@property CircularTimer *cirularTimer;


@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.sharedEventController = [EventManager sharedEventManager];
    [self.sharedEventController refreshEvents];
    self.selectedEvent = self.sharedEventController.events.firstObject;

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

@end
