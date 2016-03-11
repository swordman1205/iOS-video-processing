//
//  Constants.h
//  TikTokIOS
//
//  Created by Justin Lee on 3/19/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import <Foundation/Foundation.h>

//config
#define kEnableBetaInviteMode YES

//appMode
#define kAppMode_development 0
#define kAppMode_production 1

//isAppKilledPermanentlyKey in userDefaults
#define kIsAppKilledPermanentlyKey @"isAppKilledPermanently"

//color
#define RGBCOLOR(r,g,b)    [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

//font
#define kFontWithSize(b) [UIFont fontWithName:@"Gotham-Medium" size:(b)]
#define kFontLightWithSize(b) [UIFont fontWithName:@"Gotham-Light" size:(b)]
#define kFontMediumWithSize(b) [UIFont fontWithName:@"Gotham-Medium" size:(b)]
#define kFontBoldWithSize(b) [UIFont fontWithName:@"Gotham-Bold" size:(b)]
#define kFontBookWithSize(b) [UIFont fontWithName:@"GothamBook" size:(b)]
#define kFontNarrowBookWithSize(b) [UIFont fontWithName:@"GothamNarrow-Book" size:(b)]

#define kFontMS300WithSize(b) [UIFont fontWithName:@"MuseoSans-300" size:(b)]
#define kFontMS500WithSize(b) [UIFont fontWithName:@"MuseoSans-500" size:(b)]
#define kFontMS700WithSize(b) [UIFont fontWithName:@"MuseoSans-700" size:(b)]
#define kFontPNLightWithSize(b) [UIFont fontWithName:@"ProximaNova-Light" size:(b)]
#define kFontPNRegularWithSize(b) [UIFont fontWithName:@"ProximaNova-Regular" size:(b)]

//image
#define kAppImageOptimalLength 1080
#define kAppImageOptimalWidthPixels 1080
#define kAppAvatarWidthHeightPixels 300
#define kAppMediaHeightWidthRatio (6.0/5.0)

//distances
#define kStatusBarHeight 20
#define kNavBarHeight 44

#define kSeparatorHeight 0.5

#define kButtonHighlightedAlpha 0.4

#define kNavButtonHeight 30
#define kNavButtonMinWidth 45
#define kNavBarSpacerWidth -6
#define kNavButtonLeftRightPadding 5 //for text buttons

//avatar
#define kAppAvatarBorderThickness 0
#define kAppAvatarBorderColor [UIColor clearColor] //RGBCOLOR(220,220,220)
#define kAppAvatarDefaultColor RGBCOLOR(220,220,220)

//app colors
#define kAppPurpleColor RGBCOLOR(138,86,156)
#define kAppPurpleColorWithAlpha(a) RGBACOLOR(138,86,156, (a))
#define kAppNavBarPurpleColor kAppPurpleColor//RGBCOLOR(96, 53, 147)
#define kAppGrayTextColor RGBCOLOR(140,140,140)
#define kAppBarLightGrayColor RGBCOLOR(245,245,245)
#define kAppBarLightGrayColorWithAlpha(a) RGBACOLOR(240,240,240, (a))
#define kAppGreenColor RGBCOLOR(25,196,202)
#define kAppGreenColorWithAlpha(a) RGBACOLOR(25,196,202,(a))

#define kAppSpinnerColor RGBCOLOR(169,169,169)//RGBCOLOR(180,180,180)
#define kAppSeparatorColor RGBCOLOR(221,221,221)

//tab colors
#define kNewsFeedViewThemeColor kAppPurpleColor
#define kExploreViewThemeColor RGBCOLOR(0,199,157)
#define kPeopleViewThemeColor RGBCOLOR(255, 175, 64)
#define kMyMainUserProfileViewDefaultThemeColor RGBCOLOR(55,55,55)

//other
#define kWebURL @"http://tiktok.io" //@"http://localhost:5000" //
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

//login type
#define kLoginType_email 0
#define kLoginType_facebook 1

//post duration
#define kPostDurationDefault PostDurationOption_12hrs

//units
#define kHourToMS (60*60*1000)

//device type
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
