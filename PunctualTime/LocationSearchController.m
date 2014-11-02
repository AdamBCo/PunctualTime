//
//  LocationSearchController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/1/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "LocationSearchController.h"

//NSString *const apiURI = @"https://maps.googleapis.com/maps/api/place/autocomplete/output?parameters";
//NSString *const apiKey = @"AIzaSyBB2Uc2kK0P3zDKwgyYlyC8ivdDCSyy4xg";

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




//-(void)retrieveGooglePlaceInfromation:(NSString*)searchWord withCompletion:(void (^)(NSArray *))complete{
//
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Vict&types=geocode&language=fr&key=%@",apiKey]];
//
//    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//
//    NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//        NSLog(@"Data: %@", dict);
//
//    }];
//
//    [task resume];
//
//}

@end
