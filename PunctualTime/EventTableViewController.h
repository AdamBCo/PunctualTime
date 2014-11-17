//
//  ViewController.h
//  PunctualTime
//
//  Created by Adam Cooper on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EventTableViewDelegate <NSObject>

- (void)panGestureDetected:(UIPanGestureRecognizer *)panGesture;

@end

@interface EventTableViewController : UIViewController

@property id<EventTableViewDelegate> delegate;

- (void)rotateArrowImageToDegrees:(CGFloat)degrees;

@end

