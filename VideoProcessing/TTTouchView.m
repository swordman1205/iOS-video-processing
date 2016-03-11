//
//  TTTouchView.m
//  TikTokIOS
//
//  Created by Justin Lee on 6/11/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import "TTTouchView.h"

@implementation TTTouchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        _touchDelegate = nil;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.touchDelegate != nil){
        if ([self.touchDelegate respondsToSelector:@selector(TTTouchView:userDidTouch:)]){
            [self.touchDelegate TTTouchView:self userDidTouch:nil];
        }
        if ([self.touchDelegate respondsToSelector:@selector(TTTouchView:touchesBegan:withEvent:)]){
            [self.touchDelegate TTTouchView:self touchesBegan:touches withEvent:event];
        }
    }
}

@end
