//
//  Event.m
//  PunctualTime
//
//  Created by Nathan Hosselton on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "Event.h"

@interface Event ()

@property (readwrite) NSString* eventName;
@property (readwrite) NSString* startingAddress;
@property (readwrite) NSString* endingAddress;
@property (readwrite) NSDate* desiredArrivalTime;

@end

@implementation Event

- (instancetype)initWithEventName:(NSString *)name startingAddress:(NSString *)startingAddress endingAddress:(NSString *)endingAddress arrivalTime:(NSDate *)arrivalTime
{
    if (self = [super init])
    {
        self.eventName = name;
        self.startingAddress = startingAddress;
        self.endingAddress = endingAddress;
        self.desiredArrivalTime = arrivalTime;
    }

    return self;
}

@end
