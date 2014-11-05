//
//  LocationInfo.h
//  PunctualTime
//
//  Created by Adam Cooper on 11/4/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationInfo : NSObject
@property NSString *name;
@property NSString *address;
@property CLLocationCoordinate2D locationCoordinates;

@end
