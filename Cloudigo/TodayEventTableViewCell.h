//
//  TodayEventTableViewCell.h
//  Cloudigo
//
//  Created by Christian Villa on 11/18/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayEventTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizerLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
