//
//  TransportationTableViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 12/16/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "TransportationTableViewController.h"
#import "Constants.h"

@interface TransportationTableViewController ()

@end

@implementation TransportationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
    
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
        case 0:
            self.selectedMethodOfTransportation = TRANSPO_WALKING;
            [self performSegueWithIdentifier:@"UnwindFromTransportationView" sender:self];
            break;
        case 1:
            self.selectedMethodOfTransportation = TRANSPO_DRIVING;
            [self performSegueWithIdentifier:@"UnwindFromTransportationView" sender:self];
            break;
        case 2:
            self.selectedMethodOfTransportation = TRANSPO_BIKING;
            [self performSegueWithIdentifier:@"UnwindFromTransportationView" sender:self];
            break;
        case 3:
            self.selectedMethodOfTransportation = TRANSPO_TRANSIT;
            [self performSegueWithIdentifier:@"UnwindFromTransportationView" sender:self];
            break;
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
            cell.textLabel.text = @"Walking";
            if ([self.selectedMethodOfTransportation isEqualToString: TRANSPO_WALKING]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            };
            break;
        }
        case 1: {
            cell.textLabel.text = @"Driving";
            if ([self.selectedMethodOfTransportation isEqualToString: TRANSPO_DRIVING]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            };
            break;
        }
        case 2: {
            cell.textLabel.text = @"Biking";
            if ([self.selectedMethodOfTransportation isEqualToString: TRANSPO_BIKING]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            };
            break;
        }
        case 3: {
            cell.textLabel.text = @"Public Transit";
            if ([self.selectedMethodOfTransportation isEqualToString: TRANSPO_TRANSIT]){
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
