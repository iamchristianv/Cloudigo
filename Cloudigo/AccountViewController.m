//
//  AccountViewController.m
//  Cloudigo
//
//  Created by Christian Villa on 12/5/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import "AccountViewController.h"
#import "SWRevealViewController.h"
#import "UserListViewController.h"

@interface AccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@end

@implementation AccountViewController

# pragma mark - View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:(50.0/255.0)
                                                green:(175.0/255.0)
                                                 blue:(255.0/255.0)
                                                alpha:1.0];
    [self prepareRevealViewController];
    [self prepareNavigationBar];
    [self startCloudAnimations];
}

// animates clouds similar to the menu screen
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

# pragma mark - Navigation Controller Methods

- (void)prepareNavigationBar {
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(50.0/255.0)
                                                                           green:(175.0/255.0)
                                                                            blue:(255.0/255.0)
                                                                           alpha:1.0];
    self.navigationController.navigationBar.titleTextAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                   [UIColor whiteColor],
                                                                   NSForegroundColorAttributeName,
                                                                   [UIFont fontWithName:@"AvenirNext-Bold"
                                                                                   size:21.0],
                                                                   NSFontAttributeName,
                                                                   nil];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

# pragma mark - Action Methods

- (void)prepareRevealViewController {
    self.navigationItem.leftBarButtonItem.target = self.revealViewController;
    self.navigationItem.leftBarButtonItem.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

- (void)startCloudAnimations {
    CGFloat location = self.view.frame.size.height / 10;
    [self startRearCloudAnimationInYLocation:(location * 4) withDelay:8.0];
    [self startRearCloudAnimationInYLocation:(location * 6) withDelay:0.0];
}

- (IBAction)backgroundButtonPressed:(UIButton *)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

// queries the Parse database whether the user credentials exist and are correct or not
- (IBAction)signInButtonPressed:(UIButton *)sender {
    if ([self.usernameTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Username or Password"
                                                            message:@"Please make sure to enter both a username and password."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        [PFUser logInWithUsernameInBackground:self.usernameTextField.text
                                     password:self.passwordTextField.text
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                self.usernameTextField.text = @"";
                                                self.passwordTextField.text = @"";
                                                [self performSegueWithIdentifier:@"Show User List Segue" sender:nil];
                                            } else {
                                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incorrect Username or Password"
                                                                                                    message:@"Please make sure both the username and password are correct."
                                                                                                   delegate:nil
                                                                                          cancelButtonTitle:@"OK"
                                                                                          otherButtonTitles:nil];
                                                [alertView show];
                                                self.passwordTextField.text = @"";
                                            }
                                        }];
    }
}

@end
