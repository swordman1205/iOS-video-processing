//
//  CameraImagePickerController.m
//  TikTokIOS
//
//  Created by Justin Lee on 6/17/15.
//  Copyright (c) 2015 TikTok. All rights reserved.
//

#import "CameraImagePickerController.h"

@interface CameraImagePickerController ()

@end

@implementation CameraImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

////http://stackoverflow.com/questions/18760710/how-to-hide-status-bar-in-uiimagepickercontroller
//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}
//
//-(UIViewController *)childViewControllerForStatusBarHidden
//{
//    return nil;
//}

@end
