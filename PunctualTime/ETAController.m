//
//  ETAController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/4/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "ETAController.h"
#import "AppDelegate.h"

@implementation ETAController


-(void)calculateETAforEvent:(Event *)event withCompletion:(void (^)(NSDictionary *))complete{

    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *userLocation = appDelegate.userLocationManager.location;
    NSString *google = @"https://maps.googleapis.com/maps/api/directions/json?origin=";
    NSString *currentLatitude = [NSString stringWithFormat:@"%f,",userLocation.coordinate.latitude];
    NSString *currentLongitude = [NSString stringWithFormat:@"%f",userLocation.coordinate.longitude];
    NSString *destination = [NSString stringWithFormat: @"&destination="];

    NSString *latitude = @(event.endingAddress.latitude).stringValue;
    NSString *longitude = @(event.endingAddress.longitude).stringValue;
    NSString *apiAccessKeyURL = [NSString stringWithFormat:@"&waypoints=optimize:true&key=AIzaSyBB2Uc2kK0P3zDKwgyYlyC8ivdDCSyy4xg"];
    NSString *arrivalTime = [NSString stringWithFormat:@"&arrival_time=1415133552"];
    NSString *modeOfTransportation = [NSString stringWithFormat:@"&mode=%@",event.transportationType];

    NSArray *urlStrings = @[google, currentLatitude, currentLongitude, destination, latitude, longitude,apiAccessKeyURL, arrivalTime, modeOfTransportation];
    NSString *joinedString = [urlStrings componentsJoinedByString:@""];
    NSLog(@"%@",joinedString);

    NSURL *url = [NSURL URLWithString:joinedString];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

        NSLog(@"JSON Result %@",jSONresult);
        complete(jSONresult);

    }];
    [task resume];
    
    
}

@end
