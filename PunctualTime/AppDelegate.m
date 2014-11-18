//
//  AppDelegate.m
//  PunctualTime
//
//  Created by Adam Cooper on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "AppDelegate.h"
#import "Event.h"
#import "EventManager.h"
#import "Constants.h"
#import "SIAlertView.h"

static NSString* THIRTY_MINUTE_BUTTON = @"T-30min";
static NSString* FIFTEEN_MINUTE_BUTTON = @"T-15min";
static NSString* TEN_MINUTE_BUTTON = @"T-10min";
static NSString* FIVE_MINUTE_BUTTON = @"T-5min";
static NSString* ZERO_MINUTE_BUTTON = @"T-0min";
static NSString* STOP_BUTTON = @"Stop reminders";
static NSString* FINAL_BUTTON = @"I'm leaving!";

@interface AppDelegate ()

@property EventManager* sharedEventManager;
@property UIWindow* notificationWindow;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.userLocationManager = [UserLocationManager new];
    self.sharedEventManager = [EventManager sharedEventManager];

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

    // Show the app switcher view
    [application ignoreSnapshotOnNextApplicationLaunch];
    [self.appSwitcherViewDelegate showSwipeView];
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

    // Hide the app switcher view
    [self.appSwitcherViewDelegate hideSwipeView];

    // If the app is active and the location manager has been created, I start updating the users location.
    [self.userLocationManager updateLocation];

    // Check if any events have expired
    for (Event* event in self.sharedEventManager.events)
    {
        if ([[NSDate date] compare:event.lastLeaveTime] == NSOrderedDescending) // Current time is after event time
        {
            [self.sharedEventManager handleExpiredEvent:event completion:^{}];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Public methods

- (UILocalNotification *)getNotificationForEvent:(Event *)event
{
    NSArray* notifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    for (UILocalNotification* notification in notifications)
    {
        if ([notification.userInfo[@"Event"] isEqualToString:event.uniqueID])
        {
            return notification;
        }
    }

    return nil;
}


#pragma mark - Background refresh

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self.sharedEventManager refreshEventsWithCompletion:^(UIBackgroundFetchResult fetchResult){
        completionHandler(fetchResult);
    }];
}


#pragma mark - Local notifications

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateActive) // The app is in the foreground, so recreate the notification
    {
        // Get the Event object that scheduled the notification
        Event* schedulingEvent = [self.sharedEventManager findEventWithUniqueID:notification.userInfo[@"Event"]];

        // Setup the buttons to be used in the custom notification
        NSString* firstButtonText;
        NSString* firstButtonNewCategory;
        NSString* secondButtonText;
        NSString* inertButtonText;
        if ([notification.category isEqualToString:SIXTY_MINUTE_WARNING])
        {
            firstButtonText = THIRTY_MINUTE_BUTTON;
            firstButtonNewCategory = THIRTY_MINUTE_WARNING;
            secondButtonText = ZERO_MINUTE_BUTTON;
        }
        else if ([notification.category isEqualToString:THIRTY_MINUTE_WARNING])
        {
            firstButtonText = FIFTEEN_MINUTE_BUTTON;
            firstButtonNewCategory = FIFTEEN_MINUTE_WARNING;
            secondButtonText = ZERO_MINUTE_BUTTON;
        }
        else if ([notification.category isEqualToString:FIFTEEN_MINUTE_WARNING])
        {
            firstButtonText = TEN_MINUTE_BUTTON;
            firstButtonNewCategory = TEN_MINUTE_WARNING;
            secondButtonText = ZERO_MINUTE_BUTTON;
        }
        else if ([notification.category isEqualToString:TEN_MINUTE_WARNING])
        {
            firstButtonText = FIVE_MINUTE_BUTTON;
            firstButtonNewCategory = FIVE_MINUTE_WARNING;
            secondButtonText = ZERO_MINUTE_BUTTON;
        }
        else if ([notification.category isEqualToString:FIVE_MINUTE_WARNING])
        {
            firstButtonText = ZERO_MINUTE_BUTTON;
            inertButtonText = STOP_BUTTON;
        }
        else // This is the final warning
        {
            inertButtonText = FINAL_BUTTON;
            [self.sharedEventManager handleExpiredEvent:schedulingEvent completion:^{}];
        }

        // Create the custom notification to present to the user
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Hey!"
                                                         andMessage:[self correctedMessageBodyFromString:notification.alertBody]];
        alertView.backgroundStyle = SIAlertViewBackgroundStyleBlur;
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;

        if (firstButtonText) // This button will always create a new notification with a category
        {
            [alertView addButtonWithTitle:firstButtonText
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      [schedulingEvent makeLocalNotificationWithCategoryIdentifier:firstButtonNewCategory completion:^(NSError* error)
                                       {
                                           [[UIApplication sharedApplication] cancelLocalNotification:notification]; // dismiss from notification center
                                       }];
                                  }];
        }
        if (secondButtonText) // This button will always create a new notification without a category
        {
            [alertView addButtonWithTitle:secondButtonText
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      [schedulingEvent makeLocalNotificationWithCategoryIdentifier:nil completion:^(NSError* error)
                                       {
                                           [[UIApplication sharedApplication] cancelLocalNotification:notification]; // dismiss from notification center
                                       }];
                                  }];
        }
        if (inertButtonText) // This button will never create a new notification
        {
            [alertView addButtonWithTitle:inertButtonText
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alert) {
                                      [[UIApplication sharedApplication] cancelLocalNotification:notification]; // dismiss from notification center
                                  }];
        }
        
        [alertView show];
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler
{
    Event* schedulingEvent = [self.sharedEventManager findEventWithUniqueID:notification.userInfo[@"Event"]];

    [[UIApplication sharedApplication] cancelLocalNotification:notification]; // Dismiss the notification on action tapped - iOS 8 bug?

    if ([identifier isEqualToString:THIRTY_MINUTE_ACTION]) // Refresh ETA then set a thirty minute local notification
    {
        [schedulingEvent makeLocalNotificationWithCategoryIdentifier:THIRTY_MINUTE_WARNING completion:^(NSError* error){
             completionHandler();
         }];
    }
    else if ([identifier isEqualToString:FIFTEEN_MINUTE_ACTION]) // Refresh ETA then set a fifteen minute local notification
    {
        [schedulingEvent makeLocalNotificationWithCategoryIdentifier:FIFTEEN_MINUTE_WARNING completion:^(NSError* error){
            completionHandler();
        }];
    }
    else if ([identifier isEqualToString:TEN_MINUTE_ACTION]) // Refresh ETA then set a five minute local notification
    {
        [schedulingEvent makeLocalNotificationWithCategoryIdentifier:TEN_MINUTE_WARNING completion:^(NSError* error){
             completionHandler();
         }];
    }
    else if ([identifier isEqualToString:FIVE_MINUTE_ACTION]) // Refresh ETA then set a five minute local notification
    {
        [schedulingEvent makeLocalNotificationWithCategoryIdentifier:FIVE_MINUTE_WARNING completion:^(NSError* error){
            completionHandler();
        }];
    }
    else if ([identifier isEqualToString:ZERO_MINUTE_ACTION]) // Refresh ETA then set a zero minute local notification
    {
        [schedulingEvent makeLocalNotificationWithCategoryIdentifier:nil completion:^(NSError* error){
            completionHandler();
        }];
    }
}


#pragma mark - Private methods

- (NSSet *)createNotificationCategories
{
    UIMutableUserNotificationAction* thirtyMinuteAction = [UIMutableUserNotificationAction new];
    thirtyMinuteAction.identifier = THIRTY_MINUTE_ACTION;
    thirtyMinuteAction.title = THIRTY_MINUTE_BUTTON;
    thirtyMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    thirtyMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationAction* fifteenMinuteAction = [UIMutableUserNotificationAction new];
    fifteenMinuteAction.identifier = FIFTEEN_MINUTE_ACTION;
    fifteenMinuteAction.title = FIFTEEN_MINUTE_BUTTON;
    fifteenMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    fifteenMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationAction* tenMinuteAction = [UIMutableUserNotificationAction new];
    tenMinuteAction.identifier = TEN_MINUTE_ACTION;
    tenMinuteAction.title = TEN_MINUTE_BUTTON;
    tenMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    tenMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationAction* fiveMinuteAction = [UIMutableUserNotificationAction new];
    fiveMinuteAction.identifier = FIVE_MINUTE_ACTION;
    fiveMinuteAction.title = FIVE_MINUTE_BUTTON;
    fiveMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    fiveMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationAction* zeroMinuteAction = [UIMutableUserNotificationAction new];
    zeroMinuteAction.identifier = ZERO_MINUTE_ACTION;
    zeroMinuteAction.title = ZERO_MINUTE_BUTTON;
    zeroMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    zeroMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationCategory* sixtyMinuteWarning = [UIMutableUserNotificationCategory new];
    sixtyMinuteWarning.identifier = SIXTY_MINUTE_WARNING;
    [sixtyMinuteWarning setActions:@[thirtyMinuteAction, zeroMinuteAction] forContext:UIUserNotificationActionContextDefault];

    UIMutableUserNotificationCategory* thirtyMinuteWarning = [UIMutableUserNotificationCategory new];
    thirtyMinuteWarning.identifier = THIRTY_MINUTE_WARNING;
    [thirtyMinuteWarning setActions:@[fifteenMinuteAction, zeroMinuteAction] forContext:UIUserNotificationActionContextDefault];

    UIMutableUserNotificationCategory* fifteenMinuteWarning = [UIMutableUserNotificationCategory new];
    fifteenMinuteWarning.identifier = FIFTEEN_MINUTE_WARNING;
    [fifteenMinuteWarning setActions:@[tenMinuteAction, zeroMinuteAction] forContext:UIUserNotificationActionContextDefault];

    UIMutableUserNotificationCategory* tenMinuteWarning = [UIMutableUserNotificationCategory new];
    tenMinuteWarning.identifier = TEN_MINUTE_WARNING;
    [tenMinuteWarning setActions:@[fiveMinuteAction, zeroMinuteAction] forContext:UIUserNotificationActionContextDefault];

    UIMutableUserNotificationCategory* fiveMinuteWarning = [UIMutableUserNotificationCategory new];
    fiveMinuteWarning.identifier = FIVE_MINUTE_WARNING;
    [fiveMinuteWarning setActions:@[zeroMinuteAction] forContext:UIUserNotificationActionContextDefault];

    return [NSSet setWithObjects:sixtyMinuteWarning, thirtyMinuteWarning, fifteenMinuteWarning, tenMinuteWarning, fiveMinuteWarning, nil];
}

- (NSString *)correctedMessageBodyFromString:(NSString*)oldMessageBody
{
    NSError *error;

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:NOTIFICATION_TRAILING_TEXT
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (!error)
    {
        NSString* newMessageBody = [regex stringByReplacingMatchesInString:oldMessageBody
                                                                   options:0
                                                                     range:NSMakeRange(0, oldMessageBody.length)
                                                              withTemplate:@"Snooze?"];
        return newMessageBody;
    }

    return @"";
}

@end
