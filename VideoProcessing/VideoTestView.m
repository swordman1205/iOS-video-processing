//
//  VideoTestView.m
//  TikTokIOS
//
//  Created by Justin Lee on 8/4/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import "VideoTestView.h"

#define kPrivate_videoViewMaxWidth 450

@implementation VideoTestView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor whiteColor];
        
        self.videoContainerView = [[UIView alloc] init];
        [self addSubview:self.videoContainerView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize parentSize = self.bounds.size;
    
    CGRect videoViewFrame = [self videoViewFrame:parentSize];
    self.videoContainerView.frame = videoViewFrame;
    
    if (!self.videoView.hidden){
        self.videoView.frame = self.videoContainerView.bounds;
    }
}

- (CGRect) videoViewFrame:(CGSize)parentSize {
    float videoViewTop = 30;
    float videoViewWidthHeight = (parentSize.width > kPrivate_videoViewMaxWidth) ? kPrivate_videoViewMaxWidth : parentSize.width;
    float videoViewLeft = parentSize.width/2.0 - videoViewWidthHeight/2.0;
    CGRect frame = CGRectMake(videoViewLeft,
                              videoViewTop,
                              videoViewWidthHeight,
                              videoViewWidthHeight);
    return frame;
}

@end
