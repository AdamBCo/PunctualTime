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
static NSString* kStartingAddressLat = @"StartingAddressLat";
static NSString* kStartingAddressLon = @"StartingAddressLon";
static NSString* kEndingAddressLat = @"EndingAddressLat";
static NSString* kEndingAddressLon = @"EndingAddressLon";
static NSString* kArrivalTime = @"ArrivalTime";
static NSString* kLastNotificationDate = @"LastNotificationDate";
static NSString* kLastNotificationText = @"LastNotificationText";
static NSString* kLastTravelTime = @"LastTravelTime";
static NSString* kTransportationType = @"Transportation";
static NSString* kUniqueID = @"UniqueID";
static NSString* kCurrentNotificationCategory = @"CurrentNotificationCategory";

@interface Event () <NSCoding>

@property (readwrite) NSString* eventName;
@property (readwrite) CLLocationCoordinate2D startingAddress;
@property (readwrite) CLLocationCoordinate2D endingAddress;
@property (readwrite) NSDate* desiredArrivalTime;
@property (readwrite) NSDate* lastNotificationDate;
@property (readwrite) NSString* lastNotificationText;
@property (readwrite) NSNumber* lastTravelTime;
@property (readwrite) NSString* uniqueID;
@property (readwrite) NSString* currentNotificationCategory;
@property (readwrite) PTEventRecurrenceOption recurrenceInterval;

@end


@implementation Event

#pragma mark - Public methods

- (instancetype)initWithEventName:(NSString *)name startingAddress:(CLLocationCoordinate2D)startingAddress endingAddress:(CLLocationCoordinate2D)endingAddress arrivalTime:(NSDate *)arrivalTime transportationType:(NSString *)transporation recurrence:(PTEventRecurrenceOption)recurrenceInterval
{
    if (self = [super init])
    {
        self.eventName = name;
        self.startingAddress = startingAddress;
        self.endingAddress = endingAddress;
        self.desiredArrivalTime = arrivalTime;
        self.transportationType = transporation;
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
    UILocalNotification* newNotification = [UILocalNotification new];
    newNotification.timeZone = [NSTimeZone localTimeZone];
    newNotification.soundName = UILocalNotificationDefaultSoundName;
    newNotification.userInfo = @{@"Event": self.uniqueID};
    BOOL notificationWasSnoozed = ![self.currentNotificationCategory isEqualToString:categoryID];
    BOOL isNewEvent = self.currentNotificationCategory == nil ? YES : NO;
    self.currentNotificationCategory = categoryID;

    [self calculateETAWithCompletion:^(NSNumber* travelTime, NSError* error)
    {
        if (!error || notificationWasSnoozed)
        {
            if (notificationWasSnoozed && error) // Couldn't get new travel time, so create new notification from last travel time result
            {
                travelTime = self.lastTravelTime;
            }

            NSString* minuteWarning = [NSString new];
            double leaveTime = self.desiredArrivalTime.timeIntervalSince1970 - travelTime.doubleValue;

            if ([NSDate date].timeIntervalSince1970 > leaveTime) // Current time is after leave time
            {
                if (isNewEvent) // This is a new event so notify the user it's too late to make it on time
                {
                    NSDictionary* userInfo = @{@"overdue_amount": @(([NSDate date].timeIntervalSince1970 - leaveTime) * 60).stringValue};
                    NSError* newError = [NSError errorWithDomain:@"Event Creation Error"
                                                            code:PTEventCreationErrorCodeImpossibleEvent
                                                        userInfo:userInfo];
                    complete(newError);
                    return;
                }
            }

            double buffer = 5 * 60; // 5 minute buffer just to be sure they're on time

            if ([categoryID isEqualToString:SIXTY_MINUTE_WARNING])
            {
                minuteWarning = @"Sixty";
                newNotification.fireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - (60 * 60) - buffer)];
            }
            else if ([categoryID isEqualToString:THIRTY_MINUTE_WARNING])
            {
                minuteWarning = @"Thirty";
                newNotification.fireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - (30 * 60) - buffer)];
            }
            else if ([categoryID isEqualToString:FIFTEEN_MINUTE_WARNING])
            {
                minuteWarning = @"Fifteen";
                newNotification.fireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - (15 * 60) - buffer)];
            }
            else if ([categoryID isEqualToString:TEN_MINUTE_WARNING])
            {
                minuteWarning = @"Ten";
                newNotification.fireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - (10 * 60) - buffer)];
            }
            else if ([categoryID isEqualToString:FIVE_MINUTE_WARNING])
            {
                minuteWarning = @"Five";
                newNotification.fireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - (5 * 60) - buffer)];
            }
            else
            {
                newNotification.alertBody = [NSString stringWithFormat:@"%@: Leave Now!", self.eventName];
                newNotification.fireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - buffer)];
                self.lastNotificationDate = newNotification.fireDate;
                [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];

                complete(nil);
                return;
            }

            newNotification.alertBody = [NSString stringWithFormat:@"%@: %@ minute warning! %@", self.eventName, minuteWarning, NOTIFICATION_TRAILING_TEXT];
            newNotification.category = categoryID;
            self.lastNotificationDate = newNotification.fireDate;
            [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];

            complete(nil);
        }
        else  // There was a problem getting a new travel time so recreate the previously schedueled notification
        {
            if (self.lastNotificationDate)
            {
                newNotification.alertBody = self.lastNotificationText;
                newNotification.category = categoryID;
                newNotification.fireDate = self.lastNotificationDate;
                [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];

                complete(nil);
            }
            else // Can't recreate the notification, likely because this is the first
            {
                complete(error);
            }
        }
    }];
}

- (NSComparisonResult)compareEvent:(Event *)otherEvent
{
    return [self.desiredArrivalTime compare:otherEvent.desiredArrivalTime];
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

        if (error || [jsonResult[@"status"] isEqualToString:@"NOT_FOUND"] || [jsonResult[@"status"] isEqualToString:@"REQUEST_DENIED"])
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

        CLLocationDegrees startingLatitude = [decoder decodeDoubleForKey:kStartingAddressLat];
        CLLocationDegrees startingLongitude = [decoder decodeDoubleForKey:kStartingAddressLon];
        self.startingAddress = CLLocationCoordinate2DMake(startingLatitude, startingLongitude);
        CLLocationDegrees endingLatitude = [decoder decodeDoubleForKey:kEndingAddressLat];
        CLLocationDegrees endingLongitude = [decoder decodeDoubleForKey:kEndingAddressLon];
        self.endingAddress = CLLocationCoordinate2DMake(endingLatitude, endingLongitude);
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.eventName forKey:kName];
    [encoder encodeDouble:self.startingAddress.latitude forKey:kStartingAddressLat];
    [encoder encodeDouble:self.startingAddress.longitude forKey:kStartingAddressLon];
    [encoder encodeDouble:self.endingAddress.latitude forKey:kEndingAddressLat];
    [encoder encodeDouble:self.endingAddress.longitude forKey:kEndingAddressLon];
    [encoder encodeObject:self.desiredArrivalTime forKey:kArrivalTime];
    [encoder encodeObject:self.lastNotificationDate forKey:kLastNotificationDate];
    [encoder encodeObject:self.lastNotificationText forKey:kLastNotificationText];
    [encoder encodeObject:self.lastTravelTime forKey:kLastTravelTime];
    [encoder encodeObject:self.transportationType forKey:kTransportationType];
    [encoder encodeObject:self.uniqueID forKey:kUniqueID];
    [encoder encodeObject:self.currentNotificationCategory forKey:kCurrentNotificationCategory];

}



@end
