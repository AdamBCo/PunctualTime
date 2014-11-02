//
//  EventController.h
//  PunctualTime
//
//  Created by Nathan Hosselton on 11/1/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface EventController : NSObject

@property (readonly) NSMutableArray* events;

+ (EventController *)sharedEventController;
- (void)addEvent:(Event *)event withCompletion:(void (^)(void))completion;
- (void)removeEvent:(Event *)event;
- (void)refreshEvents;

@end
