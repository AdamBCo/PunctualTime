//
//  EventController.m
//  PunctualTime
//
//  Created by Nathan Hosselton on 11/1/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "EventManager.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface EventManager () <EventDelegate>

@property (readwrite) NSMutableArray* events;

@end

@implementation EventManager

#pragma mark - Public methods

+ (EventManager *)sharedEventManager // Returns persistent instance
{
    static EventManager* _default = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      _default = [[EventManager alloc] init];
                  });

    return _default;
}

- (void)addEvent:(Event *)event
{
    if (!self.events)
    {
        self.events = [NSMutableArray new];
    }

    event.delegate = self;
    [self.events addObject:event];

    [self sortEvents];
}

- (void)removeEvent:(Event *)event
{
    // Remove any lingering notification
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    UILocalNotification* notification = [appDelegate getNotificationForEvent:event];
    if (notification.category)
    {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }

    [self.events removeObject:event];
    [self saveEvents];
}

- (void)handleExpiredEvent:(Event *)event completion:(void (^)())completion
{
    // Remove any lingering notification
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    UILocalNotification* notification = [appDelegate getNotificationForEvent:event];
    if (notification.category)
    {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }

    if (event.recurrenceInterval == PTEventRecurrenceOptionNone) // Remove the event
    {
        [self removeEvent:event];
        [[NSNotificationCenter defaultCenter] postNotificationName:EVENTS_UPDATED object:self];
        completion();
    }
    else // Reschedule the event
    {
        [event rescheduleWithCompletion:^{
            completion();
        }];
    }
}

- (void)refreshEventsWithCompletion:(void (^)(UIBackgroundFetchResult fetchResult))completion // Updates events or removes/reschedules them if expired
{
    __block UIBackgroundFetchResult fetchResult = UIBackgroundFetchResultNoData;

    if (self.events.count > 0)
    {
        NSArray* eventsCopy = [NSArray arrayWithArray:self.events];

        for (Event* event in eventsCopy)
        {
            if ([[NSDate date] compare:event.lastLeaveTime] == NSOrderedDescending) // Current time is after event time
            {
                [self handleExpiredEvent:event completion:^{
                    if ([event isEqual:eventsCopy.lastObject]) // End of array so finish up
                    {
                        [self sortEvents];
                        completion(fetchResult);
                    }
                }];
            }
            else // Just update with the latest travel time
            {
                AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                UILocalNotification* notification = [appDelegate getNotificationForEvent:event];

                [event makeLocalNotificationWithCategoryIdentifier:event.currentNotificationCategory completion:^(NSError *error) {
                    if (!error)
                    {
                        fetchResult = UIBackgroundFetchResultNewData;

                        if (notification)
                        {
                            [[UIApplication sharedApplication] cancelLocalNotification:notification];
                        }
                    }

                    if ([event isEqual:eventsCopy.lastObject]) // End of array so finish up
                    {
                        [self sortEvents];
                        completion(fetchResult);
                    }
                }];
            }
        }
    }
    else
    {
        completion(fetchResult);
    }
}

- (Event *)findEventWithUniqueID:(NSString *)uniqueID
{
    for (Event* event in self.events)
    {
        if ([event.uniqueID isEqualToString:uniqueID])
        {
            return event;
        }
    }

    return nil;
}


#pragma mark - Private methods

- (void)sortEvents // Sort self.events by leave time
{
    NSArray *sortedEventsArray = [self.events sortedArrayUsingSelector:@selector(compareEvent:)];
    [self.events removeAllObjects];
    [self.events addObjectsFromArray: sortedEventsArray];

    [self saveEvents];
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENTS_UPDATED object:self];
}


#pragma mark - Event delegate

- (void)eventWasUpdated:(Event *)event
{
    if ([self.events containsObject:event])
    {
        [self sortEvents];
    }
}


#pragma mark - Data persistence

- (NSURL *)documentsDirectory
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* files = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];

    return files.firstObject;
}

- (void)saveEvents
{
    NSURL* plist = [[self documentsDirectory] URLByAppendingPathComponent:@"events.plist"];
    NSMutableArray* dataToSave = [NSMutableArray array];

    for (Event* event in self.events)
    {
        NSData* eventData = [NSKeyedArchiver archivedDataWithRootObject:event];
        [dataToSave addObject:eventData];
    }

    [dataToSave writeToURL:plist atomically:YES];
}

- (void)loadEvents // This method should NEVER be public
{
    NSURL* plist = [[self documentsDirectory] URLByAppendingPathComponent:@"events.plist"];
    self.events = [NSMutableArray array];
    NSArray* savedData = [NSArray arrayWithContentsOfURL:plist];

    for (NSData* data in savedData)
    {
        Event* event = [NSKeyedUnarchiver unarchiveObjectWithData:data];

        event.delegate = self;
        [self.events addObject:event];
    }

//    NSArray* eventsCopy = [NSArray arrayWithArray:self.events];
//
//    for (Event* event in eventsCopy)
//    {
//        if ([[NSDate date] compare:event.lastLeaveTime] == NSOrderedDescending) // Current time is after event time
//        {
//            [self handleExpiredEvent:event completion:^{
//                if ([event isEqual:eventsCopy.lastObject]) // End of array so finish up
//                {
//                    [self sortEvents];
//                }
//            }];
//        }
//    }
}


#pragma mark - Functions for singleton implementation

- (instancetype)init
{
    if (self = [super init])
    {
        // Load any saved Event objects from local storage
        [self loadEvents];;
    }

    return self;
}

- (void)dealloc
{
    //   ಠ_ಠ
}

@end
