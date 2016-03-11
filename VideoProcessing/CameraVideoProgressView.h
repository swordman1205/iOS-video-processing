//
//  CameraVideoProgressView.h
//  TikTokIOS
//
//  Created by Justin Lee on 8/4/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraVideoProgressView : UIView

//views
@property (nonatomic) UIView *minValueBar;
@property (nonatomic) UIView *curValueBar;
//others
@property (nonatomic) float minValue; //between 0 and 1
@property (nonatomic) float curValue; //between 0 and 1

@end
