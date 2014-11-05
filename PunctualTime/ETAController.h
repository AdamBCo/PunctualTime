//
//  ETAController.h
//  PunctualTime
//
//  Created by Adam Cooper on 11/4/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface ETAController : NSObject

-(void)calculateETAforEvent:(Event *)event withCompletion:(void (^)(NSDictionary *))complete;
@end
