
//
//  FirstViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/5/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "FirstViewController.h"
#import "EventTableViewController.h"
#import "Constants.h"
#import "LiveFrost.h"
#import "AppDelegate.h"
#import "EventManager.h"
#import "UserLocationManager.h"
#import "Event.h"
#import "PlaneView.h"
#import "CreateEventViewController.h"

#import "ChicagoAnimationView.h"
#import "SkyView.h"
#import "BirdView.h"
#include "SunView.h"

@interface FirstViewController ()
@property EventManager *sharedEventManager;
@property EventTableViewController* eventTableViewVC;
@property Event *selectedEvent;
@property NSNumber *timeTillEventTimer;
@property CGFloat lastYTranslation;

@property SunView *sunView;
@property SkyView *skyView;
@property BirdView *birdView;
@property UIView *textLabelView;
@property UILabel *eventName;
@property UILabel *eventTime;

@property PlaneView *planeView;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];


    self.sharedEventManager = [EventManager sharedEventManager];
    self.selectedEvent = self.sharedEventManager.events.firstObject;

    [self.view updateConstraints];

    [[NSNotificationCenter defaultCenter] addObserverForName:EVENTS_UPDATED
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.selectedEvent = self.sharedEventManager.events.firstObject;
                                                      if (!self.selectedEvent)
                                                      {
                                                          self.eventName.text = @"Just";
                                                          self.eventTime.text = @"Chillax";
                                                      }
                                                  }];

    // Remove shadow on transparent toolbar:

    [self startAnimations];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"introViewed"]) {
        [self performSegueWithIdentifier:@"IntroSegue" sender:self];
        [defaults setObject:@YES forKey:@"introViewed"];
        [defaults synchronize];
    }



}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //SkyView Animation
    [UIView animateWithDuration:10.0
                          delay: 0
                        options: UIViewAnimationOptionRepeat | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveLinear
                     animations:^{
                         self.skyView.center = CGPointMake(self.view.frame.size.width + self.view.frame.size.width/2, self.skyView.center.y);
                     }
                     completion:nil];

    //Birds Animation
    [UIView animateWithDuration:20.0
                          delay: 0
                        options: UIViewAnimationOptionRepeat | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.birdView.center = CGPointMake(0 - self.view.frame.size.width*4, self.birdView.center.y);
                         self.planeView.center = CGPointMake(0 - self.view.frame.size.width*4, self.planeView.center.y);
                     }
                     completion:nil];


    self.selectedEvent = self.sharedEventManager.events.firstObject;

    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateCounter)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)updateCounter
{

    int seconds = -[[NSDate date] timeIntervalSinceDate:self.selectedEvent.lastLeaveTime];

    if(seconds > 0)
    {
        seconds -- ;
        int hours = (seconds / 3600);
        int minutes = (seconds % 3600) / 60;
        seconds = (seconds %3600) % 60;
        self.eventName.text = self.selectedEvent.eventName;
        self.eventTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
        
    }
}


-(void)startAnimations {

    CGFloat const h = self.view.frame.size.height;
    CGFloat const w = self.view.frame.size.width;
    
    //SkyView
    self.skyView = [[SkyView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.skyView];

    //BirdView
    self.birdView = [[BirdView alloc] initWithFrame:CGRectMake(w*1.5, 0, w,h)];
    [self.view addSubview:self.birdView];

    //SUnView
    self.sunView = [[SunView alloc] initWithFrame:CGRectMake(w/2,h/4, w,h)];
    [self.view addSubview:self.sunView];
    
    //Chicago
    ChicagoAnimationView *chicagoAnimationView = [[ChicagoAnimationView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:chicagoAnimationView];

    //TextLabelView
    self.textLabelView = [[UIView alloc] initWithFrame:CGRectMake(0,0, w, h)];
    [self.view addSubview:self.textLabelView];

    //PlaneView
    self.planeView = [[PlaneView alloc] initWithFrame:CGRectMake(w*3, h/5, w/4, h/4)];
    [self.view addSubview:self.planeView];

    //Event Name
    self.eventName = [[UILabel alloc] initWithFrame:CGRectMake(0, self.textLabelView.frame.size.height*.33, self.textLabelView.frame.size.width, 30)];
    
    if (SCREEN_HEIGHT == kiPhone4Height)// Temporary fix for 3.5" screens
    {
        self.eventName.frame = CGRectMake(0, (self.textLabelView.frame.size.height*.33)+25, self.textLabelView.frame.size.width, 30);
    }
    
    [self.eventName setTextColor:[UIColor whiteColor]];
    [self.eventName setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:25.0]];
    self.eventName.textAlignment = NSTextAlignmentCenter;
    self.eventName.text = @"Just";
    self.eventName.adjustsFontSizeToFitWidth = YES;
    self.eventName.alpha = 0.0;
    [self.textLabelView addSubview:self.eventName];


    //Event Time
    self.eventTime = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.textLabelView.frame.size.height*.33)+30+15, self.textLabelView.frame.size.width, 30)];
    
    if (SCREEN_HEIGHT == kiPhone4Height) // Temporary fix for 3.5" screens
    {
        self.eventTime.frame = CGRectMake(0, (self.textLabelView.frame.size.height*.33)+48, self.textLabelView.frame.size.width, 30);
    }
    [self.eventTime setTextColor:[UIColor whiteColor]];
    [self.eventTime setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:25.0]];
    self.eventTime.textAlignment = NSTextAlignmentCenter;
    self.eventTime.text = @"Chillax";
    self.eventTime.adjustsFontSizeToFitWidth = YES;
    self.eventTime.alpha = 0.0;
    [self.textLabelView addSubview:self.eventTime];

    //Animate Sun Moving from Bottom View
    [UIView animateWithDuration:3.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.sunView.center = CGPointMake(w/2, self.view.center.y);
    } completion:^(BOOL finished) {

    }];

    //Animate Text Alpha
    [UIView animateWithDuration:2.0 delay:2.20 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.eventName.alpha = 1;
        self.eventTime.alpha = 1;
    } completion:^(BOOL finished) {

    }];
}


#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"CreateEventVCFromTable"])
    {
        
        CreateEventViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.segueFromTableView = NO;
        // Request location tracking for the first time
        UserLocationManager* sharedLocationManager = [UserLocationManager sharedLocationManager];
        [sharedLocationManager requestLocationFromUser];
        
        // Request to send local notifications for the first time
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate requestNotificationPermissions];
    }
    
}

- (IBAction)unwindFromCreateEventVCToFirst:(UIStoryboardSegue *)segue sender:(id)sender
{
    //
}


@end

