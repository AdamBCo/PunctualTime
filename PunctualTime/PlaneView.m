//
//  PlaneView.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/17/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "PlaneView.h"

@implementation PlaneView

-(void)drawPlane{

    [self drawBody];
    [self drawProp];
    [self drawWheel];
    [self drawTail];
    [self drawWings];

}

-(void)drawBody{
    CGFloat const width = self.frame.size.width;
    CGFloat const height = self.frame.size.height;
    CAShapeLayer *body = [CAShapeLayer new];
    CGMutablePathRef bodyPath = CGPathCreateMutable();
    CGPathMoveToPoint(bodyPath, nil, width*.25, height*.20);
    CGPathAddLineToPoint(bodyPath, nil, width*.35, height*.20);
    CGPathAddQuadCurveToPoint(bodyPath, nil, width*.40, height*.22, width*.45, height*.20);
    CGPathAddLineToPoint(bodyPath, nil, width*.45, height*.20);
    CGPathAddLineToPoint(bodyPath, nil, width*.75, height*.20);
    CGPathAddLineToPoint(bodyPath, nil, width*.25, height*.30);
    CGPathAddLineToPoint(bodyPath, nil, width*.25, height*.20);
    body.path = [UIBezierPath bezierPathWithCGPath:bodyPath].CGPath;
    body.strokeColor = [UIColor whiteColor].CGColor;
    body.fillColor = [UIColor clearColor].CGColor;
    body.lineWidth = 2;
    [self.layer addSublayer:body];

}

-(void)drawProp{

    CGFloat const width = self.frame.size.width;
    CGFloat const height = self.frame.size.height;
    CAShapeLayer *prop = [CAShapeLayer new];
    CGMutablePathRef propPath = CGPathCreateMutable();
    CGPathMoveToPoint(propPath, nil, width*.25, height*.25);
    CGPathAddLineToPoint(propPath, nil, width*.23, height*.25);
    CGPathAddLineToPoint(propPath, nil, width*.23, height*.20);
    CGPathAddLineToPoint(propPath, nil, width*.23, height*.30);
    prop.path = [UIBezierPath bezierPathWithCGPath:propPath].CGPath;
    prop.strokeColor = [UIColor whiteColor].CGColor;
    prop.fillColor = [UIColor clearColor].CGColor;
    prop.lineWidth = 2;
    [self.layer addSublayer:prop];

}


-(void)drawWheel{
    CGFloat const width = self.frame.size.width;
    CGFloat const height = self.frame.size.height;

    int radius = self.frame.size.width*.05;
    CAShapeLayer *wheel = [CAShapeLayer new];
    wheel.position = CGPointMake(width/3-radius, height/3.5);
    wheel.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                          cornerRadius:radius].CGPath;
    wheel.strokeColor = [UIColor whiteColor].CGColor;
    wheel.fillColor = [UIColor clearColor].CGColor;
    wheel.lineWidth = 2;
    [self.layer addSublayer:wheel];
    
}

-(void)drawTail{
    CGFloat const width = self.frame.size.width;
    CGFloat const height = self.frame.size.height;

    CAShapeLayer *tail = [CAShapeLayer new];
    CGMutablePathRef tailPath = CGPathCreateMutable();
    CGPathMoveToPoint(tailPath, nil, width*.65, height*.20);
    CGPathAddQuadCurveToPoint(tailPath, nil, width*.70, height*.135, width*.75, height*.20);
    tail.path = [UIBezierPath bezierPathWithCGPath:tailPath].CGPath;
    tail.strokeColor = [UIColor whiteColor].CGColor;
    tail.fillColor = [UIColor clearColor].CGColor;
    tail.lineWidth = 2;
    [self.layer addSublayer:tail];
}

-(void)drawWings{
    CGFloat const width = self.frame.size.width;
    CGFloat const height = self.frame.size.height;

    CAShapeLayer *wingOne = [CAShapeLayer new];
    wingOne.position = CGPointMake(self.frame.size.width*.25, self.frame.size.height*.15);
    wingOne.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0, 0.0, width*.18,height*.02)].CGPath;
    wingOne.strokeColor = [UIColor whiteColor].CGColor;
    wingOne.fillColor = [UIColor clearColor].CGColor;
    wingOne.lineWidth = 2;
    [self.layer addSublayer:wingOne];


    CAShapeLayer *braceOne = [CAShapeLayer new];
    CGMutablePathRef braceOnePath = CGPathCreateMutable();
    CGPathMoveToPoint(braceOnePath, nil, width*.31, height*.17);
    CGPathAddLineToPoint(braceOnePath, nil, width*.34, height*.23);
    braceOne.path = [UIBezierPath bezierPathWithCGPath:braceOnePath].CGPath;
    braceOne.strokeColor = [UIColor whiteColor].CGColor;
    braceOne.fillColor = [UIColor clearColor].CGColor;
    braceOne.lineWidth = 2;
    [self.layer addSublayer:braceOne];

    CAShapeLayer *braceTwo = [CAShapeLayer new];
    CGMutablePathRef braceTwoPath = CGPathCreateMutable();
    CGPathMoveToPoint(braceTwoPath, nil, width*.33, height*.17);
    CGPathAddLineToPoint(braceTwoPath, nil, width*.36, height*.225);
    braceTwo.path = [UIBezierPath bezierPathWithCGPath:braceTwoPath].CGPath;
    braceTwo.strokeColor = [UIColor whiteColor].CGColor;
    braceTwo.fillColor = [UIColor clearColor].CGColor;
    braceTwo.lineWidth = 2;
    [self.layer addSublayer:braceTwo];


    CAShapeLayer *braceThree = [CAShapeLayer new];
    CGMutablePathRef braceThreePath = CGPathCreateMutable();
    CGPathMoveToPoint(braceThreePath, nil, width*.39, height*.17);
    CGPathAddLineToPoint(braceThreePath, nil, width*.42, height*.225);
    braceThree.path = [UIBezierPath bezierPathWithCGPath:braceThreePath].CGPath;
    braceThree.strokeColor = [UIColor whiteColor].CGColor;
    braceThree.fillColor = [UIColor clearColor].CGColor;
    braceThree.lineWidth = 2;
    [self.layer addSublayer:braceThree];

    CAShapeLayer *braceFour = [CAShapeLayer new];
    CGMutablePathRef braceFourPath = CGPathCreateMutable();
    CGPathMoveToPoint(braceFourPath, nil, width*.37, height*.17);
    CGPathAddLineToPoint(braceFourPath, nil, width*.40, height*.225);
    braceFour.path = [UIBezierPath bezierPathWithCGPath:braceFourPath].CGPath;
    braceFour.strokeColor = [UIColor whiteColor].CGColor;
    braceFour.fillColor = [UIColor clearColor].CGColor;
    braceFour.lineWidth = 2;
    [self.layer addSublayer:braceFour];
    

    CAShapeLayer *wingTwo = [CAShapeLayer new];
    wingTwo.position = CGPointMake(self.frame.size.width*.30, self.frame.size.height*.225);
    wingTwo.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0, 0.0, width*.18,height*.02)].CGPath;
    wingTwo.strokeColor = [UIColor whiteColor].CGColor;
    wingTwo.fillColor = [UIColor clearColor].CGColor;
    wingTwo.lineWidth = 2;
    [self.layer addSublayer:wingTwo];


}

-(void)drawBanner{
    CGFloat const width = self.frame.size.width;
    CGFloat const height = self.frame.size.height;

    CAShapeLayer *banner = [CAShapeLayer new];
    CGMutablePathRef bannerPath = CGPathCreateMutable();

    CGPathMoveToPoint(bannerPath, nil, width*.25, height*.20);
    CGPathAddLineToPoint(bannerPath, nil, width*.35, height*.20);
    CGPathAddQuadCurveToPoint(bannerPath, nil, width*.40, height*.22, width*.45, height*.20);
    CGPathAddLineToPoint(bannerPath, nil, width*.45, height*.20);
    CGPathAddLineToPoint(bannerPath, nil, width*.75, height*.20);
    CGPathAddLineToPoint(bannerPath, nil, width*.25, height*.30);
    CGPathAddLineToPoint(bannerPath, nil, width*.25, height*.20);
    banner.path = [UIBezierPath bezierPathWithCGPath:bannerPath].CGPath;
    banner.strokeColor = [UIColor whiteColor].CGColor;
    banner.fillColor = [UIColor clearColor].CGColor;
    banner.lineWidth = 2;
    [self.layer addSublayer:banner];

    
}




@end
