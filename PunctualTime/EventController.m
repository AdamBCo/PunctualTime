//
//  EventController.m
//  PunctualTime
//
//  Created by Nathan Hosselton on 11/1/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "EventController.h"

@interface EventController ()

@property (readwrite) NSMutableArray* events;

@end

@implementation EventController

#pragma mark - Public methods

+ (EventController *)sharedEventController // Returns persistent instance
{
    static EventController *_default = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      _default = [[EventController alloc] init];
                  });

    return _default;
}

- (void)addEvent:(Event *)event withCompletion:(void (^)(void))completion
{
    if (!self.events)
    {
        self.events = [NSMutableArray new];
    }

    [self.events addObject:event];
    [self saveEvents];

    completion();
}

- (void)removeEvent:(Event *)event withCompletion:(void (^)(void))completion
{
    [self.events removeObject:event];
    [self saveEvents];

    completion();
}


#pragma mark - Data persistence

- (NSURL *)documentsDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];

    return files.firstObject;
}

- (void)saveEvents
{
    NSURL *plist = [[self documentsDirectory] URLByAppendingPathComponent:@"events.plist"];
    NSMutableArray *dataToSave = [NSMutableArray array];

    for (Event* event in self.events)
    {
        NSData* eventData = [NSKeyedArchiver archivedDataWithRootObject:event];
        [dataToSave addObject:eventData];
    }

    [dataToSave writeToURL:plist atomically:YES];
}

- (void)loadEvents
{
    NSURL *plist = [[self documentsDirectory] URLByAppendingPathComponent:@"events.plist"];
    self.events = [NSMutableArray array];
    NSArray *savedData = [NSArray arrayWithContentsOfURL:plist];

    for (NSData* data in savedData)
    {
        Event* event = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self.events addObject:event];
    }
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
