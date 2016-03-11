//
//  TTTouchView.h
//  TikTokIOS
//
//  Created by Justin Lee on 6/11/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TTTouchView;

@protocol TTTouchViewDelegate <NSObject>
@optional
- (void) TTTouchView:(TTTouchView *)TTTouchView userDidTouch:(UIView *)view;
- (void) TTTouchView:(TTTouchView *)TTTouchView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@interface TTTouchView : UIView

@property (nonatomic, weak) NSObject <TTTouchViewDelegate> *touchDelegate;

@end
