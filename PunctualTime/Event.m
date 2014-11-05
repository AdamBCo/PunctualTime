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
static NSString* kTransportationType = @"Transportation";
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

- (instancetype)initWithEventName:(NSString *)name startingAddress:(CLLocationCoordinate2D)startingAddress endingAddress:(CLLocationCoordinate2D)endingAddress arrivalTime:(NSDate *)arrivalTime transportationType:(NSString *)transporation
{
    if (self = [super init])
    {
        self.eventName = name;
        self.startingAddress = startingAddress;
        self.endingAddress = endingAddress;
        self.desiredArrivalTime = arrivalTime;
        self.transportationType = transporation;

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
    newNotification.timeZone = [NSTimeZone localTimeZone];
    newNotification.soundName = UILocalNotificationDefaultSoundName;
    newNotification.userInfo = @{@"Event": self.uniqueID};

    [self calculateETAWithCompletion:^(NSNumber *travelTime)
    {
        NSString* minuteWarning = [NSString new];
        double leaveTime = self.desiredArrivalTime.timeIntervalSince1970 - travelTime.doubleValue;
        double buffer = 5 * 60; // 5 minute buffer just to be sure they're on time

        if ([categoryID isEqualToString:kThirtyMinuteWarning])
        {
            minuteWarning = @"Thirty";
            newNotification.fireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - (30 * 60) - buffer)];
        }
        else if ([categoryID isEqualToString:kFifteenMinuteWarning])
        {
            minuteWarning = @"Fifteen";
            newNotification.fireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - (15 * 60) - buffer)];
        }
        else if ([categoryID isEqualToString:kFiveMinuteWarning])
        {
            minuteWarning = @"Five";
            newNotification.fireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - (5 * 60) - buffer)];
        }
        else
        {
            newNotification.alertBody = [NSString stringWithFormat:@"%@: Leave Now!", self.name];
            newNotification.fireDate = [NSDate dateWithTimeIntervalSince1970:(leaveTime - buffer)];
            [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
            return;
        }

        newNotification.alertBody = [NSString stringWithFormat:@"%@: %@ minute warning! Slide to schedule another", self.name, minuteWarning];
        newNotification.category = categoryID;
        [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
    }];
}

- (NSComparisonResult)compareEvent:(Event *)otherEvent
{
    return [self.desiredArrivalTime compare:otherEvent.desiredArrivalTime];
}


#pragma mark - Private methods

-(void)calculateETAWithCompletion:(void (^)(NSNumber *travelTime))complete
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *userLocation = appDelegate.userLocationManager.location;
    NSString *google = @"https://maps.googleapis.com/maps/api/directions/json?origin=";
    NSString *currentLatitude = [NSString stringWithFormat:@"%f,",userLocation.coordinate.latitude];
    NSString *currentLongitude = [NSString stringWithFormat:@"%f",userLocation.coordinate.longitude];
    NSString *destination = [NSString stringWithFormat: @"&destination="];

    NSString *latitude = @(self.endingAddress.latitude).stringValue;
    NSString *longitude = @(self.endingAddress.longitude).stringValue;
    NSString *apiAccessKeyURL = [NSString stringWithFormat:@"&waypoints=optimize:true&key=AIzaSyBB2Uc2kK0P3zDKwgyYlyC8ivdDCSyy4xg"];
    NSString *arrivalTime = [NSString stringWithFormat:@"&arrival_time=1415133552"];
    NSString *modeOfTransportation = [NSString stringWithFormat:@"&mode=%@",self.transportationType];

    NSArray *urlStrings = @[google, currentLatitude, currentLongitude, destination, latitude, longitude, apiAccessKeyURL, arrivalTime, modeOfTransportation];
    NSString *joinedString = [urlStrings componentsJoinedByString:@""];

    NSURL *url = [NSURL URLWithString:joinedString];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

          NSNumber *travelTimeEpoch = [[[[[[jSONresult objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"duration"] objectForKey:@"value"];
          complete(travelTimeEpoch);
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
        self.transportationType = [decoder decodeObjectForKey:kTransportationType];
        self.uniqueID = [decoder decodeObjectForKey:kUniqueID];

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
    [encoder encodeObject:self.transportationType forKey:kTransportationType];
    [encoder encodeObject:self.uniqueID forKey:kUniqueID];
}

@end
