//
//  MenuTableViewController.m
//  Cloudigo
//
//  Created by Christian Villa on 11/16/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import "MenuTableViewController.h"

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

# pragma mark - View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:(50.0/255.0)
                                                green:(175.0/255.0)
                                                 blue:(255.0/255.0)
                                                alpha:1.0];
    self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self startCloudAnimations];
    [self registerNotificationForCloudAnimations];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// makes the cloud images animate across the screen according to the delay given
- (void)startRearCloudAnimationInYLocation:(CGFloat)location withDelay:(CGFloat)delay {
    UIImageView *cloudImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloud.png"]];
    CGRect cloudFrame = cloudImage.frame;
    cloudFrame.origin.x = -cloudImage.frame.size.width;
    cloudFrame.origin.y = location;
    cloudImage.frame = cloudFrame;
    [self.view addSubview:cloudImage];
    [self.view sendSubviewToBack:cloudImage];
    [UIView animateWithDuration:20.0
                          delay:delay
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat
                     animations:^{
                         CGRect cloudFrame = cloudImage.frame;
                         cloudFrame.origin.x = self.view.frame.size.width;
                         cloudImage.frame = cloudFrame;
                     }
                     completion:^(BOOL completed) { }];
}

# pragma mark - Action Methods

// determines the locations on the screen where the clouds should animate
- (void)startCloudAnimations {
    CGFloat location = self.view.frame.size.height / 10;
    [self startRearCloudAnimationInYLocation:(location * 6) withDelay:8.0];
    [self startRearCloudAnimationInYLocation:(location * 8) withDelay:0.0];
}

- (void)registerNotificationForCloudAnimations {
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(startCloudAnimations)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
}

@end
