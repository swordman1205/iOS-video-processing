//
//  TTInfoBannerController.h
//  TikTokIOS
//
//  Created by Justin Lee on 4/30/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTInfoBannerController : NSObject

@property (nonatomic, weak) UIView *displayView;
@property (nonatomic, weak) UIView *mainContentView;
@property (nonatomic) float mainContentViewInsetTop;

- (void) showInfo:(NSString *)infoString;
- (void) showInfo:(NSString *)infoString bannerBgColor:(UIColor *)bannerBgColor;

@end
