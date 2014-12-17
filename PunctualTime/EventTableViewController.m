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
#import "CreateEventViewController.h"
#import "AppDelegate.h"
#import "UserLocationManager.h"

@interface EventTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property EventManager *sharedEventManager;

@end


@implementation EventTableViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];

    self.sharedEventManager = [EventManager sharedEventManager];

    [[NSNotificationCenter defaultCenter] addObserverForName:EVENTS_UPDATED
                                                      object:self.sharedEventManager
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note){
                                                      [self.tableView reloadData];
                                                  }];
    
}
- (IBAction)onAddButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"CreateEventVCFromTable" sender:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sharedEventManager.events.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
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

- (IBAction)unwindFromCreateEventVCToTable:(UIStoryboardSegue *)segue sender:(id)sender
{
    //
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"CreateEventVCFromTable"])
    {
        
        CreateEventViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.segueFromTableView = YES;
        // Request location tracking for the first time
        UserLocationManager* sharedLocationManager = [UserLocationManager sharedLocationManager];
        [sharedLocationManager requestLocationFromUser];
        
        // Request to send local notifications for the first time
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate requestNotificationPermissions];
    }
    
}

@end
