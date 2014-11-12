//
//  Constants.h
//  PunctualTime
//
//  Created by Nathan Hosselton on 11/4/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

// UILocalNotification category identifiers
#define SIXTY_MINUTE_WARNING (@"SixtyMinuteWarning")
#define THIRTY_MINUTE_WARNING (@"ThirtyMinuteWarning")
#define FIFTEEN_MINUTE_WARNING (@"FifteenMinuteWarning")
#define TEN_MINUTE_WARNING (@"TenMinuteWarning")
#define FIVE_MINUTE_WARNING (@"FiveMinuteWarning")

// UILocalNotification action identifiers
#define THIRTY_MINUTE_ACTION (@"ThirtyMinuteAction")
#define FIFTEEN_MINUTE_ACTION (@"FifteenMinuteAction")
#define TEN_MINUTE_ACTION (@"TenMinuteAction")
#define FIVE_MINUTE_ACTION (@"FiveMinuteAction")
#define ZERO_MINUTE_ACTION (@"ZeroMinuteAction")

// Notification body trailing string
#define NOTIFICATION_TRAILING_TEXT (@"Slide to snooze")

// Event creation error codes
typedef NS_ENUM(NSUInteger, PTEventCreationErrorCode) {
    PTEventCreationErrorCodeAPIError = 0,
    PTEventCreationErrorCodeImpossibleEvent
};

// Event recurrence options
typedef NS_ENUM(NSUInteger, PTEventRecurrenceOption) {
    PTEventRecurrenceOptionDaily = 0,
    PTEventRecurrenceOptionWeekdays,
    PTEventRecurrenceOptionWeekly
};
