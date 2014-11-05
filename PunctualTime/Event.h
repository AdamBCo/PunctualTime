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
@property (readonly) CLLocationCoordinate2D startingAddress;
@property (readonly) CLLocationCoordinate2D endingAddress;
@property (readonly) NSDate* desiredArrivalTime;
@property (readonly) NSString* uniqueID;
@property NSString *transportationType;
@property NSDate* currentNotificationTime;

- (instancetype)initWithEventName:(NSString *)name
                  startingAddress:(CLLocationCoordinate2D)startingAddress
                    endingAddress:(CLLocationCoordinate2D)endingAddress
                      arrivalTime:(NSDate *)arrivalTime
               transportationType:(NSString *)transporation;
- (void)makeLocalNotificationWithCategoryIdentifier:(NSString *)categoryID;
- (NSComparisonResult)compareEvent:(Event *)otherObject;

@end
