//
//  TTInfoBannerController.m
//  TikTokIOS
//
//  Created by Justin Lee on 4/30/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import "TTInfoBannerController.h"
#import "TTInfoBannerView.h"

#define kPrivate_infoBannerViewHeight 30

#define kPrivate_infoBannerViewAnimationDuration 0.5 //secs
#define kPrivate_infoBannerViewExposedDuration 2 //secs

@interface TTInfoBannerController()

@end

@implementation TTInfoBannerController

- (instancetype)init {
    self = [super init];
    if (self){
        self.displayView = nil;
        self.mainContentView = nil;
        self.mainContentViewInsetTop = 0;
    }
    return self;
}

- (void)showInfo:(NSString *)infoString bannerBgColor:(UIColor *)bannerBgColor {
    if (self.displayView == nil) return;
    
    UIView *infoBannerBgView = [[UIView alloc] init];
    infoBannerBgView.clipsToBounds = YES;
    infoBannerBgView.backgroundColor = [UIColor clearColor];
    
    TTInfoBannerView *infoBannerView = [[TTInfoBannerView alloc] init];
    infoBannerView.infoStr = infoString;
    [infoBannerBgView addSubview:infoBannerView];
    if (bannerBgColor != nil){
        infoBannerView.backgroundColor = bannerBgColor;
    }
    
    //set frame
    infoBannerBgView.frame = [self infoBannerBgViewFrame];
    infoBannerView.frame = [self infoBannerViewFullyHiddenFrame];
    
    [self.displayView addSubview:infoBannerBgView];
    
    [UIView animateWithDuration:kPrivate_infoBannerViewAnimationDuration
                          delay:0.0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         infoBannerView.frame = [self infoBannerViewFullyShownFrame];
                     } completion:^(BOOL finished){
                         NSLog(@"show infoBannerView completed");
                     }];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kPrivate_infoBannerViewExposedDuration * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //status view can go away after couple seconds
        [self hideInfoBannerView:infoBannerView infoBannerBgView:infoBannerBgView];
    });
}

- (void)showInfo:(NSString *)infoString {
    [self showInfo:infoString bannerBgColor:nil];
}

- (void) hideInfoBannerView:(UIView *)infoBannerView infoBannerBgView:(UIView *)infoBannerBgView {
    if (infoBannerView == nil) return;
    if (infoBannerBgView == nil) return;
    [UIView animateWithDuration:kPrivate_infoBannerViewAnimationDuration
                          delay:0.0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         infoBannerView.frame = [self infoBannerViewFullyHiddenFrame];
                     } completion:^(BOOL finished){
                         NSLog(@"hide infoBannerView completed");
                         if (infoBannerBgView == nil) return;
                         infoBannerBgView.hidden = YES;
                         [infoBannerBgView removeFromSuperview];
                     }];

}

#pragma mark - get frames

- (CGRect) infoBannerBgViewFrame {
    if (self.displayView == nil) return CGRectZero;
    CGSize displayViewSize = self.displayView.bounds.size;
    float infoBannerBgViewTop = [self displayViewTopForDisplayingBanner];
    float infoBannerBgViewWidth = displayViewSize.width;
    CGRect finalFrame = CGRectMake(0,
                                   infoBannerBgViewTop,
                                   infoBannerBgViewWidth,
                                   kPrivate_infoBannerViewHeight);
    return finalFrame;
}

- (CGRect) infoBannerViewFullyHiddenFrame {
    if (self.displayView == nil) return CGRectZero;
    CGRect infoBannerBgViewFrame = [self infoBannerBgViewFrame];
    float infoBannerViewTop = -1.0 *kPrivate_infoBannerViewHeight;
    float infoBannerViewWidth = infoBannerBgViewFrame.size.width;
    CGRect finalFrame = CGRectMake(0,
                                   infoBannerViewTop,
                                   infoBannerViewWidth,
                                   kPrivate_infoBannerViewHeight);
    return finalFrame;
}

- (CGRect) infoBannerViewFullyShownFrame {
    if (self.displayView == nil) return CGRectZero;
    CGRect infoBannerBgViewFrame = [self infoBannerBgViewFrame];
    float infoBannerViewTop = 0;
    float infoBannerViewWidth = infoBannerBgViewFrame.size.width;
    CGRect finalFrame = CGRectMake(0,
                                   infoBannerViewTop,
                                   infoBannerViewWidth,
                                   kPrivate_infoBannerViewHeight);
    return finalFrame;
}

#pragma mark - helpers

//contentInset is too much if refreshControl is active. scrollInset is hack for now. Might need to hv delegate to ask for this position
- (float) displayViewTopForDisplayingBanner {
    if (self.displayView == nil) return 0;
    if (self.mainContentView == nil) return 0;
    float displayViewTop;
    float mainContentViewTop = self.mainContentView.top;
    if ([self.mainContentView isKindOfClass:[UIScrollView class]]){
        UIScrollView *mainContentScrollView = (UIScrollView *)self.mainContentView;
        float topScrollInset = mainContentScrollView.scrollIndicatorInsets.top;
        displayViewTop = mainContentViewTop + topScrollInset;
    } else {
        displayViewTop = mainContentViewTop + self.mainContentViewInsetTop;
    }
    return displayViewTop;
}

@end
