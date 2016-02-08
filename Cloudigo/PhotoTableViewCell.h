//
//  PhotoTableViewCell.h
//  Cloudigo
//
//  Created by Christian Villa on 11/28/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *organizationNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *photoDescriptionLabel;

@end
