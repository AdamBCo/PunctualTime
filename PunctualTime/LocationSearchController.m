//
//  LocationSearchController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/1/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "LocationSearchController.h"

@interface LocationSearchController ()

@end

@implementation LocationSearchController

- (void)searchLocations:(NSString *)search withCompletion:(void (^)(NSArray *placemarks))completion{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    NSMutableArray *totalPlacemarks = [NSMutableArray array];
    [geocoder geocodeAddressString:search completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark *placemark in placemarks) {
            MKPointAnnotation *annotation = [MKPointAnnotation new];
            annotation.coordinate = placemark.location.coordinate;
            [totalPlacemarks addObject:annotation];
        }
        completion(totalPlacemarks);
    }];

}

@end
