//
//  UserLocationController.m
//  PunctualTime
//
//  Created by Adam Cooper on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "UserLocationManager.h"
#import "EventManager.h"
#import <CoreMotion/CoreMotion.h>

@interface UserLocationManager ()<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *userLocationManager;
@property EventManager* sharedEventManager;
@property NSDate* lastLocationUpdateTime;

@end

@implementation UserLocationManager

+ (UserLocationManager *)sharedLocationManager // Returns persistent instance
{
    static UserLocationManager* _default = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      _default = [[UserLocationManager alloc] init];
                  });

    return _default;
}

- (instancetype)init
{
    self = [super init];

    self.userLocationManager = [[CLLocationManager alloc] init];
    self.userLocationManager.delegate = self;

//    [_userLocationManager requestAlwaysAuthorization];

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        [self.userLocationManager startMonitoringSignificantLocationChanges];
    }

    self.sharedEventManager = [EventManager sharedEventManager];

    return self;
}

-(void)dealloc
{
    [self.userLocationManager setDelegate:nil];
}

+ (BOOL)canGetLocation
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        return YES;
    }
    return NO;
}

- (void)requestLocationFromUser
{
    [self.userLocationManager requestAlwaysAuthorization];
}


#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = [locations lastObject]; // Grab the most recent location update

    // Only ping Google if it has been more than 5 minutes since the last update or this is a cold launch
    if ([NSDate date].timeIntervalSince1970 - self.lastLocationUpdateTime.timeIntervalSince1970 > (5*60))
    {
        [self.sharedEventManager refreshEventsWithCompletion:^(UIBackgroundFetchResult fetchResult){
            if (fetchResult == UIBackgroundFetchResultNewData)
            {
                self.lastLocationUpdateTime = [NSDate date];
            }
        }];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't get location"
                                                    message:@"Make sure Punctual can use your location in Settings"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    NSLog(@"Error: %@", error.userInfo);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways)
    {
        [self.userLocationManager startMonitoringSignificantLocationChanges];
    }
}


@end
