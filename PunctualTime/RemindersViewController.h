//
//  RemindersViewController.h
//  PunctualTime
//
//  Created by Nathan Hosselton on 11/12/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RemindersViewControllerDelegate <NSObject>

- (void)reminderSelected:(NSString *)reminderCategory;

@end

@interface RemindersViewController : UIViewController

@property id<RemindersViewControllerDelegate> delegate;

@end
