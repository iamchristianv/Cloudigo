//
//  UserListViewController.m
//  Cloudigo
//
//  Created by Christian Villa on 12/5/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import "MessageViewController.h"
#import "UserListViewController.h"

@interface UserListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) PFObject *school;
@end

@implementation UserListViewController

# pragma mark - View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    PFQuery *query = [PFQuery queryWithClassName:@"School"];
    [query fromLocalDatastore];
    self.school = (PFObject *)[[query findObjects] firstObject];
    [self prepareNavigationBar];
    [self prepareTableView];
}

# pragma mark - Table View Data Source and Delegate Methods

- (void)prepareTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self fetchUsers];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *userCell = [self.tableView dequeueReusableCellWithIdentifier:@"User Cell"];
    PFUser *user = [self.users objectAtIndex:indexPath.row];
    userCell.textLabel.text = user[@"username"];
    userCell.detailTextLabel.text = user[@"description"];
    return userCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath
                                  animated:YES];
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

// passes the information of the person that the user selected to message in PFUser format
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MessageViewController *MVC = (MessageViewController *)segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    MVC.otherUser = [self.users objectAtIndex:indexPath.row];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

# pragma mark - Query Methods

// finds all users that belong to the school and that don't have the same username as the current user
- (void)fetchUsers {
    PFUser *currentUser = [PFUser currentUser];
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"(school = %@) AND (username != %@)",
                                  self.school.objectId,
                                  currentUser.username];
    PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"
                                           predicate:userPredicate];
    [userQuery orderByAscending:@"username"];
    self.users = [[NSMutableArray alloc] initWithArray:[userQuery findObjects]];
    [self.tableView reloadData];
}

# pragma mark - Action Methods

- (IBAction)logoutButtonPressed:(UIBarButtonItem *)sender {
    [PFUser logOut];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
