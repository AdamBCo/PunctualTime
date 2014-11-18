//
//  AppSwitcherViewDelegate.h
//  PunctualTime
//
//  Created by Nathan Hosselton on 11/17/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppSwitcherViewDelegate <NSObject>

- (void)showSwipeView;
- (void)hideSwipeView;

@end
