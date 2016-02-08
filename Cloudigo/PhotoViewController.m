//
//  PhotoViewController.m
//  Cloudigo
//
//  Created by Christian Villa on 11/28/15.
//  Copyright (c) 2015 Christian Villa. All rights reserved.
//

#import "PhotoTableViewCell.h"
#import "PhotoViewController.h"
#import "SWRevealViewController.h"

@interface PhotoViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) PFObject *school;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *photos;
@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PFQuery *query = [PFQuery queryWithClassName:@"School"];
    [query fromLocalDatastore];
    self.school = (PFObject *)[[query findObjects] firstObject];
    [self prepareRevealViewController];
    [self prepareNavigationBar];
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

# pragma - Table View Data Source and Delegate Methods

- (void)prepareTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchPhotos];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoTableViewCell *photoCell = [self.tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
    PFObject *photo = [self.photos objectAtIndex:indexPath.row];
    photoCell.organizationNameLabel.text = photo[@"organizer"];
    PFFile *photoFile = photo[@"photo"];
    photoCell.photoImageView.image = [UIImage imageWithData:[photoFile getData]];
    photoCell.photoDescriptionLabel.text = photo[@"description"];
    return photoCell;
}

# pragma - Query Methods

// finds all photos that belong to the school that posted them
- (void)fetchPhotos {
    NSPredicate *photoPredicate = [NSPredicate predicateWithFormat:@"(school = %@)", self.school.objectId];
    PFQuery *photoQuery = [PFQuery queryWithClassName:@"Photo" predicate:photoPredicate];
    [photoQuery orderByAscending:@"createdAt"];
    self.photos = [[NSMutableArray alloc] initWithArray:[photoQuery findObjects]];
    [self.tableView reloadData];
}

# pragma - Action Methods

- (void)prepareRevealViewController {
    self.navigationItem.leftBarButtonItem.target = self.revealViewController;
    self.navigationItem.leftBarButtonItem.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

- (IBAction)refreshButtonPressed:(UIBarButtonItem *)sender {
    [self prepareTableView];
}

@end
