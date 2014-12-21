//
//  SkyView.m
//  PunctualTime
//
//  Created by Adam Cooper on 12/21/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "SkyView.h"

@implementation SkyView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self createSkyViewWithAnimation];
    }
    return self;
}

-(void)createSkyViewWithAnimation {
    
    
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
    
    
    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = 2.0;
    drawAnimation.repeatCount         = 1.0;
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [sky addAnimation:drawAnimation forKey:@"drawSkyAnimation"];
    [skyTwo addAnimation:drawAnimation forKey:@"drawSkyTwoAnimation"];
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"Move"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:1000];
    rotationAnimation.duration = 10;
    rotationAnimation.repeatCount = INFINITY;
    
    [self.layer addSublayer:sky];
    [self.layer addSublayer:skyTwo];
}


@end
