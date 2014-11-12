//
//  EventController.m
//  PunctualTime
//
//  Created by Nathan Hosselton on 11/1/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "EventManager.h"

@interface EventManager ()

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

    [self.events addObject:event];
    [self saveEvents];
}

- (void)removeEvent:(Event *)event
{
    NSArray* notifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    for (UILocalNotification* notification in notifications)
    {
        if ([notification.userInfo[@"Event"] isEqualToString:event.uniqueID])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:notification]; // Cancel the associated notification first
        }
    }
    [self.events removeObject:event];
    [self saveEvents];
}

- (void)refreshEvents // Removes or reschedules expired events and resorts by date
{
    NSArray* eventsToCheckForExpiration = [NSArray arrayWithArray:self.events];
    for (Event* event in eventsToCheckForExpiration)
    {
        if ([[NSDate date] compare:event.desiredArrivalTime] == NSOrderedDescending) // Current time is after event time
        {
            if (event.recurrenceInterval == PTEventRecurrenceOptionNone)
            {
                [self removeEvent:event];
                [self.events sortUsingSelector:@selector(compareEvent:)]; // Sort remaining events by date
            }
            else
            {
                [event rescheduleWithCompletion:^{
                    [self.events sortUsingSelector:@selector(compareEvent:)];
                }];
            }
        }
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

- (void)loadEvents
{
    NSURL* plist = [[self documentsDirectory] URLByAppendingPathComponent:@"events.plist"];
    self.events = [NSMutableArray array];
    NSArray* savedData = [NSArray arrayWithContentsOfURL:plist];

    for (NSData* data in savedData)
    {
        Event* event = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self.events addObject:event];
    }

    [self refreshEvents];
}


#pragma mark - Functions for singleton implementation

- (instancetype)init
{
    if (self = [super init])
    {
        // Load any saved Event objects from local storage
        [self loadEvents];
    }

    return self;
}

- (void)dealloc
{
    //   ಠ_ಠ
}

@end
