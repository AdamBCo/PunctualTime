
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
#import "EventManager.h"
#import "Event.h"
#import "CircularTimer.h"
#import "PlaneView.h"
#import "ChicagoView.h"
#import "BirdView.h"
#import "SkyView.h"

BOOL isOpeningEventTable;
static CGFloat INITIAL_CONTAINER_LOC;

@interface FirstViewController () <EventTableViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UIToolbar *addButtonToolbar;
@property EventManager *sharedEventManager;
@property EventTableViewController* eventTableViewVC;
@property Event *selectedEvent;
@property NSNumber *timeTillEventTimer;
@property CircularTimer *cirularTimer;
@property CGFloat lastYTranslation;
@property LFGlassView* blurView;

@property UIView *sunView;
@property UIView *textLabelView;
@property UILabel *eventName;
@property UILabel *eventTime;

@property NSArray *animationsArray;

@property PlaneView *planeView;
@property ChicagoView *chicagoView;
@property BirdView *birdView;
@property SkyView *skyView;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sharedEventManager = [EventManager sharedEventManager];
    self.selectedEvent = self.sharedEventManager.events.firstObject;

    self.addButtonToolbar.alpha = 0;
    self.containerView.alpha = 0;

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
    
    [self createViews];

    self.navigationItem.title = @"Cancel"; // For the back button on CreateEventVC

    // Remove shadow on transparent toolbar:

    [self.addButtonToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.addButtonToolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];

    [self startAnimations];


    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"introViewed"]) {
        [self performSegueWithIdentifier:@"IntroSegue" sender:self];
        [defaults setObject:@YES forKey:@"introViewed"];
        [defaults synchronize];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"ViewWillAppear Called");
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;

    [self animateBirdsPlanesAndSkyAcross];



    self.navigationController.navigationBar.hidden = YES;
    INITIAL_CONTAINER_LOC = self.containerViewHeightConstraint.constant;

    self.selectedEvent = self.sharedEventManager.events.firstObject;

    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateCounter)
                                   userInfo:nil
                                    repeats:YES];

    // Check if any events have expired
    if (self.sharedEventManager.events.count > 0)
    {
        for (Event* event in self.sharedEventManager.events)
        {
            if ([[NSDate date] compare:event.lastLeaveTime] == NSOrderedDescending) // Current time is after event time
            {
                [self.sharedEventManager handleExpiredEvent:event completion:^{}];
            }
        }
    }
}


-(void)animateBirdsPlanesAndSkyAcross{

    [UIView animateWithDuration:10
                          delay: 0
                        options: UIViewAnimationOptionRepeat | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveLinear
                     animations:^{
                         self.skyView.center = CGPointMake(self.view.frame.size.width + self.view.frame.size.width/2, self.skyView.center.y);
                     }
                     completion:^(BOOL finished){

                         if (finished) {
                            [self.skyView removeFromSuperview];
                            NSLog(@"Sky Animation Finished");

                         }
                         NSLog(@"Animation Called");
                     }];
    [UIView animateWithDuration:20.0
                          delay: 0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.birdView.center = CGPointMake(0 - self.view.frame.size.width*4, self.birdView.center.y);
                         self.planeView.center = CGPointMake(0 - self.view.frame.size.width*4, self.planeView.center.y);
                     }
                     completion:^(BOOL finished){
                         [self.birdView.layer removeAllAnimations];
                         [self.planeView.layer removeAllAnimations];
                     }];

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

-(void)createViews{

    CGFloat const h = self.view.frame.size.height;
    CGFloat const w = self.view.frame.size.width;

    /////
    self.skyView = [[SkyView alloc] initWithFrame:self.view.frame];
    [self.skyView drawSkyView];
//    [self.view addSubview:self.skyView];

    self.birdView = [[BirdView alloc] initWithFrame:CGRectMake(w*1.5, 0, w,h)];
    [self.view addSubview:self.birdView];
    [self.birdView drawBirds];

    self.sunView = [[UIView alloc] initWithFrame:CGRectMake(w/2,h/4, w,h)];
    [self.view addSubview:self.sunView];

    self.chicagoView = [[ChicagoView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.chicagoView];
    [self.chicagoView drawChicago];

    self.textLabelView = [[UIView alloc] initWithFrame:CGRectMake(0,0, w, h)];
    [self.view addSubview:self.textLabelView];

    self.planeView = [[PlaneView alloc] initWithFrame:CGRectMake(w*3, h/5, w/4, h/4)];
    [self.planeView drawPlane];
    self.planeView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.planeView];

}

-(void)startAnimations {

    CGFloat const h = self.view.frame.size.height;
    CGFloat const w = self.view.frame.size.width;

    //Sun
    int radius = w*.23;
    CAShapeLayer *sun = [CAShapeLayer new];
    sun.position = CGPointMake(self.sunView.frame.size.width/2-radius, self.sunView.frame.size.height/8 + radius);
    sun.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius) cornerRadius:radius].CGPath;
    sun.fillColor = [UIColor orangeColor].CGColor;
    sun.strokeColor = [UIColor whiteColor].CGColor;
    sun.lineWidth = 5;
    self.sunView.center = CGPointMake(0, h);
    [self.sunView.layer addSublayer:sun];

    self.eventName = [[UILabel alloc] initWithFrame:CGRectMake(0, self.textLabelView.frame.size.height*.33, self.textLabelView.frame.size.width, 30)];
    [self.eventName setTextColor:[UIColor whiteColor]];
    [self.eventName setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:25.0]];
    self.eventName.textAlignment = NSTextAlignmentCenter;
    self.eventName.text = @"Just";
    self.eventName.adjustsFontSizeToFitWidth = YES;
    self.eventName.alpha = 0.0;
    [self.textLabelView addSubview:self.eventName];

    self.eventTime = [[UILabel alloc] initWithFrame:CGRectMake(0, self.textLabelView.frame.size.height*.33+25, self.textLabelView.frame.size.width, 30)];
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
        self.addButtonToolbar.alpha = 1;
        self.containerView.alpha = 1;
    } completion:^(BOOL finished){

    }];


//
    // Drawings animations
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"drawingAnimation"];
    drawAnimation.duration            = 2.0;
    drawAnimation.repeatCount         = 1.0;
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

    [self.chicagoView.layer addAnimation:drawAnimation forKey:@"drawingAnimation"];


}

#pragma mark - EventTableViewControllerDelegate

- (void)panGestureDetected:(UIPanGestureRecognizer *)gesture
{
    if (UIGestureRecognizerStateBegan == gesture.state)
    {
        if (self.containerViewHeightConstraint.constant == INITIAL_CONTAINER_LOC) // Container is being moved up
        {
            // Create blur view to animate
            self.blurView = [[LFGlassView alloc] initWithFrame:self.view.frame];
            self.blurView.alpha = 0.0;
            [self.view insertSubview:self.blurView belowSubview:self.containerView];
        }
    }
    else if (UIGestureRecognizerStateChanged == gesture.state)
    {
        CGPoint translation = [gesture translationInView:gesture.view];
        self.containerViewHeightConstraint.constant -= translation.y;
        [gesture setTranslation:CGPointMake(0, 0) inView:gesture.view];
        self.lastYTranslation = translation.y;

        // Set blurView alpha
        CGPoint location = [gesture locationInView:self.view];
        self.blurView.alpha = 1.06 - (location.y/SCREEN_HEIGHT);
    }

    else if (UIGestureRecognizerStateEnded == gesture.state)
    {
        if (self.lastYTranslation > 0) // User was panning down so finish closing
        {
            self.containerViewHeightConstraint.constant = INITIAL_CONTAINER_LOC;
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
                self.blurView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.blurView removeFromSuperview];
            }];

            [self.eventTableViewVC rotateArrowImageToDegrees:0.0];
        }
        else // User was panning up so finish opening
        {
            self.containerViewHeightConstraint.constant = SCREEN_HEIGHT;
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
                self.blurView.alpha = 1.0;
            }];

            [self.eventTableViewVC rotateArrowImageToDegrees:180.0];
        }
    }

    else // Gesture was cancelled or failed so animate back to original location
    {
        self.containerViewHeightConstraint.constant = INITIAL_CONTAINER_LOC;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
            self.blurView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.blurView removeFromSuperview];
        }];
    }
}

- (void)tapGestureDetected:(UITapGestureRecognizer *)gesture
{
    if (self.containerViewHeightConstraint.constant == INITIAL_CONTAINER_LOC) // Container is being moved up
    {
        isOpeningEventTable = YES;

        // Create blur view to animate
        self.blurView = [[LFGlassView alloc] initWithFrame:self.view.frame];
        self.blurView.alpha = 0.0;
        [self.view insertSubview:self.blurView belowSubview:self.containerView];
    }
    else
    {
        isOpeningEventTable = NO;
    }

    if (UIGestureRecognizerStateEnded == gesture.state)
    {
        if (!isOpeningEventTable)
        {
            self.containerViewHeightConstraint.constant = INITIAL_CONTAINER_LOC;
            [UIView animateWithDuration:0.3 animations:^{
                [self.view layoutIfNeeded];
                self.blurView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.blurView removeFromSuperview];
            }];

            [self.eventTableViewVC rotateArrowImageToDegrees:0.0];
        }
        else
        {
            self.containerViewHeightConstraint.constant = SCREEN_HEIGHT;
            [UIView animateWithDuration:0.3 animations:^{
                [self.view layoutIfNeeded];
                self.blurView.alpha = 1.0;
            }];

            [self.eventTableViewVC rotateArrowImageToDegrees:180.0];
        }
    }

    else // Gesture was cancelled or failed so animate back to original location
    {
        self.containerViewHeightConstraint.constant = INITIAL_CONTAINER_LOC;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
            self.blurView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.blurView removeFromSuperview];
        }];
    }

}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EventTableVC"])
    {
        self.eventTableViewVC = segue.destinationViewController;
        self.eventTableViewVC.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"CreateEventVC"])
    {
        self.navigationController.navigationBar.hidden = NO;
    }
}


@end

