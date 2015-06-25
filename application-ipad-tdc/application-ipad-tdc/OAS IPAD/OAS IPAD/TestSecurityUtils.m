//
//  TestSecurityUtils.m
//  OAS IPAD
//
//  Created by mcgrawhill ctb on 3/13/13.
//  Copyright (c) 2013 mcgrawhill ctb. All rights reserved.
//

#import "TestSecurityUtils.h"

@implementation TestSecurityUtils
static int oldPhotoCount=-1;
static bool screenshotTaken=false;


+ (BOOL)WasScreenshotTaken
{
    return screenshotTaken;
}

+ (void)updatePhotoCount
{
    
    
    NSMutableArray *albums = [[NSMutableArray alloc] init]; // Prepare array to have retrieved assetgroups by Assets Library.
    
    //NSMutableArray *assets = [[NSMutableArray alloc] init]; // Prepare array to have retrieved images by Assets Library.
    
    /*
     //Block to enumerate assets in asset group (Called from assetGroupEnumerator)
     void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
     if(asset != NULL) {
     [assets addObject:asset];
     //NSLog(@"Asset found");
     
     }
     };
     */
    
    //Block to enumerate assets in asset library
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
        int photoCount=0;
        if(group != nil) {
            [albums addObject:group];
            //[group enumerateAssetsUsingBlock:assetEnumerator];
            NSLog(@"Number of assets in group: %d",[group numberOfAssets]);
            
        }
        else
        {
            for (ALAssetsGroup *album in albums) {
                photoCount+=[album numberOfAssets];
            }
            NSLog(@"Old Photo count %d",oldPhotoCount);
            NSLog(@"New Photo count %d",photoCount);
            
            if (oldPhotoCount>=0) {
                
                if (photoCount>oldPhotoCount) {
                    screenshotTaken=true;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ScreenshotTakenNotification" object:self];
                    //NSLog(@"screenshot taken");
                }
            }
            oldPhotoCount=photoCount;
            //screenshotTaken=true;
            
            
        }
    };
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetTypePhoto usingBlock:assetGroupEnumerator failureBlock:^(NSError *error) {NSLog(@"Problem reading asset groups");}];
    
    //NSLog(@"Returned Photo count %d",photoCount);
    
}
@end
