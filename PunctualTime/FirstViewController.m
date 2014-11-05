//
//  FirstViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/5/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "FirstViewController.h"
#import "EventController.h"
#import "Event.h"

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTillEvent;
@property EventController *sharedEventController;
@property Event *selectedEvent;
@property NSNumber *timeTillEventTimer;


@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.sharedEventController = [EventController sharedEventController];
    [self.sharedEventController refreshEvents];


    NSDate *startDate = [NSDate date];

    NSDate *destinationDate = self.selectedEvent.desiredArrivalTime;
    NSLog(@"Count: %lu ",(unsigned long)self.sharedEventController.events.count);



    NSLog(@"Seconds --------> %f",[destinationDate timeIntervalSinceDate: startDate]);

    NSLog(@"EventOne: %@",self.selectedEvent.desiredArrivalTime);
    NSLog(@"Current Time: %@",[NSDate date]);
    NSLog(@"Current Time Two: %@",[NSDate date]);



    self.eventNameLabel.text = self.selectedEvent.name;

    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(negativeOneSecond)
                                   userInfo:nil
                                    repeats:YES];
}

-(void)negativeOneSecond{
    int value = ([self.timeTillEventTimer intValue] - 1);
    NSLog(@"Hello %d",value);
    self.timeTillEventTimer = [NSNumber numberWithInt:value];

    self.timeTillEvent.text = [NSString stringWithFormat:@"%d",value];

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
