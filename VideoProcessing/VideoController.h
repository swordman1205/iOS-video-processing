//
//  VideoController.h
//  TikTokIOS
//
//  Created by Justin Lee on 8/4/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^VideoControllerActionCompletion)(NSError *error, NSURL* finalVideoURL);

@interface VideoController : NSObject

+ (VideoController *)sharedInstance;
- (AVAssetExportSession *)applyCropToVideo:(NSURL *)videoURL cropRect:(CGRect)cropRect withCompletion:(VideoControllerActionCompletion)completion;
- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL handler:(void (^)(AVAssetExportSession*))handler;
- (NSURL *)getCleanedRecordVideoURL;
- (NSURL *)getCleanedCompressedVideoURL;
-(UIImage *)generateThumbImageForVideoURL: (NSURL *)videoURL;

@end
