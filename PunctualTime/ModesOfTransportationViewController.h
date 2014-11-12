//
//  ModesOfTransportationViewController.h
//  PunctualTime
//
//  Created by Adam Cooper on 11/11/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ModesOfTransportationDelegate

-(void)modeOfTransportationSelected:(NSString *)transportationType;

@end

@interface ModesOfTransportationViewController : UIViewController

@property id<ModesOfTransportationDelegate> delegate;

@end
