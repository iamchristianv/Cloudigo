//
//  CalendarViewController.m
//  Cloudigo
//
//  Created by Christian Villa on 11/22/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import "CalendarEventTableViewCell.h"
#import "CalendarViewController.h"
#import "DetailsViewController.h"
#import "FSCalendar.h"
#import "SWRevealViewController.h"

@interface CalendarViewController () <FSCalendarDataSource, FSCalendarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) PFObject *school;
@property (strong, nonatomic) NSMutableArray *events; // contains instances of PFObject
@property (strong, nonatomic) NSMutableDictionary *eventsDictionary; // used to determine the dates for events in O(1) time in the calendar

@end

@implementation CalendarViewController

# pragma mark - View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:(50.0/255.0)
                                                green:(175.0/255.0)
                                                 blue:(255.0/255.0)
                                                alpha:1.0];
    PFQuery *query = [PFQuery queryWithClassName:@"School"];
    [query fromLocalDatastore];
    self.school = (PFObject *)[[query findObjects] firstObject];
    [self prepareNavigationBar];
    [self prepareRevealViewController];
    [self prepareCalendar];
    [self prepareTableView];
}

# pragma - Navigation Controller Methods

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

// passes information regarding the event the user chose to the details screen
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    DetailsViewController *DVC = (DetailsViewController *)[segue destinationViewController];
    DVC.event = [self.events objectAtIndex:indexPath.row];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

# pragma mark - Calendar Data Source and Delegate Methods

- (void)prepareCalendar {
    self.calendar.dataSource = self;
    self.calendar.delegate = self;
    self.calendar.selectedDate = [NSDate date];
    self.calendar.backgroundColor = [UIColor colorWithRed:(50.0/255.0)
                                                    green:(175.0/255.0)
                                                     blue:(255.0/255.0)
                                                    alpha:1.0];
    self.calendar.appearance.autoAdjustTitleSize = NO;
    self.calendar.appearance.headerTitleFont = [UIFont fontWithName:@"AvenirNext-Medium"
                                                               size:20.0];
    self.calendar.appearance.headerTitleColor = [UIColor whiteColor];
    self.calendar.appearance.weekdayFont = [UIFont fontWithName:@"AvenirNext-Medium"
                                                           size:15.0];
    self.calendar.appearance.weekdayTextColor = [UIColor whiteColor];
    self.calendar.appearance.titleFont = [UIFont fontWithName:@"AvenirNext-Medium"
                                                         size:15.0];
    self.calendar.appearance.titleDefaultColor = [UIColor whiteColor];
    self.calendar.appearance.todayColor = [UIColor grayColor];
    self.calendar.appearance.selectionColor = [UIColor blackColor];
    self.calendar.appearance.eventColor = [UIColor whiteColor];
    self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    return nil;
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar {
    return nil;
}

// goes through every date from the current month and the previous month and next month to see when the events are
// cyles through approximately 90 days every time the calendar is loaded
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    if ([self.eventsDictionary valueForKey:[dateFormatter stringFromDate:date]]) {
        return YES;
    }
    return NO;
}

// executed if user selected a day from the calendar
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {
    [self fetchEventsForSelectedDay];
}

// executed if user changed months
- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar {
    [self fetchEventsForMonth];
}

# pragma mark - Table View Data Source and Delegate Methods

- (void)prepareTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self fetchEventsForSelectedDay];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.events objectAtIndex:indexPath.row] isKindOfClass:[NSNumber class]]) {
        return [self createSearchingCell];
    } else if ([[self.events objectAtIndex:indexPath.row] isKindOfClass:[PFObject class]]) {
        return [self createEventCellWithIndexPath:indexPath];
    } else {
        return [self createNoEventsCell];
    }
}

- (UITableViewCell *)createSearchingCell {
    UITableViewCell *searchingCell = [self.tableView dequeueReusableCellWithIdentifier:@"Searching Cell"];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:1];
    [activityIndicator startAnimating];
    searchingCell.userInteractionEnabled = NO;
    return searchingCell;
}

- (CalendarEventTableViewCell *)createEventCellWithIndexPath:(NSIndexPath *)indexPath {
    CalendarEventTableViewCell *eventCell = [self.tableView dequeueReusableCellWithIdentifier:@"Event Cell"];
    PFObject *event = [self.events objectAtIndex:indexPath.row];
    eventCell.nameLabel.text = event[@"name"];
    eventCell.locationLabel.text = event[@"location"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"h:mm a";
    eventCell.timeLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@",
                                [dateFormatter stringFromDate:event[@"startDate"]],
                                [dateFormatter stringFromDate:event[@"endDate"]]];
    return eventCell;
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
        return 90;
    } else {
        return 70;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath
                                  animated:YES];
}

# pragma mark - Query Methods

// fetches events for the month similar to how the today feed works
- (void)fetchEventsForSelectedDay {
    self.events = [[NSMutableArray alloc] initWithObjects:@0, nil];
    [self.tableView reloadData]; // shows searching cells
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSPredicate *eventPredicate = [NSPredicate predicateWithFormat:@"(school = %@) AND (startDate => %@) AND (endDate <= %@)",
                                   self.school.objectId,
                                   [calendar dateBySettingHour:0 minute:0 second:0 ofDate:self.calendar.selectedDate options:0],
                                   [calendar dateBySettingHour:23 minute:59 second:59 ofDate:self.calendar.selectedDate options:0]];
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event" predicate:eventPredicate];
    [eventQuery orderByAscending:@"startDate"];
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            
        }
        self.events = [[NSMutableArray alloc] init];
        if (objects.count == 0) {
            [self.events addObject:objects];
        } else {
            [self.events addObjectsFromArray:objects];
        }
        [self.tableView reloadData];
    }];
}

- (void)fetchEventsForMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekday
                                               fromDate:self.calendar.currentMonth];
    //components.month = components.month - 1;  uncomment for month before current month
    components.day = 1;
    NSDate *startDate = [calendar dateFromComponents:components];
    //components.month = components.month + 3;  uncomment for month after current month
    components.month = components.month + 1;
    components.day = 0;
    NSDate *endDate = [calendar dateFromComponents:components];
    NSPredicate *eventPredicate = [NSPredicate predicateWithFormat:@"(school = %@) AND (startDate => %@) AND (endDate <= %@)",
                                   self.school.objectId,
                                   startDate,
                                   endDate];
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event" predicate:eventPredicate];
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            
        }
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        self.eventsDictionary = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < objects.count; i++) {
            [self.eventsDictionary setValue:@1 forKey:[dateFormatter stringFromDate:(objects[i])[@"startDate"]]];
        }
        [self.calendar reloadData];
    }];
}

# pragma mark - Action Methods

- (void)prepareRevealViewController {
    self.navigationItem.leftBarButtonItem.target = self.revealViewController;
    self.navigationItem.leftBarButtonItem.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

- (IBAction)refreshButtonPressed:(UIBarButtonItem *)sender {
    [self fetchEventsForMonth];
    [self fetchEventsForSelectedDay];
}

@end

