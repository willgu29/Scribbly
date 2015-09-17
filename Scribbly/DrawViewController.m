//
//  DrawViewController.m
//  Scribbly
//
//  Created by William Gu on 8/7/15.
//  Copyright (c) 2015 Gu Studios. All rights reserved.
//

@class BackgroundViewController;

#import "Scribbly-Swift.h"

#import "DrawViewController.h"
#import "BezierPathView.h"


#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface DrawViewController () <BackgroundSelectorDelegate>
{
    BOOL textFieldEditing;
    BOOL isControlPanelShowing;
    BOOL isSaved;
    BOOL isDoubleTapped;
    UIView *lastSelectedView;
}

@property (nonatomic, weak) IBOutlet UIView *containerView;

@property (nonatomic, weak) IBOutlet BezierPathView *drawView;
@property (nonatomic, strong) ControlPanelView *cpView;

@property (nonatomic, strong) TextFieldCreator *tfCreator;
@property (nonatomic, strong) ALAssetsLibrary *photoLibrary;
@property (nonatomic, strong) NSMutableArray *textFieldReferences;
@property (nonatomic, strong) NSMutableArray *pictureReferences;


@property (nonatomic, strong) UIButton *lastSelectedColorButton;

@end

@implementation DrawViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    textFieldEditing = NO;
    _containerView.userInteractionEnabled = YES;
    self.containerView.multipleTouchEnabled = YES;
    // Do any additional setup after loading the view.
    _photoLibrary = [[ALAssetsLibrary alloc] init];
    _tfCreator = [[TextFieldCreator alloc] init];
    _tfCreator.delegate = self;
    _textFieldReferences = [[NSMutableArray alloc] init];
    _pictureReferences = [[NSMutableArray alloc] init];
    
    isControlPanelShowing = NO;
    
    [_drawView setupDrawing];
    [self registerOrientationChangeObserver];
    

}
-(void)viewWillAppear:(BOOL)animated
{
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
    
    if (textFieldEditing) {
        if ([lastSelectedView isKindOfClass:[UITextField class]]){
            UITextField *textField = (UITextField *)lastSelectedView;
            textField.textColor = colorSelected;
        }
    }
}

-(IBAction)controlPanel:(UIButton *)sender
{
    //TODO: Animate
    CGRect frame = CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-100, 200, 200);
    _cpView.frame = frame;
    [self.view addSubview:_cpView];
    
    isControlPanelShowing = YES;
}

-(IBAction)addText:(UIButton *)sender
{
    CGPoint textLocation = CGPointMake(20, self.view.frame.size.height/3);
    UITextField *textField = [_tfCreator createGestureTextField:@"Double Tap to Edit" atLocation:textLocation];
//    [self createGestureTextField:@"Double Tap to Edit" atLocation:textLocation];
    
//    textField.delegate= self;
//
    [self.containerView addSubview:textField];
    
    [_textFieldReferences addObject:textField];
    lastSelectedView = textField;
    
    isSaved = NO;
}
-(IBAction)addBackground:(UIButton *)sender
{
    BackgroundViewController *backgroundVC = [[BackgroundViewController alloc] initWithNibName:@"BackgroundViewController" bundle:nil];
    backgroundVC.delegate = self;
    [self presentViewController:backgroundVC animated:YES completion:nil];
}




#pragma mark - TextFieldCreatorDelegate
-(void)newViewSelected:(UIView *)view
{
    lastSelectedView = view;
}
-(void)textFieldBeganEditing:(UIView *)view
{
    lastSelectedView = view;
    textFieldEditing = YES;
}
-(void)textFieldDoneEditing:(UIView *)view
{
    isSaved = NO;
    textFieldEditing = NO;
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
        isSaved = YES;
        
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
    for (int i = 0; i < [_textFieldReferences count]; i++) {
        UITextField *textField = [_textFieldReferences objectAtIndex:i];
        [textField removeFromSuperview];
    }
    for (int i = 0; i < [_pictureReferences count]; i++) {
        UIImageView *imageView = [_pictureReferences objectAtIndex:i];
        [imageView removeFromSuperview];
    }
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

-(void)newBackgroundSelected:(UIColor *)backgroundColor
{
    [_drawView changeBackgroundColor:backgroundColor];
}
-(void)newImageSelected:(ALAsset *)newImage
{
    UIImage *image = [[UIImage alloc] initWithCGImage:[newImage thumbnail]];
    UIImageView *imageView = [_tfCreator createImageView:image atLocation:CGPointMake(10, 10)];
    [self.containerView addSubview:imageView];
    
    [_pictureReferences addObject:imageView];
    
    
}

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
