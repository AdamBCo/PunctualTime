//
//  DatePickerViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/8/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "DatePickerViewController.h"
#import "MinutesViewController.h"
#import "HourViewController.h"


@interface DatePickerViewController () <UIGestureRecognizerDelegate, MinuteViewDelegate, HourViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property NSString *timeOfDay;


@end

@implementation DatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

-  (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"MinutesSegue"]) {
        MinutesViewController *minutesViewController = segue.destinationViewController;
        minutesViewController.delegate = self;

    } else if ([segue.identifier isEqualToString:@"HourSegue"]){
        HourViewController *hoursViewController = segue.destinationViewController;
        hoursViewController.delegate = self;

    }
}
- (IBAction)onDoneButtonPressed:(id)sender {

}

- (IBAction)segemntedControl:(id)sender {
    switch ([self.segmentedControl selectedSegmentIndex]) {
        case 0:
            self.timeOfDay = @"AM";
            NSLog(@"AM");
            break;
        case 1:
            self.timeOfDay = @"PM";
            NSLog(@"PM");
            break;

        default:
            break;
    }
}

-(void)minuteSelected:(NSString *)string{
    NSLog(@"Minute: %@",string);
}

-(void)hourSelected:(NSString *)string{
    NSLog(@"Hour: %@",string);
}


@end
