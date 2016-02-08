//
//  TodayViewController.m
//  Cloudigo
//
//  Created by Christian Villa on 11/18/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import "DetailsViewController.h"
#import "SWRevealViewController.h"
#import "TodayEventTableViewCell.h"
#import "TodayViewController.h"

@interface TodayViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) PFObject *school;
@property (strong, nonatomic) NSMutableArray *events; // contains earlierEvents, nowEvents, and laterEvents for tableView
@property (strong, nonatomic) NSMutableArray *earlierEvents;
@property (strong, nonatomic) NSMutableArray *nowEvents;
@property (strong, nonatomic) NSMutableArray *laterEvents;
@end

@implementation TodayViewController

# pragma mark - View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:(50.0/255.0)
                                                green:(175.0/255.0)
                                                 blue:(255.0/255.0)
                                                alpha:1.0];
    // finds the school that the user selected at the start
    PFQuery *query = [PFQuery queryWithClassName:@"School"];
    [query fromLocalDatastore];
    self.school = (PFObject *)[[query findObjects] firstObject];
    [self prepareNavigationBar];
    [self prepareRevealViewController];
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

// passes the PFObject event that the user chose to show on the details screen
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailsViewController *DVC = (DetailsViewController *)[segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    DVC.event = [self.events objectAtIndex:indexPath.row];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

# pragma mark - Table View Data Source and Delegate Methods

- (void)prepareTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self fetchEvents];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.events objectAtIndex:indexPath.row] isKindOfClass:[NSNumber class]]) {
        return  [self createSearchingCell];
    } else if ([[self.events objectAtIndex:indexPath.row] isKindOfClass:[PFObject class]]) {
        return [self createEventCellWithIndexPath:indexPath];
    } else if ([[self.events objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        return [self createTimeCellWithIndexPath:indexPath];
    } else {
        return [self createNoEventsCell];
    }
}

// creates searching cell with moving activity indicator
- (UITableViewCell *)createSearchingCell {
    UITableViewCell *searchingCell = [self.tableView dequeueReusableCellWithIdentifier:@"Searching Cell"];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:1];
    [activityIndicator startAnimating];
    searchingCell.userInteractionEnabled = NO;
    return searchingCell;
}

// creates event cell with information regarding the event according to the PFObject
- (TodayEventTableViewCell *)createEventCellWithIndexPath:(NSIndexPath *)indexPath {
    PFObject *event = [self.events objectAtIndex:indexPath.row];
    TodayEventTableViewCell *eventCell = [self.tableView dequeueReusableCellWithIdentifier:@"Event Cell"];
    eventCell.nameLabel.text = event[@"name"];
    eventCell.organizerLabel.text = [[NSString alloc] initWithFormat:@"%@", event[@"organizer"]];
    eventCell.locationLabel.text = [[NSString alloc] initWithFormat:@"%@", event[@"location"]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"h:mm a";
    eventCell.timeLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@",
                                [dateFormatter stringFromDate:event[@"startDate"]],
                                [dateFormatter stringFromDate:event[@"endDate"]]];
    return eventCell;
}

- (UITableViewCell *)createTimeCellWithIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *timeCell = [self.tableView dequeueReusableCellWithIdentifier:@"Time Cell"];
    timeCell.backgroundColor = [UIColor colorWithRed:(50.0/255.0)
                                               green:(175.0/255.0)
                                                blue:(255.0/255.0)
                                               alpha:1.0];
    timeCell.textLabel.text = (NSString *)[self.events objectAtIndex:indexPath.row];
    timeCell.userInteractionEnabled = NO;
    return timeCell;
}

- (UITableViewCell *)createNoEventsCell {
    UITableViewCell *noEventsCell = [self.tableView dequeueReusableCellWithIdentifier:@"No Events Cell"];
    noEventsCell.textLabel.text = @"No Events";
    noEventsCell.userInteractionEnabled = NO;
    return noEventsCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.events objectAtIndex:indexPath.row] isKindOfClass:[NSNumber class]]) {
        return  70;
    } else if ([[self.events objectAtIndex:indexPath.row] isKindOfClass:[PFObject class]]) {
        return 112;
    } else if ([[self.events objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        return 44;
    } else {
        return 70;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath
                                  animated:YES];
}

# pragma mark - Query Methods

// preloads the array with default values until the real events are fetched from the Parse database
- (void)fetchEvents {
    self.events = [[NSMutableArray alloc] initWithObjects:@"Earlier", @1, @"Now", @3, @"Later", @5, nil];
    [self.tableView reloadData]; // shows searching cells
    [self fetchEarlierEvents];
    [self fetchNowEvents];
    [self fetchLaterEvents];
}

- (void)fetchEarlierEvents {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSPredicate *earlierPredicate = [NSPredicate predicateWithFormat:@"(school = %@) AND (startDate > %@ AND endDate < %@) AND (endDate < %@)",
                                     self.school.objectId,
                                     [calendar dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0],
                                     [calendar dateBySettingHour:23 minute:59 second:59 ofDate:[NSDate date] options:0],
                                     [NSDate date]];
    PFQuery *earlierQuery = [PFQuery queryWithClassName:@"Event"
                                              predicate:earlierPredicate];
    [earlierQuery orderByAscending:@"startDate"];
    [earlierQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            
        }
        self.earlierEvents = [[NSMutableArray alloc] init];
        [self.earlierEvents addObject:@"Earlier"];
        if (objects.count == 0) {
            [self.earlierEvents addObject:objects];
        } else {
            [self.earlierEvents addObjectsFromArray:objects];
        }
        if (self.nowEvents.count >= 2 && self.laterEvents.count >= 2) {
            [self addFetchedEvents];
        }
    }];
}

- (void)fetchNowEvents {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSPredicate *nowPredicate = [NSPredicate predicateWithFormat:@"(school = %@) AND (startDate > %@ AND endDate < %@) AND (startDate <= %@) AND (endDate > %@)",
                                 self.school.objectId,
                                 [calendar dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0],
                                 [calendar dateBySettingHour:23 minute:59 second:59 ofDate:[NSDate date] options:0],
                                 [NSDate date],
                                 [NSDate date]];
    PFQuery *nowQuery = [PFQuery queryWithClassName:@"Event"
                                          predicate:nowPredicate];
    [nowQuery orderByAscending:@"startDate"];
    [nowQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            
        }
        self.nowEvents = [[NSMutableArray alloc] init];
        [self.nowEvents addObject:@"Now"];
        if (objects.count == 0) {
            [self.nowEvents addObject:objects];
        } else {
            [self.nowEvents addObjectsFromArray:objects];
        }
        if (self.earlierEvents.count >= 2 && self.laterEvents.count >= 2) {
            [self addFetchedEvents];
        }
    }];
}

- (void)fetchLaterEvents {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSPredicate *laterPredicate = [NSPredicate predicateWithFormat:@"(school = %@) AND (startDate > %@ AND endDate < %@) AND (startDate > %@)",
                                   self.school.objectId,
                                   [calendar dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0],
                                   [calendar dateBySettingHour:23 minute:59 second:59 ofDate:[NSDate date] options:0],
                                   [NSDate date]];
    PFQuery *laterQuery = [PFQuery queryWithClassName:@"Event"
                                            predicate:laterPredicate];
    [laterQuery orderByAscending:@"startDate"];
    [laterQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            
        }
        self.laterEvents = [[NSMutableArray alloc] init];
        [self.laterEvents addObject:@"Later"];
        if (objects.count == 0) {
            [self.laterEvents addObject:objects];
        } else {
            [self.laterEvents addObjectsFromArray:objects];
        }
        if (self.earlierEvents.count >= 2 && self.nowEvents.count >= 2) {
            [self addFetchedEvents];
        }
    }];
}

// adds all the fetched events together into one array for the table view
- (void)addFetchedEvents {
    self.events = [[NSMutableArray alloc] init];
    [self.events addObjectsFromArray:self.earlierEvents];
    [self.events addObjectsFromArray:self.nowEvents];
    [self.events addObjectsFromArray:self.laterEvents];
    [self.tableView reloadData]; // shows event cells
}

# pragma mark - Action Methods

- (void)prepareRevealViewController {
    self.navigationItem.leftBarButtonItem.target = self.revealViewController;
    self.navigationItem.leftBarButtonItem.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

- (IBAction)refreshButtonPressed:(UIBarButtonItem *)sender {
    [self fetchEvents];
}

@end
