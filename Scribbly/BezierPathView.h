//
//  BezierPathView.h
//  PictureApp
//
//  Created by William Gu on 6/15/15.
//  Copyright (c) 2015 William Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BezierPathView : UIView <UIGestureRecognizerDelegate>


- (void)eraseDrawing:(UITapGestureRecognizer *)t;
-(UIImage *)getDrawnImage;
-(NSMutableArray *)getFullPath;
-(CGMutablePathRef)getReferencePath;

-(void)setPathColor:(UIColor *)color;
-(void)setupDrawing;

@end
