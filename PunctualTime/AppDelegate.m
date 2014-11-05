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

@interface AppDelegate ()

@property EventController* sharedEventController;

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


#pragma mark - ┌∩┐(◣_◢)┌∩┐ Background Refresh ┌∩┐(◣_◢)┌∩┐

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    int counter = 0;
    [application cancelAllLocalNotifications];
    for (Event *event in self.sharedEventController.events) {
        [event makeLocalNotificationWithCategoryIdentifier:event.currentNotificationCategory];
        NSLog(@"New time: %@",event.currentNotificationCategory);
        counter++;
    }
    NSLog(@"Events have been refreshed %d times",counter);
    completionHandler(UIBackgroundFetchResultNewData);
}


#pragma mark - Local notifications

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler
{
    if ([identifier isEqualToString:kFifteenMinuteAction]) // Refresh ETA then set a fifteen minute local notification
    {
        Event* schedulingEvent = [self.sharedEventController findEventWithUniqueID:notification.userInfo[@"Event"]];
        // Get ETA for event
        [schedulingEvent makeLocalNotificationWithCategoryIdentifier:kFifteenMinuteWarning];
    }
    else if ([identifier isEqualToString:kFiveMinuteAction]) // Refresh ETA then set a five minute local notification
    {
        Event* schedulingEvent = [self.sharedEventController findEventWithUniqueID:notification.userInfo[@"Event"]];
        // Get ETA for event
        [schedulingEvent makeLocalNotificationWithCategoryIdentifier:kFiveMinuteWarning];
    }
    else if ([identifier isEqualToString:kZeroMinuteAction]) // Refresh ETA then set a zero minute local notification
    {
        Event* schedulingEvent = [self.sharedEventController findEventWithUniqueID:notification.userInfo[@"Event"]];
        // Get ETA for event
        [schedulingEvent makeLocalNotificationWithCategoryIdentifier:nil];
    }
    completionHandler();
}


#pragma mark - Private methods

- (NSSet *)createNotificationCategories // Bless this mess
{
    UIMutableUserNotificationAction* fifteenMinuteAction = [[UIMutableUserNotificationAction alloc] init];
    fifteenMinuteAction.identifier = kFifteenMinuteAction;
    fifteenMinuteAction.title = @"T-15min";
    fifteenMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    fifteenMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationAction* fiveMinuteAction = [[UIMutableUserNotificationAction alloc] init];
    fiveMinuteAction.identifier = kFiveMinuteAction;
    fiveMinuteAction.title = @"T-5min";
    fiveMinuteAction.activationMode = UIUserNotificationActivationModeBackground;
    fiveMinuteAction.authenticationRequired = NO;

    UIMutableUserNotificationAction* zeroMinuteAction = [[UIMutableUserNotificationAction alloc] init];
    zeroMinuteAction.identifier = kZeroMinuteAction;
    zeroMinuteAction.title = @"T-0min";
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

@end
