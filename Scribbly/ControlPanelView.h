//
//  ControlPanelView.h
//  Scribbly
//
//  Created by William Gu on 9/13/15.
//  Copyright (c) 2015 Gu Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ControlPanelViewDelegate <NSObject>

-(void)savePicture;
-(void)clearPicture;

@end

@interface ControlPanelView : UIView

@property (nonatomic, assign) id delegate;


@end
