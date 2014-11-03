//
//  Event.m
//  PunctualTime
//
//  Created by Nathan Hosselton on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "Event.h"

@interface Event () <NSCoding>

@property (readwrite) NSString* eventName;
@property (readwrite) NSString* startingAddress;
@property (readwrite) NSString* endingAddress;
@property (readwrite) NSDate* desiredArrivalTime;

@end

@implementation Event

#pragma mark - Public methods

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

- (NSComparisonResult)compareEvent:(Event *)otherEvent
{
    return [self.desiredArrivalTime compare:otherEvent.desiredArrivalTime];
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        self.eventName = [decoder decodeObjectForKey:@"kName"];
        self.startingAddress = [decoder decodeObjectForKey:@"kStartingAddress"];
        self.endingAddress = [decoder decodeObjectForKey:@"kEndingAddress"];
        self.desiredArrivalTime = [decoder decodeObjectForKey:@"kArrivalTime"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.eventName forKey:@"kName"];
    [encoder encodeObject:self.startingAddress forKey:@"kStartingAddress"];
    [encoder encodeObject:self.endingAddress forKey:@"kEndingAddress"];
    [encoder encodeObject:self.desiredArrivalTime forKey:@"kArrivalTime"];
}

@end
