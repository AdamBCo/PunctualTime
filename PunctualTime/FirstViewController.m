
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
#import "FBShimmeringView.h"
#import "PlaneView.h"

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
@property UIView *animationShapeView;

@property UIView *chicagoAnimationView;
@property UIView *sunView;
@property UIView *skyView;
@property UIView *birds;
@property UIView *bottomView;
@property UIView *textLabelView;
@property UILabel *eventName;
@property UILabel *eventTime;

@property PlaneView *planeView;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sharedEventManager = [EventManager sharedEventManager];
    self.selectedEvent = self.sharedEventManager.events.firstObject;

    NSLog(@"Seconds: %@",self.selectedEvent.lastLeaveTime);

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

    self.animationShapeView = [[UIView alloc]initWithFrame:CGRectMake(0 ,self.view.frame.size.height/6, self.view.frame.size.width, self.view.frame.size.width)];

    self.navigationItem.title = @"Cancel"; // For the back button on CreateEventVC

    // Remove shadow on transparent toolbar:

    [self.addButtonToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.addButtonToolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];

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
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;


#warning Ask mask why this doesn't work properly.
    //SkyView Animation
    [UIView animateWithDuration:10.0
                          delay: 0
                        options: UIViewAnimationOptionRepeat | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.skyView.center = CGPointMake(self.view.frame.size.width + self.view.frame.size.width/2, self.skyView.center.y);
                     }
                     completion:nil];

    //BIRds Animation
    [UIView animateWithDuration:20.0
                          delay: 0
                        options: UIViewAnimationOptionRepeat | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.birds.center = CGPointMake(0 - self.view.frame.size.width*4, self.birds.center.y);
                         self.planeView.center = CGPointMake(0 - self.view.frame.size.width*4, self.planeView.center.y);
                     }
                     completion:nil];


#warning if line is deleted, animations act weird. Why?
    self.navigationController.navigationBar.hidden = YES;
    INITIAL_CONTAINER_LOC = self.containerViewHeightConstraint.constant;

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

    self.skyView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.skyView];

    self.birds = [[UIView alloc] initWithFrame:CGRectMake(w*1.5, 0, w,h)];
    [self.view addSubview:self.birds];

    self.sunView = [[UIView alloc] initWithFrame:CGRectMake(w/2,h/4, w,h)];
    [self.view addSubview:self.sunView];

    self.chicagoAnimationView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.chicagoAnimationView];

    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, h*.80, w, h *.2)];
    self.bottomView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.bottomView];

    self.textLabelView = [[UIView alloc] initWithFrame:CGRectMake(0,0, w, h)];
    [self.view addSubview:self.textLabelView];

    self.planeView = [[PlaneView alloc] initWithFrame:CGRectMake(w*3, h/5, w/4, h/4)];
    [self.planeView drawPlane];
    self.planeView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.planeView];

    //Sun
    int radius = w*.23;
    CAShapeLayer *sun = [CAShapeLayer new];
    sun.position = CGPointMake(self.sunView.frame.size.width/2-radius, self.sunView.frame.size.height/8 + radius);
    sun.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                          cornerRadius:radius].CGPath;
    sun.fillColor = [UIColor orangeColor].CGColor;
    sun.strokeColor = [UIColor whiteColor].CGColor;
    sun.lineWidth = 5;
    self.sunView.center = CGPointMake(0, h);
    [self.sunView.layer addSublayer:sun];

//    CABasicAnimation* sunRotationAnimation;
//    sunRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    sunRotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
//    sunRotationAnimation.duration = 1000;
//    sunRotationAnimation.repeatCount = INFINITY;
//    [self.sunView.layer addAnimation:sunRotationAnimation forKey:@"rotationAnimation"];



    self.eventName = [[UILabel alloc] initWithFrame:CGRectMake(0, self.textLabelView.frame.size.height*.33, self.textLabelView.frame.size.width, 30)];
    [self.eventName setTextColor:[UIColor whiteColor]];
    [self.eventName setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:25.0]];
    self.eventName.textAlignment = NSTextAlignmentCenter;
    self.eventName.text = @"Just";
    self.eventName.adjustsFontSizeToFitWidth = YES;
    self.eventName.alpha = 0.0;
    [self.textLabelView addSubview:self.eventName];


    self.eventTime = [[UILabel alloc] initWithFrame:CGRectMake(0, self.textLabelView.frame.size.height*.38, self.textLabelView.frame.size.width, 30)];
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

    //Ground
    self.chicagoAnimationView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.chicagoAnimationView];
    CAShapeLayer *ground = [CAShapeLayer new];
    CGMutablePathRef background = CGPathCreateMutable();
    CGPathMoveToPoint(background, nil, 0, h*.80);
    CGPathAddLineToPoint(background, nil, w, h*.80);
    CGPathRetain(background);
    ground.path = [UIBezierPath bezierPathWithCGPath:background].CGPath;
    ground.strokeColor = [UIColor whiteColor].CGColor;
    ground.lineWidth = 5;

    //Sky
    CAShapeLayer *sky = [CAShapeLayer new];
    CGMutablePathRef skyPath = CGPathCreateMutable();
    CGPathMoveToPoint(skyPath, nil, -w, h*.25);
    CGPathAddCurveToPoint(skyPath, nil, -w*.5, h*.2, -w*.5, h*.3, 0, h*.25);
    CGPathMoveToPoint(skyPath, nil, 0, h*.25);
    CGPathAddCurveToPoint(skyPath, nil, w*.5, h*.2, w*.5, h*.3, w, h*.25);
    sky.path = [UIBezierPath bezierPathWithCGPath:skyPath].CGPath;
    sky.strokeColor = [UIColor whiteColor].CGColor;
    sky.fillColor = [UIColor clearColor].CGColor;
    sky.lineWidth = 2;

    //SkyTwo
    CAShapeLayer *skyTwo = [CAShapeLayer new];
    CGMutablePathRef skyPathTwo = CGPathCreateMutable();
    CGPathMoveToPoint(skyPathTwo, nil, -w, h*.45);
    CGPathAddCurveToPoint(skyPathTwo, nil, -w*.5, h*.4, -w*.5, h*.5, 0, h*.45);
    CGPathMoveToPoint(skyPathTwo, nil, 0, h*.45);
    CGPathAddCurveToPoint(skyPathTwo, nil, w*.5, h*.4, w*.5, h*.5, w, h*.45);
    skyTwo.path = [UIBezierPath bezierPathWithCGPath:skyPathTwo].CGPath;
    skyTwo.strokeColor = [UIColor whiteColor].CGColor;
    skyTwo.fillColor = [UIColor clearColor].CGColor;
    skyTwo.lineWidth = 2;

    //Birds
    CAShapeLayer *birdOne = [CAShapeLayer new];
    CGMutablePathRef birdPath = CGPathCreateMutable();
    CGPathMoveToPoint(birdPath, nil, w*.4, h*.20);
    CGPathAddQuadCurveToPoint(birdPath, nil, w*.43, h*.18, w*.45, h*.20);
    CGPathAddQuadCurveToPoint(birdPath, nil, w*.46, h*.18, w*.50, h*.20);
    birdOne.path = [UIBezierPath bezierPathWithCGPath:birdPath].CGPath;
    birdOne.strokeColor = [UIColor whiteColor].CGColor;
    birdOne.fillColor = [UIColor clearColor].CGColor;
    birdOne.lineWidth = 2;

    CAShapeLayer *birdTwo = [CAShapeLayer new];
    CGMutablePathRef birdPathTwo = CGPathCreateMutable();
    CGPathMoveToPoint(birdPathTwo, nil, w*.44, h*.24);
    CGPathAddQuadCurveToPoint(birdPathTwo, nil, w*.47, h*.22, w*.49, h*.24);
    CGPathAddQuadCurveToPoint(birdPathTwo, nil, w*.50, h*.22, w*.54, h*.24);
    birdTwo.path = [UIBezierPath bezierPathWithCGPath:birdPathTwo].CGPath;
    birdTwo.strokeColor = [UIColor whiteColor].CGColor;
    birdTwo.fillColor = [UIColor clearColor].CGColor;
    birdTwo.lineWidth = 2;

    //Buildings
    CAShapeLayer *buildings = [CAShapeLayer new];
    CGMutablePathRef chicago = CGPathCreateMutable();
    CGPathMoveToPoint(chicago, nil, 0, h*.80);//Starting Point
    CGPathAddLineToPoint(chicago, nil, 0, h*.65);
    CGPathAddLineToPoint(chicago, nil, w*.05, h*.65);//Building One

    CGPathAddLineToPoint(chicago, nil, w*.05, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.08, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.10, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.10, h*.51);
    CGPathAddLineToPoint(chicago, nil, w*.10, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.14, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.14, h*.51);
    CGPathAddLineToPoint(chicago, nil, w*.14, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.16, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.19, h*.80);

    CGPathAddLineToPoint(chicago, nil, w*.19, h*.70);
    CGPathAddLineToPoint(chicago, nil, w*.21, h*.70);
    CGPathAddLineToPoint(chicago, nil, w*.21, h*.52);
    CGPathAddLineToPoint(chicago, nil, w*.22, h*.52);
    CGPathAddLineToPoint(chicago, nil, w*.22, h*.52);
    CGPathAddLineToPoint(chicago, nil, w*.23, h*.52);
    CGPathAddLineToPoint(chicago, nil, w*.23, h*.50);
    CGPathAddLineToPoint(chicago, nil, w*.24, h*.50);
    CGPathAddLineToPoint(chicago, nil, w*.25, h*.50);
    CGPathAddLineToPoint(chicago, nil, w*.25, h*.46);
    CGPathAddLineToPoint(chicago, nil, w*.25, h*.50);
    CGPathAddLineToPoint(chicago, nil, w*.27, h*.50);
    CGPathAddLineToPoint(chicago, nil, w*.27, h*.65);
    CGPathAddLineToPoint(chicago, nil, w*.29, h*.65);
    CGPathAddLineToPoint(chicago, nil, w*.29, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.29, h*.80);

    CGPathAddLineToPoint(chicago, nil, w*.29, h*.70);
    CGPathAddLineToPoint(chicago, nil, w*.35, h*.70);
    CGPathAddLineToPoint(chicago, nil, w*.35, h*.80);


    CGPathAddLineToPoint(chicago, nil, w*.35, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.35, h*.65);
    CGPathAddLineToPoint(chicago, nil, w*.37, h*.60);
    CGPathAddLineToPoint(chicago, nil, w*.39, h*.65);
    CGPathAddLineToPoint(chicago, nil, w*.39, h*.80);

    CGPathAddLineToPoint(chicago, nil, w*.39, h*.68);
    CGPathAddLineToPoint(chicago, nil, w*.41, h*.67);
    CGPathAddLineToPoint(chicago, nil, w*.46, h*.67);
    CGPathAddLineToPoint(chicago, nil, w*.47, h*.68);
    CGPathAddLineToPoint(chicago, nil, w*.47, h*.80);

    CGPathAddLineToPoint(chicago, nil, w*.47, h*.74);//Merchant mart
    CGPathAddLineToPoint(chicago, nil, w*.485, h*.735);

    CGPathAddLineToPoint(chicago, nil, w*.52, h*.735);//base
    CGPathAddLineToPoint(chicago, nil, w*.52, h*.73);
    CGPathAddLineToPoint(chicago, nil, w*.53, h*.725);//Bridge
    CGPathAddLineToPoint(chicago, nil, w*.60, h*.725);
    CGPathAddLineToPoint(chicago, nil, w*.61, h*.73);
    CGPathAddLineToPoint(chicago, nil, w*.61, h*.735);

    CGPathAddLineToPoint(chicago, nil, w*.645, h*.735);
    CGPathAddLineToPoint(chicago, nil, w*.65, h*.74);//base

    CGPathAddLineToPoint(chicago, nil, w*.65, h*.80);


    CGPathAddLineToPoint(chicago, nil, w*.65, h*.80);//Space
    CGPathAddLineToPoint(chicago, nil, w*.65, h*.67);//Building Four
    CGPathAddLineToPoint(chicago, nil, w*.70, h*.64);
    CGPathAddLineToPoint(chicago, nil, w*.70, h*.665);
    CGPathAddLineToPoint(chicago, nil, w*.70, h*.64);
    CGPathAddLineToPoint(chicago, nil, w*.75, h*.67);
    CGPathAddLineToPoint(chicago, nil, w*.70, h*.692);
    CGPathAddLineToPoint(chicago, nil, w*.65, h*.67);
    CGPathAddLineToPoint(chicago, nil, w*.70, h*.692);
    CGPathAddLineToPoint(chicago, nil, w*.75, h*.67);


    CGPathAddLineToPoint(chicago, nil, w*.75, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.75, h*.80);//Building Five
    CGPathAddLineToPoint(chicago, nil, w*.75, h*.70);
    CGPathAddLineToPoint(chicago, nil, w*.80, h*.70);
    CGPathAddLineToPoint(chicago, nil, w*.80, h*.80);

    //Sears Tower
    CGPathAddLineToPoint(chicago, nil, w*.80, h*.75);
    CGPathAddLineToPoint(chicago, nil, w*.80, h*.75);

    CGPathAddLineToPoint(chicago, nil, w*.80, h*.65);
    CGPathAddLineToPoint(chicago, nil, w*.81, h*.65);

    CGPathAddLineToPoint(chicago, nil, w*.81, h*.55);
    CGPathAddLineToPoint(chicago, nil, w*.82, h*.55);

    CGPathAddLineToPoint(chicago, nil, w*.82, h*.45);//First Spike
    CGPathAddLineToPoint(chicago, nil, w*.83, h*.45);
    CGPathAddLineToPoint(chicago, nil, w*.83, h*.35);
    CGPathAddLineToPoint(chicago, nil, w*.83, h*.45);

    CGPathAddLineToPoint(chicago, nil, w*.85, h*.45);//Second Spike
    CGPathAddLineToPoint(chicago, nil, w*.85, h*.35);//Top of Spike
    CGPathAddLineToPoint(chicago, nil, w*.85, h*.45);//Back To Bottom
    CGPathAddLineToPoint(chicago, nil, w*.86, h*.45);//Top right Edge

    CGPathAddLineToPoint(chicago, nil, w*.86, h*.55);//First Down
    CGPathAddLineToPoint(chicago, nil, w*.87, h*.55);//Edge

    CGPathAddLineToPoint(chicago, nil, w*.87, h*.65);//Third Down
    CGPathAddLineToPoint(chicago, nil, w*.88, h*.65);//Third Edge


    CGPathAddLineToPoint(chicago, nil, w*.88, h*.75);//Fourth Edge
    CGPathAddLineToPoint(chicago, nil, w*.89, h*.75);//
    CGPathAddLineToPoint(chicago, nil, w*.89, h*.80);//Bottom

    //New Building
    CGPathAddLineToPoint(chicago, nil, w*.91, h*.80);
    CGPathAddLineToPoint(chicago, nil, w*.91, h*.65);
    CGPathAddLineToPoint(chicago, nil, w, h*.65);

    CGPathAddLineToPoint(chicago, nil, w, h*.80);//End of Drawing


    CGPathRetain(chicago);
    buildings.path = [UIBezierPath bezierPathWithCGPath:chicago].CGPath;
    buildings.strokeColor = [UIColor whiteColor].CGColor;
    buildings.fillColor = [UIColor orangeColor].CGColor;
    buildings.lineWidth = 2;

    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = 2.0;
    drawAnimation.repeatCount         = 1.0;
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

    [ground addAnimation:drawAnimation forKey:@"drawGroundAnimation"];
    [buildings addAnimation:drawAnimation forKey:@"drawChicagoAnimation"];
    [sky addAnimation:drawAnimation forKey:@"drawSkyAnimation"];
    [skyTwo addAnimation:drawAnimation forKey:@"drawSkyTwoAnimation"];

    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"Move"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:1000];
    rotationAnimation.duration = 10;
    rotationAnimation.repeatCount = INFINITY;

    [self.chicagoAnimationView.layer addSublayer:ground];
    [self.skyView.layer addSublayer:sky];
    [self.skyView.layer addSublayer:skyTwo];
    [self.birds.layer addSublayer:birdOne];
    [self.birds.layer addSublayer:birdTwo];
    [self.chicagoAnimationView.layer addSublayer:buildings];
    [self.view insertSubview:self.animationShapeView aboveSubview:self.containerView];


//    [UIView animateWithDuration:20 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
//                self.view.backgroundColor = [UIColor colorWithRed:0.093 green:0.539 blue:1.000 alpha:1.000];
//    } completion:^(BOOL finished) {
//    }];

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

