//
//  MessageViewController.m
//  Cloudigo
//
//  Created by Christian Villa on 12/5/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "MessageViewController.h"

@interface MessageViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) NSMutableArray *messages;
@end

@implementation MessageViewController

# pragma mark - View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareTableView];
    [self prepareTextField];
    // creates a timer to fetch and update the messages from the Parse database every few seconds
    [NSTimer scheduledTimerWithTimeInterval:5.0f
                                     target:self
                                   selector:@selector(fetchMessages)
                                   userInfo:nil
                                    repeats:YES];
}

# pragma mark - Table View Data Source and Delegate Methods

- (void)prepareTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self fetchMessages];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

// creates the cell to show all the information of the message that was sent or received
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageTableViewCell *messageCell = [self.tableView dequeueReusableCellWithIdentifier:@"Message Cell"];
    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    PFUser *sender = ([message[@"sender"] isEqualToString:self.otherUser.objectId]) ? self.otherUser : [PFUser currentUser];
    messageCell.senderLabel.text = sender[@"username"];
    messageCell.messageLabel.text = message[@"text"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"h:mm a";
    messageCell.timeSentLabel.text = [dateFormatter stringFromDate:message.createdAt];
    return messageCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0;
}

// scrolls the table view to the bottom to show the most recent message sent or received
- (void)scrollToBottom {
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height)
                               animated:YES];
}

# pragma mark - Text Field Delegate Methods

- (void)prepareTextField {
    [self.messageTextField becomeFirstResponder];
    self.messageTextField.returnKeyType = UIReturnKeySend;
    self.messageTextField.delegate = self;
}

// creates a new message PFObject and sends it to the Parse database every time the user sends a message
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    PFObject *message = [PFObject objectWithClassName:@"Message"];
    message[@"sender"] = [PFUser currentUser].objectId;
    message[@"receiver"] = self.otherUser.objectId;
    message[@"text"] = self.messageTextField.text;
    [message save];
    [self fetchMessages];
    self.messageTextField.text = @"";
    return NO;
}

# pragma mark - Query Methods

// searches the Parse database for messages that were only sent or received between the current user and the selected user
- (void)fetchMessages {
    PFUser *currentUser = [PFUser currentUser];
    NSPredicate *messagePredicate = [NSPredicate predicateWithFormat:@"((sender = %@) AND (receiver = %@)) OR ((sender = %@) AND (receiver = %@))",
                                     currentUser.objectId,
                                     self.otherUser.objectId,
                                     self.otherUser.objectId,
                                     currentUser.objectId];
    PFQuery *messageQuery = [PFQuery queryWithClassName:@"Message"
                                              predicate:messagePredicate];
    [messageQuery orderByAscending:@"createdAt"];
    self.messages = [[NSMutableArray alloc] initWithArray:[messageQuery findObjects]];
    [self.tableView reloadData];
    [self scrollToBottom];
}

@end
