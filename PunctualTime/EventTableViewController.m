//
//  ViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "EventTableViewController.h"
#import "EventManager.h"
#import "Constants.h"
#import "Event.h"

@interface EventTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIImageView *dragImageView;
@property (strong, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (strong, nonatomic) IBOutlet UIView *panView;
@property EventManager *sharedEventManager;

@end


@implementation EventTableViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sharedEventManager = [EventManager sharedEventManager];

    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGestureDetected:)];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGestureDetected:)];
    [self.panView setGestureRecognizers:@[panGesture, tapGesture]];

    [[NSNotificationCenter defaultCenter] addObserverForName:EVENTS_UPDATED
                                                      object:self.sharedEventManager
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note){
                                                      [self.tableView reloadData];
                                                  }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    [super viewWillAppear:animated];
}

- (void)rotateArrowImageToDegrees:(CGFloat)degrees
{
    [UIView animateWithDuration:0.2 animations:^{
        self.arrowImageView.transform = CGAffineTransformMakeRotation(degrees * M_PI/180);
    }];
}


#pragma mark - Private methods

- (IBAction)onPanGestureDetected:(UIPanGestureRecognizer *)panGesture
{
    [self.tableView setEditing:NO animated:YES];
    [self.delegate panGestureDetected:panGesture];
}

- (IBAction)onTapGestureDetected:(UITapGestureRecognizer *)tapGesture
{
    [self.tableView setEditing:NO animated:YES];
    [self.delegate tapGestureDetected:tapGesture];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:EVENTS_UPDATED object:self];
    }
}
- (IBAction)onBackButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
