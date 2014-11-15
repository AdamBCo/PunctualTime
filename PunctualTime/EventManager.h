//
//  EventController.h
//  PunctualTime
//
//  Created by Nathan Hosselton on 11/1/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface EventManager : NSObject

@property (readonly) NSMutableArray* events;

+ (EventManager *)sharedEventManager;
- (void)addEvent:(Event *)event;
- (void)removeEvent:(Event *)event;
- (void)handleExpiredEvent:(Event *)event completion:(void (^)())completion;
- (void)refreshEventsWithCompletion:(void (^)(void))completion;
- (Event *)findEventWithUniqueID:(NSString *)uniqueID;

@end
