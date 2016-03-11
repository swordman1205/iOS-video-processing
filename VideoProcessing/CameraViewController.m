//
//  CameraViewController.m
//  TikTokIOS
//
//  Created by Justin Lee on 3/29/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

//vcs
#import "CameraViewController.h"
#import "CameraImagePickerController.h"
#import "VideoTestViewController.h"
#import "AppDelegate.h"
//views
#import "CameraView.h"
#import "TTTouchView.h"
#import "CameraVideoProgressView.h"
//controllers
#import "TTCamera.h"
#import "VideoController.h"
#import "TTInfoBannerController.h"
//others
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIAlertView+TTAlertViews.h"
#import "UIImage+TTImage.h"
#import "CameraMode.h"
#import <AVFoundation/AVFoundation.h>
#import "ALAssetsLibrary+TT.h"

#define kPrivate_flashMode_default AVCaptureFlashModeOff
#define kPrivate_squareBoxesMode_isOnInitially NO
#define kPrivate_minVideoTimeSecs 2.0
#define kPrivate_maxVideoTimeSecs 12.0

static void *captureSessionRunningContext = &captureSessionRunningContext;

@interface CameraViewController () <TTTouchViewDelegate, AVCaptureFileOutputRecordingDelegate>

@property (nonatomic) TTInfoBannerController *infoBannerController;
@property (nonatomic) TTCamera *camera;
@property (nonatomic) CameraMode cameraMode;
@property (nonatomic) NSTimer *captureButtonTimer;
@property (nonatomic) NSTimer *videoProgressUITimer;
@property (nonatomic) AVAssetExportSession *cropVidExporter;
@property (nonatomic) NSNumber *isCameraAccessEnabled;
@property (nonatomic) NSNumber *hasCameraFlash;
@property (nonatomic) AVCaptureFlashMode flashMode;
@property (nonatomic) BOOL isSquareBoxesModeOn;
@property (nonatomic) BOOL isCapturingImage;
@property (nonatomic) BOOL isRecordingVideo;
@property (nonatomic) BOOL hasCaptureButtonDetectedEvent;

@end

@implementation CameraViewController

#pragma mark - UIViewController

- (void) commonInit {
    _infoBannerController = [[TTInfoBannerController alloc] init];
    _camera = [[TTCamera alloc] init];
    _cameraMode = CameraMode_photo;
    _captureButtonTimer = nil;
    _videoProgressUITimer = nil;
    _cropVidExporter = nil;
    _isCameraAccessEnabled = nil;
    _hasCameraFlash = nil;
    _flashMode = kPrivate_flashMode_default;
    _isCapturingImage = NO;
    _isRecordingVideo = NO;
    _isSquareBoxesModeOn = kPrivate_squareBoxesMode_isOnInitially;
    _hasCaptureButtonDetectedEvent = NO;
}

- (instancetype)init {
    self = [super init];
    if (self){
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"camera.captureSession.running" context:captureSessionRunningContext];
    [self removeObserver:self forKeyPath:@"camera.flashMode" context:nil];
    [self removeObserver:self forKeyPath:@"camera.hasCameraFlash" context:nil];
    [self removeObserver:self forKeyPath:@"camera.isCameraAccessEnabled" context:nil];
    [self.camera.captureSession stopRunning];
}

- (void)loadView {
    [super loadView];
    
    self.cameraView = [[CameraView alloc] init];
    [self.cameraView.closeButton addTarget:self action:@selector(navBarLeftButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraView.squareBoxesModeButton addTarget:self action:@selector(squareBoxesModeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraView.flipCameraButton addTarget:self action:@selector(flipCameraButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraView.flashModeButton addTarget:self action:@selector(flashModeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraView.photoAlbumButton addTarget:self action:@selector(photoAlbumButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraView.captureImageButton addTarget:self action:@selector(captureImageButtonDidTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.cameraView.captureImageButton addTarget:self action:@selector(captureImageButtonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraView.captureImageButton addTarget:self action:@selector(captureImageButtonDidTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
//    [self.cameraView.textPostButton addTarget:self action:@selector(textPostButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.cameraView.previewView.touchDelegate = self;
    self.view = self.cameraView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"camera";
    
    //must add observers first
    [self addObserversAndNotifications];

    self.infoBannerController.displayView = self.cameraView;
    self.infoBannerController.mainContentView = self.cameraView;
    self.infoBannerController.mainContentViewInsetTop = kCameraView_topPanelHeight;
    
    self.cameraView.textPostButton.hidden = YES;
    
    self.cameraMode = CameraMode_photo;
    self.isCameraAccessEnabled = nil;
    self.hasCameraFlash = nil;
    self.flashMode = kPrivate_flashMode_default;
    self.cameraView.isPreviewCoverShown = YES;
    self.isSquareBoxesModeOn = kPrivate_squareBoxesMode_isOnInitially;
    self.cameraView.photoAlbumButtonImage = nil;
    
    self.cameraView.videoProgressBar.minValue = (kPrivate_minVideoTimeSecs * 1.0 / kPrivate_maxVideoTimeSecs);
    self.cameraView.videoProgressBar.curValue = 0;

    [self getThumbnailOfLatestPhotoInAlbum];
    
    [self.camera startVideoCapture:^(NSError *error){
        if (error != nil) return;
        //add video preview layer
        NSLog(@"Adding video preview layer");
        
        AVCaptureVideoPreviewLayer *previewLayer = self.camera.videoPreviewLayer;
        if (previewLayer != nil){
            //first clear old preview layer
            self.camera.movieFileOutput.maxRecordedDuration = CMTimeMakeWithSeconds(kPrivate_maxVideoTimeSecs, 50);
            if (self.cameraView.previewLayer != nil){
                [self.cameraView.previewLayer removeFromSuperlayer];
                self.cameraView.previewLayer = nil;
            }
            self.cameraView.previewLayer = self.camera.videoPreviewLayer;
            [[self.cameraView.previewView layer] insertSublayer:self.camera.videoPreviewLayer atIndex:0];
            [self.cameraView setNeedsLayout];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL curIsNavigationBarHidden = self.navigationController.isNavigationBarHidden;
    BOOL shouldNavigationBarBeHidden = YES;
    if (shouldNavigationBarBeHidden != curIsNavigationBarHidden){
        [self.navigationController setNavigationBarHidden:shouldNavigationBarBeHidden animated:animated];
    }
    
    if (self.camera.captureSession != nil){
        dispatch_async(self.camera.serialQueue, ^{
            if (self.camera.captureSession.running) return;
            NSLog(@"viewWillAppear...capture session: start running");
            [self.camera.captureSession startRunning];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.camera.captureSession != nil){
        dispatch_async(self.camera.serialQueue, ^{
            if (!self.camera.captureSession.running) return;
            NSLog(@"viewDidDisappear...capture session: stop running");
            [self.camera.captureSession stopRunning];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - nav bar button click handler

- (void) navBarLeftButtonDidClick:(UIButton *)button {
//    [self.navigationController.presentingViewController dismissViewControllerAnimated:self.createMediaInfo.shouldAnimateEnd completion:nil];
}

#pragma mark - add notifications

- (void) addObserversAndNotifications {
    //camera
    [self addObserver:self forKeyPath:@"camera.captureSession.running" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:captureSessionRunningContext];
    [self addObserver:self forKeyPath:@"camera.flashMode" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
    [self addObserver:self forKeyPath:@"camera.hasCameraFlash" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
    [self addObserver:self forKeyPath:@"camera.isCameraAccessEnabled" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionDidRunIntoError:) name:AVCaptureSessionRuntimeErrorNotification
                                               object:nil];
}

#pragma mark - override setters

- (void)setCameraMode:(CameraMode)cameraMode {
    _cameraMode = cameraMode;
    self.cameraView.cameraMode = cameraMode;
}

- (void)setIsCameraAccessEnabled:(NSNumber *)isCameraAccessEnabled {
    _isCameraAccessEnabled = isCameraAccessEnabled;
    self.cameraView.isCameraAccessEnabled = isCameraAccessEnabled;
}

- (void)setIsSquareBoxesModeOn:(BOOL)isSquareBoxesModeOn {
    _isSquareBoxesModeOn = isSquareBoxesModeOn;
    self.cameraView.shouldSquareBoxesBeShown = isSquareBoxesModeOn;
}

- (void)setHasCameraFlash:(NSNumber *)hasCameraFlash {
    _hasCameraFlash = hasCameraFlash;
    self.cameraView.hasCameraFlash = hasCameraFlash;
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    _flashMode = flashMode;
    self.cameraView.flashMode = flashMode;
}

- (void)setIsRecordingVideo:(BOOL)isRecordingVideo {
    BOOL oldIsRecordingVideo = _isRecordingVideo;
    _isRecordingVideo = isRecordingVideo;
    if (!isRecordingVideo){
        self.camera.shouldLockFocus = NO;
        if (oldIsRecordingVideo){
            //UI chnages
            [self.cameraView setIsRecordingVideo:NO animateChanges:YES];
        }
    }
}

#pragma mark - squareBoxesButton click handler

- (void)squareBoxesModeButtonDidClick:(id)sender {
    BOOL newIsSquareBoxesModeOn = !self.isSquareBoxesModeOn;
    self.isSquareBoxesModeOn = newIsSquareBoxesModeOn;
}

#pragma mark - flipCameraButton click handler

- (void)flipCameraButtonDidPress:(id)sender
{
    if (self.isRecordingVideo) return;
    //Only do if device has multiple cameras
    [self.camera flipCamera];
}

#pragma mark - flashModeButton click handler

- (void) flashModeButtonDidClick:(UIButton *)button {
    if (self.isRecordingVideo) return;
    [self.camera changeFlashMode];
}

#pragma mark - photoGalleryButton click handler

- (void) photoAlbumButtonDidClick:(UIButton *)button {
    if (self.isCapturingImage) return;
    if (self.isRecordingVideo) return;
    //choose from library
    [self goToPhotoPicker];
}

#pragma mark - textModeButton click handler

- (void)textPostButtonDidClick:(UIButton *)button {
    if (self.isCapturingImage) return;
    if (self.isRecordingVideo) return;
    //go to CPShare page
    [self goToNextPageWithImage:nil videoURL:nil];
}

#pragma mark - captureButton click handler

- (void)captureImageButtonDidTouchDown:(UIButton *)button {
    [self.captureButtonTimer invalidate];
    [self.videoProgressUITimer invalidate];
    self.hasCaptureButtonDetectedEvent = NO;
    self.captureButtonTimer = [NSTimer scheduledTimerWithTimeInterval:0.4
                                                               target:self
                                                             selector:@selector(captureButtonTimerDidHit:)
                                                             userInfo:nil
                                                              repeats:NO];
}

- (void)captureImageButtonDidTouchUpOutside:(UIButton *)button {
    NSLog(@"touchup outside");
    if (self.hasCaptureButtonDetectedEvent) return;
    self.hasCaptureButtonDetectedEvent = YES;
    [self.captureButtonTimer invalidate];
    self.captureButtonTimer = nil;
    [self.videoProgressUITimer invalidate];
    self.videoProgressUITimer = nil;

    if (self.cameraMode == CameraMode_video){
        NSLog(@"captured video");
        [self stopRecordingVideo];
    }
}

- (void)captureImageButtonDidTouchUpInside:(UIButton *)button {
    NSLog(@"touchup inside");
    if (self.hasCaptureButtonDetectedEvent) return;
    self.hasCaptureButtonDetectedEvent = YES;
    [self.captureButtonTimer invalidate];
    self.captureButtonTimer = nil;
    [self.videoProgressUITimer invalidate];
    self.videoProgressUITimer = nil;
    if (self.cameraMode == CameraMode_photo){
        NSLog(@"captured photo");
        [self captureImage];
    }
    else if (self.cameraMode == CameraMode_video){
        NSLog(@"captured video");
        [self stopRecordingVideo];
    }
}

#pragma mark - handle captureButtonTimer

- (void)captureButtonTimerDidHit:(NSTimer *)timer {
    [self.captureButtonTimer invalidate];
    self.captureButtonTimer = nil;
    if (self.camera.movieFileOutput == nil) return;
    
    self.cameraMode = CameraMode_video;
    [self startRecordingVideo];
    
    self.videoProgressUITimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                               target:self
                                                             selector:@selector(videoProgressUITimerDidHit:)
                                                             userInfo:nil
                                                              repeats:YES];
    [self videoProgressUITimerDidHit:timer];
    NSLog(@"now in video mode");
}

#pragma mark - handle videoProgressUITimer

- (void)videoProgressUITimerDidHit:(NSTimer *)timer {
    //UI stuff
//    NSLog(@"video progress timer");
    if (!self.isRecordingVideo) return;
    //check this so that doesn't return old progress time at beginning of timer when recording hasn't started
    if (!self.camera.movieFileOutput.isRecording)return;
    float curTime = CMTimeGetSeconds(self.camera.movieFileOutput.recordedDuration);
    float videoProgress = curTime/kPrivate_maxVideoTimeSecs;
    self.cameraView.videoProgressBar.curValue = videoProgress;
}

#pragma mark - capture image

- (void)captureImage {
    if (self.isCapturingImage) return;
    if (self.isRecordingVideo) return;
    self.isCapturingImage = YES;
    CGRect previewViewVisibleAreaFrame = [self.cameraView previewViewVisibleAreaFrame];
    [self.camera captureImageWithPreviewViewVisibleAreaFrame:previewViewVisibleAreaFrame completionBlock:^(NSError *error, UIImage *finalImage){
        self.isCapturingImage = NO;
        if (error != nil || finalImage == nil){
            dispatch_async(self.camera.serialQueue,^{
                [self.camera.captureSession startRunning];
            });
        } else {
            //success
            dispatch_async(self.camera.serialQueue,^{
                [self.camera.captureSession stopRunning];
            });
            [self goToNextPageWithImage:finalImage videoURL:nil];
        }
    }];
}

#pragma mark - start/stop video

- (void)startRecordingVideo {
    if (self.isCapturingImage) return;
    if (self.isRecordingVideo) return;
    self.isRecordingVideo = YES;
    self.cameraView.videoProgressBar.curValue = 0;
    
    if (self.camera.flashMode == AVCaptureFlashModeOn){
        [self.camera turnTorchOn];
    }
    self.camera.shouldLockFocus = YES;
    
    //UI changes
    [self.cameraView setIsRecordingVideo:YES animateChanges:YES];
    
    //Create temporary URL to record to
    NSURL *outputURL = [[VideoController sharedInstance] getCleanedRecordVideoURL];
    //Start recording
    [self.camera.movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

- (void)stopRecordingVideo {
    [self.camera.movieFileOutput stopRecording];
}

#pragma mark - TTTouchViewDelegate

- (void)TTTouchView:(TTTouchView *)TTTouchView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.cameraView.previewLayer == nil) return;
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UITouch *touch = obj;
        CGPoint pointInPreview = [touch locationInView:touch.view];
        CGPoint pointInCamera = [self.cameraView.previewLayer captureDevicePointOfInterestForPoint:pointInPreview];
        [self.camera focusAndExposePoint:pointInCamera];
    }];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error
{
    NSLog(@"didFinishRecordingToOutputFileAtURL - enter");
    
    [self.captureButtonTimer invalidate];
    self.captureButtonTimer = nil;
    [self.videoProgressUITimer invalidate];
    self.videoProgressUITimer = nil;

    [self.camera turnTorchOff];
    
    self.hasCaptureButtonDetectedEvent = YES;
    
    if (error != nil){
        if (error.code == -11810){
            //reached max length
            //continue
        } else {
            self.isRecordingVideo = NO;
            self.cameraMode = CameraMode_photo;
            return;
        }
    }
    
    float curDuration = CMTimeGetSeconds([captureOutput recordedDuration]);
    if (curDuration < kPrivate_minVideoTimeSecs){
        self.isRecordingVideo = NO;
        self.cameraMode = CameraMode_photo;
        NSString *failureString = [NSString stringWithFormat:@"Please record a minimum of %i seconds.",(int)kPrivate_minVideoTimeSecs];
        [self.infoBannerController showInfo:failureString];
        return;
    }
    
    CGRect previewViewVisibleAreaFrame = [self.cameraView previewViewVisibleAreaFrame];
    CGRect outputRect = [self.cameraView.previewLayer metadataOutputRectOfInterestForRect:previewViewVisibleAreaFrame];
    __weak CameraViewController *weakSelf = self;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        VideoControllerActionCompletion completion = ^(NSError *error, NSURL* finalVideoURL) {
            if (weakSelf == nil) return;
            [weakSelf.cropVidExporter cancelExport];
            
            if (error != nil){
                //error
                //            [DKAlertController showError:errorMessage];
                //TODO: mainqeue
                self.isRecordingVideo = NO;
                self.cameraMode = CameraMode_photo;
            } else {
                NSURL *compressedURL = [[VideoController sharedInstance] getCleanedCompressedVideoURL];
                void(^compressVideoSizeCompletionBLock)(AVAssetExportSession *) = ^(AVAssetExportSession *exportSession){
                    if (weakSelf == nil) return;
                    if (exportSession == nil || exportSession.outputURL == nil) {
                        //error
                        //            [DKAlertController showError:errorMessage];
                        //TODO: mainqeue
                        self.isRecordingVideo = NO;
                        self.cameraMode = CameraMode_photo;
                        return;
                    }
                    UIImage *videoImage = [[VideoController sharedInstance] generateThumbImageForVideoURL:exportSession.outputURL];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf goToNextPageWithImage:videoImage videoURL:exportSession.outputURL];
                        
//                        VideoTestViewController *vc = [[VideoTestViewController alloc] init];
//                        vc.finalVideoURL = exportSession.outputURL;
//                        [weakSelf.navigationController pushViewController:vc animated:YES];
                        [CATransaction setCompletionBlock:^{
                            if (weakSelf == nil) return;
                            //whatever you want to do after the push
                            _isRecordingVideo = NO;
                            weakSelf.camera.shouldLockFocus = NO;
                            //UI changes
                            [weakSelf.cameraView setIsRecordingVideo:NO animateChanges:NO];
                            weakSelf.cameraMode = CameraMode_photo;
                        }];
                        [CATransaction commit];

                    });
                };
                [[VideoController sharedInstance] convertVideoToLowQuailtyWithInputURL:finalVideoURL outputURL:compressedURL handler:compressVideoSizeCompletionBLock];
            }
        };
        VideoController *videoController = [VideoController sharedInstance];
        weakSelf.cropVidExporter = [videoController applyCropToVideo:outputFileURL cropRect:outputRect withCompletion:completion];
    });
}

#pragma mark - go to photo picker

- (void)goToPhotoPicker {
}

#pragma mark - get thumbnail of latest photo in photo_album

- (void)getThumbnailOfLatestPhotoInAlbum {
    ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
    
    __weak CameraViewController *weakSelf = self;
    void (^completionBlock)(UIImage *) = ^(UIImage *thumbnailImage){
        if (weakSelf == nil) return;
        weakSelf.cameraView.photoAlbumButtonImage = thumbnailImage;
    };
    [assetsLib thumbnailOfMostRecentAsset:completionBlock];
}

#pragma mark - key value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == captureSessionRunningContext){
        BOOL isSessionRunning = [change[NSKeyValueChangeNewKey] boolValue];
        if (isSessionRunning){
            //animate opening eyes
            dispatch_async(dispatch_get_main_queue(), ^{
                self.cameraView.isPreviewCoverShown = NO;
            });

        } else {
            //animate close the eyes
            dispatch_async(dispatch_get_main_queue(), ^{
                self.cameraView.isPreviewCoverShown = YES;
            });
        }
    }
    else if ([keyPath isEqualToString:@"camera.flashMode"]){
        self.flashMode = self.camera.flashMode;
    }
    else if ([keyPath isEqualToString:@"camera.hasCameraFlash"]){
        self.hasCameraFlash = self.camera.hasCameraFlash;
    }
    else if ([keyPath isEqualToString:@"camera.isCameraAccessEnabled"]){
        self.isCameraAccessEnabled = self.camera.isCameraAccessEnabled;
    }
}

#pragma mark - NSNotification handler

- (void)captureSessionDidRunIntoError:(NSNotification *) notification {
    id sender = [notification object];
    if (sender != self.camera.captureSession) return;
    dispatch_async(self.camera.serialQueue,^{
        [self.camera.captureSession startRunning];
    });
}

- (void)ALAssetsLibraryDidGrantPermission:(NSNotification *)notification {
    [self getThumbnailOfLatestPhotoInAlbum];
}

#pragma mark - go to next page

- (void)goToNextPageWithImage:(UIImage *)image videoURL:(NSURL *)videoURL {
    if (videoURL == nil){
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor redColor];
        [self.navigationController pushViewController:vc animated:NO];
    } else {
        VideoTestViewController *vc = [[VideoTestViewController alloc] init];
        vc.finalVideoURL = videoURL;
        [self.navigationController pushViewController:vc animated:NO];
    }
}

@end
