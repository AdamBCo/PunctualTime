
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

static CGFloat INITIAL_CONTAINER_LOC;

@interface FirstViewController () <EventTableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTillEvent;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UIToolbar *addButtonToolbar;
@property EventManager *sharedEventManager;
@property Event *selectedEvent;
@property NSNumber *timeTillEventTimer;
@property CircularTimer *cirularTimer;
@property CGFloat lastYTranslation;
@property LFGlassView* blurView;
@property UIView *animationShapeView;

@property UIView *chicagoAnimationView;
@property UIView *sunView;
@property UIView *skyView;
@property UIView *bottomView;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.eventNameLabel.alpha =0;
    self.timeTillEvent.alpha = 0;

    self.sharedEventManager = [EventManager sharedEventManager];
    self.selectedEvent = self.sharedEventManager.events.firstObject;

    for (Event *event in self.sharedEventManager.events) {
        NSLog(@"Event: %@\n DesiredTime: %@\n Recurrence %u\n",event.eventName, event.desiredArrivalTime, event.recurrenceInterval);
    }

    NSLog(@"Seconds: %@",self.selectedEvent.lastLeaveTime);

    [[NSNotificationCenter defaultCenter] addObserverForName:EVENTS_UPDATED
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.selectedEvent = self.sharedEventManager.events.firstObject;
                                                  }];

    self.animationShapeView = [[UIView alloc]initWithFrame:CGRectMake(0 ,self.view.bounds.size.height/6, self.view.bounds.size.width, self.view.bounds.size.width)];

    self.navigationItem.title = @"Cancel"; // For the back button on CreateEventVC

    // Remove shadow on transparent toolbar:

    [self.addButtonToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.addButtonToolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];


//    //Star Drawing
//
//    CAShapeLayer *star = [CAShapeLayer layer];
//    CGPoint offset = CGPointMake(self.animationShapeView.frame.size.width/2, self.animationShapeView.frame.size.height/2);
//    int r1 = self.animationShapeView.frame.size.width/2;
//    int r2 = r1 - 20;
//    int numberOfPoints =    60;//60
//    float TWOPI = 2 * M_PI;
//    CGMutablePathRef drawStarPath = CGPathCreateMutable();
//    for (float n=0; n < numberOfPoints; n+=3)
//    {
//        int x1 = offset.x + sin((TWOPI/numberOfPoints) * n) * r2;
//        int y1 = offset.y + cos((TWOPI/numberOfPoints) * n) * r2;
//        if (n==0){
//
//            CGPathMoveToPoint(drawStarPath, NULL, x1, y1);
//        }else {
//            CGPathAddLineToPoint(drawStarPath, NULL, x1, y1);
//            int x2 = offset.x + sin((TWOPI/numberOfPoints) * n+1) * r1;
//            int y2 = offset.y + cos((TWOPI/numberOfPoints) * n+1) * r1;
//            CGPathAddLineToPoint(drawStarPath, NULL, x2, y2);
//            int x3 = offset.x + sin((TWOPI/numberOfPoints) * n+2) * r2;
//            int y3 = offset.y + cos((TWOPI/numberOfPoints) * n+2) * r2;
//            CGPathAddLineToPoint(drawStarPath, NULL, x3, y3);
//        }
//    }
//    CGPathCloseSubpath(drawStarPath);
//
//    star.path = [UIBezierPath bezierPathWithCGPath:drawStarPath].CGPath;
//    star.fillColor = [UIColor clearColor].CGColor;
//    star.strokeColor = [UIColor whiteColor].CGColor;
//    star.lineWidth = 5;

    self.skyView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.skyView];

    self.sunView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2,self.view.bounds.size.height/4, self.view.bounds.size.width,self.view.bounds.size.height/2)];
    [self.view addSubview:self.sunView];

    self.chicagoAnimationView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.chicagoAnimationView];

//
//    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.eventNameLabel.bounds];
//    s
//    shimmeringView.shimmering = YES;


    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height*.80, self.view.bounds.size.width, self.view.bounds.size.height *.2)];
    self.bottomView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.bottomView];


    //Sun
    int radius = self.view.frame.size.width*.23;
    CAShapeLayer *sun = [CAShapeLayer new];
    sun.position = CGPointMake(self.sunView.frame.size.width/2-radius, self.sunView.frame.size.height/4);
    sun.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                          cornerRadius:radius].CGPath;
    sun.fillColor = [UIColor orangeColor].CGColor;
    sun.strokeColor = [UIColor whiteColor].CGColor;
    sun.lineWidth = 5;
    self.sunView.center = CGPointMake(0, self.view.bounds.size.height);
    [self.sunView.layer addSublayer:sun];

    CABasicAnimation* sunRotationAnimation;
    sunRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    sunRotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    sunRotationAnimation.duration = 1000;
    sunRotationAnimation.repeatCount = INFINITY;
    [self.sunView.layer addAnimation:sunRotationAnimation forKey:@"rotationAnimation"];


    //Animate Sun Moving from Bottom View
    [UIView animateWithDuration:3.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.sunView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height*.4);
    } completion:^(BOOL finished) {

    }];

    //Animate Text Alpha
    [UIView animateWithDuration:2.0 delay:2.20 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.eventNameLabel.alpha = 1;
        self.timeTillEvent.alpha = 1;
    } completion:^(BOOL finished) {

    }];

    //Ground
    self.chicagoAnimationView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.chicagoAnimationView];

    CAShapeLayer *ground = [CAShapeLayer new];
    CGMutablePathRef background = CGPathCreateMutable();
    CGPathMoveToPoint(background, nil, 0, self.view.bounds.size.height*.80);
    CGPathAddLineToPoint(background, nil, self.view.bounds.size.width, self.view.bounds.size.height*.80);
    CGPathRetain(background);
    ground.path = [UIBezierPath bezierPathWithCGPath:background].CGPath;
    ground.strokeColor = [UIColor whiteColor].CGColor;
    ground.lineWidth = 5;

    //Sky
    CAShapeLayer *sky = [CAShapeLayer new];
    CGMutablePathRef skyPath = CGPathCreateMutable();
    CGPathMoveToPoint(skyPath, nil, -self.view.bounds.size.width, self.view.bounds.size.height*.25);
    CGPathAddCurveToPoint(skyPath, nil, -self.view.bounds.size.width*.5, self.view.bounds.size.height*.2, -self.view.bounds.size.width*.5, self.view.bounds.size.height*.3, 0, self.view.bounds.size.height*.25);
    CGPathMoveToPoint(skyPath, nil, 0, self.view.bounds.size.height*.25);
    CGPathAddCurveToPoint(skyPath, nil, self.view.bounds.size.width*.5, self.view.bounds.size.height*.2, self.view.bounds.size.width*.5, self.view.bounds.size.height*.3, self.view.bounds.size.width, self.view.bounds.size.height*.25);
    sky.path = [UIBezierPath bezierPathWithCGPath:skyPath].CGPath;
    sky.strokeColor = [UIColor whiteColor].CGColor;
    sky.fillColor = [UIColor clearColor].CGColor;
    sky.lineWidth = 2;

    //SkyTwo
    CAShapeLayer *skyTwo = [CAShapeLayer new];
    CGMutablePathRef skyPathTwo = CGPathCreateMutable();
    CGPathMoveToPoint(skyPathTwo, nil, -self.view.bounds.size.width, self.view.bounds.size.height*.45);
    CGPathAddCurveToPoint(skyPathTwo, nil, -self.view.bounds.size.width*.5, self.view.bounds.size.height*.4, -self.view.bounds.size.width*.5, self.view.bounds.size.height*.5, 0, self.view.bounds.size.height*.45);
    CGPathMoveToPoint(skyPathTwo, nil, 0, self.view.bounds.size.height*.45);
    CGPathAddCurveToPoint(skyPathTwo, nil, self.view.bounds.size.width*.5, self.view.bounds.size.height*.4, self.view.bounds.size.width*.5, self.view.bounds.size.height*.5, self.view.bounds.size.width, self.view.bounds.size.height*.45);
    skyTwo.path = [UIBezierPath bezierPathWithCGPath:skyPathTwo].CGPath;
    skyTwo.strokeColor = [UIColor whiteColor].CGColor;
    skyTwo.fillColor = [UIColor clearColor].CGColor;
    skyTwo.lineWidth = 2;

    //Birds
    CAShapeLayer *birdOne = [CAShapeLayer new];
    CGMutablePathRef birdPath = CGPathCreateMutable();
    CGPathMoveToPoint(birdPath, nil, self.view.bounds.size.width*.4, self.view.bounds.size.height*.20);
    CGPathAddQuadCurveToPoint(birdPath, nil, self.view.bounds.size.width*.43, self.view.bounds.size.height*.18, self.view.bounds.size.width*.45, self.view.bounds.size.height*.20);
    CGPathAddQuadCurveToPoint(birdPath, nil, self.view.bounds.size.width*.46, self.view.bounds.size.height*.18, self.view.bounds.size.width*.50, self.view.bounds.size.height*.20);
    birdOne.path = [UIBezierPath bezierPathWithCGPath:birdPath].CGPath;
    birdOne.strokeColor = [UIColor whiteColor].CGColor;
    birdOne.fillColor = [UIColor clearColor].CGColor;
    birdOne.lineWidth = 2;

    CAShapeLayer *birdTwo = [CAShapeLayer new];
    CGMutablePathRef birdPathTwo = CGPathCreateMutable();
    CGPathMoveToPoint(birdPathTwo, nil, self.view.bounds.size.width*.44, self.view.bounds.size.height*.24);
    CGPathAddQuadCurveToPoint(birdPathTwo, nil, self.view.bounds.size.width*.47, self.view.bounds.size.height*.22, self.view.bounds.size.width*.49, self.view.bounds.size.height*.24);
    CGPathAddQuadCurveToPoint(birdPathTwo, nil, self.view.bounds.size.width*.50, self.view.bounds.size.height*.22, self.view.bounds.size.width*.54, self.view.bounds.size.height*.24);
    birdTwo.path = [UIBezierPath bezierPathWithCGPath:birdPathTwo].CGPath;
    birdTwo.strokeColor = [UIColor whiteColor].CGColor;
    birdTwo.fillColor = [UIColor clearColor].CGColor;
    birdTwo.lineWidth = 2;



    //Buildings
    CAShapeLayer *buildings = [CAShapeLayer new];
    CGMutablePathRef chicago = CGPathCreateMutable();
    CGPathMoveToPoint(chicago, nil, 0, self.view.bounds.size.height*.80);//Starting Point
    CGPathAddLineToPoint(chicago, nil, 0, self.view.bounds.size.height*.65);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.05, self.view.bounds.size.height*.65);//Building One
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.05, self.view.bounds.size.height*.80);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.08, self.view.bounds.size.height*.55);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.10, self.view.bounds.size.height*.55);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.10, self.view.bounds.size.height*.51);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.10, self.view.bounds.size.height*.55);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.14, self.view.bounds.size.height*.55);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.14, self.view.bounds.size.height*.51);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.14, self.view.bounds.size.height*.55);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.16, self.view.bounds.size.height*.55);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.19, self.view.bounds.size.height*.80);

    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.19, self.view.bounds.size.height*.70);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.21, self.view.bounds.size.height*.70);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.21, self.view.bounds.size.height*.52);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.22, self.view.bounds.size.height*.52);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.22, self.view.bounds.size.height*.52);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.23, self.view.bounds.size.height*.52);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.23, self.view.bounds.size.height*.50);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.24, self.view.bounds.size.height*.50);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height*.50);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height*.46);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height*.50);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.27, self.view.bounds.size.height*.50);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.27, self.view.bounds.size.height*.65);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.29, self.view.bounds.size.height*.65);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.29, self.view.bounds.size.height*.80);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.29, self.view.bounds.size.height*.80);

    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.29, self.view.bounds.size.height*.70);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.35, self.view.bounds.size.height*.70);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.35, self.view.bounds.size.height*.80);


    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.35, self.view.bounds.size.height*.80);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.35, self.view.bounds.size.height*.65);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.37, self.view.bounds.size.height*.60);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.39, self.view.bounds.size.height*.65);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.39, self.view.bounds.size.height*.80);

    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.39, self.view.bounds.size.height*.68);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.41, self.view.bounds.size.height*.67);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.46, self.view.bounds.size.height*.67);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.47, self.view.bounds.size.height*.68);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.47, self.view.bounds.size.height*.80);

    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.47, self.view.bounds.size.height*.74);//Merchant mart
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.485, self.view.bounds.size.height*.735);

    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.52, self.view.bounds.size.height*.735);//base
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.52, self.view.bounds.size.height*.73);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.53, self.view.bounds.size.height*.725);//Bridge
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.60, self.view.bounds.size.height*.725);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.61, self.view.bounds.size.height*.73);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.61, self.view.bounds.size.height*.735);

    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.645, self.view.bounds.size.height*.735);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.65, self.view.bounds.size.height*.74);//base

    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.65, self.view.bounds.size.height*.80);


    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.65, self.view.bounds.size.height*.80);//Space
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.65, self.view.bounds.size.height*.67);//Building Four
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.70, self.view.bounds.size.height*.64);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.70, self.view.bounds.size.height*.665);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.70, self.view.bounds.size.height*.64);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.75, self.view.bounds.size.height*.67);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.70, self.view.bounds.size.height*.692);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.65, self.view.bounds.size.height*.67);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.70, self.view.bounds.size.height*.692);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.75, self.view.bounds.size.height*.67);


    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.75, self.view.bounds.size.height*.80);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.75, self.view.bounds.size.height*.80);//Building Five
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.75, self.view.bounds.size.height*.70);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.80, self.view.bounds.size.height*.70);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.80, self.view.bounds.size.height*.80);

    //Sears Tower
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.80, self.view.bounds.size.height*.75);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.80, self.view.bounds.size.height*.75);

    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.80, self.view.bounds.size.height*.65);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.81, self.view.bounds.size.height*.65);

    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.81, self.view.bounds.size.height*.55);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.82, self.view.bounds.size.height*.55);

    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.82, self.view.bounds.size.height*.45);//First Spike
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.83, self.view.bounds.size.height*.45);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.83, self.view.bounds.size.height*.35);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.83, self.view.bounds.size.height*.45);

    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.85, self.view.bounds.size.height*.45);//Second Spike
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.85, self.view.bounds.size.height*.35);//Top of Spike
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.85, self.view.bounds.size.height*.45);//Back To Bottom
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.86, self.view.bounds.size.height*.45);//Top right Edge

    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.86, self.view.bounds.size.height*.55);//First Down
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.87, self.view.bounds.size.height*.55);//Edge

    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.87, self.view.bounds.size.height*.65);//Third Down
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.88, self.view.bounds.size.height*.65);//Third Edge


    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.88, self.view.bounds.size.height*.75);//Fourth Edge
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.89, self.view.bounds.size.height*.75);//
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.89, self.view.bounds.size.height*.80);//Bottom

    //New Building
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.91, self.view.bounds.size.height*.80);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.91, self.view.bounds.size.height*.65);
    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width, self.view.bounds.size.height*.65);

    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width, self.view.bounds.size.height*.80);//End of Drawing

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
    [birdOne addAnimation:drawAnimation forKey:@"drawBirdOneAnimation"];
    [birdTwo addAnimation:drawAnimation forKey:@"drawBirdTwoAnimation"];

    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"Move"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:1000];
    rotationAnimation.duration = 10;
    rotationAnimation.repeatCount = INFINITY;

    //SkyView Animation
    [UIView animateWithDuration:10.0
                          delay: 0
                        options: UIViewAnimationOptionRepeat | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.skyView.center = CGPointMake(self.view.frame.size.width + self.view.frame.size.width/2, self.view.bounds.size.height/2);
                     }
                     completion:nil];


    [self.chicagoAnimationView.layer addSublayer:ground];
    [self.skyView.layer addSublayer:sky];
    [self.skyView.layer addSublayer:skyTwo];
//    [self.skyView.layer addSublayer:birdOne];
//    [self.skyView.layer addSublayer:birdTwo];
    [self.chicagoAnimationView.layer addSublayer:buildings];
    [self.view insertSubview:self.animationShapeView aboveSubview:self.containerView];


    [UIView animateWithDuration:20 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
//        self.view.backgroundColor = [UIColor colorWithRed:0.093 green:0.539 blue:1.000 alpha:1.000];
    } completion:^(BOOL finished) {
    }];

}


-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];

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
        self.eventNameLabel.text = self.selectedEvent.eventName;
        self.timeTillEvent.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
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
        self.blurView.alpha = 1.06 - (location.y/self.view.frame.size.height);

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
        }
        else // User was panning up so finish opening
        {

            self.containerViewHeightConstraint.constant = self.view.frame.size.height;
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
                self.blurView.alpha = 1.0;
                
            }];
            
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
    if ([segue.identifier isEqualToString:@"EventTableVC"]){
        
        EventTableViewController* eventTableVC = segue.destinationViewController;
        eventTableVC.delegate = self;
        
    }
    if ([segue.identifier isEqualToString:@"CreateEventVC"]){

        self.navigationController.navigationBar.hidden = NO;
    }
}

- (IBAction)unwindFromCreateEventVC:(UIStoryboardSegue *)segue sender:(id)sender
{
    //
}

@end

