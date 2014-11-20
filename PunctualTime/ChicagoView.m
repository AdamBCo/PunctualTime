//
//  ChicagoView.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/20/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "ChicagoView.h"

@implementation ChicagoView

-(void)drawChicago{
    [self drawBuildings];
    [self drawGround];

}
-(void)drawBuildings{

    CGFloat const h = self.frame.size.height;
    CGFloat const w = self.frame.size.width;

    CAShapeLayer *buildings = [CAShapeLayer new];
    CGMutablePathRef chicago = CGPathCreateMutable();
    CGPathMoveToPoint(chicago, nil, 0, h*.80);//Starting Point
    CGPathAddLineToPoint(chicago, nil, 0, h*.65);
    CGPathAddLineToPoint(chicago, nil, w*.05, h*.65);//Building One
    CGPathAddLineToPoint(chicago, nil, w*.05, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.08, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.10, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.10, h*.51);
    CGPathAddLineToPoint(chicago, nil, w*.10, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.14, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.14, h*.51);
    CGPathAddLineToPoint(chicago, nil, w*.14, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.16, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.19, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.19, h*.70);
    CGPathAddLineToPoint(chicago, nil, w*.21, h*.70);
    CGPathAddLineToPoint(chicago, nil, w*.21, h*.52);
    CGPathAddLineToPoint(chicago, nil, w*.22, h*.52);
    CGPathAddLineToPoint(chicago, nil, w*.22, h*.52);
    CGPathAddLineToPoint(chicago, nil, w*.23, h*.52);
    CGPathAddLineToPoint(chicago, nil, w*.23, h*.50);
    CGPathAddLineToPoint(chicago, nil, w*.24, h*.50);
    CGPathAddLineToPoint(chicago, nil, w*.25, h*.50);
    CGPathAddLineToPoint(chicago, nil, w*.25, h*.46);
    CGPathAddLineToPoint(chicago, nil, w*.25, h*.50);
    CGPathAddLineToPoint(chicago, nil, w*.27, h*.50);
    CGPathAddLineToPoint(chicago, nil, w*.27, h*.65);
    CGPathAddLineToPoint(chicago, nil, w*.29, h*.65);
    CGPathAddLineToPoint(chicago, nil, w*.29, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.29, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.29, h*.70);
    CGPathAddLineToPoint(chicago, nil, w*.35, h*.70);
    CGPathAddLineToPoint(chicago, nil, w*.35, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.35, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.35, h*.65);
    CGPathAddLineToPoint(chicago, nil, w*.37, h*.60);
    CGPathAddLineToPoint(chicago, nil, w*.39, h*.65);
    CGPathAddLineToPoint(chicago, nil, w*.39, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.39, h*.68);
    CGPathAddLineToPoint(chicago, nil, w*.41, h*.67);
    CGPathAddLineToPoint(chicago, nil, w*.46, h*.67);
    CGPathAddLineToPoint(chicago, nil, w*.47, h*.68);
    CGPathAddLineToPoint(chicago, nil, w*.47, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.47, h*.74);//Merchant mart
    CGPathAddLineToPoint(chicago, nil, w*.485, h*.735);
    CGPathAddLineToPoint(chicago, nil, w*.52, h*.735);//base
    CGPathAddLineToPoint(chicago, nil, w*.52, h*.73);
    CGPathAddLineToPoint(chicago, nil, w*.53, h*.725);//Bridge
    CGPathAddLineToPoint(chicago, nil, w*.60, h*.725);
    CGPathAddLineToPoint(chicago, nil, w*.61, h*.73);
    CGPathAddLineToPoint(chicago, nil, w*.61, h*.735);
    CGPathAddLineToPoint(chicago, nil, w*.645, h*.735);
    CGPathAddLineToPoint(chicago, nil, w*.65, h*.74);//base
    CGPathAddLineToPoint(chicago, nil, w*.65, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.65, h*.80);//Space
    CGPathAddLineToPoint(chicago, nil, w*.65, h*.67);//Building Four
    CGPathAddLineToPoint(chicago, nil, w*.70, h*.64);
    CGPathAddLineToPoint(chicago, nil, w*.70, h*.665);
    CGPathAddLineToPoint(chicago, nil, w*.70, h*.64);
    CGPathAddLineToPoint(chicago, nil, w*.75, h*.67);
    CGPathAddLineToPoint(chicago, nil, w*.70, h*.692);
    CGPathAddLineToPoint(chicago, nil, w*.65, h*.67);
    CGPathAddLineToPoint(chicago, nil, w*.70, h*.692);
    CGPathAddLineToPoint(chicago, nil, w*.75, h*.67);
    CGPathAddLineToPoint(chicago, nil, w*.75, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.75, h*.80);//Building Five
    CGPathAddLineToPoint(chicago, nil, w*.75, h*.70);
    CGPathAddLineToPoint(chicago, nil, w*.80, h*.70);
    CGPathAddLineToPoint(chicago, nil, w*.80, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.80, h*.75);//Sears Tower
    CGPathAddLineToPoint(chicago, nil, w*.80, h*.75);
    CGPathAddLineToPoint(chicago, nil, w*.80, h*.65);
    CGPathAddLineToPoint(chicago, nil, w*.81, h*.65);
    CGPathAddLineToPoint(chicago, nil, w*.81, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.82, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.82, h*.45);//First Spike
    CGPathAddLineToPoint(chicago, nil, w*.83, h*.45);
    CGPathAddLineToPoint(chicago, nil, w*.83, h*.35);
    CGPathAddLineToPoint(chicago, nil, w*.83, h*.45);
    CGPathAddLineToPoint(chicago, nil, w*.85, h*.45);//Second Spike
    CGPathAddLineToPoint(chicago, nil, w*.85, h*.35);//Top of Spike
    CGPathAddLineToPoint(chicago, nil, w*.85, h*.45);//Back To Bottom
    CGPathAddLineToPoint(chicago, nil, w*.86, h*.45);//Top right Edge
    CGPathAddLineToPoint(chicago, nil, w*.86, h*.55);//First Down
    CGPathAddLineToPoint(chicago, nil, w*.87, h*.55);//Edge
    CGPathAddLineToPoint(chicago, nil, w*.87, h*.65);//Third Down
    CGPathAddLineToPoint(chicago, nil, w*.88, h*.65);//Third Edge
    CGPathAddLineToPoint(chicago, nil, w*.88, h*.75);//Fourth Edge
    CGPathAddLineToPoint(chicago, nil, w*.89, h*.75);//
    CGPathAddLineToPoint(chicago, nil, w*.89, h*.80);//Bottom
    CGPathAddLineToPoint(chicago, nil, w*.91, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.91, h*.65);
    CGPathAddLineToPoint(chicago, nil, w, h*.65);
    CGPathAddLineToPoint(chicago, nil, w, h*.80);//End of Drawing

    CGPathRetain(chicago);
    buildings.path = [UIBezierPath bezierPathWithCGPath:chicago].CGPath;
    buildings.strokeColor = [UIColor whiteColor].CGColor;
    buildings.fillColor = [UIColor orangeColor].CGColor;
    buildings.lineWidth = 2;

    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"drawingAnimation"];
    drawAnimation.duration            = 2.0;
    drawAnimation.repeatCount         = 1.0;
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [buildings addAnimation:drawAnimation forKey:@"drawBuildings"];
    [self.layer addSublayer:buildings];

}

-(void)drawGround{

    CAShapeLayer *ground = [CAShapeLayer new];
    CGMutablePathRef background = CGPathCreateMutable();
    CGPathMoveToPoint(background, nil, 0, self.frame.size.height*.80);
    CGPathAddLineToPoint(background, nil, self.frame.size.width, self.frame.size.height*.80);
    CGPathRetain(background);

    ground.path = [UIBezierPath bezierPathWithCGPath:background].CGPath;
    ground.strokeColor = [UIColor whiteColor].CGColor;
    ground.lineWidth = 5;
    [self.layer addSublayer:ground];



    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"drawingAnimation"];
    drawAnimation.duration            = 2.0;
    drawAnimation.repeatCount         = 1.0;
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [ground addAnimation:drawAnimation forKey:@"drawBuildings"];
    [self.layer addSublayer:ground];


    UIView *bottomCover = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.8, self.frame.size.width, self.frame.size.height*.2)];
    bottomCover.backgroundColor = [UIColor orangeColor];
    [self addSubview:bottomCover];
}

@end
