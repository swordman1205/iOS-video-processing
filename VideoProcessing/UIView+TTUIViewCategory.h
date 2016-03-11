//
//  UIView+DKUIViewCategory.h
//  DubKing
//
//  Created by Justin Lee on 1/20/15.
//  Copyright (c) 2015 SpencerKing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(TTUIViewCategory)

- (CGSize) TTSizeThatFits:(CGSize)constrainedSize;
- (void) setCornerRadii:(CGSize)cornerRadii forCorners:(UIRectCorner)corners;

@end
