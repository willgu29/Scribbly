//
//  TextFieldCreator.h
//  Scribbly
//
//  Created by William Gu on 9/13/15.
//  Copyright (c) 2015 Gu Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TextFieldCreatorDelegate <NSObject>

-(void)newViewSelected:(UIView *)view;
-(void)textFieldBeganEditing:(UIView *)view;
-(void)textFieldDoneEditing:(UIView *)view;

@end

@interface TextFieldCreator : NSObject 

@property (nonatomic, assign) id delegate;
-(UITextField *)createGestureTextField:(NSString *)message atLocation:(CGPoint)location;
-(UIImageView *)createImageView:(UIImage *)image atLocation:(CGPoint)location;
@end
