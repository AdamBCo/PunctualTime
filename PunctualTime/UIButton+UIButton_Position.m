//
//  UIButton+UIButton_Position.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/19/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "UIButton+UIButton_Position.h"

@implementation UIButton (UIButton_Position)

-(void) centerButtonAndImageWithSpacing:(CGFloat)spacing {
    self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
}

@end
