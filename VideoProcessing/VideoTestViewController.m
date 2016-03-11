//
//  VideoTestViewController.m
//  TikTokIOS
//
//  Created by Justin Lee on 8/4/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import "VideoTestViewController.h"
#import "VideoTestView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoTestViewController ()
@property (nonatomic) MPMoviePlayerController *moviePlayerController;
@end

@implementation VideoTestViewController

- (void)loadView {
    [super loadView];
    self.videoTestView = [[VideoTestView alloc] init];
    self.view = self.videoTestView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeMoviePlayerController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeMoviePlayerController {
    self.moviePlayerController = [[MPMoviePlayerController alloc]
                                  initWithContentURL:self.finalVideoURL];
    self.moviePlayerController.view.backgroundColor = [UIColor clearColor];
    self.moviePlayerController.scalingMode = MPMovieScalingModeAspectFit;
    self.moviePlayerController.fullscreen = NO;
    //bug: MPMovieControlStyleDefault triggers layoutSubview for superview constantly, causing scrolling to slow down and stutter.
    [self.moviePlayerController setControlStyle:MPMovieControlStyleDefault];
    self.moviePlayerController.shouldAutoplay = NO;
    self.videoTestView.videoView = self.moviePlayerController.view;
    [self.videoTestView.videoContainerView addSubview:self.videoTestView.videoView];
    [self.moviePlayerController prepareToPlay];
}

@end
