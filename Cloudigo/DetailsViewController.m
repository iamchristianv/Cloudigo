//
//  DetailsViewController.m
//  Cloudigo
//
//  Created by Christian Villa on 11/22/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizerLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@end

@implementation DetailsViewController

# pragma - View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:(50.0/255.0)
                                                green:(175.0/255.0)
                                                 blue:(255.0/255.0)
                                                alpha:1.0];
    self.nameLabel.text = self.event[@"name"];
    self.organizerLabel.text = self.event[@"organizer"];
    self.locationLabel.text = self.event[@"location"];
    // formats the date given to only show the hour 
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"h:mm a";
    self.timeLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@",
                           [dateFormatter stringFromDate:self.event[@"startDate"]],
                           [dateFormatter stringFromDate:self.event[@"endDate"]]];
    self.descriptionTextView.text = self.event[@"description"];
}

@end
