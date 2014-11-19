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
#define STOP_ACTION (@"StopAction")

// Notification body trailing string
#define NOTIFICATION_TRAILING_TEXT (@" Slide to snooze")

// Transporation strings for Google Maps API
#define TRANSPO_DRIVING @"driving"
#define TRANSPO_WALKING @"walking"
#define TRANSPO_BIKING @"bicycling"
#define TRANSPO_TRANSIT @"transit"

// NSNotificationCenter
#define EVENTS_UPDATED @"EventsUpdated"

// Screen size
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)