//
//  CameraVideoProgressView.m
//  TikTokIOS
//
//  Created by Justin Lee on 8/4/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import "CameraVideoProgressView.h"
#import "UIView+TTUIViewCategory.h"

@implementation CameraVideoProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.minValueBar = [[UIView alloc] init];
        self.minValueBar.backgroundColor = RGBCOLOR(200, 200, 200);
        [self addSubview:self.minValueBar];
        
        self.curValueBar = [[UIView alloc] init];
        self.curValueBar.backgroundColor = RGBCOLOR(255, 89, 103);
        [self addSubview:self.curValueBar];
        
        _minValue = 0;
        _curValue = 0;
    }
    return self;
}

- (void)layoutSubviews {
    self.minValueBar.frame = [self minValueBarFrame];
    self.curValueBar.frame = [self curValueBarFrame];
}

#pragma mark - get UIView frames

- (CGRect)minValueBarFrame {
    CGSize parentSize = self.bounds.size;
    float minValueBarLeft = 0;
    float minValueBarWidth = self.minValue * parentSize.width - minValueBarLeft;
    CGRect finalFrame = CGRectMake(minValueBarLeft,
                                   0,
                                   minValueBarWidth,
                                   parentSize.height);
    return finalFrame;
}

- (CGRect)curValueBarFrame {
    CGSize parentSize = self.bounds.size;
    float curValueBarLeft = 0;
    float curValueBarWidth = self.curValue * parentSize.width - curValueBarLeft;
    CGRect finalFrame = CGRectMake(curValueBarLeft,
                                   0,
                                   curValueBarWidth,
                                   parentSize.height);
    return finalFrame;
}

#pragma mark - override setters

- (void)setMinValue:(float)minValue {
    _minValue = minValue;
    [self setNeedsLayout];
}

- (void)setCurValue:(float)curValue {
    _curValue = curValue;
//    NSLog(@"curValue:%f",curValue);
    [self setNeedsLayout];
}

@end
