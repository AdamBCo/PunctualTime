//
//  EventLite.h
//  PunctualTime
//
//  Created by Nathan Hosselton on 12/6/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventLite : NSObject

@property (readonly) NSString* eventName;
@property (readonly) NSDate *lastLeaveTime;

@end
