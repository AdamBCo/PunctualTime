//
//  Event.h
//  PunctualTime
//
//  Created by Nathan Hosselton on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Event : MKMapItem

@property (readonly) NSString* eventName;
@property (readonly) NSString* startingAddress;
@property (readonly) NSString* endingAddress;
@property (readonly) NSDate* desiredArrivalTime;

- (instancetype)initWithEventName:(NSString *)name
                  startingAddress:(NSString *)startingAddress
                    endingAddress:(NSString *)endingAddress
                      arrivalTime:(NSDate *)arrivalTime;

- (NSComparisonResult)compareEvent:(Event *)otherObject;

@end
