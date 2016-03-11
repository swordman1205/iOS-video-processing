//
//  CameraView.h
//  TikTokIOS
//
//  Created by Justin Lee on 3/29/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CameraMode.h"
@class SquareBoxesView;

#define kCameraView_topPanelHeight 50

@class CameraVideoProgressView;
@class TTTouchView;

@interface CameraView : UIView

//views
@property TTTouchView *previewView;
@property AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) UIView * previewCoverTopView;
@property (nonatomic) UIView *previewCoverBottomView;
@property (nonatomic) SquareBoxesView *squareBoxesView;

@property (nonatomic) UIVisualEffectView *topPanel;
//@property (nonatomic) UIView *deviceConfigRow;
@property (nonatomic) UIView *bottomPanel;

@property (nonatomic) UIButton *closeButton;

@property (nonatomic) UIButton *squareBoxesModeButton;
@property (nonatomic) UIButton *flipCameraButton;
@property (nonatomic) UIButton *flashModeButton;

@property (nonatomic) CameraVideoProgressView *videoProgressBar;

@property (nonatomic) UIButton *photoAlbumButton;
@property (nonatomic) UIButton *captureImageButton;
@property (nonatomic) UIButton *textPostButton;

//others
@property (nonatomic) NSNumber *isCameraAccessEnabled;
@property (nonatomic) NSNumber *hasCameraFlash;
@property (nonatomic) AVCaptureFlashMode flashMode;
@property (nonatomic) BOOL isPreviewCoverShown;
@property (nonatomic) BOOL shouldSquareBoxesBeShown;
@property (nonatomic) CameraMode cameraMode;
@property (nonatomic) UIImage *photoAlbumButtonImage;
@property (nonatomic) BOOL isRecordingVideo;

- (CGRect) previewViewVisibleAreaFrame;
- (void)setIsRecordingVideo:(BOOL)isRecordingVideo animateChanges:(BOOL)animateChanges;

@end
