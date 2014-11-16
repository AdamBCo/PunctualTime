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
#define NOTIFICATION_TRAILING_TEXT (@" Slide to snooze")

// Transporation strings for Google Maps API
#define TRANSPO_DRIVING @"driving"
#define TRANSPO_WALKING @"walking"
#define TRANSPO_BIKING @"bicycling"
#define TRANSPO_TRANSIT @"transit"

// NSNotificationCenter
#define EVENTS_UPDATED @"EventsUpdated"

//// Screen sizes
///// The height and width (in points) of a 3.5" iPhone
//#define k3_5iPhoneHeight = 480.0
//#define k3_5iPhoneWidth = 320.0
///// The height (in points) of a 4" iPhone
//#define k4_iPhoneHeight = 568.0
///// The height and width (in points) of a 4.7" iPhone
//#define k4_7iPhoneHeight = 667.0
//#define k4_7iPhoneWidth = 375.0
///// The height and width (in points) of a 5.5" iPhone
//#define k5_5iPhoneHeight = 736.0
//#define k5_5iPhoneWidth = 414.0

// Screen size
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)