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
    completion();
}

- (void)removeEvent:(Event *)event withCompletion:(void (^)(void))completion
{
    [self.events removeObject:event];
    completion();
}


#pragma mark - Functions for singleton implementation

- (instancetype)init
{
    if (self = [super init])
    {
        // Do init prep if necessary
        return self;
    }

    return self;
}

- (void)dealloc
{
    //   ಠ_ಠ
}

@end
