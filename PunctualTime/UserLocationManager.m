//
//  UserLocationController.m
//  PunctualTime
//
//  Created by Adam Cooper on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "UserLocationManager.h"
#import <CoreMotion/CoreMotion.h>

@interface UserLocationManager ()<CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *userLocationManager;
@end

@implementation UserLocationManager

-(void)updateLocation {
    [self.userLocationManager startUpdatingLocation];
}


-(void)dealloc
{
    [self.userLocationManager setDelegate:nil];
}

#pragma mark - Location

+ (BOOL)canGetLocation
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted) {
        return YES;
    }
    return NO;
}

- (void)setLocationAccuracyBestAndUpdate{
    [self.userLocationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.userLocationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.userLocationManager startUpdatingLocation];
    NSLog(@"The location accuracy has been set to Best");
}


- (CLLocationManager *)userLocationManager {

    if (!_userLocationManager) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        self.userLocationManager = locationManager;
    }
    [_userLocationManager requestAlwaysAuthorization];

    return _userLocationManager;
}


- (void)startStandardLocationUpdates {

    self.userLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.userLocationManager startUpdatingLocation];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{

        CLLocation *newLocation = [locations firstObject];
        CLLocation *oldLocation;
        if (locations.count > 1) {
            oldLocation = [locations objectAtIndex:locations.count-2];
        } else {
            oldLocation = nil;
        }
    self.location = newLocation;
}



-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Failure" message:@"We failed to find your current location?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alert addButtonWithTitle:@"Close"];
    [alert show];
    NSLog(@"Error: %@", error.userInfo);

}




@end
