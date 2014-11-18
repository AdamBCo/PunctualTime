//
//  PlaneView.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/17/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "PlaneView.h"

@implementation PlaneView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)drawPlane{

//CAShapeLayer *plane = [CAShapeLayer new];
//CGMutablePathRef planePath = CGPathCreateMutable();
//CGPathMoveToPoint(planePath, nil, self.bounds.size.width*.44, self.bounds.size.height*.24);
//CGPathAddQuadCurveToPoint(planePath, nil, self.bounds.size.width*.47, self.bounds.size.height*.22, self.bounds.size.width*.49, self.bounds.size.height*.24);
//CGPathAddQuadCurveToPoint(planePath, nil, self.bounds.size.width*.50, self.bounds.size.height*.22, self.bounds.size.width*.54, self.bounds.size.height*.24);
//plane.path = [UIBezierPath bezierPathWithCGPath:planePath].CGPath;
//plane.strokeColor = [UIColor whiteColor].CGColor;
//plane.fillColor = [UIColor clearColor].CGColor;
//plane.lineWidth = 2;

    [self drawBody];
    [self drawProp];
    [self drawWheel];
    [self drawTail];
    [self drawWings];
//    [self.layer addSublayer:plane];


}

-(void)drawBody{
    CAShapeLayer *body = [CAShapeLayer new];
    CGMutablePathRef bodyPath = CGPathCreateMutable();

    CGPathMoveToPoint(bodyPath, nil, self.bounds.size.width*.25, self.bounds.size.height*.20);
    CGPathAddLineToPoint(bodyPath, nil, self.bounds.size.width*.35, self.bounds.size.height*.20);
    CGPathAddQuadCurveToPoint(bodyPath, nil, self.bounds.size.width*.40, self.bounds.size.height*.22, self.bounds.size.width*.45, self.bounds.size.height*.20);
    CGPathAddLineToPoint(bodyPath, nil, self.bounds.size.width*.45, self.bounds.size.height*.20);
    CGPathAddLineToPoint(bodyPath, nil, self.bounds.size.width*.75, self.bounds.size.height*.20);
    CGPathAddLineToPoint(bodyPath, nil, self.bounds.size.width*.25, self.bounds.size.height*.30);
    CGPathAddLineToPoint(bodyPath, nil, self.bounds.size.width*.25, self.bounds.size.height*.20);
    body.path = [UIBezierPath bezierPathWithCGPath:bodyPath].CGPath;
    body.strokeColor = [UIColor whiteColor].CGColor;
    body.fillColor = [UIColor clearColor].CGColor;
    body.lineWidth = 2;
    [self.layer addSublayer:body];

}

-(void)drawProp{

    CAShapeLayer *prop = [CAShapeLayer new];
    CGMutablePathRef propPath = CGPathCreateMutable();

    CGPathMoveToPoint(propPath, nil, self.bounds.size.width*.25, self.bounds.size.height*.25);
    CGPathAddLineToPoint(propPath, nil, self.bounds.size.width*.23, self.bounds.size.height*.25);
    CGPathAddLineToPoint(propPath, nil, self.bounds.size.width*.23, self.bounds.size.height*.20);
    CGPathAddLineToPoint(propPath, nil, self.bounds.size.width*.23, self.bounds.size.height*.30);
    prop.path = [UIBezierPath bezierPathWithCGPath:propPath].CGPath;
    prop.strokeColor = [UIColor whiteColor].CGColor;
    prop.fillColor = [UIColor clearColor].CGColor;
    prop.lineWidth = 2;
    [self.layer addSublayer:prop];

}


-(void)drawWheel{

    int radius = self.frame.size.width*.05;
    CAShapeLayer *wheel = [CAShapeLayer new];
    wheel.position = CGPointMake(self.frame.size.width/3-radius, self.frame.size.height/3.5);
    wheel.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                          cornerRadius:radius].CGPath;
    wheel.strokeColor = [UIColor whiteColor].CGColor;
    wheel.fillColor = [UIColor clearColor].CGColor;
    wheel.lineWidth = 2;
    [self.layer addSublayer:wheel];
    
}

-(void)drawTail{
    CAShapeLayer *tail = [CAShapeLayer new];
    CGMutablePathRef tailPath = CGPathCreateMutable();
    CGPathMoveToPoint(tailPath, nil, self.bounds.size.width*.65, self.bounds.size.height*.20);
    CGPathAddQuadCurveToPoint(tailPath, nil, self.bounds.size.width*.70, self.bounds.size.height*.135, self.bounds.size.width*.75, self.bounds.size.height*.20);
    tail.path = [UIBezierPath bezierPathWithCGPath:tailPath].CGPath;
    tail.strokeColor = [UIColor whiteColor].CGColor;
    tail.fillColor = [UIColor clearColor].CGColor;
    tail.lineWidth = 2;
    [self.layer addSublayer:tail];
}

-(void)drawWings{
    CAShapeLayer *wingOne = [CAShapeLayer new];
    wingOne.position = CGPointMake(self.frame.size.width*.25, self.frame.size.height*.15);
    wingOne.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0, 0.0, self.bounds.size.width*.18,self.bounds.size.height*.02)].CGPath;
    wingOne.strokeColor = [UIColor whiteColor].CGColor;
    wingOne.fillColor = [UIColor clearColor].CGColor;
    wingOne.lineWidth = 2;
    [self.layer addSublayer:wingOne];


    CAShapeLayer *braceOne = [CAShapeLayer new];
    CGMutablePathRef braceOnePath = CGPathCreateMutable();
    CGPathMoveToPoint(braceOnePath, nil, self.bounds.size.width*.31, self.bounds.size.height*.17);
    CGPathAddLineToPoint(braceOnePath, nil, self.bounds.size.width*.34, self.bounds.size.height*.23);
    braceOne.path = [UIBezierPath bezierPathWithCGPath:braceOnePath].CGPath;
    braceOne.strokeColor = [UIColor whiteColor].CGColor;
    braceOne.fillColor = [UIColor clearColor].CGColor;
    braceOne.lineWidth = 2;
    [self.layer addSublayer:braceOne];

    CAShapeLayer *braceTwo = [CAShapeLayer new];
    CGMutablePathRef braceTwoPath = CGPathCreateMutable();
    CGPathMoveToPoint(braceTwoPath, nil, self.bounds.size.width*.33, self.bounds.size.height*.17);
    CGPathAddLineToPoint(braceTwoPath, nil, self.bounds.size.width*.36, self.bounds.size.height*.225);
    braceTwo.path = [UIBezierPath bezierPathWithCGPath:braceTwoPath].CGPath;
    braceTwo.strokeColor = [UIColor whiteColor].CGColor;
    braceTwo.fillColor = [UIColor clearColor].CGColor;
    braceTwo.lineWidth = 2;
    [self.layer addSublayer:braceTwo];



    CAShapeLayer *wingTwo = [CAShapeLayer new];
    wingTwo.position = CGPointMake(self.frame.size.width*.30, self.frame.size.height*.225);
    wingTwo.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0, 0.0, self.bounds.size.width*.18,self.bounds.size.height*.02)].CGPath;
    wingTwo.strokeColor = [UIColor whiteColor].CGColor;
    wingTwo.fillColor = [UIColor clearColor].CGColor;
    wingTwo.lineWidth = 2;
    [self.layer addSublayer:wingTwo];


}





@end
