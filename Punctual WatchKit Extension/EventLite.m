//
//  EventLite.m
//  PunctualTime
//
//  Created by Nathan Hosselton on 12/6/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "EventLite.h"

static NSString* kName = @"Name";
static NSString* kLastLeaveTime = @"LastLeaveTime";

@interface EventLite () <NSCoding>

@property (readwrite) NSString* eventName;
@property (readwrite) NSDate* lastLeaveTime;

@end


@implementation EventLite

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        self.eventName = [decoder decodeObjectForKey:kName];
        self.lastLeaveTime = [decoder decodeObjectForKey:kLastLeaveTime];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    //
}

@end
