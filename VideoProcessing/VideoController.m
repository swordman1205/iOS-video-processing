//
//  VideoController.m
//  TikTokIOS
//
//  Created by Justin Lee on 8/4/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import "VideoController.h"

#define kPrivate_defaultErrorMessage NSLocalizedString(@"Unable to create video", nil)

@implementation VideoController

static VideoController *sharedInstance;

+ (VideoController *)sharedInstance {
    if (sharedInstance == nil){
        sharedInstance = [[VideoController alloc] init];
    }
    return sharedInstance;
}

-(AVAssetExportSession *)applyCropToVideo:(NSURL *)videoURL cropRect:(CGRect)cropRect withCompletion:(VideoControllerActionCompletion)completion {
    if (videoURL == nil){
        completion([self defaultError], nil);
        return nil;
    }
    
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    if (asset == nil){
        completion([self defaultError], nil);
        return nil;
    }
    
    //create an avassetrack with our asset
    NSArray *assetTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    if (assetTracks == nil || [assetTracks count] <= 0){
        completion([self defaultError], nil);
        return nil;
    }
    AVAssetTrack *clipVideoTrack = [assetTracks objectAtIndex:0];
    
    //create a video composition and preset some settings
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    CGSize clipNatureSize = clipVideoTrack.naturalSize;
    
    //cropRect is flipped 90degree as well...
    CGFloat cropOffX = floorf(cropRect.origin.y * clipNatureSize.height);
    CGFloat cropOffY = floorf(cropRect.origin.x * clipNatureSize.width);
    
    //http://stackoverflow.com/questions/22883525/avassetexportsession-giving-me-a-green-border-on-right-and-bottom-of-output-vide
    //must be divisble by 2, otherwise greenline shows up
    CGFloat cropWidth = floorf(cropRect.size.height * clipVideoTrack.naturalSize.height);
    if ((int)cropWidth % 2 != 0){
        cropWidth += 1;
    }
    CGFloat cropHeight = floorf(cropRect.size.width * clipVideoTrack.naturalSize.width);
    if (((int)cropHeight) % 2 != 0){
        cropHeight += 1;
    }
    
    videoComposition.renderSize = CGSizeMake(cropWidth, cropHeight);
    
    //create a video instruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,asset.duration);
    instruction.timeRange = video_timeRange;
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
    UIImageOrientation videoOrientation = [self getVideoOrientationFromAsset:asset];
    
    CGAffineTransform t1 = CGAffineTransformIdentity;
    CGAffineTransform t2 = CGAffineTransformIdentity;
    
    switch (videoOrientation) {
        case UIImageOrientationUp:
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height - cropOffX, 0 - cropOffY );
            t2 = CGAffineTransformRotate(t1, M_PI_2 );
            break;
        case UIImageOrientationDown:
            t1 = CGAffineTransformMakeTranslation(0 - cropOffX, clipVideoTrack.naturalSize.width - cropOffY ); // not fixed width is the real height in upside down
            t2 = CGAffineTransformRotate(t1, - M_PI_2 );
            break;
        case UIImageOrientationRight:
            t1 = CGAffineTransformMakeTranslation(0 - cropOffX, 0 - cropOffY );
            t2 = CGAffineTransformRotate(t1, 0 );
            break;
        case UIImageOrientationLeft:
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.width - cropOffX, clipVideoTrack.naturalSize.height - cropOffY );
            t2 = CGAffineTransformRotate(t1, M_PI  );
            break;
        default:
            NSLog(@"no supported orientation has been found in this video");
            break;
    }
    
    CGAffineTransform finalTransform = t2;
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    
    //add the transformer layer instructions, then add to video composition
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    // assign all instruction for the video processing (in this case the transformation for cropping the video
    AVAssetExportSession* exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    exporter.videoComposition = videoComposition;
    exporter.outputFileType = AVFileTypeMPEG4;
    
    NSURL *outputURL = [self findURLForCroppingSquareVideo];
    if (outputURL == nil){
        completion([self defaultError], nil);
        return nil;
    } else {
        //export it
        exporter.outputURL = outputURL;
        [self exportAsset:exporter completion:completion];
        return exporter;
    }
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
     }];
}

-(UIImage *)generateThumbImageForVideoURL: (NSURL *)videoURL
{
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = 0;
    NSError *error;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
    if (error || !imageRef){
        CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
        return nil;
    }
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    return thumbnail;
}

#pragma mark - export asset

- (void) exportAsset:(AVAssetExportSession *)exporter completion:(VideoControllerActionCompletion)completion {
    void (^exportCompletion)(void) = ^{
        NSInteger exportStatus = [exporter status];
        if (exportStatus == AVAssetExportSessionStatusFailed){
            NSString *errorMessage = [[exporter error] localizedDescription];;
            NSLog(@"crop Export failed: %@", errorMessage);
            if (completion){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion([self defaultError],nil);
                });
            }
        }
        else if (exportStatus == AVAssetExportSessionStatusCancelled){
            NSLog(@"crop Export canceled");
            if (completion){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion([self defaultError],nil);
                });
            }
        } else {
            if (completion){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil,exporter.outputURL);
                });
            }
        }
    };
    [exporter exportAsynchronouslyWithCompletionHandler:exportCompletion];
}

#pragma mark - find URL for use

- (NSURL *)getCleanedRecordVideoURL {
    //Create temporary URL to record to
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
    if ([self cleanLocalPath:outputPath]){
        NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
        return outputURL;
    } else {
        return nil;
    }
}

- (NSURL *)getCleanedCompressedVideoURL {
    //Create temporary URL to record to
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"compressed_output.mp4"];
    if ([self cleanLocalPath:outputPath]){
        NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
        return outputURL;
    } else {
        return nil;
    }
}

//mp4
- (NSURL *) findURLForCroppingSquareVideo {
    NSNumber *curTimeMS = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Square-Video-%@.mp4", curTimeMS]];
    if ([self cleanLocalPath:outputFilePath]){
        NSURL *outputURL = [NSURL fileURLWithPath:outputFilePath];
        return outputURL;
    } else {
        return nil;
    }
}

//return success/not success
- (BOOL)cleanLocalPath:(NSString *)localPath {
    if (localPath == nil) return NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:localPath])
    {
        NSError *error;
        if ([fileManager removeItemAtPath:localPath error:&error] == NO)
        {
            //Error - handle if requried
            return NO;
        }
    }
    return YES;
}

#pragma mark - get video orientation of asset

- (UIImageOrientation)getVideoOrientationFromAsset:(AVAsset *)asset
{
    if (asset == nil) return UIImageOrientationUp;
    NSArray *assetTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (assetTracks == nil || [assetTracks count] <= 0){
        return UIImageOrientationUp;
    }
    AVAssetTrack *videoTrack = [assetTracks objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIImageOrientationLeft; //return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIImageOrientationRight; //return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIImageOrientationDown; //return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIImageOrientationUp;  //return UIInterfaceOrientationPortrait;
}

#pragma mark - create error

- (NSError *)defaultError {
    return [VideoController createError:kPrivate_defaultErrorMessage];
}

+ (NSError*)createError:(NSString*)errorDescription {
    return [NSError errorWithDomain:@"VideoController" code:200 userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
}

@end
