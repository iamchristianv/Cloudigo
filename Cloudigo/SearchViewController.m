//
//  SearchViewController.m
//  Cloudigo
//
//  Created by Christian Villa on 11/16/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *searchResults; // contains instances of PFObject

@property BOOL isSearching;
@property BOOL noResultsFound;
@end

@implementation SearchViewController

# pragma mark - View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:(50.0/255.0)
                                                green:(175.0/255.0)
                                                 blue:(255.0/255.0)
                                                alpha:1.0];
    [self prepareNavigationBar];
    [self prepareSearchBar];
    [self prepareTableView];
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

# pragma mark - Search Bar Methods

- (void)prepareSearchBar {
    self.searchBar.barTintColor = [UIColor colorWithRed:(50.0/255.0)
                                                  green:(175.0/255.0)
                                                   blue:(255.0/255.0)
                                                  alpha:1.0];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search";
}

// executes each time the user enters a character
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.tableView.hidden = [self.searchBar.text isEqualToString:@""];
    [self fetchSearchResults];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

# pragma mark - Table View Data Source and Delegate Methods

- (void)prepareTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.hidden = YES;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// checks whether the table view has schools to show or no events to show
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.scrollEnabled = (self.isSearching || self.noResultsFound) ? NO : YES;
    return (self.isSearching || self.noResultsFound) ? 1 : self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearching) {
        return [self createSearchingCell];
    } else if (self.noResultsFound) {
        return [self createNoResultsFoundCell];
    } else {
        return [self createSearchResultCellWithIndexPath:indexPath];
    }
}

// creates a searching cell with moving activity indicator
- (UITableViewCell *)createSearchingCell {
    UITableViewCell *searchingCell = [self.tableView dequeueReusableCellWithIdentifier:@"Searching Cell"];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:1];
    [activityIndicator startAnimating];
    searchingCell.userInteractionEnabled = NO;
    self.isSearching = NO;
    return searchingCell;
}

- (UITableViewCell *)createNoResultsFoundCell {
    UITableViewCell *noResultsFoundCell = [self.tableView dequeueReusableCellWithIdentifier:@"No Results Found Cell"];
    noResultsFoundCell.userInteractionEnabled = NO;
    self.noResultsFound = NO;
    return noResultsFoundCell;
}

// creates a search result cell containing information about the school
- (UITableViewCell *)createSearchResultCellWithIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *searchResultCell = [self.tableView dequeueReusableCellWithIdentifier:@"Search Result Cell"];
    PFObject *searchResult = [self.searchResults objectAtIndex:indexPath.row];
    searchResultCell.textLabel.text = searchResult[@"name"];
    searchResultCell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@, %@", searchResult[@"city"], searchResult[@"state"]];
    return searchResultCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath
                                  animated:YES];
    PFObject *school = [self.searchResults objectAtIndex:indexPath.row];
    if ([school[@"registered"] boolValue]) {
        [self performSegueWithIdentifier:@"Today Segue"
                                  sender:school];
        [school pinInBackground];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                            message:@"Your school is not registered with us!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

# pragma - Query Methods

// queries the Parse database to find schools according to user text
- (void)fetchSearchResults {
    self.isSearching = YES;
    [self.tableView reloadData];
    if (![self.searchBar.text isEqualToString:@""]) {
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(name BEGINSWITH %@) OR (city BEGINSWITH %@)",
                                        [self.searchBar.text capitalizedString],
                                        [self.searchBar.text capitalizedString]];
        PFQuery *searchQuery = [PFQuery queryWithClassName:@"School"
                                                 predicate:searchPredicate];
        // searches for schools on a separate thread 
        [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                    message:@"Please check your internet connection."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
            self.searchResults = [[NSMutableArray alloc] initWithArray:objects];
            self.noResultsFound = (self.searchResults.count == 0) ? YES : NO;
            [self.tableView reloadData];
        }];
    }
}

# pragma - Action Methods

- (IBAction)backgroundButtonPressed:(UIButton *)sender {
    [self.searchBar resignFirstResponder];
}

@end
