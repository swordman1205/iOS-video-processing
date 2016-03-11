//
//  TTInfoBannerView.m
//  TikTokIOS
//
//  Created by Justin Lee on 4/30/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import "TTInfoBannerView.h"

#define kPrivate_paddingLeftRight 10

@implementation TTInfoBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = RGBACOLOR(255, 89, 103, 0.85);
        
        self.infoLabel = [[UILabel alloc] init];
        self.infoLabel.font = kFontMediumWithSize(13);
        self.infoLabel.textColor = RGBCOLOR(255, 255, 255);
        self.infoLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.infoLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize parentSize = self.bounds.size;
    float maxWidth = parentSize.width - 2 *kPrivate_paddingLeftRight;
    float labelHeight = ceilf(self.infoLabel.font.lineHeight);
    CGSize infoLabelSize = [self.infoLabel sizeThatFits:CGSizeMake(maxWidth, labelHeight)];
    float infoLabelTop = parentSize.height/2.0 - labelHeight/2.0;
    float infoLabelLeft = parentSize.width/2.0 - infoLabelSize.width/2.0;
    self.infoLabel.frame = CGRectMake(infoLabelLeft,
                                      infoLabelTop,
                                      infoLabelSize.width,
                                      infoLabelSize.height);
}

#pragma mark - override setters

- (void)setInfoStr:(NSString *)infoStr {
    _infoStr = infoStr;
    self.infoLabel.text = infoStr;
}

@end
