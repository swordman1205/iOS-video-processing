//
//  UIImage+DKImage.m
//  DubKing
//
//  Created by Justin Lee on 1/15/15.
//  Copyright (c) 2015 SpencerKing. All rights reserved.
//

#import "UIImage+TTImage.h"

@implementation UIImage (TTImage)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)bigLikeIconWithColor:(UIColor *)color {
    UIImage *borderImage = [[UIImage imageNamed:@"like_icon_big_border"] maskWithColor:color];
    UIImage *whiteHeartImage = [UIImage imageNamed:@"like_icon_big"];
    UIImage *finalImage = [self drawImage:borderImage inImage:whiteHeartImage];
    return finalImage;
}

//http://stackoverflow.com/questions/19274789/how-can-i-change-image-tintcolor-in-ios-and-watchkit
- (UIImage *)maskWithColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)resizeToOptimalTTSize {
//    float optimalImageLength = kAppImageOptimalLength;
//    CGSize curImageSize = self.size;
    CGSize finalImageSize = CGSizeMake(kAppImageOptimalWidthPixels, kAppImageOptimalWidthPixels*kAppMediaHeightWidthRatio);
//    if (curImageSize.width > curImageSize.height){
//        finalImageSize.width = optimalImageLength;
//        finalImageSize.height = finalImageSize.width * 1.0 * (curImageSize.height / curImageSize.width);
//    } else {
//        finalImageSize.height = optimalImageLength;
//        finalImageSize.width = finalImageSize.height * 1.0 * (curImageSize.width / curImageSize.height);
//    }
    UIImage *finalImage = [self convertToPixelSize:finalImageSize];
    return finalImage;
}

- (UIImage *)resizeToScreenSize {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float maxImageLength = (screenSize.height > screenSize.width) ? screenSize.width : screenSize.height;
    maxImageLength = (maxImageLength > 400) ? 400 : maxImageLength;
    CGSize curImageSize = self.size;
    CGSize finalImageSize;
    if (curImageSize.width > curImageSize.height){
        finalImageSize.width = (curImageSize.width > maxImageLength) ? maxImageLength : curImageSize.width;
        finalImageSize.height = finalImageSize.width * 1.0 * (curImageSize.height / curImageSize.width);
    } else {
        finalImageSize.height = (curImageSize.height > maxImageLength) ? maxImageLength : curImageSize.height;
        finalImageSize.width = finalImageSize.height * 1.0 * (curImageSize.width / curImageSize.height);
    }
    UIImage *finalImage = [self convertToPixelSize:finalImageSize];
    return finalImage;
}

- (UIImage *)resizeToAvatarSize {
    return [self convertToPixelSize:CGSizeMake(kAppAvatarWidthHeightPixels, kAppAvatarWidthHeightPixels)];
}

//in pixels
- (UIImage *)convertToPixelSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}


//http://stackoverflow.com/questions/2025319/scale-image-in-an-uibutton-to-aspectfit
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (!CGSizeEqualToSize(imageSize, targetSize)) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    return newImage ;
}

//-------------- UIImage Crop
//http://stackoverflow.com/questions/158914/cropping-a-uiimage/14712184#14712184
//TODO:returned size is 480px x 481px. check why not exactly the same
- (UIImage *)cropWithRect:(CGRect)rect {
    CGAffineTransform rectTransform;
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), 0, -self.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -self.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI), -self.size.width, -self.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    rectTransform = CGAffineTransformScale(rectTransform, self.scale, self.scale);
    
    CGRect finalCropRect = CGRectApplyAffineTransform(rect, rectTransform);
//    if (finalCropRect.size.height < finalCropRect.size.width){
//        finalCropRect.size.width = finalCropRect.size.height;
//    } else {
//        finalCropRect.size.height = finalCropRect.size.width;
//    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], finalCropRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

#pragma mark - helper

//http://stackoverflow.com/questions/7313023/overlay-an-image-over-another-image-in-ios
+(UIImage*) drawImage:(UIImage*) fgImage
              inImage:(UIImage*) bgImage
{
    CGSize newImageSize = (fgImage.size.width > bgImage.size.width) ? fgImage.size : bgImage.size;
    UIGraphicsBeginImageContextWithOptions(newImageSize, FALSE, 0.0);
    CGSize bgImageSize = bgImage.size;
    float bgImageLeft = newImageSize.width/2.0 - bgImageSize.width/2.0;
    float bgImageTop = newImageSize.height/2.0 - bgImageSize.height/2.0;
    [bgImage drawInRect:CGRectMake( bgImageLeft, bgImageTop, bgImageSize.width, bgImageSize.height)];
    CGSize fgImageSize = fgImage.size;
    float fgImageLeft = newImageSize.width/2.0 - fgImageSize.width/2.0;
    float fgImageTop = newImageSize.height/2.0 - fgImageSize.height/2.0;
    [fgImage drawInRect:CGRectMake( fgImageLeft, fgImageTop, fgImageSize.width, fgImageSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
