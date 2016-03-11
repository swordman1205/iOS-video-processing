//
//  CameraView.m
//  TikTokIOS
//
//  Created by Justin Lee on 3/29/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import "CameraView.h"
#import "TTTouchView.h"
#import "CameraVideoProgressView.h"
#import "UIImage+TTImage.h"
#import "SquareBoxesView.h"

//distances
#define kPrivate_paddingLeftRight 10

#define kPrivate_topButtonWidth 50
#define kPrivate_topButtonHeight 30

#define kPrivate_topPanelHeight kCameraView_topPanelHeight
#define kPrivate_previewViewMaxWidth 450 //iphone6s width?

#define kPrivate_squareBoxLinesThickness 1

#define kPrivate_deviceConfigRowHeight 64
#define kPrivate_deviceConfigButtonsWidth 44
#define kPrivate_deviceConfigButtonsHeight 44

#define kPrivate_videoProgressBarHeight 5

#define kPrivate_captureImageButtonWidthLarge 72
#define kPrivate_captureImageButtonWidthSmall 45

#define kPrivate_captureImageButtonBgViewLargeCircleWidth 95
#define kPrivate_captureImageButtonBgViewSmallCircleWidth 57

#define kPrivate_photoAlbumButtonWidthHeightLarge 50
#define kPrivate_photoAlbumButtonWidthHeightSmall 45

#define kPrivate_textPostButtonWidthHeightLarge 50
#define kPrivate_textPostButtonWidthHeightSmall 45

//others
#define kPrivate_topPanelBgColor RGBACOLOR(255,255,255,0.8)
#define kPrivate_previewCoverViewBgColor RGBCOLOR(74,74,74)
#define kPrivate_squareBoxLinesBgColor RGBCOLOR(155,155,155)
#define kPrivate_deviceConfigRowBgColor RGBACOLOR(255,255,255,0.8)
#define kPrivate_bottomPanelBgColor RGBCOLOR(166,163,198)
#define kPrivate_captureImageButtonBgColor kAppPurpleColor
#define kPrivate_previewCoverAnimationTimeSecs 0.3
#define kPrivate_flashModeButtonFlashOnImageName @"btn_viewfinder_flash_on"
#define kPrivate_flashModeButtonFlashOffImageName @"btn_viewfinder_flash_off"
#define kPrivate_photoAlbumButtonDefaultImage @"photo_album_icon"
#define kPrivate_textPostButtonDefaultImage @"text_post_icon"

@implementation CameraView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = RGBCOLOR(216, 216, 216);
        
        self.previewView = [[TTTouchView alloc] init];
        self.previewView.clipsToBounds = YES;
        self.previewView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.previewView];
        
        self.squareBoxesView = [[SquareBoxesView alloc] init];
        self.squareBoxesView.lineColor = kPrivate_squareBoxLinesBgColor;
        [self.previewView addSubview:self.squareBoxesView];
        
        self.previewCoverTopView = [[UIView alloc] init];
        self.previewCoverTopView.backgroundColor = kPrivate_previewCoverViewBgColor;
        [self.previewView addSubview:self.previewCoverTopView];
        
        self.previewCoverBottomView = [[UIView alloc] init];
        self.previewCoverBottomView.backgroundColor = kPrivate_previewCoverViewBgColor;
        [self.previewView addSubview:self.previewCoverBottomView];
        
        UIBlurEffect *topPanelBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.topPanel = [[UIVisualEffectView alloc] initWithEffect:topPanelBlurEffect];
        [self addSubview:self.topPanel];
        
//        self.deviceConfigRow = [[UIView alloc] init];
//        self.deviceConfigRow.backgroundColor = kPrivate_deviceConfigRowBgColor;
//        [self addSubview:self.deviceConfigRow];
        
        UIBlurEffect *bottomPanelBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.bottomPanel = [[UIVisualEffectView alloc] initWithEffect:bottomPanelBlurEffect];
        [self addSubview:self.bottomPanel];
        
        self.closeButton = [[UIButton alloc] init];
        UIImage *closeButtonImage = [[UIImage imageNamed:@"close_icon_purple"] maskWithColor:RGBCOLOR(255, 255, 255)];
        [self.closeButton setImage:closeButtonImage forState:UIControlStateNormal];
        float closeButtonImageInsetX = kPrivate_topButtonWidth/2.0 - closeButtonImage.size.width/2.0;
        self.closeButton.imageEdgeInsets = UIEdgeInsetsMake(0,
                                                           -1 *closeButtonImageInsetX,
                                                           0,
                                                           closeButtonImageInsetX);
        [self.topPanel addSubview:self.closeButton];
        
        self.squareBoxesModeButton = [[UIButton alloc] init];
        UIImage *squareBoxesModeButtonImage = [UIImage imageNamed:@"btn_viewfinder_grid"];
        [self.squareBoxesModeButton setImage:squareBoxesModeButtonImage forState:UIControlStateNormal];
        [self.previewView addSubview:self.squareBoxesModeButton];
        
        self.flashModeButton = [[UIButton alloc] init];
        [self.previewView addSubview:self.flashModeButton];
        
        self.flipCameraButton = [[UIButton alloc] init];
        UIImage *flipCameraButtonImage = [UIImage imageNamed:@"btn_viewfinder_flip"];
        [self.flipCameraButton setImage:flipCameraButtonImage forState:UIControlStateNormal];
        [self.previewView addSubview:self.flipCameraButton];
        
        self.videoProgressBar = [[CameraVideoProgressView alloc] init];
        [self.bottomPanel addSubview:self.videoProgressBar];
        
        self.photoAlbumButton = [[UIButton alloc] init];
        self.photoAlbumButton.clipsToBounds = YES;
        self.photoAlbumButton.layer.cornerRadius = 3;
        [self.bottomPanel addSubview:self.photoAlbumButton];
        
        self.captureImageButton = [[UIButton alloc] init];
        self.captureImageButton.clipsToBounds = YES;
        UIImage *captureImageButtonImage = [UIImage imageNamed:@"btn_viewfinder_shutter"];
        self.captureImageButton.layer.cornerRadius = kPrivate_captureImageButtonWidthLarge/2.0;
        [self.captureImageButton setImage:captureImageButtonImage forState:UIControlStateNormal];
        [self.bottomPanel addSubview:self.captureImageButton];
        
        self.textPostButton = [[UIButton alloc] init];
        self.textPostButton.clipsToBounds = YES;
        self.textPostButton.layer.cornerRadius = 3;
        [self.textPostButton setBackgroundImage:[UIImage imageNamed:kPrivate_textPostButtonDefaultImage] forState:UIControlStateNormal];
//        [self.bottomPanel addSubview:self.textPostButton];
        
        _isCameraAccessEnabled = nil;
        _hasCameraFlash = nil;
        _flashMode = AVCaptureFlashModeAuto;
        _isPreviewCoverShown = YES;
        _shouldSquareBoxesBeShown = NO;
        _cameraMode = CameraMode_photo;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize parentSize = self.bounds.size;
    
    //previewView
    self.previewView.frame = [self previewViewFrame];
    
    //previewLayer
    self.previewLayer.frame = self.previewView.bounds;
    
    //previewCoverTopView
    self.previewCoverTopView.frame = [self previewCoverTopViewFrame];
    
    //previewCoverBottomView
    self.previewCoverBottomView.frame = [self previewCoverBottomViewFrame];
    
    //square box lines
    if (self.shouldSquareBoxesBeShown){
        [self setSquareBoxLinesFrames];
    }
    
    //top panel
    self.topPanel.frame = CGRectMake(0,
                                     0,
                                     parentSize.width,
                                     kPrivate_topPanelHeight);
    
//    //deviceConfigRow
//    CGRect previewViewVisibleAreaFrame = [self previewViewVisibleAreaFrame];
//    float deviceConfigRowTop = previewViewVisibleAreaFrame.origin.y + previewViewVisibleAreaFrame.size.height;
//    self.deviceConfigRow.frame = CGRectMake(0,
//                                            deviceConfigRowTop,
//                                            parentSize.width,
//                                            kPrivate_deviceConfigRowHeight);

    CGRect previewViewVisibleAreaFrame = [self previewViewVisibleAreaFrame];
    float previewViewVisibleAreaBottom = self.previewView.top + (previewViewVisibleAreaFrame.origin.y + previewViewVisibleAreaFrame.size.height);
    //bottom panel
    float bottomPanelTop = previewViewVisibleAreaBottom;
    float bottomPanelHeight = parentSize.height - bottomPanelTop;
    self.bottomPanel.frame = CGRectMake(0,
                                        bottomPanelTop,
                                        parentSize.width,
                                        bottomPanelHeight);
    
    //closeButton
    //CGSize closeButtonImageSize = [self.closeButton imageForState:UIControlStateNormal].size;
    float closeButtonTop = kPrivate_topPanelHeight/2.0 - kPrivate_topButtonHeight/2.0; //kPrivate_topButtonImageTop + closeButtonImageSize.height/2.0 - kPrivate_topButtonHeight/2.0;
    self.closeButton.frame = CGRectMake(kPrivate_paddingLeftRight,
                                       closeButtonTop,
                                       kPrivate_topButtonWidth,
                                       kPrivate_topButtonHeight);
    
    //deviceConfigRow
    float deviceConfigRowCenterY = previewViewVisibleAreaBottom - kPrivate_deviceConfigRowHeight/2.0;
    float deviceConfigRowGapBetweenButtons = (self.previewView.width - (3*kPrivate_deviceConfigButtonsWidth))/4.0;
    float deviceConfigRowButtonTop = deviceConfigRowCenterY - kPrivate_deviceConfigButtonsHeight/2.0;
    
    //squareBoxesModeButton
    float squareBoxesModeButtonLeft = deviceConfigRowGapBetweenButtons;
    self.squareBoxesModeButton.frame = CGRectMake(squareBoxesModeButtonLeft,
                                                  deviceConfigRowButtonTop,
                                                  kPrivate_deviceConfigButtonsWidth,
                                                  kPrivate_deviceConfigButtonsHeight);
    
    //flipCameraButton
    float flipCameraButtonLeft = self.squareBoxesModeButton.right + deviceConfigRowGapBetweenButtons;
    self.flipCameraButton.frame = CGRectMake(flipCameraButtonLeft,
                                             deviceConfigRowButtonTop,
                                             kPrivate_deviceConfigButtonsWidth,
                                             kPrivate_deviceConfigButtonsHeight);
    
    //flashModeButton
    float flashModeButtonLeft = self.flipCameraButton.right + deviceConfigRowGapBetweenButtons;
    self.flashModeButton.frame = CGRectMake(flashModeButtonLeft,
                                            deviceConfigRowButtonTop,
                                            kPrivate_deviceConfigButtonsWidth,
                                            kPrivate_deviceConfigButtonsHeight);

    if (!self.videoProgressBar.hidden){
        self.videoProgressBar.frame = [self videoProgressBarFrame];
        [self.videoProgressBar setNeedsLayout];
    }
    
    float bottomPanelBottomPartCenterY = self.bottomPanel.height/2.0;
    
    //captureImageButton
    CGSize captureImageButtonImageSize = [self.captureImageButton imageForState:UIControlStateNormal].size;
    float captureImageButtonTop = bottomPanelBottomPartCenterY - captureImageButtonImageSize.height/2.0;
    float captureImageButtonLeft = self.bottomPanel.width/2.0 - captureImageButtonImageSize.width/2.0;
    self.captureImageButton.frame = CGRectMake(captureImageButtonLeft,
                                               captureImageButtonTop,
                                               captureImageButtonImageSize.width,
                                               captureImageButtonImageSize.height);
    
    //photoAlbumButton
    self.photoAlbumButton.frame = [self photoAlbumButtonFrame];
    
    //textPostButton
    self.textPostButton.frame = [self textPostButtonFrame];
}

#pragma mark - override setters

- (void)setIsPreviewCoverShown:(BOOL)isPreviewCoverShown {
    NSLog(@"isPreviewCoverShown: %i",isPreviewCoverShown);
    BOOL oldIsPreviewCoverShown = _isPreviewCoverShown;
    _isPreviewCoverShown = isPreviewCoverShown;
    
    if (isPreviewCoverShown && !oldIsPreviewCoverShown){
        //closing the eyes
        [UIView animateWithDuration:kPrivate_previewCoverAnimationTimeSecs animations:^{
            self.previewCoverTopView.frame = [self previewCoverTopViewFrame];
            self.previewCoverBottomView.frame = [self previewCoverBottomViewFrame];
        }completion:^(BOOL finished){
            if (finished){
            }
        }];
    }
    else if (!isPreviewCoverShown && oldIsPreviewCoverShown){
        //opening the eyes
        [UIView animateWithDuration:kPrivate_previewCoverAnimationTimeSecs animations:^{
            self.previewCoverTopView.frame = [self previewCoverTopViewFrame];
            self.previewCoverBottomView.frame = [self previewCoverBottomViewFrame];
        }completion:^(BOOL finished){
            if (finished){
            }
        }];
    }
}

- (void)setIsCameraAccessEnabled:(NSNumber *)isCameraAccessEnabled {
    _isCameraAccessEnabled = isCameraAccessEnabled;
    [self refreshSquareBoxesModeButtonUI];
    [self refreshFlipCameraButtonUI];
    [self refreshFlashModeButtonUI];
}

- (void)setHasCameraFlash:(NSNumber *)hasCameraFlash {
    _hasCameraFlash = hasCameraFlash;
    [self refreshFlashModeButtonUI];
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    _flashMode =flashMode;
    [self refreshFlashModeButtonUI];
}

- (void)setShouldSquareBoxesBeShown:(BOOL)shouldSquareBoxesBeShown {
    _shouldSquareBoxesBeShown = shouldSquareBoxesBeShown;
    if (shouldSquareBoxesBeShown){
        self.squareBoxesView.hidden = NO;
    } else {
        self.squareBoxesView.hidden = YES;
    }
    [self setSquareBoxLinesFrames];
}

- (void)setCameraMode:(CameraMode)cameraMode {
    CameraMode oldCameraMode = _cameraMode;
    _cameraMode = cameraMode;
    if (cameraMode == CameraMode_photo){
        if (oldCameraMode == CameraMode_video){
            self.videoProgressBar.curValue = 0;
        }
        self.videoProgressBar.hidden =YES;
    }
    else if (cameraMode == CameraMode_video){
        self.videoProgressBar.hidden = NO;
        self.videoProgressBar.frame = [self videoProgressBarFrame];
        if (oldCameraMode != CameraMode_video){
            self.videoProgressBar.curValue = 0;
        }
        [self.videoProgressBar setNeedsLayout];
    }
}

- (void)setPhotoAlbumButtonImage:(UIImage *)photoAlbumButtonImage {
    _photoAlbumButtonImage = photoAlbumButtonImage;
    UIImage *finalImage;
    if (photoAlbumButtonImage == nil){
        //use default
        finalImage = [UIImage imageNamed:kPrivate_photoAlbumButtonDefaultImage];
    } else {
        finalImage = photoAlbumButtonImage;
    }
    [self.photoAlbumButton setBackgroundImage:finalImage forState:UIControlStateNormal];
}

- (void)setIsRecordingVideo:(BOOL)isRecordingVideo {
    _isRecordingVideo = isRecordingVideo;
    [self setIsRecordingVideo:isRecordingVideo animateChanges:NO];
}

- (void)setIsRecordingVideo:(BOOL)isRecordingVideo animateChanges:(BOOL)animateChanges {
    _isRecordingVideo = isRecordingVideo;
    float alpha = (isRecordingVideo) ? 0 : 1;
    if (animateChanges){
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveLinear animations:^{
                                self.closeButton.alpha = alpha;
                                self.squareBoxesModeButton.alpha = alpha;
                                self.flipCameraButton.alpha = alpha;
                                self.flashModeButton.alpha = alpha;
                                self.photoAlbumButton.alpha = alpha;
                            }completion:nil];
    } else {
        self.closeButton.alpha = alpha;
        self.squareBoxesModeButton.alpha = alpha;
        self.flipCameraButton.alpha = alpha;
        self.flashModeButton.alpha = alpha;
        self.photoAlbumButton.alpha = alpha;
    }
}

#pragma mark - refresh UI elements

- (void) refreshSquareBoxesModeButtonUI {
    if (self.isCameraAccessEnabled == nil){
        self.squareBoxesModeButton.enabled = YES;
    } else {
        BOOL isCameraAccessEnabledBool = [self.isCameraAccessEnabled boolValue];
        if (isCameraAccessEnabledBool){
            self.squareBoxesModeButton.enabled = YES;
        } else {
            self.squareBoxesModeButton.enabled = NO;
        }
    }
}

- (void) refreshFlipCameraButtonUI {
    if (self.isCameraAccessEnabled == nil){
        self.flipCameraButton.enabled = YES;
    } else {
        BOOL isCameraAccessEnabledBool = [self.isCameraAccessEnabled boolValue];
        if (isCameraAccessEnabledBool){
            self.flipCameraButton.enabled = YES;
        } else {
            self.flipCameraButton.enabled = NO;
        }
    }
}

- (void) refreshFlashModeButtonUI {
    NSString *buttonImageName = nil;
    if (self.isCameraAccessEnabled == nil){
        self.flashModeButton.enabled = YES;
        buttonImageName = kPrivate_flashModeButtonFlashOffImageName;
    } else {
        BOOL isCameraAccessEnabledBool = [self.isCameraAccessEnabled boolValue];
        if (isCameraAccessEnabledBool){
            if (self.hasCameraFlash == nil){
                self.flashModeButton.enabled = YES;
                buttonImageName = kPrivate_flashModeButtonFlashOffImageName;
            }else {
                BOOL hasCameraFlashBool = [self.hasCameraFlash boolValue];
                if (hasCameraFlashBool){
                    self.flashModeButton.enabled = YES;
                    if (self.flashMode == AVCaptureFlashModeOff){
                        buttonImageName = kPrivate_flashModeButtonFlashOffImageName;
                    }
                    else if (self.flashMode == AVCaptureFlashModeOn){
                        buttonImageName = kPrivate_flashModeButtonFlashOnImageName;
                    }
                } else {
                    self.flashModeButton.enabled = NO;
                    buttonImageName = kPrivate_flashModeButtonFlashOffImageName;
                }
            }
        } else {
            self.flashModeButton.enabled = NO;
            buttonImageName = kPrivate_flashModeButtonFlashOffImageName;
        }
    }
    
    UIImage *buttonImage = [UIImage imageNamed:buttonImageName];
    [self.flashModeButton setImage:buttonImage forState:UIControlStateNormal];
}


#pragma mark - get frame of UI elements

- (CGRect) previewViewFrame {
    CGSize parentSize = self.bounds.size;
//    float previewViewTop = 0;
  
    CGRect finalFrame = CGRectMake(0,
                                   0,
                                   parentSize.width,
                                   parentSize.height);
    
//    CGRect previewViewVisibleAreaFrame = [self previewViewVisibleAreaFrame];
//
//    float previewViewVisibleAreaWidthHeight = [self previewViewVisibleAreaWidthHeight];
//    float previewViewLeft = parentSize.width/2.0 - previewViewVisibleAreaWidthHeight/2.0;
//    float previewViewHeight = kPrivate_topPanelHeight + previewViewVisibleAreaWidthHeight + kPrivate_deviceConfigRowHeight;
//    CGRect finalFrame = CGRectMake(previewViewLeft,
//                                   previewViewTop,
//                                   previewViewVisibleAreaWidthHeight,
//                                   previewViewHeight);
    return finalFrame;
}

//beware its dependent on frame of previewView
- (CGRect) previewCoverTopViewFrame {
    CGSize parentSize = self.bounds.size;
    
    float previewCoverPartViewHeight = self.previewView.height/2.0;
    float previewCoverTopViewTop = 0;
    if (!self.isPreviewCoverShown){
        previewCoverTopViewTop = -1 * previewCoverPartViewHeight;
    }
    CGRect frame = CGRectMake(0,
                              previewCoverTopViewTop,
                              parentSize.width,
                              previewCoverPartViewHeight);
    NSLog(@"previewCoverTopView frame:@%f, %f, %f, %f",frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    return frame;
}

//beware its dependent on frame of previewView
- (CGRect) previewCoverBottomViewFrame {
    CGSize parentSize = self.bounds.size;
    
    float previewCoverPartViewHeight = self.previewView.height/2.0;
    float previewCoverBottomViewTop = self.previewView.height - previewCoverPartViewHeight;
    if (!self.isPreviewCoverShown){
        previewCoverBottomViewTop = self.previewView.height;
    }
    CGRect frame = CGRectMake(0,
                              previewCoverBottomViewTop,
                              parentSize.width,
                              previewCoverPartViewHeight);
    NSLog(@"previewCoverBottomView frame: %f, %f, %f, %f",frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    return frame;
}

- (CGRect) previewViewVisibleAreaFrame {
    CGSize parentSize = self.bounds.size;
    float top = kPrivate_topPanelHeight;
    float width = parentSize.width;
    float height = width *kAppMediaHeightWidthRatio;
    float left = parentSize.width/2.0 - width/2.0;
    CGRect finalFrame = CGRectMake(left,
                                   top,
                                   width,
                                   height);
    return finalFrame;
}

//- (float) previewViewVisibleAreaWidthHeight {
//    CGSize parentSize = self.bounds.size;
//    float previewViewWidthHeight = (parentSize.width > kPrivate_previewViewMaxWidth) ? kPrivate_previewViewMaxWidth : parentSize.width;
//    return previewViewWidthHeight;
//}

- (void) setSquareBoxLinesFrames {
    CGRect previewViewVisibleAreaFrame = [self previewViewVisibleAreaFrame];
    self.squareBoxesView.frame = previewViewVisibleAreaFrame;
    [self.squareBoxesView setNeedsLayout];
}

- (CGRect)videoProgressBarFrame {
    float videoProgressBarTop = 0;
    float videoProgressBarLeft = 0;
    float videoProgressBarWidth = self.previewView.width;
    CGRect finalFrame = CGRectMake(videoProgressBarLeft,
                                   videoProgressBarTop,
                                   videoProgressBarWidth,
                                   kPrivate_videoProgressBarHeight);
    return finalFrame;
}

- (CGRect)photoAlbumButtonFrame {
    float photoAlbumButtonWidthHeight;
    if (IS_IPHONE_4_OR_LESS){
        photoAlbumButtonWidthHeight = kPrivate_photoAlbumButtonWidthHeightSmall;
    } else {
        photoAlbumButtonWidthHeight = kPrivate_photoAlbumButtonWidthHeightLarge;
    }
    CGSize photoAlbumButtonSize = CGSizeMake(photoAlbumButtonWidthHeight, photoAlbumButtonWidthHeight);
    float photoAlbumButtonCenterX = self.captureImageButton.left/2.0;
    float photoAlbumButtonWidth = photoAlbumButtonSize.width;
    float photoAlbumButtonLeft = photoAlbumButtonCenterX - photoAlbumButtonWidth/2.0;
    float photoAlbumButtonHeight = photoAlbumButtonSize.height;
    float bottomPanelBottomPartCenterY = self.bottomPanel.height/2.0;
    float photoAlbumButtonTop = bottomPanelBottomPartCenterY - photoAlbumButtonHeight/2.0;
    CGRect finalFrame = CGRectMake(photoAlbumButtonLeft,
                                   photoAlbumButtonTop,
                                   photoAlbumButtonWidth,
                                   photoAlbumButtonHeight);
    return finalFrame;
}

- (CGRect)textPostButtonFrame {
    float textPostButtonWidthHeight;
    if (IS_IPHONE_4_OR_LESS){
        textPostButtonWidthHeight = kPrivate_textPostButtonWidthHeightSmall;
    } else {
        textPostButtonWidthHeight = kPrivate_textPostButtonWidthHeightLarge;
    }
    CGSize textPostButtonSize = CGSizeMake(textPostButtonWidthHeight, textPostButtonWidthHeight);
    float textPostButtonCenterX = self.captureImageButton.right + (self.bottomPanel.width - self.captureImageButton.right)/2.0;
    float textPostButtonWidth = textPostButtonSize.width;
    float textPostButtonLeft = textPostButtonCenterX - textPostButtonWidth/2.0;
    float textPostButtonHeight = textPostButtonSize.height;
    float bottomPanelBottomPartCenterY = self.bottomPanel.height/2.0;
    float textPostButtonTop = bottomPanelBottomPartCenterY - textPostButtonHeight/2.0;
    CGRect finalFrame = CGRectMake(textPostButtonLeft,
                                   textPostButtonTop,
                                   textPostButtonWidth,
                                   textPostButtonHeight);
    return finalFrame;
}

@end
