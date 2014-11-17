
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

@property BOOL animating;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    UIView *test = [[UIView alloc] initWithFrame:self.view.bounds];
//    test.backgroundColor = [UIColor purpleColor];
//
//    [self.view addSubview:test];
//
//
//    UIBezierPath *myClippingPath = [UIBezierPath bezierPath];
//    [myClippingPath moveToPoint:CGPointMake(100, 100)];
//    [myClippingPath addCurveToPoint:CGPointMake(200, 200) controlPoint1:CGPointMake(self.view.frame.size.width, 0) controlPoint2:CGPointMake(self.self.view.frame.size.width, 50)];
//    [myClippingPath closePath];
//
//    CAShapeLayer *mask = [CAShapeLayer layer];
//    mask.path = myClippingPath.CGPath;
//
//    self.view.layer.mask = mask;



    self.sharedEventManager = [EventManager sharedEventManager];
    self.selectedEvent = self.sharedEventManager.events.firstObject;

    NSLog(@"Seconds: %@",self.selectedEvent.lastLeaveTime);

    [[NSNotificationCenter defaultCenter] addObserverForName:EVENTS_UPDATED
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.selectedEvent = self.sharedEventManager.events.firstObject;
                                                  }];

    self.eventNameLabel.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 100);
    self.timeTillEvent.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height + 100);

    self.animationShapeView = [[UIView alloc]initWithFrame:CGRectMake(0 ,self.view.bounds.size.height/6, self.view.bounds.size.width, self.view.bounds.size.width)];

    self.navigationItem.title = @"Cancel"; // For the back button on CreateEventVC

    // Remove shadow on transparent toolbar:

    [self.addButtonToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.addButtonToolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];


    [UIView animateWithDuration:3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.03 options:UIViewAnimationOptionAllowUserInteraction animations:^{

        self.eventNameLabel.center = CGPointMake(self.view.frame.size.width/2, 300);

        self.timeTillEvent.center = self.view.center;

    } completion:^(BOOL finished) {

    }];

//    //Circle Drawing
//
//    int radius = 120;
//
//    CAShapeLayer *circle = [CAShapeLayer layer];
//    circle.position = CGPointMake(self.view.frame.size.width, self.view.frame.size.height);
//    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius-20, 2.0*radius-20)
//                                             cornerRadius:radius].CGPath;
//    circle.fillColor = [UIColor blueColor].CGColor;
//    circle.strokeColor = [UIColor whiteColor].CGColor;
//    circle.lineWidth = 5;
//
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

    //Sun
    int radius = self.view.frame.size.width*.23;
    CAShapeLayer *sun = [CAShapeLayer new];
    sun.position = CGPointMake(self.view.frame.size.width*.28, self.view.frame.size.height*.28);
    sun.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                             cornerRadius:radius].CGPath;
    sun.fillColor = [UIColor greenColor].CGColor;
    sun.strokeColor = [UIColor whiteColor].CGColor;
    sun.lineWidth = 5;

    //Ground
    CAShapeLayer *ground = [CAShapeLayer new];
    CGMutablePathRef background = CGPathCreateMutable();
    CGPathMoveToPoint(background, nil, 0, self.view.bounds.size.height*.80);
    CGPathAddLineToPoint(background, nil, self.view.bounds.size.width, self.view.bounds.size.height*.80);
    CGPathRetain(background);
    ground.path = [UIBezierPath bezierPathWithCGPath:background].CGPath;
    ground.strokeColor = [UIColor whiteColor].CGColor;
    ground.lineWidth = 5;

    //SKY
    CAShapeLayer *sky = [CAShapeLayer new];
    CGMutablePathRef skyPath = CGPathCreateMutable();
    CGPathMoveToPoint(skyPath, nil, 0, self.view.bounds.size.height*.25);

    CGPathAddCurveToPoint(skyPath, nil, self.view.bounds.size.width*.5, self.view.bounds.size.height*.2, self.view.bounds.size.width*.5, self.view.bounds.size.height*.3, self.view.bounds.size.width, self.view.bounds.size.height*.3);
    sky.path = [UIBezierPath bezierPathWithCGPath:skyPath].CGPath;
    sky.strokeColor = [UIColor whiteColor].CGColor;
    sky.fillColor = [UIColor clearColor].CGColor;
    sky.lineWidth = 2;

    //SkyTwo
    CAShapeLayer *skyTwo = [CAShapeLayer new];
    CGMutablePathRef skyPathTwo = CGPathCreateMutable();
    CGPathMoveToPoint(skyPathTwo, nil, 0, self.view.bounds.size.height*.45);

    CGPathAddCurveToPoint(skyPathTwo, nil, self.view.bounds.size.width*.5, self.view.bounds.size.height*.4, self.view.bounds.size.width*.5, self.view.bounds.size.height*.5, self.view.bounds.size.width, self.view.bounds.size.height*.5);
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
    CGPathMoveToPoint(chicago, nil, 0, self.view.bounds.size.height*.65);//Starting Point
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.05, self.view.bounds.size.height*.65);//Building One
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.06, self.view.bounds.size.height*.64);
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.06, self.view.bounds.size.height*.62);//Arc Begin
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.07, self.view.bounds.size.height*.60);//Arch End
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.17, self.view.bounds.size.height*.60);//Top of Building One
//
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.18, self.view.bounds.size.height*.62);
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.18, self.view.bounds.size.height*.65);
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.20, self.view.bounds.size.height*.65);
//
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height *.65);
//
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height*.60); //Building Two
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.40, self.view.bounds.size.height*.60);
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.40, self.view.bounds.size.height*.80);
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.45, self.view.bounds.size.height*.80);//Space

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


//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.17, self.view.bounds.size.height*.75);
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.17, self.view.bounds.size.height*.60);
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height*.55);//Point
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height*.60);//Slit
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height*.55);//Point
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.32, self.view.bounds.size.height*.60);//Corner
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height*.64);//Bottom of Diamond
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.17, self.view.bounds.size.height*.60);
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height*.64);//Bottom of Diamond
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.32, self.view.bounds.size.height*.60);
//    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.32, self.view.bounds.size.height*.80);




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

    //    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.17, self.view.bounds.size.height*.75);
    //    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.17, self.view.bounds.size.height*.60);
    //    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height*.55);//Point
    //    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height*.60);//Slit
    //    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height*.55);//Point
    //    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.32, self.view.bounds.size.height*.60);//Corner
    //    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height*.64);//Bottom of Diamond
    //    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.17, self.view.bounds.size.height*.60);
    //    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.25, self.view.bounds.size.height*.64);//Bottom of Diamond
    //    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.32, self.view.bounds.size.height*.60);
    //    CGPathAddLineToPoint(chicago, nil, self.view.bounds.size.width*.32, self.view.bounds.size.height*.80);

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
    buildings.fillColor = [UIColor clearColor].CGColor;
    buildings.lineWidth = 2;



    // Configure animation

    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = 2.0; // "animate over 10 seconds or so.."
    drawAnimation.repeatCount         = 1.0;  // Animate only once..
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [sun addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
//    [star addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    [ground addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    [buildings addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    [sky addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    [skyTwo addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    [birdOne addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    [birdTwo addAnimation:drawAnimation forKey:@"drawCircleAnimation"];


    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 10;
    rotationAnimation.repeatCount = INFINITY;
//    [sun addAnimation:rotationAnimation forKey:@"rotationAnimation"];

    //Add layers to Animation View

//    [self.animationShapeView.layer addSublayer:star];
    [self.view.layer addSublayer:sky];
    [self.view.layer addSublayer:skyTwo];
    [self.view.layer addSublayer:ground];
    [self.view.layer addSublayer:sun];
    [self.view.layer addSublayer:birdOne];
    [self.view.layer addSublayer:birdTwo];
    [self.view.layer addSublayer:buildings];
    [self.view insertSubview:self.animationShapeView aboveSubview:self.containerView];
//    [self runSpinAnimationOnView:self.animationShapeView duration:3 rotations:1 repeat:1];

}

- (void)runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat
{

    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;

    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];

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

