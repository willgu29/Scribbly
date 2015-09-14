//
//  ControlPanelView.m
//  Scribbly
//
//  Created by William Gu on 9/13/15.
//  Copyright (c) 2015 Gu Studios. All rights reserved.
//

#import "ControlPanelView.h"

@implementation ControlPanelView

-(void)awakeFromNib
{
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.cornerRadius = 20;
    self.layer.borderWidth = 3.0f;
    self.layer.shadowOffset = CGSizeMake(3, 3);
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
      
    
    }
    return self;
}

-(IBAction)savePicture:(id)sender
{
    [_delegate savePicture];
}

-(IBAction)clearPicture:(id)sender
{
    [_delegate clearPicture];
}

@end
