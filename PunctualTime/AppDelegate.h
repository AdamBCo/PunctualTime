//
//  AppDelegate.h
//  PunctualTime
//
//  Created by Adam Cooper on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserLocationManager.h"

@class Event;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UserLocationManager *userLocationManager;
@property (strong, nonatomic) UIWindow *window;

- (UILocalNotification *)getNotificationForEvent:(Event *)event;
- (void)requestNotificationPermissions;

@end

