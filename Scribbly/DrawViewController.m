//
//  DrawViewController.m
//  Scribbly
//
//  Created by William Gu on 8/7/15.
//  Copyright (c) 2015 Gu Studios. All rights reserved.
//

#import "DrawViewController.h"
#import "BezierPathView.h"
#import "ControlPanelView.h"

#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface DrawViewController () <ControlPanelViewDelegate>
{
    BOOL isControlPanelShowing;
}

@property (nonatomic, strong) IBOutlet BezierPathView *drawView;
@property (nonatomic, strong) ControlPanelView *cpView;

@property (nonatomic, strong) ALAssetsLibrary *photoLibrary;


@property (nonatomic, strong) UIButton *lastSelectedColorButton;

@end

@implementation DrawViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _photoLibrary = [[ALAssetsLibrary alloc] init];

    isControlPanelShowing = NO;
    
   
    [self registerOrientationChangeObserver];

}
-(void)viewWillAppear:(BOOL)animated
{
    [_drawView setupDrawing];
    
    //INIT cpView
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ControlPanelView" owner:self options:nil];
    _cpView = [nib objectAtIndex:0];
    _cpView.delegate = self;

}
-(void)viewDidAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isControlPanelShowing)
    {
        [self closeControlPanel];
    }
}

#pragma mark - IBActions
-(IBAction)colorButtonSelected:(UIButton *)sender
{
    UIColor *colorSelected = sender.backgroundColor;
    
    if ([colorSelected isEqual:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]]) {
        sender.layer.borderColor = [UIColor whiteColor].CGColor;
    } else {
        sender.layer.borderColor = [UIColor blackColor].CGColor;
    }
    
    sender.layer.borderWidth = 2;
    _lastSelectedColorButton.layer.borderWidth = 0;
    _lastSelectedColorButton = sender;
    [_drawView setPathColor:colorSelected];
}

-(IBAction)controlPanel:(UIButton *)sender
{
    //TODO: Animate
    CGRect frame = CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-100, 200, 200);
    _cpView.frame = frame;
    [self.view addSubview:_cpView];
    
    isControlPanelShowing = YES;
}

#pragma mark - ControlPanelDelegate

-(void)savePicture
{
    [self closeControlPanel];
    
    UIImage *collageImage = [self formNewUIImage];
    [self.photoLibrary saveImage:collageImage toAlbum:@"Scribbly" completion:^(NSURL *assetURL, NSError *error) {
        NSLog(@"Asset URL: %@", assetURL);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your photo has been saved in both your Scribbly album \nand camera roll!" delegate:nil cancelButtonTitle:@"Great!" otherButtonTitles:nil];
        [alertView show];
        //_isSaved = YES;
        
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hmmm..." message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alertView show];
    }];
}
-(void)clearPicture
{
    [self closeControlPanel];
    [_drawView eraseDrawing:nil];
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
    //Reorient control panel
    [self closeControlPanel];
   
    
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

#pragma mark - Helper functions
-(UIImage *)formNewUIImage
{
    
    
    CGSize displayBounds = self.drawView.bounds.size;
    UIImage *myImage;

    UIGraphicsBeginImageContextWithOptions(displayBounds, NO, 0);
    [self.drawView.layer renderInContext:UIGraphicsGetCurrentContext()];

    myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return myImage;
}

-(void)closeControlPanel
{
    [_cpView removeFromSuperview];
    isControlPanelShowing = NO;
}

@end
