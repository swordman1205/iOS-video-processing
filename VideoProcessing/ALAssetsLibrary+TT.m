//
//  ALAssetsLibrary+TT.m
//  TikTokIOS
//
//  Created by Justin Lee on 8/7/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import "ALAssetsLibrary+TT.h"

@implementation ALAssetsLibrary(TT)

- (void)thumbnailOfMostRecentAsset:(void (^)(UIImage *))completionBlock {
    switch ([ALAssetsLibrary authorizationStatus])
    {
        case ALAuthorizationStatusDenied:
        case ALAuthorizationStatusRestricted:
        case ALAuthorizationStatusNotDetermined:
            completionBlock(nil);
            return;
        case ALAuthorizationStatusAuthorized:
            break;
    }
    ALAssetsLibraryGroupsEnumerationResultsBlock enumGroupsResultsBlock = ^(ALAssetsGroup* group, BOOL* stop) {
        if (group != nil){
            // be sure to filter the group so you only get photos
            //[group setAssetsFilter:[ALAssetsFilter allPhotos]];
            //[group setAssetsFilter:[ALAssetsFilter allVideos]];
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
            if (group.numberOfAssets <= 0) return;
            
            ALAssetsGroupEnumerationResultsBlock enumGroupResultsBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop2) {
                if (result == nil) return;
                UIImage *thumbnail = [UIImage imageWithCGImage:[result thumbnail]];
                completionBlock(thumbnail);
                // we only need the first (most recent)
                // photo -- stop the enumeration
                *stop2 = YES;
                *stop = YES;
            };
            
            [group enumerateAssetsAtIndexes: [NSIndexSet indexSetWithIndex:group.numberOfAssets - 1]
                                    options:0
                                 usingBlock:enumGroupResultsBlock];
        }
        
        if (group == nil){
            //done
            if (stop == NO){
                completionBlock(nil);
            }
        }
    };
    
    ALAssetsLibraryAccessFailureBlock enumGroupsfailureBlock = ^(NSError *error){
        NSLog(@"error: %@", error);
        completionBlock(nil);
    };
    
    [self enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                        usingBlock:enumGroupsResultsBlock
                      failureBlock:enumGroupsfailureBlock];
}

@end
