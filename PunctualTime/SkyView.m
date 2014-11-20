//
//  SkyView.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/20/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "SkyView.h"

@implementation SkyView

-(void)drawSkyView{

    CGFloat const h = self.frame.size.height;
    CGFloat const w = self.frame.size.width;

    //Sky
    CAShapeLayer *sky = [CAShapeLayer new];
    CGMutablePathRef skyPath = CGPathCreateMutable();
    CGPathMoveToPoint(skyPath, nil, -w, h*.25);
    CGPathAddCurveToPoint(skyPath, nil, -w*.5, h*.2, -w*.5, h*.3, 0, h*.25);
    CGPathMoveToPoint(skyPath, nil, 0, h*.25);
    CGPathAddCurveToPoint(skyPath, nil, w*.5, h*.2, w*.5, h*.3, w, h*.25);
    sky.path = [UIBezierPath bezierPathWithCGPath:skyPath].CGPath;
    sky.strokeColor = [UIColor whiteColor].CGColor;
    sky.fillColor = [UIColor clearColor].CGColor;
    sky.lineWidth = 2;
    [self.layer addSublayer:sky];
    

    //SkyTwo
    CAShapeLayer *skyTwo = [CAShapeLayer new];
    CGMutablePathRef skyPathTwo = CGPathCreateMutable();
    CGPathMoveToPoint(skyPathTwo, nil, -w, h*.45);
    CGPathAddCurveToPoint(skyPathTwo, nil, -w*.5, h*.4, -w*.5, h*.5, 0, h*.45);
    CGPathMoveToPoint(skyPathTwo, nil, 0, h*.45);
    CGPathAddCurveToPoint(skyPathTwo, nil, w*.5, h*.4, w*.5, h*.5, w, h*.45);
    skyTwo.path = [UIBezierPath bezierPathWithCGPath:skyPathTwo].CGPath;
    skyTwo.strokeColor = [UIColor whiteColor].CGColor;
    skyTwo.fillColor = [UIColor clearColor].CGColor;
    skyTwo.lineWidth = 2;
    [self.layer addSublayer:skyTwo];
}



@end
