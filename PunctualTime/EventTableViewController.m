//
//  ViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "EventTableViewController.h"
#import "EventController.h"
#import "Event.h"

@interface EventTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property EventController *sharedEventController;

@end


@implementation EventTableViewController
- (IBAction)onDoneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sharedEventController = [EventController sharedEventController];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self.sharedEventController refreshEvents];

    [self.tableView reloadData];

    [super viewWillAppear:animated];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sharedEventController.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [self.sharedEventController.events objectAtIndex:indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    cell.textLabel.text = event.eventName;
//    NSString *formattedArrivalDate = [NSDateFormatter localizedStringFromDate:event.desiredArrivalTime
//                                                                    dateStyle:NSDateFormatterMediumStyle
//                                                                    timeStyle:NSDateFormatterShortStyle];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"From: %@  To: %@  By: %@", event.startingAddress, event.endingAddress, formattedArrivalDate];

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
        [self.sharedEventController removeEvent:[self.sharedEventController.events objectAtIndex:indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

@end
