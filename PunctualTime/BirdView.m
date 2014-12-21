//
//  BirdView.m
//  PunctualTime
//
//  Created by Adam Cooper on 12/21/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "BirdView.h"

@implementation BirdView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self createBirdView];
    }
    return self;
}

-(void)createBirdView {
    
    CGFloat const h = self.frame.size.height;
    CGFloat const w = self.frame.size.width;
    
    CAShapeLayer *birdOne = [CAShapeLayer new];
    CGMutablePathRef birdPath = CGPathCreateMutable();
    CGPathMoveToPoint(birdPath, nil, w*.4, h*.20);
    CGPathAddQuadCurveToPoint(birdPath, nil, w*.43, h*.18, w*.45, h*.20);
    CGPathAddQuadCurveToPoint(birdPath, nil, w*.46, h*.18, w*.50, h*.20);
    birdOne.path = [UIBezierPath bezierPathWithCGPath:birdPath].CGPath;
    birdOne.strokeColor = [UIColor whiteColor].CGColor;
    birdOne.fillColor = [UIColor clearColor].CGColor;
    birdOne.lineWidth = 2;
    
    CAShapeLayer *birdTwo = [CAShapeLayer new];
    CGMutablePathRef birdPathTwo = CGPathCreateMutable();
    CGPathMoveToPoint(birdPathTwo, nil, w*.44, h*.24);
    CGPathAddQuadCurveToPoint(birdPathTwo, nil, w*.47, h*.22, w*.49, h*.24);
    CGPathAddQuadCurveToPoint(birdPathTwo, nil, w*.50, h*.22, w*.54, h*.24);
    birdTwo.path = [UIBezierPath bezierPathWithCGPath:birdPathTwo].CGPath;
    birdTwo.strokeColor = [UIColor whiteColor].CGColor;
    birdTwo.fillColor = [UIColor clearColor].CGColor;
    birdTwo.lineWidth = 2;
    
    
    [self.layer addSublayer:birdOne];
    [self.layer addSublayer:birdTwo];
    
}
@end
