//
//  ALAssetsLibrary+TT.h
//  TikTokIOS
//
//  Created by Justin Lee on 8/7/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary(TT)

- (void)thumbnailOfMostRecentAsset:(void (^)(UIImage *))completionBlock;

@end
