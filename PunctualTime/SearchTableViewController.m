//
//  SearchTableViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/3/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "SearchTableViewController.h"
#import "AppDelegate.h"


@interface SearchTableViewController () <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchTextField;
@property NSMutableArray *localSearchQueries;
@property NSMutableArray *pastSearchQueries;
@property AppDelegate *applicationDelegate;
@property NSTimer *autoCompleteTimer;
@property NSString *substring;

@end

NSString *const apiKey = @"AIzaSyBB2Uc2kK0P3zDKwgyYlyC8ivdDCSyy4xg";

typedef NS_ENUM(NSUInteger, TableViewSection){
    TableViewSectionStatic,
    TableViewSectionMain,

    TableViewSectionCount

};


@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pastSearchQueries = [NSMutableArray array];
    self.localSearchQueries = [NSMutableArray array];
    self.searchTextField.delegate = self;
    self.applicationDelegate = [UIApplication sharedApplication].delegate;
    self.locationInfo = [LocationInfo new];
    [self createFooterViewForTable];

}

-(void)viewWillAppear:(BOOL)animated{
    [self.applicationDelegate.userLocationManager updateLocation];
    [self.searchTextField becomeFirstResponder];
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
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=establishment|geocode&language=en&key=%@",searchWord,apiKey];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *results = [jSONresult valueForKey:@"predictions"];
        //NSLog(@"Results %@",results.firstObject);

        NSLog(@"We got %lu locations for %@.",(unsigned long)results.count,self.substring);
        complete(results);

    }];
    [task resume];

}

-(void)retrieveJSONDetailsAbout:(NSString *)place withCompletion:(void (^)(NSArray *))complete {

    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",place,apiKey];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
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
//        case TableVIewSectionLogo:
//            return 1;
//            break;
    }

    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CLLocation *userLocation = self.applicationDelegate.userLocationManager.location;
    NSString *currentLatitude = [NSString stringWithFormat:@"%f,",userLocation.coordinate.latitude];
    NSString *currentLongitude = [NSString stringWithFormat:@"%f",userLocation.coordinate.longitude];

    switch (indexPath.section) {
        case TableViewSectionStatic: {
            self.locationInfo.name = @"Current Name";
            self.locationInfo.address = @"Current Address";
            self.locationInfo.locationCoordinates = CLLocationCoordinate2DMake(currentLatitude.doubleValue, currentLongitude.doubleValue);
            [self performSegueWithIdentifier:@"BackToTheMapSegue" sender:self];


        }    break;
        case TableViewSectionMain: {
            NSDictionary *searchResult = [self.pastSearchQueries objectAtIndex:indexPath.row];
            NSString *placeID = [searchResult objectForKey:@"place_id"];
            [self retrieveJSONDetailsAbout:placeID withCompletion:^(NSArray *place) {
                        //NSLog(@"Place %@", place);
                self.locationInfo.name = [place valueForKey:@"name"];
                self.locationInfo.address = [place valueForKey:@"formatted_address"];
                NSString *latitude = [NSString stringWithFormat:@"%@,",[place valueForKey:@"geometry"][@"location"][@"lat"]];
                NSString *longitude = [NSString stringWithFormat:@"%@",[place valueForKey:@"geometry"][@"location"][@"lng"]];
                self.locationInfo.locationCoordinates = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);

                NSLog(@"Location:%@",self.locationInfo);
                [self performSegueWithIdentifier:@"BackToTheMapSegue" sender:self];
            }];
        }break;

        default:
            break;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    switch (indexPath.section) {
        case TableViewSectionStatic: {
            cell.imageView.image = [UIImage imageNamed:@"cursor6"];
            cell.textLabel.text = @"My Current Location";
        }    break;

        case TableViewSectionMain: {
            NSDictionary *searchResult = [self.pastSearchQueries objectAtIndex:indexPath.row];
            cell.textLabel.text = [searchResult[@"terms"] objectAtIndex:0][@"value"];
            cell.detailTextLabel.text = searchResult[@"description"];
        }break;

        default:
            break;
    }
    return cell;
}


- (void)createFooterViewForTable{
    UIView *footerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 500, 320, 70)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powered-by-google-on-white"]];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    imageView.frame = CGRectMake(110,10,100,12);
    [footerView addSubview:imageView];
    self.tableView.tableFooterView = footerView;
}




@end
