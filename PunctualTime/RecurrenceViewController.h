//
//  RecurrenceViewController.h
//  PunctualTime
//
//  Created by Nathan Hosselton on 11/13/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@protocol RecurrenceViewControllerDelegate <NSObject>

- (void)recurrenceSelected:(PTEventRecurrenceOption)recurrenceInterval;

@end

@interface RecurrenceViewController : UIViewController

@property id<RecurrenceViewControllerDelegate> delegate;

@end
