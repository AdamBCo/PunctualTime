//
//  Event.m
//  PunctualTime
//
//  Created by Nathan Hosselton on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "Event.h"
#import "Constants.h"

static NSString* kName = @"Name";
static NSString* kStartingAddress = @"StartingAddress";
static NSString* kEndingAddress = @"EndingAddress";
static NSString* kArrivalTime = @"ArrivalTime";
static NSString* kUniqueID = @"UniqueID";

@interface Event () <NSCoding>

@property (readwrite) NSString* eventName;
@property (readwrite) CLLocationCoordinate2D startingAddress;
@property (readwrite) CLLocationCoordinate2D endingAddress;
@property (readwrite) NSDate* desiredArrivalTime;
@property (readwrite) NSString* uniqueID;

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

        CFUUIDRef uuid = CFUUIDCreate(NULL);
        NSString *uniqueID = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);

        self.uniqueID = uniqueID;
    }

    return self;
}

- (void)makeLocalNotificationWithCategoryIdentifier:(NSString *)categoryID 
{
    UILocalNotification *newNotification = [UILocalNotification new];
    newNotification.fireDate = self.currentNotificationTime;
    newNotification.timeZone = [NSTimeZone localTimeZone];
    newNotification.soundName = UILocalNotificationDefaultSoundName;
    newNotification.userInfo = @{@"Event": self.uniqueID};

    NSString* minuteWarning = [NSString new];
    if ([categoryID isEqualToString:kThirtyMinuteWarning])
    {
        minuteWarning = @"Thirty";
    }
    else if ([categoryID isEqualToString:kFifteenMinuteWarning])
    {
        minuteWarning = @"Fifteen";
    }
    else if ([categoryID isEqualToString:kFiveMinuteWarning])
    {
        minuteWarning = @"Five";
    }
    else
    {
        newNotification.alertBody = [NSString stringWithFormat:@"Leave Now!"];
        [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
        return;
    }

    newNotification.alertBody = [NSString stringWithFormat:@"%@: %@ Minute Warning! Slide to schedule another", self.name, minuteWarning];
    newNotification.category = categoryID;
    [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
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
