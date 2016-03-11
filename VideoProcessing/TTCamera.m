//
//  TTCamera.m
//  TikTokIOS
//
//  Created by Justin Lee on 8/3/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import "TTCamera.h"
#import "UIImage+TTImage.h"

#define kPrivate_flashMode_default AVCaptureFlashModeOff

@implementation TTCamera

static TTCamera *sharedInstance;

+ (instancetype)sharedInstance {
    if (sharedInstance == nil){
        sharedInstance = [[TTCamera alloc] init];
    }
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self){
        _isCameraAccessEnabled = nil;
        _hasCameraFlash = nil;
        _frontCameraFlashMode = kPrivate_flashMode_default;
        _backCameraFlashMode = kPrivate_flashMode_default;
        _flashMode = kPrivate_flashMode_default;
        _serialQueue = dispatch_queue_create("com.TikTok.TTcamera.serial.queue", DISPATCH_QUEUE_SERIAL);
        _shouldLockFocus = NO;
    }
    return self;
}

#pragma mark - override setters

- (void)setVideoInputDevice:(AVCaptureDeviceInput *)videoInputDevice {
    _videoInputDevice = videoInputDevice;
    if (videoInputDevice == nil){
        self.hasCameraFlash = nil;
        self.flashMode = AVCaptureFlashModeOff;
    } else {
        AVCaptureDevice * device = videoInputDevice.device;
        if (device == nil){
            self.hasCameraFlash = nil;
            self.flashMode = AVCaptureFlashModeOff;
        } else {
            if ([device hasFlash]){
                self.hasCameraFlash = @(YES);
                self.flashMode = device.flashMode;
            } else {
                self.hasCameraFlash = @(NO);
                self.flashMode = AVCaptureFlashModeOff;
            }
            
            AVCaptureDevicePosition devicePosition = [device position];
            if (devicePosition == AVCaptureDevicePositionFront){
                self.frontCameraFlashMode = self.flashMode;
            }
            else if (devicePosition == AVCaptureDevicePositionBack){
                self.backCameraFlashMode = self.flashMode;
            }
        }
    }
}

- (void)setShouldLockFocus:(BOOL)shouldLockFocus {
    _shouldLockFocus = shouldLockFocus;
    AVCaptureDevice *captureDevice = self.videoInputDevice.device;
    if (captureDevice == nil) return;
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        if (shouldLockFocus){
            if ([captureDevice isFocusModeSupported:AVCaptureFocusModeLocked]){
                [captureDevice setFocusMode:AVCaptureFocusModeLocked];
            }
        } else {
            if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
                [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
        }
        [captureDevice unlockForConfiguration];
    }
}

#pragma mark - public method

- (void) startVideoCapture:(void (^)(NSError *))completionBlock {
    //set up camera capture session
    void (^requestVideoCaptureAccessFailureCallback)(void) = ^{
        self.isCameraAccessEnabled = @(NO);
        UIAlertView *errorDialog = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please allow access to your camera and microphone", nil)
                                                              message:NSLocalizedString(@"Go to settings to enable camera and microphone access", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                    otherButtonTitles:nil];
        [errorDialog show];
        NSError *error = [TTCamera createError:@"didn't get permission for video"];
        completionBlock(error);
    };
    void (^requestVideoCaptureAccessSuccessCallback)(void) = ^{
        self.isCameraAccessEnabled = @(YES);
        [self openSession:completionBlock];
    };
    [self requestVideoCaptureAccessWithSuccessBlock:requestVideoCaptureAccessSuccessCallback failureBlock:requestVideoCaptureAccessFailureCallback];
}

- (void)flipCamera {
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] <= 1) return;
    NSLog(@"Toggle camera");
    NSError *error;
    //AVCaptureDeviceInput *videoInput = [self videoInput];
    AVCaptureDeviceInput *NewVideoInput;
    AVCaptureDevicePosition position = [[self.videoInputDevice device] position];
    if (position == AVCaptureDevicePositionBack)
    {
        NewVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionFront] error:&error];
    }
    else if (position == AVCaptureDevicePositionFront)
    {
        NewVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionBack] error:&error];
    }
    
    if (NewVideoInput != nil)
    {
        //We can now change the inputs and output configuration.  Use commitConfiguration to end
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.videoInputDevice];
        if ([self.captureSession canAddInput:NewVideoInput])
        {
            [self.captureSession addInput:NewVideoInput];
            self.videoInputDevice = NewVideoInput;
        } else {
            [self.captureSession addInput:self.videoInputDevice];
        }
        [self.captureSession commitConfiguration];
    }
}

- (void)changeFlashMode {
    AVCaptureDevice *videoCaptureDevice = self.videoInputDevice.device;
    if (videoCaptureDevice == nil) return;
    
    if ([videoCaptureDevice hasFlash]){
        AVCaptureFlashMode oldFlashMode = videoCaptureDevice.flashMode;
        AVCaptureFlashMode newFlashMode = AVCaptureFlashModeOff;
        if (oldFlashMode == AVCaptureFlashModeOff){
            newFlashMode = AVCaptureFlashModeOn;
        }
        else if (oldFlashMode == AVCaptureFlashModeOn){
            newFlashMode = AVCaptureFlashModeOff;
        }
        NSError *error;
        if ([videoCaptureDevice lockForConfiguration:&error]) {
            if ([videoCaptureDevice isFlashModeSupported:newFlashMode]){
                [videoCaptureDevice setFlashMode:newFlashMode];
                self.flashMode = newFlashMode;
                AVCaptureDevicePosition devicePosition = [videoCaptureDevice position];
                if (devicePosition == AVCaptureDevicePositionFront){
                    self.frontCameraFlashMode = self.flashMode;
                }
                else if (devicePosition == AVCaptureDevicePositionBack){
                    self.backCameraFlashMode = self.flashMode;
                }
            }
            [videoCaptureDevice unlockForConfiguration];
        }
    }
}

- (void)turnTorchOn {
    AVCaptureDevice *videoCaptureDevice = self.videoInputDevice.device;
    if (videoCaptureDevice == nil) return;
    NSError *error;
    if ([videoCaptureDevice lockForConfiguration:&error]) {
        if ([videoCaptureDevice hasFlash]){
            if ([videoCaptureDevice isTorchModeSupported:AVCaptureTorchModeOn]){
                videoCaptureDevice.torchMode = AVCaptureTorchModeOn;
            }
        }
        [videoCaptureDevice unlockForConfiguration];
    }
}

- (void)turnTorchOff {
    AVCaptureDevice *videoCaptureDevice = self.videoInputDevice.device;
    if (videoCaptureDevice == nil) return;
    NSError *error;
    if ([videoCaptureDevice lockForConfiguration:&error]) {
        if ([videoCaptureDevice hasFlash]){
            if ([videoCaptureDevice isTorchModeSupported:AVCaptureTorchModeOff]){
                videoCaptureDevice.torchMode = AVCaptureTorchModeOff;
            }
        }
        [videoCaptureDevice unlockForConfiguration];
    }
}

- (void)focusAndExposePoint:(CGPoint)point {
    AVCaptureDevice *videoCaptureDevice = self.videoInputDevice.device;
    if (videoCaptureDevice == nil) return;
    
    NSError *error;
    if ([videoCaptureDevice lockForConfiguration:&error]) {
        if ([videoCaptureDevice isFocusPointOfInterestSupported]) {
            [videoCaptureDevice setFocusPointOfInterest:point];
        }
        
        AVCaptureFocusMode curFocusMode = videoCaptureDevice.focusMode;
        if (curFocusMode == AVCaptureFocusModeContinuousAutoFocus){
            videoCaptureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        } else {
            if ([videoCaptureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
                [videoCaptureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
            }
        }
        
        if ([videoCaptureDevice isExposurePointOfInterestSupported]){
            [videoCaptureDevice setExposurePointOfInterest:point];
        }

        if ([videoCaptureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
            [videoCaptureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
//        AVCaptureExposureMode curExposureMode = videoCaptureDevice.exposureMode;
//        if (curExposureMode == AVCaptureExposureModeContinuousAutoExposure){
//            videoCaptureDevice.exposureMode = curExposureMode;
//        } else {
//            if ([videoCaptureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
//                [videoCaptureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
//            }
//        }
        
        [videoCaptureDevice unlockForConfiguration];
    }
}

- (void)captureImageWithPreviewViewVisibleAreaFrame:(CGRect)previewViewVisibleAreaFrame completionBlock:(void (^)(NSError *, UIImage *))completionBlock {    
    AVCaptureConnection *videoConnection = [self getStillImageOutputVideoConnection];
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         if (error != nil){
             completionBlock(error, nil);
             return;
         }
         
         if(!CMSampleBufferIsValid(imageSampleBuffer))
         {
             NSError *error = [TTCamera createError:@"imageSampleBuffer is invalid"];
             completionBlock(error, nil);
             return;
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         void (^cropImageCompletionBlock)(BOOL,UIImage *) = ^(BOOL success, UIImage *squareImage){
             UIImage *finalImage = [squareImage resizeToOptimalTTSize];
             dispatch_async(dispatch_get_main_queue(), ^{
                 completionBlock(nil,finalImage);
                 return;
             });
         };
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
             CGRect cropRect = [self.videoPreviewLayer metadataOutputRectOfInterestForRect:previewViewVisibleAreaFrame];
             [self cropImage:image withCropRect:cropRect completionBlock:cropImageCompletionBlock];
         });
     }];
}

- (AVCaptureConnection *)getStillImageOutputVideoConnection {
    if (self.stillImageOutput == nil) return nil;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    return videoConnection;
}

#pragma mark - request video capture access

- (void)requestVideoCaptureAccessWithSuccessBlock:(void (^)(void))successBlock failureBlock:(void (^)(void))failureBlock {
    void (^requestVideoAccessSuccessBlock)(void) = ^{
        [self requestMicrophoneAccessWithSuccessBlock:successBlock failureBlock:failureBlock];
    };
    [self requestVideoAccessWithSuccessBlock:requestVideoAccessSuccessBlock failureBlock:failureBlock];
}

- (void)requestVideoAccessWithSuccessBlock:(void (^)(void))successBlock failureBlock:(void (^)(void))failureBlock {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized) {
        // authorized
        successBlock();
    } else if(status == AVAuthorizationStatusDenied){
        // denied
        failureBlock();
    } else if(status == AVAuthorizationStatusRestricted){
        // restricted
        failureBlock();
    } else if(status == AVAuthorizationStatusNotDetermined){
        // not determined
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access");
                successBlock();
            } else {
                NSLog(@"Not granted access");
                failureBlock();
            }
        }];
    }
}

- (void)requestMicrophoneAccessWithSuccessBlock:(void (^)(void))successBlock failureBlock:(void (^)(void))failureBlock {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(status == AVAuthorizationStatusAuthorized) {
        // authorized
        successBlock();
    } else if(status == AVAuthorizationStatusDenied){
        // denied
        failureBlock();
    } else if(status == AVAuthorizationStatusRestricted){
        // restricted
        failureBlock();
    } else if(status == AVAuthorizationStatusNotDetermined){
        // not determined
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access");
                successBlock();
            } else {
                NSLog(@"Not granted access");
                failureBlock();
            }
        }];
    }
}

#pragma mark - camera stuff

- (void)openSession:(void (^)(NSError *))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Setting up capture session");
        
        NSError *finalError;
        
        //set up capture session
        AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
        [captureSession beginConfiguration];
        
        //set capture session quality/resolution
        if ([captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]){
            [captureSession setSessionPreset:AVCaptureSessionPresetHigh];
        }
        
        //add video input
        AVCaptureDeviceInput *videoInputDevice = nil;
        AVCaptureDevice *VideoDevice = [self getBackCameraCaptureDeviceIfPossible];
        if (!VideoDevice){
            finalError = [TTCamera createError:@"Couldn't create video capture device"];
            NSLog(@"Couldn't create video capture device");
        } else {
            NSError *error;
            videoInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:VideoDevice error:&error];
            if (error || videoInputDevice == nil){
                finalError = [TTCamera createError:@"Couldn't create video input"];
                NSLog(@"Couldn't create video input");
            } else {
                if (![captureSession canAddInput:videoInputDevice]){
                    finalError = [TTCamera createError:@"Couldn't add video input"];
                } else {
                    [captureSession addInput:videoInputDevice];
                }
            }
        }
        
        //add audio input
        AVCaptureDevice *micDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        if (!micDevice){
            finalError = [TTCamera createError:@"Couldn't create mic capture device"];
            NSLog(@"Couldn't create video capture device");
        } else {
            NSError *error;
            AVCaptureDeviceInput * micDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:micDevice error:&error];
;
            if (error || micDeviceInput == nil){
                finalError = [TTCamera createError:@"Couldn't create mic input"];
                NSLog(@"Couldn't create video input");
            } else {
                if (![captureSession canAddInput:micDeviceInput]){
                    finalError = [TTCamera createError:@"Couldn't add mic input"];
                } else {
                    [captureSession addInput:micDeviceInput];
                }
            }
        }
        
        //create preview layer
        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        //add still image output
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [stillImageOutput setOutputSettings:outputSettings];
        if (![captureSession canAddOutput:stillImageOutput]){
            [TTCamera createError:@"cound't add stillImageOutput "];
        } else {
            [captureSession addOutput:stillImageOutput];
        }
        
        //add movie output
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        Float64 TotalSeconds = 60;			//Total seconds
        int32_t preferredTimeScale = 30;	//Frames per second
        CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);	//<<SET MAX DURATION
        movieFileOutput.maxRecordedDuration = maxDuration;
        movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;						//<<SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
        if (![captureSession canAddOutput:movieFileOutput]){
            [TTCamera createError:@"cound't add movieFileOutput "];
        } else {
            [captureSession addOutput:movieFileOutput];
        }
        
        [captureSession commitConfiguration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self == nil) return;
            
            if (finalError != nil){
                completionBlock(finalError);
                return;
            }
            
            self.captureSession = captureSession;
            self.videoInputDevice = videoInputDevice;
            self.stillImageOutput = stillImageOutput;
            self.movieFileOutput = movieFileOutput;
            self.videoPreviewLayer = previewLayer;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //----- START THE CAPTURE SESSION RUNNING -----
                [self.captureSession startRunning];
                NSLog(@"done capture session start running");
            });
            
            completionBlock(finalError);
        });
    });
}

//get camera in specific position if exists
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) Position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == Position)
        {
            [self configureCaptureDevice:device];
            return device;
        }
    }
    return nil;
}

//returns back if not possible
- (AVCaptureDevice *) getBackCameraCaptureDeviceIfPossible {
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    if (device == nil){
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [self configureCaptureDevice:device];
    }
    return device;
}

- (void) configureCaptureDevice:(AVCaptureDevice *)captureDevice {
    if (captureDevice == nil) return;
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
            [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        if ([captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
            [captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        if ([captureDevice hasFlash]){
            
            AVCaptureDevicePosition devicePosition = [captureDevice position];
            
            AVCaptureFlashMode correctFlashMode = AVCaptureFlashModeOff;
            
            if (devicePosition == AVCaptureDevicePositionFront){
                correctFlashMode = self.frontCameraFlashMode;
            }
            else if (devicePosition == AVCaptureDevicePositionBack){
                correctFlashMode = self.backCameraFlashMode;
            }
            
            if ([captureDevice isFlashModeSupported:correctFlashMode]){
                captureDevice.flashMode = correctFlashMode;
            }
            
            if ([captureDevice isTorchModeSupported:AVCaptureTorchModeOff]){
                captureDevice.torchMode = AVCaptureTorchModeOff;
            }
        }
        
        [captureDevice unlockForConfiguration];
    }
}

- (AVCaptureVideoOrientation)actualVideoOrientation {
    AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortrait:
            videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            break;
    }
    return videoOrientation;
}

#pragma mark - create error

+ (NSError*)createError:(NSString*)errorDescription {
    return [NSError errorWithDomain:@"TTCamera" code:200 userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
}

#pragma mark - helpers

//make UIImage and also make it square too
//cropRect is a proportion
- (void) cropImage:(UIImage *)image withCropRect:(CGRect)cropRect completionBlock:(void (^)(BOOL, UIImage *))completionBlock {
    if (image == nil) {
        completionBlock(NO, nil);
        return;
    }
    //get real crop rect
    CGSize imageSize = image.size;
    //cropRect is flipped 90degree as well...
    CGFloat cropOffX = floorf(cropRect.origin.y * imageSize.width);
    CGFloat cropOffY = floorf(cropRect.origin.x * imageSize.height);
    CGFloat cropWidth = floorf(cropRect.size.height * imageSize.width);
    CGFloat cropHeight = floorf(cropRect.size.width * imageSize.height);
//    if (cropWidth < cropHeight){
//        cropHeight = cropWidth;
//    } else {
//        cropWidth = cropHeight;
//    }
    CGRect realCropRect = CGRectMake(cropOffX, cropOffY, cropWidth, cropHeight);
    UIImage *croppedImage = [image cropWithRect:realCropRect];
    if (croppedImage == nil){
        completionBlock(NO, nil);
        return;
    }
    completionBlock(YES, croppedImage);
}

@end
