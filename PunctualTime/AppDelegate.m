//
//  AppDelegate.m
//  PunctualTime
//
//  Created by Adam Cooper on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "AppDelegate.h"
#import "Event.h"
#import "EventController.h"
#import "Constants.h"
#import "SIAlertView.h"

static NSString* FIFTEEN_MINUTE_BUTTON = @"T-15min";
static NSString* FIVE_MINUTE_BUTTON = @"T-5min";
static NSString* ZERO_MINUTE_BUTTON = @"T-0min";
static NSString* STOP_BUTTON = @"Stop reminders";
static NSString* FINAL_BUTTON = @"I'm leaving!";

@interface AppDelegate ()

@property EventController* sharedEventController;
@property UIWindow* notificationWindow;
@property UIVisualEffectView* blurView;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.userLocationManager = [UserLocationManager new];
    self.sharedEventController = [EventController sharedEventController];

    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    //Ask the user permission to send them Local Push LocalNotifications
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:[self createNotificationCategories]];
        [application registerUserNotificationSettings:settings];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    //If the app is active and the location manager has been created, I start updating the users location.
    [self.userLocationManager updateLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Background Refresh

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    int counter = 0;
    [application cancelAllLocalNotifications]; // We're going to recreate them

    if (self.sharedEventController.events.count > 0)
    {
        for (Event *event in self.sharedEventController.events)
        {
            [event makeLocalNotificationWithCategoryIdentifier:event.currentNotificationCategory completion:^(NSError* error)
            {
                if (error) // This shouldn't ever happen
                {
                    NSLog(@"Background Fetch error: %@", error.userInfo);
                }

                NSLog(@"Name: %@",event.eventName);
                NSLog(@"Time to go off: %@",event.desiredArrivalTime);
                NSLog(@"Notification Category: %@",event.currentNotificationCategory);

                if (counter+1 == self.sharedEventController.events.count) // We're at the last object, so call completion handler
                {
                    NSLog(@"Events have been refreshed %d times",counter+1);
                    completionHandler(UIBackgroundFetchResultNewData);
                }
            }];
            counter++;
        }
    }
    else
    {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}


#pragma mark - Local notifications

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateActive) // The app is in the foreground, so recreate the notification
    {
        // Get the Event object that scheduled the notification
        Event* schedulingEvent = [self.sharedEventController findEventWithUniqueID:notification.userInfo[@"Event"]];

        // Setup the buttons to be used in the custom notification
        NSString* firstButtonText;
        NSString* secondButtonText;
        NSString* inertButtonText;
        if ([notification.category isEqualToString:kThirtyMinuteWarning])
        {
            firstButtonText = FIFTEEN_MINUTE_BUTTON;
            secondButtonText = ZERO_MINUTE_BUTTON;
        }
        else if ([notification.category isEqualToString:kFifteenMinuteWarning])
        {
            firstButtonText = FIVE_MINUTE_BUTTON;
            secondButtonText = ZERO_MINUTE_BUTTON;
        }
        else if ([notification.category isEqualToString:kFiveMinuteWarning])
        {
            firstButtonText = ZERO_MINUTE_BUTTON;
            inertButtonText = STOP_BUTTON;
        }
        else // This is the final warning
        {
            inertButtonText = FINAL_BUTTON;
        }

        // Create the custom notification to present to the user
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Hey!"
                                                         andMessage:notification.alertBody];

        alertView.backgroundStyle = SIAlertViewBackgroundStyleBlur;
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;

        if (firstButtonText) // This button will always create a new notification
        {
            [alertView addButtonWithTitle:firstButtonText
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alert) {
                                      [schedulingEvent makeLocalNotificationWithCategoryIdentifier:notification.category completion:^(NSError* error)
                                       {
                                           if (error) // This shouldn't ever happen
                                           {
                                               NSLog(@"Error snoozing: %@", error.userInfo);
                                           }
                                           [self cancelNotifcationForEvent:schedulingEvent]; // dismiss from notification center
                                       }];
                                  }];
        }
        if (secondButtonText) // This button will always create a new notification
        {
            [alertView addButtonWithTitle:secondButtonText
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alert) {
                                      [schedulingEvent makeLocalNotificationWithCategoryIdentifier:notification.category completion:^(NSError* error)
                                       {
                                           if (error) // This shouldn't ever happen
                                           {
                                               NSLog(@"Error snoozing: %@", error.userInfo);
                                           }
                                           [self cancelNotifcationForEvent:schedulingEvent]; // dismiss from notification center
                                       }];
                                  }];
        }
        if (inertButtonText) // This button will never create a new notification
        {
            [alertView addButtonWithTitle:inertButtonText
                                     type:SIAlertViewButtonTypeDestructive
                                  handler:^(SIAlertView *alert){
                                      [self cancelNotifcationForEvent:schedulingEvent]; // dismiss from notification center
                                  }];
        }
        
        [alertView show];
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler
{
    Event* schedulingEvent = [self.sharedEventController findEventWithUniqueID:notification.userInfo[@"Event"]];

    [self cancelNotifcationForEvent:schedulingEvent]; // Dismiss the notification on action tapped - iOS 8 bug?

    if ([identifier isEqualToString:kFifteenMinuteAction]) // Refresh ETA then set a fifteen minute local notification
    {
        [schedulingEvent makeLocalNotificationWithCategoryIdentifier:kFifteenMinuteWarning completion:^(NSError* error)
        {
            if (error) // This shouldn't ever happen
            {
                NSLog(@"Error snoozing: %@", error.userInfo);
            }
            completionHandler();
        }];
    }
    else if ([identifier isEqualToString:kFiveMinuteAction]) // Refresh ETA then set a five minute local notification
    {
        [schedulingEvent makeLocalNotificationWithCategoryIdentifier:kFiveMinuteWarning completion:^(NSError* error)
        {
            if (error) // This shouldn't ever happen
            {
                NSLog(@"Error snoozing: %@", error.userInfo);
            }
            completionHandler();
        }];
    }
    else if ([identifier isEqualToString:kZeroMinuteAction]) // Refresh ETA then set a zero minute local notification
    {
        [schedulingEvent makeLocalNotificationWithCategoryIdentifier:nil completion:^(NSError* error)
        {
            if (error) // This shouldn't ever happen
            {
                NSLog(@"Error snoozing: %@", error.userInfo);
            }
            completionHandler();
        }];
    }
}


#pragma mark - Private methods

- (NSSet *)createNotificationCategories
{
    UIMutableUserNotificationAction* fifteenMinuteAction = [[UIMutableUserNotificationAction alloc] init];
    fifteenMinuteAction.identifier = kFifteenMinuteAction;
    fifteenMinuteAction.title = FIFTEEN_MINUTE_BUTTON;
    fifteenMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    fifteenMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationAction* fiveMinuteAction = [[UIMutableUserNotificationAction alloc] init];
    fiveMinuteAction.identifier = kFiveMinuteAction;
    fiveMinuteAction.title = FIVE_MINUTE_BUTTON;
    fiveMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    fiveMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationAction* zeroMinuteAction = [[UIMutableUserNotificationAction alloc] init];
    zeroMinuteAction.identifier = kZeroMinuteAction;
    zeroMinuteAction.title = ZERO_MINUTE_BUTTON;
    zeroMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    zeroMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationCategory* thirtyMinuteWarning = [[UIMutableUserNotificationCategory alloc] init];
    thirtyMinuteWarning.identifier = kThirtyMinuteWarning;
    [thirtyMinuteWarning setActions:@[fifteenMinuteAction, zeroMinuteAction] forContext:UIUserNotificationActionContextDefault];

    UIMutableUserNotificationCategory* fifteenMinuteWarning = [[UIMutableUserNotificationCategory alloc] init];
    fifteenMinuteWarning.identifier = kFifteenMinuteWarning;
    [fifteenMinuteWarning setActions:@[fiveMinuteAction, zeroMinuteAction] forContext:UIUserNotificationActionContextDefault];

    UIMutableUserNotificationCategory* fiveMinuteWarning = [[UIMutableUserNotificationCategory alloc] init];
    fiveMinuteWarning.identifier = kFiveMinuteWarning;
    [fiveMinuteWarning setActions:@[zeroMinuteAction] forContext:UIUserNotificationActionContextDefault];

    return [NSSet setWithObjects:thirtyMinuteWarning, fifteenMinuteWarning, fiveMinuteWarning, nil];
}

- (void)cancelNotifcationForEvent:(Event *)event
{
    for (UILocalNotification* notification in [UIApplication sharedApplication].scheduledLocalNotifications)
    {
        if ([notification.userInfo[@"Event"] isEqualToString:event.uniqueID])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

@end
