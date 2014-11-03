//
//  SearchTableViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/3/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "SearchTableViewController.h"

@interface SearchTableViewController () <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchTextField;
@property NSMutableArray *localSearchQueries;
@property NSMutableArray *pastSearchQueries;

@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pastSearchQueries = [NSMutableArray array];
    self.localSearchQueries = [NSMutableArray array];
    self.searchTextField.delegate = self;

}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (![self.localSearchQueries containsObject:self.searchTextField.text]) {
        [self.localSearchQueries addObject:self.searchTextField.text];
        NSLog(@"Added");
    }
    [self.tableView reloadData];
    NSLog(@"There are %lu searches in array", (unsigned long)self.localSearchQueries.count);
}

- (void)searchAutocompleteLocationsWithSubstring:(NSString *)substring{
    [self.pastSearchQueries removeAllObjects];
    NSLog(@"Sub: %@", substring);
    NSLog(@"Search numbers: %lu", (unsigned long)self.pastSearchQueries.count);

    for(NSString *pastSearch in self.localSearchQueries) {
        NSRange substringRange = [pastSearch rangeOfString:substring];
        if (substringRange.location == 0) {
            [self.pastSearchQueries addObject:pastSearch];

        }
    }
    [self.tableView reloadData];
}

#pragma mark UITextFieldDelegate methods

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *substring = [NSString stringWithString:self.searchTextField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:text];
    [self searchAutocompleteLocationsWithSubstring:substring];
    return YES;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pastSearchQueries.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.pastSearchQueries objectAtIndex:indexPath.row];
    
    return cell;
}


@end
