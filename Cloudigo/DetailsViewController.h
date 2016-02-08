//
//  DetailsViewController.h
//  Cloudigo
//
//  Created by Christian Villa on 11/22/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface DetailsViewController : UIViewController

@property (strong, nonatomic) PFObject *event;

@end
