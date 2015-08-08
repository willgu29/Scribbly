//
//  ColorPickerView.m
//  Scribbly
//
//  Created by William Gu on 8/8/15.
//  Copyright (c) 2015 Gu Studios. All rights reserved.
//

#import "ColorPickerView.h"

@interface ColorPickerView()

@property (nonatomic, strong) UIButton *lastSelectedColorButton;

@end

@implementation ColorPickerView



-(void)createColorButtons{
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

@end
