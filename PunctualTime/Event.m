//
//  Event.m
//  PunctualTime
//
//  Created by Nathan Hosselton on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "Event.h"
#import "Constants.h"
#import "AppDelegate.h"

static NSString* kName = @"Name";
static NSString* kEndingAddressLat = @"EndingAddressLat";
static NSString* kEndingAddressLon = @"EndingAddressLon";
static NSString* kArrivalTime = @"ArrivalTime";
static NSString* kLastNotificationDate = @"LastNotificationDate";
static NSString* kLastNotificationText = @"LastNotificationText";
static NSString* kLastTravelTime = @"LastTravelTime";
static NSString* kTransportationType = @"Transportation";
static NSString* kUniqueID = @"UniqueID";
static NSString* kCurrentNotificationCategory = @"CurrentNotificationCategory";
static NSString* kInitialNotificationCategory = @"InitialNotificationCategory";
static NSString* kRecurrenceInterval = @"RecurrenceInterval";
static NSString* kLastLeaveTime = @"LastLeaveTime";


@interface Event () <NSCoding>

@property (readwrite) NSString* eventName;
@property (readwrite) CLLocationCoordinate2D endingAddress;
@property (readwrite) NSDate* desiredArrivalTime;
@property (readwrite) NSString* uniqueID;
@property (readwrite) PTEventRecurrenceOption recurrenceInterval;
@property (readwrite) NSString* transportationType;
@property (readwrite) NSString* initialNotificationCategory;

@property (readwrite) NSString* currentNotificationCategory;
@property (readwrite) NSDate* lastNotificationDate;
@property (readwrite) NSString* lastNotificationText;
@property (readwrite) NSNumber* lastTravelTime;
@property (readwrite) NSDate* lastLeaveTime;

@end


@implementation Event

#pragma mark - Public methods

- (instancetype)initWithEventName:(NSString *)name endingAddress:(CLLocationCoordinate2D)endingAddress arrivalTime:(NSDate *)arrivalTime transportationType:(NSString *)transporation notificationCategory:(NSString *)category recurrence:(PTEventRecurrenceOption)recurrenceInterval
{
    if (self = [super init])
    {
        self.eventName = name;
        self.endingAddress = endingAddress;
        self.desiredArrivalTime = arrivalTime;
        self.transportationType = transporation;
        self.initialNotificationCategory = category;
        self.recurrenceInterval = recurrenceInterval;

        CFUUIDRef uuid = CFUUIDCreate(NULL);
        NSString *uniqueID = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);

        self.uniqueID = uniqueID;
    }

    return self;
}

- (void)makeLocalNotificationWithCategoryIdentifier:(NSString *)categoryID completion:(void (^)(NSError* error))complete
{
    BOOL isNewEvent = self.lastNotificationDate == nil ? YES : NO;

    [self calculateETAWithCompletion:^(NSNumber* travelTime, NSError* error)
    {
        if (!error || !isNewEvent)
        {
            if (error && !isNewEvent)
            {
                travelTime = self.lastTravelTime;
            }

            NSString* minuteWarning;
            NSDate* notificationFireDate;
            double buffer = 5 * 60; // 5 minute buffer just to be sure they're on time
            double leaveTime = self.desiredArrivalTime.timeIntervalSince1970 - travelTime.doubleValue - buffer;

            // Check if the leave time is in the past
            if ([NSDate date].timeIntervalSince1970 > leaveTime)
            {
                if (isNewEvent) // This is a new event so notify the user it's too late to make it on time
                {
                    NSDictionary* userInfo = @{@"overdue_amount": @(roundf(([NSDate date].timeIntervalSince1970 - leaveTime)/60)).stringValue};
                    NSError* newError = [NSError errorWithDomain:@"Event Creation Error"
                                                            code:PTEventCreationErrorCodeImpossibleEvent
                                                        userInfo:userInfo];
                    complete(newError);
                    return;
                }
            }

            if ([categoryID isEqualToString:SIXTY_MINUTE_WARNING])
            {
                minuteWarning = @"Sixty minute warning!";
                notificationFireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - (60 * 60))];
            }
            else if ([categoryID isEqualToString:THIRTY_MINUTE_WARNING])
            {
                minuteWarning = @"Thirty minute warning!";
                notificationFireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - (30 * 60))];
            }
            else if ([categoryID isEqualToString:FIFTEEN_MINUTE_WARNING])
            {
                minuteWarning = @"Fifteen minute warning!";
                notificationFireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - (15 * 60))];
            }
            else if ([categoryID isEqualToString:TEN_MINUTE_WARNING])
            {
                minuteWarning = @"Ten minute warning!";
                notificationFireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - (10 * 60))];
            }
            else if ([categoryID isEqualToString:FIVE_MINUTE_WARNING])
            {
                minuteWarning = @"Five minute warning!";
                notificationFireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - (5 * 60))];
            }
            else // Zero minute warning
            {
                minuteWarning = @"Leave Now!";
                notificationFireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime)];
            }

            // Schedule the new notification
            UILocalNotification* newNotification = [UILocalNotification new];
            newNotification.timeZone = [NSTimeZone localTimeZone];
            newNotification.soundName = UILocalNotificationDefaultSoundName;
            newNotification.userInfo = @{@"Event": self.uniqueID};
            newNotification.category = categoryID;
            newNotification.fireDate = notificationFireDate;
            NSString* trailingMessageText = categoryID ? NOTIFICATION_TRAILING_TEXT : @"";
            newNotification.alertBody = [NSString stringWithFormat:@"%@: %@%@", self.eventName, minuteWarning, trailingMessageText];
            [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];

            // Save notification data for future error handling and general status reference
            self.currentNotificationCategory = categoryID;
            self.lastNotificationDate = newNotification.fireDate;
            self.lastNotificationText = newNotification.alertBody;
            self.lastLeaveTime = [NSDate dateWithTimeIntervalSince1970: leaveTime];
            self.lastTravelTime = travelTime;

            [self.delegate eventWasUpdated:self];
            complete(nil);
        }
        else
        {
            complete(error);
        }
    }];
}

- (void)rescheduleWithCompletion:(void (^)(void))completion
{
    NSTimeInterval dayInterval = (60*60*24);
    NSTimeInterval weekdayInterval;

    // Get the current day of week
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger numericDayOfWeek = [weekdayComponents weekday];
    double daysSinceEvent = (floor((([NSDate date].timeIntervalSince1970/60)/60)/24) - (((self.desiredArrivalTime.timeIntervalSince1970/60)/60)/24));
    daysSinceEvent *= dayInterval;

    if (numericDayOfWeek == 6) // Today is Friday so weekdayInterval should account for weekend
    {
        weekdayInterval = daysSinceEvent + (dayInterval * 3);
    }
    else if (numericDayOfWeek == 7) // Today is Saturday so skip to Monday
    {
        weekdayInterval = daysSinceEvent + (dayInterval * 2);
    }
    else
    {
        weekdayInterval = daysSinceEvent + dayInterval;
    }

    switch (self.recurrenceInterval)
    {
        case PTEventRecurrenceOptionDaily:
            self.desiredArrivalTime = [NSDate dateWithTimeIntervalSince1970:(self.desiredArrivalTime.timeIntervalSince1970 + daysSinceEvent + dayInterval)];
            break;
        case PTEventRecurrenceOptionWeekdays:
            self.desiredArrivalTime = [NSDate dateWithTimeIntervalSince1970:(self.desiredArrivalTime.timeIntervalSince1970 + weekdayInterval)];
            break;
        case PTEventRecurrenceOptionWeekly:
            self.desiredArrivalTime = [NSDate dateWithTimeIntervalSince1970:(self.desiredArrivalTime.timeIntervalSince1970 + daysSinceEvent + (dayInterval*7))];
            break;

        default:
            break;
    }

    [self makeLocalNotificationWithCategoryIdentifier:self.initialNotificationCategory completion:^(NSError *error) {
        completion();
    }];
}

- (NSComparisonResult)compareEvent:(Event *)otherEvent
{
    return [self.lastLeaveTime compare:otherEvent.lastLeaveTime];
}


#pragma mark - Private methods

-(void)calculateETAWithCompletion:(void (^)(NSNumber* travelTime, NSError* error))complete
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;

    NSString *google = @"https://maps.googleapis.com/maps/api/directions/json?origin=";

    CLLocation *userLocation = appDelegate.userLocationManager.location;
    NSString *currentLatitude = @(userLocation.coordinate.latitude).stringValue;
    NSString *currentLongitude = @(userLocation.coordinate.longitude).stringValue;
    NSString *originCoord = [NSString stringWithFormat:@"%@,%@", currentLatitude, currentLongitude];
    NSString *destination = [NSString stringWithFormat: @"&destination="];

    NSString *latitude = @(self.endingAddress.latitude).stringValue;
    NSString *longitude = @(self.endingAddress.longitude).stringValue;
    NSString *destinationCoord = [NSString stringWithFormat:@"%@,%@",latitude,longitude];

    NSString *apiAccessKeyURL = [NSString stringWithFormat:@"&waypoints=optimize:true&key=AIzaSyBB2Uc2kK0P3zDKwgyYlyC8ivdDCSyy4xg"];
    int arrivalInt = self.desiredArrivalTime.timeIntervalSince1970;
    NSString *arrivalTime = [NSString stringWithFormat:@"&arrival_time=%d",arrivalInt];
    NSString *modeOfTransportation = [NSString stringWithFormat:@"&mode=%@",self.transportationType];

    NSArray *urlStrings = @[google, originCoord, destination, destinationCoord, apiAccessKeyURL, arrivalTime, modeOfTransportation];
    NSString *joinedString = [urlStrings componentsJoinedByString:@""];
    NSURL *url = [NSURL URLWithString:[joinedString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSLog(@"URL: %@",url);

    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        //NSLog(@"JSON: %@",jsonResult);

        if (error || [jsonResult[@"status"] isEqualToString:@"NOT_FOUND"] ||
                [jsonResult[@"status"] isEqualToString:@"REQUEST_DENIED"] ||
                    [jsonResult[@"status"] isEqualToString:@"ZERO_RESULTS"])
        {
            if (!error)
            {
                NSDictionary* userInfo = @{@"error": jsonResult[@"status"]};
                NSError* newError = [NSError errorWithDomain:@"API Error"
                                                        code:PTEventCreationErrorCodeAPIError
                                                    userInfo:userInfo];
                complete(nil, newError);
                return;
            }
            complete(nil, error);
            return;
        }
        else
        {
            NSNumber *travelTimeEpoch = [[[[[[jsonResult objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"duration"] objectForKey:@"value"];
            complete(travelTimeEpoch, nil);
        }
    }];

    [task resume];
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        self.eventName = [decoder decodeObjectForKey:kName];
        self.desiredArrivalTime = [decoder decodeObjectForKey:kArrivalTime];
        self.lastNotificationDate = [decoder decodeObjectForKey:kLastNotificationDate];
        self.lastNotificationText = [decoder decodeObjectForKey:kLastNotificationText];
        self.lastTravelTime = [decoder decodeObjectForKey:kLastTravelTime];
        self.transportationType = [decoder decodeObjectForKey:kTransportationType];
        self.uniqueID = [decoder decodeObjectForKey:kUniqueID];
        self.currentNotificationCategory = [decoder decodeObjectForKey:kCurrentNotificationCategory];
        self.initialNotificationCategory = [decoder decodeObjectForKey:kInitialNotificationCategory];
        self.recurrenceInterval = [decoder decodeIntegerForKey:kRecurrenceInterval];
        self.lastLeaveTime = [decoder decodeObjectForKey:kLastLeaveTime];

        CLLocationDegrees endingLatitude = [decoder decodeDoubleForKey:kEndingAddressLat];
        CLLocationDegrees endingLongitude = [decoder decodeDoubleForKey:kEndingAddressLon];
        self.endingAddress = CLLocationCoordinate2DMake(endingLatitude, endingLongitude);
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.eventName forKey:kName];
    [encoder encodeDouble:self.endingAddress.latitude forKey:kEndingAddressLat];
    [encoder encodeDouble:self.endingAddress.longitude forKey:kEndingAddressLon];
    [encoder encodeObject:self.desiredArrivalTime forKey:kArrivalTime];
    [encoder encodeObject:self.lastNotificationDate forKey:kLastNotificationDate];
    [encoder encodeObject:self.lastNotificationText forKey:kLastNotificationText];
    [encoder encodeObject:self.lastTravelTime forKey:kLastTravelTime];
    [encoder encodeObject:self.transportationType forKey:kTransportationType];
    [encoder encodeObject:self.uniqueID forKey:kUniqueID];
    [encoder encodeObject:self.currentNotificationCategory forKey:kCurrentNotificationCategory];
    [encoder encodeObject:self.initialNotificationCategory forKey:kInitialNotificationCategory];
    [encoder encodeInteger:self.recurrenceInterval forKey:kRecurrenceInterval];
    [encoder encodeObject:self.lastLeaveTime forKey:kLastLeaveTime];
}

@end
