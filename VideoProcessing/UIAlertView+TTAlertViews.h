//
//  UIAlertView+TTAlertViews.h
//  TikTokIOS
//
//  Created by Justin Lee on 5/23/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIAlertView(TTAlertViews)

+ (instancetype) photoAccessDeniedAlert;
+ (instancetype) cameraAccessDeniedAlert;
+ (instancetype) editProfileUnsavedChangesAlert;

@end
