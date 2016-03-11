//
//  TTCamera.h
//  TikTokIOS
//
//  Created by Justin Lee on 8/3/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TTCamera : NSObject

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureDeviceInput *videoInputDevice;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) dispatch_queue_t serialQueue;

@property (nonatomic) NSNumber *isCameraAccessEnabled;
@property (nonatomic) NSNumber *hasCameraFlash;
@property (nonatomic) AVCaptureFlashMode frontCameraFlashMode;
@property (nonatomic) AVCaptureFlashMode backCameraFlashMode;
@property (nonatomic) AVCaptureFlashMode flashMode;
@property (nonatomic) BOOL shouldLockFocus;

- (void)startVideoCapture:(void(^)(NSError *error))completionBlock;
- (void)flipCamera;
- (void)changeFlashMode;
- (void)turnTorchOn;
- (void)turnTorchOff;
- (void)focusAndExposePoint:(CGPoint)point;
- (void)captureImageWithPreviewViewVisibleAreaFrame:(CGRect)previewViewVisibleAreaFrame completionBlock:(void(^)(NSError *error, UIImage *capturedImage))completionBlock;
- (AVCaptureConnection *)getStillImageOutputVideoConnection;

+ (instancetype)sharedInstance;

@end
