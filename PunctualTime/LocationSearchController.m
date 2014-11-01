//
//  LocationSearchController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/1/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "LocationSearchController.h"

NSString *const apiURI = @"https://maps.googleapis.com/maps/api/place/autocomplete/output?parameters";
NSString *const apiKey = @"AIzaSyBB2Uc2kK0P3zDKwgyYlyC8ivdDCSyy4xg";

@implementation LocationSearchController


-(void)searchForPlacesNamed:(NSString *)search inArea:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:search completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *placemark = [placemarks firstObject];
            [self localSearch:placemark.location];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

-(void)localSearch:(CLLocation *)location {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"haunted";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1,1));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (!error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSArray *mapItems = response.mapItems;
            NSLog(@"%@",mapItems);
        }
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
