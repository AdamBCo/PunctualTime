//
//  ViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 10/31/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "RootViewController.h"
#import "EventController.h"
#import "Event.h"

@interface RootViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property EventController *sharedEventController;

@end


@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sharedEventController = [EventController sharedEventController];
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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ to %@ by %@", event.startingAddress, event.endingAddress, event.desiredArrivalTime];

    return cell;
}

@end
