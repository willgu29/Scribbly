//
//  ALAsset+Date.m
//  WYMSi
//
//  Created by William Gu on 7/6/15.
//  Copyright (c) 2015 William Gu. All rights reserved.
//

#import "ALAsset+Date.h"

@implementation ALAsset (Date)


- (NSDate *) date
{
    return [self valueForProperty:ALAssetPropertyDate];
}

@end
