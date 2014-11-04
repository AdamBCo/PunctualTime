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
@property (readwrite) CLLocationCoordinate2D startingAddress;
@property (readwrite) CLLocationCoordinate2D endingAddress;
@property (readwrite) NSDate* desiredArrivalTime;

@end

@implementation Event

#pragma mark - Public methods

- (instancetype)initWithEventName:(NSString *)name startingAddress:(CLLocationCoordinate2D)startingAddress endingAddress:(CLLocationCoordinate2D)endingAddress arrivalTime:(NSDate *)arrivalTime
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
        CLLocationDegrees startingLatitude = [decoder decodeDoubleForKey:@"kStartingAddressLat"];
        CLLocationDegrees startingLongitude = [decoder decodeDoubleForKey:@"kStartingAddressLong"];
        self.startingAddress = CLLocationCoordinate2DMake(startingLatitude, startingLongitude);

        CLLocationDegrees endingLatitude = [decoder decodeDoubleForKey:@"kStartingAddressLat"];
        CLLocationDegrees endingLongitude = [decoder decodeDoubleForKey:@"kEndingAddressLong"];
        self.endingAddress = CLLocationCoordinate2DMake(endingLatitude, endingLongitude);
        self.desiredArrivalTime = [decoder decodeObjectForKey:@"kArrivalTime"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.eventName forKey:@"kName"];
    [encoder encodeDouble:self.startingAddress.latitude forKey:@"kStartingAddressLat"];
    [encoder encodeDouble:self.startingAddress.longitude forKey:@"kStartingAddressLat"];
    [encoder encodeDouble:self.endingAddress.latitude forKey:@"kEndingAddressLat"];
    [encoder encodeDouble:self.endingAddress.longitude forKey:@"kEndingAddressLong"];
    [encoder encodeObject:self.desiredArrivalTime forKey:@"kArrivalTime"];
}

@end
