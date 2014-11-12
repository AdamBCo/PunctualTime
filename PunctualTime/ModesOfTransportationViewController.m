//
//  ModesOfTransportationViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/11/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "ModesOfTransportationViewController.h"
#import "Constants.h"

@interface ModesOfTransportationViewController ()

@end

@implementation ModesOfTransportationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTransportationButtonPressed:(UIButton *)sender {

    switch (sender.tag)
    {
        case 0:
            [self.delegate modeOfTransportationSelected:TRANSPO_DRIVING];
            break;
        case 1:
            [self.delegate modeOfTransportationSelected:TRANSPO_WALKING];
            break;
        case 2:
            [self.delegate modeOfTransportationSelected:TRANSPO_BIKING];
            break;
        case 3:
            [self.delegate modeOfTransportationSelected:TRANSPO_TRANSIT];
            break;

        default:
            break;
    }
}


@end
