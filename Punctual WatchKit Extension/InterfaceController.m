//
//  InterfaceController.m
//  Punctual WatchKit Extension
//
//  Created by Nathan Hosselton on 12/6/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "InterfaceController.h"
#import "EventLite.h"

static NSString* const appGroupIdentifier = @"group.com.Punctual.app";

@interface InterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceButton *nextButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *previousButton;

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *eventLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceTimer *eventTimer;
@property NSMutableArray *events;
@property int eventIndex;

@end


@implementation InterfaceController

#pragma mark - Lifecycle

- (instancetype)initWithContext:(id)context {
    self = [super initWithContext:context];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.

        [self loadEvents]; // Get the events from the app
        self.eventIndex = 0;
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [self.eventLabel setText:((EventLite *)[self.events objectAtIndex:self.eventIndex]).eventName];
    [self.eventTimer setDate:((EventLite *)[self.events objectAtIndex:self.eventIndex]).lastLeaveTime];

    [self.eventTimer start];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
}

- (IBAction)onPreviousButtonTapped
{
    if (self.eventIndex > 0)
    {
        self.eventIndex--;
        [self.eventLabel setText:((EventLite *)[self.events objectAtIndex:self.eventIndex]).eventName];
        [self.eventTimer setDate:((EventLite *)[self.events objectAtIndex:self.eventIndex]).lastLeaveTime];
    }

    if(self.eventIndex < self.events.count-1) {
        [self.nextButton setEnabled:YES];
    }

    if(self.eventIndex == 0) {
        [self.previousButton setEnabled:NO];
    }
}

-(IBAction)onNextButtonTapped
{
    if (self.eventIndex < self.events.count-1)
    {
        self.eventIndex++;
        [self.eventLabel setText:((EventLite *)[self.events objectAtIndex:self.eventIndex]).eventName];
        [self.eventTimer setDate:((EventLite *)[self.events objectAtIndex:self.eventIndex]).lastLeaveTime];
    }

    if (self.eventIndex == self.events.count-1) {
        [self.nextButton setEnabled:NO];
    }

    if (self.eventIndex > 0) {
        [self.previousButton setEnabled:YES];
    }
}


#pragma mark - Data persistence

- (NSURL *)documentsDirectory
{
    // TODO: Migrate user data to new container
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* fileURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:appGroupIdentifier];

    return fileURL;
}

- (void)loadEvents // This method should NEVER be public
{
    NSURL* plist = [[self documentsDirectory] URLByAppendingPathComponent:@"events.plist"];
    NSArray* savedData = [NSArray arrayWithContentsOfURL:plist];
    self.events = [NSMutableArray new];

    [NSKeyedUnarchiver setClass:[EventLite class] forClassName:@"Event"];
    for (NSData *data in savedData){
        EventLite *event = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self.events addObject:event];
    }
}

@end



