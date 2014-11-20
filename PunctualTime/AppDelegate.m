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

static NSString* SNOOZE_BUTTON = @"Snooze";
static NSString* STOP_BUTTON = @"Stop Reminders";
static NSString* FINAL_BUTTON = @"I'm leaving!";

@interface AppDelegate ()

@property EventManager* sharedEventManager;
@property UIWindow* notificationWindow;


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.sharedEventManager = [EventManager sharedEventManager];
    self.userLocationManager = [UserLocationManager sharedLocationManager];

    // Naviation appearance
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-Thin" size:22.0], NSFontAttributeName, nil]];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0],
                                                          NSFontAttributeName, nil] forState:UIControlStateNormal];
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

    // Check if any events have expired - needs refactored
    if (self.sharedEventManager.events.count > 0)
    {
        NSArray* eventsCopy = [NSArray arrayWithArray:self.sharedEventManager.events];

        for (Event* event in eventsCopy)
        {
            if ([[NSDate date] compare:event.lastLeaveTime] == NSOrderedDescending) // Current time is after event time
            {
                [self.sharedEventManager handleExpiredEvent:event completion:^{}];
            }
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

- (void)requestNotificationPermissions
{
    UIApplication* application = [UIApplication sharedApplication];

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:[self createNotificationCategories]];
        [application registerUserNotificationSettings:settings];
    }
}


#pragma mark - Local notifications

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateActive) // The app is in the foreground, so recreate the notification
    {
        // Get the Event object that scheduled the notification
        Event* schedulingEvent = [self.sharedEventManager findEventWithUniqueID:notification.userInfo[@"Event"]];

        // Setup the buttons to be used in the custom notification
        NSString* actionButtonText;
        NSString* actionButtonNewCategory;
        NSString* inertButtonText;
        if ([notification.category isEqualToString:SIXTY_MINUTE_WARNING])
        {
            actionButtonText = SNOOZE_BUTTON;
            actionButtonNewCategory = THIRTY_MINUTE_WARNING;
            inertButtonText = STOP_BUTTON;
        }
        else if ([notification.category isEqualToString:THIRTY_MINUTE_WARNING])
        {
            actionButtonText = SNOOZE_BUTTON;
            actionButtonNewCategory = FIFTEEN_MINUTE_WARNING;
            inertButtonText = STOP_BUTTON;
        }
        else if ([notification.category isEqualToString:FIFTEEN_MINUTE_WARNING])
        {
            actionButtonText = SNOOZE_BUTTON;
            actionButtonNewCategory = TEN_MINUTE_WARNING;
            inertButtonText = STOP_BUTTON;
        }
        else if ([notification.category isEqualToString:TEN_MINUTE_WARNING])
        {
            actionButtonText = SNOOZE_BUTTON;
            actionButtonNewCategory = FIVE_MINUTE_WARNING;
            inertButtonText = STOP_BUTTON;
        }
        else if ([notification.category isEqualToString:FIVE_MINUTE_WARNING])
        {
            actionButtonText = SNOOZE_BUTTON;
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

        if (actionButtonText) // This button will always create a new notification
        {
            [alertView addButtonWithTitle:actionButtonText
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      [schedulingEvent makeLocalNotificationWithCategoryIdentifier:actionButtonNewCategory completion:^(NSError* error){
                                           if (notification) // Dismiss lingering notification
                                           {
                                               [[UIApplication sharedApplication] cancelLocalNotification:notification];
                                           }
                                       }];
                                  }];
        }
        if (inertButtonText) // This button will never create a new notification
        {
            [alertView addButtonWithTitle:inertButtonText
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alert){
                                      if (notification) // Dismiss lingering notification
                                      {
                                          [[UIApplication sharedApplication] cancelLocalNotification:notification];
                                      }
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
    thirtyMinuteAction.title = SNOOZE_BUTTON;
    thirtyMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    thirtyMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationAction* fifteenMinuteAction = [UIMutableUserNotificationAction new];
    fifteenMinuteAction.identifier = FIFTEEN_MINUTE_ACTION;
    fifteenMinuteAction.title = SNOOZE_BUTTON;
    fifteenMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    fifteenMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationAction* tenMinuteAction = [UIMutableUserNotificationAction new];
    tenMinuteAction.identifier = TEN_MINUTE_ACTION;
    tenMinuteAction.title = SNOOZE_BUTTON;
    tenMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    tenMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationAction* fiveMinuteAction = [UIMutableUserNotificationAction new];
    fiveMinuteAction.identifier = FIVE_MINUTE_ACTION;
    fiveMinuteAction.title = SNOOZE_BUTTON;
    fiveMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    fiveMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationAction* zeroMinuteAction = [UIMutableUserNotificationAction new];
    zeroMinuteAction.identifier = ZERO_MINUTE_ACTION;
    zeroMinuteAction.title = SNOOZE_BUTTON;
    zeroMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    zeroMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationAction* stopAction = [UIMutableUserNotificationAction new];
    stopAction.identifier = STOP_ACTION;
    stopAction.title = STOP_BUTTON;
    stopAction.activationMode = UIUserNotificationActivationModeBackground;
    stopAction.authenticationRequired = NO;

    UIMutableUserNotificationCategory* sixtyMinuteWarning = [UIMutableUserNotificationCategory new];
    sixtyMinuteWarning.identifier = SIXTY_MINUTE_WARNING;
    [sixtyMinuteWarning setActions:@[thirtyMinuteAction, stopAction] forContext:UIUserNotificationActionContextDefault];

    UIMutableUserNotificationCategory* thirtyMinuteWarning = [UIMutableUserNotificationCategory new];
    thirtyMinuteWarning.identifier = THIRTY_MINUTE_WARNING;
    [thirtyMinuteWarning setActions:@[fifteenMinuteAction, stopAction] forContext:UIUserNotificationActionContextDefault];

    UIMutableUserNotificationCategory* fifteenMinuteWarning = [UIMutableUserNotificationCategory new];
    fifteenMinuteWarning.identifier = FIFTEEN_MINUTE_WARNING;
    [fifteenMinuteWarning setActions:@[tenMinuteAction, stopAction] forContext:UIUserNotificationActionContextDefault];

    UIMutableUserNotificationCategory* tenMinuteWarning = [UIMutableUserNotificationCategory new];
    tenMinuteWarning.identifier = TEN_MINUTE_WARNING;
    [tenMinuteWarning setActions:@[fiveMinuteAction, stopAction] forContext:UIUserNotificationActionContextDefault];

    UIMutableUserNotificationCategory* fiveMinuteWarning = [UIMutableUserNotificationCategory new];
    fiveMinuteWarning.identifier = FIVE_MINUTE_WARNING;
    [fiveMinuteWarning setActions:@[zeroMinuteAction, stopAction] forContext:UIUserNotificationActionContextDefault];

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
                                                              withTemplate:@""];
        return newMessageBody;
    }

    return @"";
}

@end
