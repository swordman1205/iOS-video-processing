//
//  squareBoxesView.m
//  TikTokIOS
//
//  Created by Justin Lee on 8/6/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import "SquareBoxesView.h"

#define kPrivate_squareBoxLinesBgColor RGBCOLOR(155,155,155)
#define kPrivate_squareBoxLinesThickness 1

@implementation SquareBoxesView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.hLine1 = [[UIView alloc] init];
        [self addSubview:self.hLine1];
        
        self.hLine2 = [[UIView alloc] init];
        [self addSubview:self.hLine2];
        
        self.vLine1 = [[UIView alloc] init];
        [self addSubview:self.vLine1];
        
        self.vLine2 = [[UIView alloc] init];
        [self addSubview:self.vLine2];
        
        self.lineColor = kPrivate_squareBoxLinesBgColor;
        
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize parentSize = self.bounds.size;
    
    float verticalGap = parentSize.height/3.0;
    float horizontalGap = parentSize.width/3.0;
    
    float vLine1Top = verticalGap - kPrivate_squareBoxLinesThickness/2.0;
    self.vLine1.frame = CGRectMake(0,
                                   vLine1Top,
                                   parentSize.width,
                                   kPrivate_squareBoxLinesThickness);
    
    float vLine2Top = verticalGap*2 - kPrivate_squareBoxLinesThickness/2.0;
    self.vLine2.frame = CGRectMake(0,
                                   vLine2Top,
                                   parentSize.width,
                                   kPrivate_squareBoxLinesThickness);
    
    float hLine1Left = horizontalGap - kPrivate_squareBoxLinesThickness/2.0;
    self.hLine1.frame = CGRectMake(hLine1Left,
                                   0,
                                   kPrivate_squareBoxLinesThickness,
                                   parentSize.height);
    
    float hLine2Left = horizontalGap*2 - kPrivate_squareBoxLinesThickness/2.0;
    self.hLine2.frame = CGRectMake(hLine2Left,
                                   0,
                                   kPrivate_squareBoxLinesThickness,
                                   parentSize.height);
}

#pragma mark - override setters

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    self.hLine1.backgroundColor = lineColor;
    self.hLine2.backgroundColor = lineColor;
    self.vLine1.backgroundColor = lineColor;
    self.vLine2.backgroundColor = lineColor;
}

@end
