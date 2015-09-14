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
@interface DrawViewController ()
{
    BOOL isControlPanelShowing;
}

@property (nonatomic, strong) IBOutlet BezierPathView *drawView;
@property (nonatomic, strong) ControlPanelView *cpView;

@property (nonatomic, strong) UIButton *lastSelectedColorButton;

@end

@implementation DrawViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isControlPanelShowing = NO;
    
   
//
//    [_drawView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//
//    
//    _drawView.translatesAutoresizingMaskIntoConstraints = NO;
//    self.view.translatesAutoresizingMaskIntoConstraints = NO;
//    
    [self registerOrientationChangeObserver];

}
-(void)viewWillAppear:(BOOL)animated
{
    [_drawView setupDrawing];
    
    //INIT cpView
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ControlPanelView" owner:self options:nil];
    _cpView = [nib objectAtIndex:0];

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
        [_cpView removeFromSuperview];
        isControlPanelShowing = NO;
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

#pragma mark - Create View Objects
-(void)createColorButtons
{
    NSArray *colorArray = @[[UIColor whiteColor],[UIColor redColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor greenColor], [UIColor blueColor], [UIColor purpleColor], [UIColor blackColor]];
    
    NSMutableArray *buttonArray = [[NSMutableArray alloc] init];
    for (UIColor *color in colorArray) {
      
        
        UIButton *newButton = [[UIButton alloc] init];
        newButton.translatesAutoresizingMaskIntoConstraints = NO;
        newButton.backgroundColor = color;
    
        if ([color isEqual:[UIColor whiteColor]]) {
            _lastSelectedColorButton = newButton;
        }
        
        [buttonArray addObject:newButton];
    }

    
    
}

#pragma mark - Constraints 

-(void)addDrawViewConstraints
{
    NSLayoutConstraint *equalWidth = [NSLayoutConstraint constraintWithItem:_drawView attribute:NSLayoutAttributeWidth relatedBy:0 toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:_drawView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0f
                               constant:0.f];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:_drawView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f];
    
    
    NSLayoutConstraint *height =[NSLayoutConstraint
                                 constraintWithItem:_drawView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:0
                                 toItem:self.view
                                 attribute:NSLayoutAttributeHeight
                                 multiplier:0.66
                                 constant:0];
    

    [self.view addConstraint:equalWidth];
    [self.view addConstraint:top];
    [self.view addConstraint:leading];
    [self.view addConstraint:height];
    
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
    [_cpView removeFromSuperview];
   
    
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
