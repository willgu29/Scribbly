//
//  PhotoFetcher.h
//  PictureApp
//
//  Created by William Gu on 4/13/15.
//  Copyright (c) 2015 William Gu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PhotoFetcherDelegate <NSObject>

-(void)fetchPicturesOnDeviceSuccess:(NSArray *)photos;

@end

@interface PhotoFetcher : NSObject

@property (nonatomic, assign) id delegate;
-(void)getPhotosOnDevice; //Only collects photos taken (i.e. photos uploaded onto phone don't count)
+ (instancetype)sharedInstance;  //Do not alloc/init. Use this
@end
