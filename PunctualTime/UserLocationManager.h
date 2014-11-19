//
//  UserLocationController.h
//  PunctualTime
//
//  Created by Adam Cooper on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface UserLocationManager : NSObject

@property CLLocation *location;

+ (UserLocationManager *)sharedLocationManager;

@end
