//
//  Event.m
//  PunctualTime
//
//  Created by Nathan Hosselton on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "Event.h"

static NSString* kName = @"Name";
static NSString* kStartingAddress = @"StartingAddress";
static NSString* kEndingAddress = @"EndingAddress";
static NSString* kArrivalTime = @"ArrivalTime";
static NSString* kUniqueID = @"UniqueID";

@interface Event () <NSCoding>

@property (readwrite) NSString* eventName;
@property (readwrite) NSString* startingAddress;
@property (readwrite) NSString* endingAddress;
@property (readwrite) NSDate* desiredArrivalTime;
@property (readwrite) NSString* uniqueID;

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
        self.eventName = [decoder decodeObjectForKey:kName];
        self.startingAddress = [decoder decodeObjectForKey:kStartingAddress];
        self.endingAddress = [decoder decodeObjectForKey:kEndingAddress];
        self.desiredArrivalTime = [decoder decodeObjectForKey:kArrivalTime];
        self.uniqueID = [decoder decodeObjectForKey:kUniqueID];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.eventName forKey:kName];
    [encoder encodeObject:self.startingAddress forKey:kStartingAddress];
    [encoder encodeObject:self.endingAddress forKey:kEndingAddress];
    [encoder encodeObject:self.desiredArrivalTime forKey:kArrivalTime];
    [encoder encodeObject:self.uniqueID forKey:kUniqueID];
}

@end
