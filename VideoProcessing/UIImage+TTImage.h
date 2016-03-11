//
//  UIImage+DKImage.h
//  DubKing
//
//  Created by Justin Lee on 1/15/15.
//  Copyright (c) 2015 SpencerKing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TTImage)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)bigLikeIconWithColor:(UIColor *)color;

- (UIImage *)maskWithColor:(UIColor *)color;
- (UIImage *)convertToPixelSize:(CGSize)size;
- (UIImage *)resizeToScreenSize;
- (UIImage *)resizeToOptimalTTSize;
- (UIImage *)resizeToAvatarSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)cropWithRect:(CGRect)rect;

@end
