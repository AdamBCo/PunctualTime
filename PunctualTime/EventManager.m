//
//  EventController.m
//  PunctualTime
//
//  Created by Nathan Hosselton on 11/1/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "EventManager.h"
#import "AppDelegate.h"

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
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    UILocalNotification* notification = [appDelegate getNotificationForEvent:event];

    if (notification)
    {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }

    [self.events removeObject:event];
    [self sortEvents];
}

- (void)refreshEventsWithCompletion:(void (^)(void))completion // Updates events or removes/reschedules them if expired
{
    if (self.events.count > 0)
    {
        NSArray* eventsCopy = [NSArray arrayWithArray:self.events];

        for (Event* event in eventsCopy)
        {
            if ([[NSDate date] compare:event.lastLeaveTime] == NSOrderedDescending) // Current time is after event time
            {
                if (event.recurrenceInterval == PTEventRecurrenceOptionNone) // Remove the event
                {
                    [self removeEvent:event];
                    if ([event isEqual:eventsCopy.lastObject]) // End of array so finish up
                    {
                        [self sortEvents];
                        completion();
                    }
                }
                else // Reschedule the event
                {
                    [event rescheduleWithCompletion:^{
                        if ([event isEqual:eventsCopy.lastObject]) // End of array so finish up
                        {
                            [self sortEvents];
                            completion();
                        }
                    }];
                }
            }
            else // Just update with the latest travel time
            {
                AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                UILocalNotification* notification = [appDelegate getNotificationForEvent:event];

                [event makeLocalNotificationWithCategoryIdentifier:event.currentNotificationCategory completion:^(NSError *error) {
                    if (!error)
                    {
                        if (notification)
                        {
                            [[UIApplication sharedApplication] cancelLocalNotification:notification];
                        }
                    }

                    if ([event isEqual:eventsCopy.lastObject]) // End of array so finish up
                    {
                        [self sortEvents];
                        completion();
                    }
                }];
            }
        }
    }
    else
    {
        completion();
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
    [self.delegate eventManagerHasBeenUpdated]; //TODO: replace delegate with NSNotificationCenter message
}


#pragma mark - Event delegate

- (void)eventWasUpdated
{
    [self sortEvents];
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

    [self refreshEventsWithCompletion:^{}];
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
