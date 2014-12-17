//
//  AlertTableViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 12/16/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "AlertTableViewController.h"
#import "Constants.h"

@interface AlertTableViewController ()

@end

@implementation AlertTableViewController

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
    return 5;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
            case 0:
                self.reminderSelected = FIVE_MINUTE_WARNING;
                [self performSegueWithIdentifier:@"UnwindFromAlertView" sender:self];
                break;
            case 1:
                self.reminderSelected = TEN_MINUTE_WARNING;
                [self performSegueWithIdentifier:@"UnwindFromAlertView" sender:self];
                break;
            case 2:
                self.reminderSelected = FIFTEEN_MINUTE_WARNING;
                [self performSegueWithIdentifier:@"UnwindFromAlertView" sender:self];
                break;
            case 3:
                self.reminderSelected = THIRTY_MINUTE_WARNING;
                [self performSegueWithIdentifier:@"UnwindFromAlertView" sender:self];
                break;
            case 4:
                self.reminderSelected = SIXTY_MINUTE_WARNING;
                [self performSegueWithIdentifier:@"UnwindFromAlertView" sender:self];
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
            cell.textLabel.text = @"5 minutes before";
            if ([self.reminderSelected isEqualToString: FIVE_MINUTE_WARNING]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            };
            break;
        }
        case 1: {
            cell.textLabel.text = @"10 minutes before";
            if ([self.reminderSelected  isEqualToString: TEN_MINUTE_WARNING]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            };
            break;
        }
        case 2: {
            cell.textLabel.text = @"15 minutes before";
            if ([self.reminderSelected  isEqualToString: FIFTEEN_MINUTE_WARNING]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            };
            break;
        }
        case 3: {
            cell.textLabel.text = @"30 minutes before";
            if ([self.reminderSelected  isEqualToString: THIRTY_MINUTE_WARNING]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            };
            break;
        }
        case 4: {
            cell.textLabel.text = @"60 minutes before";
            if ([self.reminderSelected  isEqualToString: SIXTY_MINUTE_WARNING]){
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
