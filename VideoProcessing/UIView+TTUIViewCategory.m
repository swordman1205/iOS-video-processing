//
//  UIView+DKUIViewCategory.m
//  DubKing
//
//  Created by Justin Lee on 1/20/15.
//  Copyright (c) 2015 SpencerKing. All rights reserved.
//

#import "UIView+TTUIViewCategory.h"

@implementation UIView(TTUIViewCategory)

- (CGSize)TTSizeThatFits:(CGSize)constrainedSize {
    CGSize size = [self sizeThatFits:constrainedSize];
    CGSize finalSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    return finalSize;
}

- (void) setCornerRadii:(CGSize)cornerRadii forCorners:(UIRectCorner)corners {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:cornerRadii];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

@end
