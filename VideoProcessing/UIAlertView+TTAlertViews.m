//
//  UIAlertView+TTAlertViews.m
//  TikTokIOS
//
//  Created by Justin Lee on 5/23/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import "UIAlertView+TTAlertViews.h"

@implementation UIAlertView(TTAlertViews)

+ (instancetype) photoAccessDeniedAlert
{
    return [[self alloc] initWithTitle:@"Photo Access Denied"
                               message:@"This app requires access to your photos.\n\nPlease enable Photo access for this app in Settings / Privacy / Photos"
                              delegate:nil
                     cancelButtonTitle:@"Dismiss"
                     otherButtonTitles:nil];
}

+ (instancetype) cameraAccessDeniedAlert
{
    return [[self alloc] initWithTitle:@"Camera Access Denied"
                               message:@"This app requires access to your camera.\n\nPlease enable Camera access for this app in Settings / Privacy / Camera"
                              delegate:nil
                     cancelButtonTitle:@"Dismiss"
                     otherButtonTitles:nil];
}

+ (instancetype) editProfileUnsavedChangesAlert
{
    return [[self alloc] initWithTitle:@"Unsaved Changes"
                               message:@"You have unsaved changes. Are you sure you want to cancel?"
                              delegate:nil
                     cancelButtonTitle:@"NO"
                     otherButtonTitles:@"YES",nil];
}

@end
