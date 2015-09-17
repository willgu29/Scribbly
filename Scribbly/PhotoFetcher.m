//
//  PhotoFetcher.m
//  PictureApp
//
//  Created by William Gu on 4/13/15.
//  Copyright (c) 2015 William Gu. All rights reserved.
//

#import "PhotoFetcher.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAsset+Date.h"


@implementation PhotoFetcher

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)getPhotosOnDevice
{
    NSMutableArray *collector = [[NSMutableArray alloc] initWithCapacity:0];
    ALAssetsLibrary *al = [PhotoFetcher defaultAssetsLibrary];
    
    [al enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                      usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         
         [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
          {
              if (asset) {
                  if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                      [collector addObject:asset];
                  }
              }
          }];
         NSArray *mostRecentPictures = [self sortArrayByDate:collector];
         if ([mostRecentPictures count] >=10) //recent 10 max
         {
             NSRange range = NSMakeRange(0, 10);
             mostRecentPictures = [mostRecentPictures subarrayWithRange:range];
         }
         [_delegate fetchPicturesOnDeviceSuccess:mostRecentPictures];
     }
                    failureBlock:^(NSError *error) { NSLog(@"Something went wrong: %@", error);}
     ];
    
}

+(ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

#pragma mark - Helper functions

//Requires ALAsset+Date.h (reference to date)
-(NSArray *)sortArrayByDate:(NSArray *)photoArray
{
    NSArray *sortedArray = [[NSArray alloc] init];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    sortedArray = [photoArray sortedArrayUsingDescriptors:@[sort]];

    
    return sortedArray;

}

@end
