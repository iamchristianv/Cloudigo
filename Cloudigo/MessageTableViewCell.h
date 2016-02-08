//
//  MessageTableViewCell.h
//  Cloudigo
//
//  Created by Christian Villa on 12/5/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeSentLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
