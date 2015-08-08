//
//  DrawViewController.m
//  Scribbly
//
//  Created by William Gu on 8/7/15.
//  Copyright (c) 2015 Gu Studios. All rights reserved.
//

#import "DrawViewController.h"
#import "BezierPathView.h"

@interface DrawViewController ()

@property (nonatomic, strong) BezierPathView *drawView;

@end

@implementation DrawViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self registerOrientationChangeObserver];
}
-(void)viewWillAppear:(BOOL)animated
{

    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = bounds.size.width;
    CGFloat screenHeight = bounds.size.height;
    
    NSLog(@"Screen: %f %f", screenWidth, screenHeight);
    
    BezierPathView *drawView = [[BezierPathView alloc] initWithFrame:CGRectMake(0, 0,screenWidth, screenHeight*2/3)];
    [self.view addSubview:drawView];
}
-(void)viewDidAppear:(BOOL)animated
{
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Orientation Changes
//Detect orientation device changes
-(void)registerOrientationChangeObserver
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
}
-(void)orientationChanged:(NSNotification *)notification
{
    UIDevice * device = notification.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            /* start special animation */
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            /* start special animation */
            break;
            
        default:
            break;
    };
}


@end
