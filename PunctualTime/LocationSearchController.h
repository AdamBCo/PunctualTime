//
//  LocationSearchController.h
//  PunctualTime
//
//  Created by Adam Cooper on 11/1/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationSearchController : NSObject <MKMapViewDelegate>

-(void)searchForPlacesNamed:(NSString *)search inArea:(CLLocation *)location;
-(void)localSearch:(CLLocation *)location;


@end
