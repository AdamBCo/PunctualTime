//
//  GlanceController.m
//  Punctual WatchKit Extension
//
//  Created by Nathan Hosselton on 12/6/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "GlanceController.h"
#import "EventLite.h"

static NSString* const appGroupIdentifier = @"group.com.Punctual.app";

@interface GlanceController()

@property (weak, nonatomic) IBOutlet WKInterfaceTimer *glanceTimer;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *glanceEventLabel;
@property EventLite *nextEvent;
@end


@implementation GlanceController

- (instancetype)initWithContext:(id)context {
    self = [super initWithContext:context];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        NSLog(@"%@ initWithContext", self);
        [self loadEvent];
        
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    if (self.nextEvent)
    {
        [self.glanceEventLabel setText:self.nextEvent.eventName];
        [self.glanceTimer setDate:self.nextEvent.lastLeaveTime];
        [self.glanceTimer start];
    }
    else
    {
        [self.glanceEventLabel setText:@"No events"];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
}

- (NSURL *)documentsDirectory
{
    // TODO: Migrate user data to new container
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* fileURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:appGroupIdentifier];

    return fileURL;
}

- (void)loadEvent // This method should NEVER be public
{
    NSURL* plist = [[self documentsDirectory] URLByAppendingPathComponent:@"events.plist"];
    NSArray* savedData = [NSArray arrayWithContentsOfURL:plist];

    [NSKeyedUnarchiver setClass:[EventLite class] forClassName:@"Event"];
    self.nextEvent = [NSKeyedUnarchiver unarchiveObjectWithData:[savedData firstObject]];
}

@end



