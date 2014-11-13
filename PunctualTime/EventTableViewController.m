//
//  ViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "EventTableViewController.h"
#import "EventManager.h"
#import "Event.h"

@interface EventTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIImageView *dragImageView;
@property EventManager *sharedEventManager;

@end


@implementation EventTableViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

//    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack)];
//    [self.navigationController.navigationItem setBackBarButtonItem:cancelButton];

    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGestureDetected:)];
    [self.dragImageView addGestureRecognizer:panGesture];

    self.sharedEventManager = [EventManager sharedEventManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];

    [self.sharedEventManager refreshEvents];

    [self.tableView reloadData];

    [super viewWillAppear:animated];
}


#pragma mark - Private methods

- (IBAction)onPanGestureDetected:(UIPanGestureRecognizer *)panGesture
{
    [self.tableView setEditing:NO animated:YES];
    [self.delegate panGestureDetected:panGesture];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sharedEventManager.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [self.sharedEventManager.events objectAtIndex:indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    cell.textLabel.text = event.eventName;
    NSString *formattedLeaveDate = [NSDateFormatter localizedStringFromDate:event.lastLeaveTime
                                                                    dateStyle:NSDateFormatterMediumStyle
                                                                    timeStyle:NSDateFormatterShortStyle];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Leave: %@", formattedLeaveDate];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.sharedEventManager removeEvent:[self.sharedEventManager.events objectAtIndex:indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

@end
