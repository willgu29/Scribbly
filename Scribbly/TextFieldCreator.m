//
//  TextFieldCreator.m
//  Scribbly
//
//  Created by William Gu on 9/13/15.
//  Copyright (c) 2015 Gu Studios. All rights reserved.
//

#import "TextFieldCreator.h"

@interface TextFieldCreator() <UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    BOOL isDoubleTapped;
}

@end

@implementation TextFieldCreator

const int DEFAULT_FONT_SIZE = 25;

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        isDoubleTapped = NO;
    
    }
    return self;
}

-(UITextField *)createGestureTextField:(NSString *)message atLocation:(CGPoint)location
{
    
    if ([message isEqualToString:@""])
    {
        message = @"Hello";
    }
    UITextField *label = [[UITextField alloc] initWithFrame:CGRectMake(location.x, location.y, 0,0)];
    
    label.delegate = self;
    label.text = message;
    label.textAlignment = NSTextAlignmentCenter;
    label.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentCenter;
    label.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    
    [label setFont:[UIFont fontWithName:@"Academy Engraved LET" size:25]];
    
    label.textColor = [UIColor whiteColor];
    label.userInteractionEnabled = YES;
    label.multipleTouchEnabled = YES;
    label.adjustsFontSizeToFitWidth = YES;
    [label addGestureRecognizer:[self createDoubleTapGesture]];
    [label addGestureRecognizer:[self createPanGesture]];
    [label addGestureRecognizer:[self createRotateGesture]];
    [label addGestureRecognizer:[self createPinchGesture]];
    
    [label sizeToFit];
    //    label.tag = tagCounter;
    //
    //    tagCounter++;
    //    [_textFieldReferences addObject:label];
    
    return label;
    //
    //lastSelectedView = label;
}


#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (isDoubleTapped)
    {
        isDoubleTapped = NO;
        return YES;
    }
    return NO;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"Edit begin");
    [textField becomeFirstResponder];
    [textField selectAll:nil];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    CGPoint centerPoint = textField.center;
    [textField sizeToFit];
    textField.center = centerPoint;
    //isSaved = NO;
    [_delegate textFieldDoneEditing:textField];
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //    [textField endEditing:YES];
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - Gesture Delegates

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
-(void)viewDoubleTapped:(UIGestureRecognizer *)sender
{
    isDoubleTapped = YES;
    UITextField *textField = (UITextField *)[sender view];
    [self performSelector:@selector(textFieldDidBeginEditing:) withObject:sender.view];
    
}

-(void)labelPanned:(UIPanGestureRecognizer *)sender

{
    NSLog(@"Label Panned");
//    lastSelectedView = sender.view;
    [_delegate newViewSelected:sender.view];
    UIViewController *delegateVC = _delegate;
    CGPoint translation = [sender translationInView:delegateVC.view];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x,
                                     sender.view.center.y + translation.y);
    [sender setTranslation:CGPointMake(0, 0) inView:delegateVC.view];
    
    
}
-(void)labelRotated:(UIRotationGestureRecognizer *)sender
{
    NSLog(@"Label Rotated");
    sender.view.transform = CGAffineTransformRotate(sender.view.transform, sender.rotation);
    sender.rotation = 0;
}
-(void)labelPinched:(UIPinchGestureRecognizer *)sender
{
    NSLog(@"Label Pinched");
    sender.view.transform = CGAffineTransformScale(sender.view.transform, sender.scale, sender.scale);
    sender.scale = 1;
    
    //Re-rendering text for better qualitty
    //    CGFloat scale = sender.scale;
    //    UILabel *label = (UILabel *)sender.view;
    //    CGFloat fontSize = label.font.pointSize;
    //    label.font = [UIFont systemFontOfSize:fontSize*scale];
    //    label.frame = [self getTextDimensions:label.text withFontSize:fontSize*scale];
}





#pragma mark - Create Gestures
-(UITapGestureRecognizer *)createDoubleTapGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDoubleTapped:)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 2;
    return tapGesture;
}
-(UIPanGestureRecognizer *)createPanGesture
{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(labelPanned:)];
    panGestureRecognizer.delegate = self;
    panGestureRecognizer.minimumNumberOfTouches = 1;
    return panGestureRecognizer;
}
-(UIRotationGestureRecognizer *)createRotateGesture
{
    UIRotationGestureRecognizer *rotateGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(labelRotated:)];
    rotateGestureRecognizer.delegate = self;
    return rotateGestureRecognizer;
}
-(UIPinchGestureRecognizer *)createPinchGesture
{
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(labelPinched:)];
    pinchGestureRecognizer.delegate = self;
    return pinchGestureRecognizer;
}

@end
