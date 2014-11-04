//
//  SearchTableViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/3/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "SearchTableViewController.h"
#import "AppDelegate.h"

NSString *const apiURI = @"https://maps.googleapis.com/maps/api/place/autocomplete/output?parameters";
NSString *const apiKey = @"AIzaSyBB2Uc2kK0P3zDKwgyYlyC8ivdDCSyy4xg";

@interface SearchTableViewController () <UISearchBarDelegate>


@property (weak, nonatomic) IBOutlet UISearchBar *searchTextField;
@property NSMutableArray *localSearchQueries;
@property NSMutableArray *pastSearchQueries;
@property AppDelegate *applicationDelegate;

@property NSTimer *autoCompleteTimer;
@property NSString *substring;


@end

typedef enum {
    TableViewSectionStatic = 1,
    TableViewSectionMain,

    TableViewSectionCount

} Sections;

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pastSearchQueries = [NSMutableArray array];
    self.localSearchQueries = [NSMutableArray array];
    self.searchTextField.delegate = self;
    self.applicationDelegate = [UIApplication sharedApplication].delegate;

}

-(void)viewWillAppear:(BOOL)animated{
    [self.applicationDelegate.userLocationManager updateLocation];
}


#pragma mark - Autocomplete SearchBar methods
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (![self.localSearchQueries containsObject:self.searchTextField.text]) {
        [self.localSearchQueries addObject:self.searchTextField.text];
    }
    [self.tableView reloadData];
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    self.substring = [NSString stringWithString:self.searchTextField.text];
    self.substring= [self.substring stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    self.substring = [self.substring stringByReplacingCharactersInRange:range withString:text];

    [self runScript];

    return YES;
}


- (void)runScript{

    [self.autoCompleteTimer invalidate];
    self.autoCompleteTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                              target:self
                                                            selector:@selector(searchAutocompleteLocationsWithSubstring:)
                                                            userInfo:nil
                                                             repeats:NO];
}


- (void)searchAutocompleteLocationsWithSubstring:(NSString *)substring{
    [self.pastSearchQueries removeAllObjects];

    [self retrieveGooglePlaceInformation:self.substring withCompletion:^(NSArray * results) {
        [self.pastSearchQueries addObjectsFromArray:results];
        [self.tableView reloadData];
    }];

    for(NSString *pastSearch in self.localSearchQueries) {
        NSRange substringRange = [pastSearch rangeOfString:substring];
        if (substringRange.location == 0) {
            [self.pastSearchQueries addObject:pastSearch];

        }
    }
}


#pragma mark - Google API Requests


-(void)retrieveGooglePlaceInformation:(NSString *)searchWord withCompletion:(void (^)(NSArray *))complete{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=geocode&language=en&key=%@",searchWord,apiKey]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *results = [jSONresult valueForKey:@"predictions"];

        NSLog(@"We got %lu locations for %@.",(unsigned long)results.count,self.substring);
        complete(results);

    }];
    [task resume];

}

-(void)retrieveJSONDetailsAbout:(NSString *)place withCompletion:(void (^)(NSArray *))complete{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",place,apiKey]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *results = [jSONresult valueForKey:@"result"];

        complete(results);
    }];
    [task resume];
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return TableViewSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.pastSearchQueries.count;
    switch (section) {
        case TableViewSectionStatic:
            return 1;
            break;
        case TableViewSectionMain:
            return self.pastSearchQueries.count;
            break;
    }

    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CLLocation *userLocation = self.applicationDelegate.userLocationManager.location;
    NSString *currentLatitude = [NSString stringWithFormat:@"%f,",userLocation.coordinate.latitude];
    NSString *currentLongitude = [NSString stringWithFormat:@"%f",userLocation.coordinate.longitude];

    switch (indexPath.section) {
        case TableViewSectionStatic: {
            self.chosenLocation = @{ @"name" :@"Current Location",
                                     @"address" :@"Current Address",
                                     @"lat" : currentLatitude,
                                     @"long" :currentLongitude
                                     };

        }    break;
        case TableViewSectionMain: {
            NSDictionary *searchResult = [self.pastSearchQueries objectAtIndex:indexPath.row];
            NSString *placeID = [searchResult objectForKey:@"place_id"];
            [self retrieveJSONDetailsAbout:placeID withCompletion:^(NSArray *place) {

                self.chosenLocation = @{ @"name" :[place valueForKey:@"name"],
                                         @"address" :[place valueForKey:@"formatted_address"],
                                         @"lat" :[place valueForKey:@"geometry"][@"location"][@"lat"],
                                         @"long" :[place valueForKey:@"geometry"][@"location"][@"lng"]
                                         };
                NSLog(@"Google: %@",self.chosenLocation);
                
            }];
        }break;

        default:
            break;
    }
    [self performSegueWithIdentifier:@"BackToTheMapSegue" sender:self];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    switch (indexPath.section) {
        case TableViewSectionStatic: {
            cell.textLabel.text = @"My Current Location";
            cell.backgroundColor = [UIColor redColor];
        }    break;
        case TableViewSectionMain: {
            NSDictionary *searchResult = [self.pastSearchQueries objectAtIndex:indexPath.row];
            cell.textLabel.text = [searchResult objectForKey:@"description"];
        }break;

        default:
            break;
    }
    return cell;
}


//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//
////    UIView *footerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 500, 320, 70)];
////    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powered-by-google-on-white"]];
////    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
////    imageView.frame = CGRectMake(110,10,100,12);
////    [footerView addSubview:imageView];
////
////    self.tableView.tableFooterView = footerView;
////
////    return footerView;
//
//}



@end
