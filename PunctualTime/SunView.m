//
//  SunView.m
//  PunctualTime
//
//  Created by Adam Cooper on 12/21/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "SunView.h"

@implementation SunView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
        if (self) {
            [self createSunView];
        }
    return self;
}

-(void)createSunView {
    
    CGFloat const h = self.frame.size.height;
    CGFloat const w = self.frame.size.width;
    
    int radius = w *.23;
    CAShapeLayer *sun = [CAShapeLayer new];
    sun.position = CGPointMake(self.frame.size.width/2-radius, self.frame.size.height/8 + radius);
    sun.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                          cornerRadius:radius].CGPath;
    sun.fillColor = [UIColor orangeColor].CGColor;
    sun.strokeColor = [UIColor whiteColor].CGColor;
    sun.lineWidth = 5;
    self.center = CGPointMake(0, h);
    [self.layer addSublayer:sun];
}

@end
