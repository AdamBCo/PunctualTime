//
//  IntroViewController.m
//  PunctualTime
//
//  Created by Adam Cooper on 11/18/14.
//  Copyright (c) 2014 The Timers. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property UIView *stepOneVC;
@property UIView *stepTwoVC;
@property UIView *stepThreeVC;
@property UIView *stepFourVC;

@end

@implementation IntroViewController




- (void)viewDidLoad {

    [super viewDidLoad];

    NSInteger numberOfViews = 10;
    for (int i = 0; i < numberOfViews; i++) {

        //set the origin of the sub view
        CGFloat myOrigin = i * self.view.frame.size.width;

        //create the sub view and allocate memory
        UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(myOrigin, 0, self.view.frame.size.width, self.view.frame.size.height)];
        //set the background to white color
        myView.backgroundColor = [UIColor whiteColor];

        //create a label and add to the sub view
        CGRect myFrame = CGRectMake(10.0f, 10.0f, 200.0f, 25.0f);
        UILabel *myLabel = [[UILabel alloc] initWithFrame:myFrame];
        myLabel.text = [NSString stringWithFormat:@"This is page number %d", i];
        myLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        myLabel.textAlignment =  NSTextAlignmentLeft;
        [myView addSubview:myLabel];

        //create a text field and add to the sub view
        myFrame.origin.y += myFrame.size.height + 10.0f;
        UITextField *myTextField = [[UITextField alloc] initWithFrame:myFrame];
        myTextField.borderStyle = UITextBorderStyleRoundedRect;
        myTextField.placeholder = [NSString stringWithFormat:@"Enter data in field %i", i];
        myTextField.tag = i+1;
        [myView addSubview:myTextField];

        //set the scroll view delegate to self so that we can listen for changes
        self.scrollView.delegate = self;
        //add the subview to the scroll view
        [self.scrollView addSubview:myView];
    }



    self.pageControl.numberOfPages = 10;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width *10, self.scrollView.frame.size.height);

    CGPoint scrollPoint = CGPointMake(self.view.frame.size.width * 2, 0);
    [self.scrollView setContentOffset:scrollPoint animated:YES];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat pageWidth = CGRectGetWidth(self.view.bounds);
    CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = roundf(pageFraction);
    
}


@end
