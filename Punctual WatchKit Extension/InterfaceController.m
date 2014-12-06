//
//  InterfaceController.m
//  Punctual WatchKit Extension
//
//  Created by Nathan Hosselton on 12/6/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "InterfaceController.h"
#import "Event.h"

static NSString* const appGroupIdentifier = @"group.com.Punctual.app";

@interface InterfaceController()

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *eventLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceTimer *eventTimer;
@property Event* nextEvent;

@end


@implementation InterfaceController

#pragma mark - Lifecycle

- (instancetype)initWithContext:(id)context {
    self = [super initWithContext:context];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.

        [self loadEvent]; // Get the next upcoming event
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
}


#pragma mark - Data persistence

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

    self.nextEvent = [NSKeyedUnarchiver unarchiveObjectWithData:[savedData firstObject]];
}

@end



