//
//  Event.h
//  PunctualTime
//
//  Created by Nathan Hosselton on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

// Event creation error codes
typedef NS_ENUM(NSUInteger, PTEventCreationErrorCode) {
    PTEventCreationErrorCodeAPIError = 0,
    PTEventCreationErrorCodeImpossibleEvent
};

// Event recurrence options
typedef NS_ENUM(NSUInteger, PTEventRecurrenceOption) {
    PTEventRecurrenceOptionDaily = 0,
    PTEventRecurrenceOptionWeekdays,
    PTEventRecurrenceOptionWeekly,
    PTEventRecurrenceOptionNone
};

@interface Event : NSObject

@property (readonly) NSString* eventName;
@property (readonly) CLLocationCoordinate2D startingAddress;
@property (readonly) CLLocationCoordinate2D endingAddress;
@property (readonly) NSDate* desiredArrivalTime;
@property (readonly) NSDate* lastNotificationDate;
@property (readonly) NSString* lastNotificationText;
@property (readonly) NSNumber* lastTravelTime;
@property (readonly) NSString* uniqueID;
@property (readonly) NSString* currentNotificationCategory;
@property NSString *transportationType;



- (instancetype)initWithEventName:(NSString *)name
                  startingAddress:(CLLocationCoordinate2D)startingAddress
                    endingAddress:(CLLocationCoordinate2D)endingAddress
                      arrivalTime:(NSDate *)arrivalTime
               transportationType:(NSString *)transporation;
- (void)makeLocalNotificationWithCategoryIdentifier:(NSString *)categoryID completion:(void (^)(NSError* error))complete;
- (NSComparisonResult)compareEvent:(Event *)otherObject;


@end
