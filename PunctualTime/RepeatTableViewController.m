//
//  RepeatTableViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 12/16/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "RepeatTableViewController.h"

@interface RepeatTableViewController ()

@end

@implementation RepeatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
    
    NSLog(@"Gelp: %lu",self.selectedRecurrenceOption);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0: {
            self.selectedRecurrenceOption = PTEventRecurrenceOptionNone;
            [self performSegueWithIdentifier:@"UnwindFromRepeatView" sender:self];
            break;
        }
        case 1: {
            self.selectedRecurrenceOption = PTEventRecurrenceOptionDaily;
            [self performSegueWithIdentifier:@"UnwindFromRepeatView" sender:self];
            break;
        }
        case 2: {
            self.selectedRecurrenceOption = PTEventRecurrenceOptionWeekdays;
            [self performSegueWithIdentifier:@"UnwindFromRepeatView" sender:self];
            break;
        }
        case 3: {
            self.selectedRecurrenceOption = PTEventRecurrenceOptionWeekly;
            [self performSegueWithIdentifier:@"UnwindFromRepeatView" sender:self];
            break;
        }
        default:
            break;
    }
    [self.tableView reloadData];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"None";
            if (self.selectedRecurrenceOption == PTEventRecurrenceOptionNone){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            };
            break;
        }
        case 1: {
            cell.textLabel.text = @"Every Day";
            if (self.selectedRecurrenceOption == PTEventRecurrenceOptionDaily){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            };
            break;
        }
        case 2: {
            cell.textLabel.text = @"Every Weekday";
            if (self.selectedRecurrenceOption == PTEventRecurrenceOptionWeekdays){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            };
            break;
        }
        case 3: {
            cell.textLabel.text = @"Every Week";
            if (self.selectedRecurrenceOption == PTEventRecurrenceOptionWeekly){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            };
            break;
        }
        default:
            break;
    }
    
    return cell;
}


@end
