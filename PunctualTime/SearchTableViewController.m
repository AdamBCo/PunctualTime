//
//  SearchTableViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/3/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "SearchTableViewController.h"

NSString *const apiURI = @"https://maps.googleapis.com/maps/api/place/autocomplete/output?parameters";
NSString *const apiKey = @"AIzaSyBB2Uc2kK0P3zDKwgyYlyC8ivdDCSyy4xg";

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

    [self retrieveGooglePlaceInformation:substring withCompletion:^(NSArray * results) {
        [self.pastSearchQueries addObjectsFromArray:results];
        [self.tableView reloadData];
    }];
    NSLog(@"Search numbers: %lu", (unsigned long)self.pastSearchQueries.count);

    for(NSString *pastSearch in self.localSearchQueries) {
        NSRange substringRange = [pastSearch rangeOfString:substring];
        if (substringRange.location == 0) {
            [self.pastSearchQueries addObject:pastSearch];

        }
    }
}

#pragma mark UITextFieldDelegate methods

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *substring = [NSString stringWithString:self.searchTextField.text];
    substring= [substring stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    substring = [substring stringByReplacingCharactersInRange:range withString:text];
    [self searchAutocompleteLocationsWithSubstring:substring];
    return YES;
}



#pragma mark - Google API Requests

-(void)retrieveGooglePlaceInformation:(NSString*)searchWord withCompletion:(void (^)(NSArray *))complete{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=geocode&language=en&key=%@",searchWord,apiKey]];

    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *results = [jSONresult valueForKey:@"predictions"];

        NSLog(@"We got %lu locations from google.",(unsigned long)results.count);
        complete(results);

    }];
    [task resume];

}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pastSearchQueries.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *searchResult = [self.pastSearchQueries objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    cell.textLabel.text = [searchResult objectForKey:@"description"];
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    UIView *footerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 500, 320, 70)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powered-by-google-on-white"]];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    imageView.frame = CGRectMake(110,10,100,12);
    [footerView addSubview:imageView];

    self.tableView.tableFooterView = footerView;

    return footerView;

}



@end
