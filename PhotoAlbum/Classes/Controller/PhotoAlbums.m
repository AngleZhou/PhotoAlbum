//
//  PhotoAlbums.m
//  Tripinsiders
//
//  Created by ZhouQian on 16/7/28.
//  Copyright © 2016年 Tripinsiders. All rights reserved.
//

#import "PhotoAlbums.h"
#import "CTAlbumNavVC.h"
#import <Photos/Photos.h>
#import "CTPhotoFetcher.h"

@implementation PhotoAlbums

//video
+ (void)photoVideoWithMaxDurtion:(NSTimeInterval)duration
                        Delegate:(id)delegate
      updateUIFinishPickingBlock:(void (^)(UIImage *cover))uiUpdateBlock
     didFinishPickingVideoHandle:(void (^ )(NSURL *url, UIImage *cover, id avAsset))didFinishPickingVideoHandle {
    void (^block)(void) = ^{
        CTAlbumNavVC *navVc = [[CTAlbumNavVC alloc] initWithMaxImagesCount:1 type:CTAlbumTypeVideo bSingleSelect:YES];
        navVc.albumDelegate = delegate;
        navVc.maxVideoDurationInSeconds = duration;
        navVc.updateUIFinishVideoPicking = uiUpdateBlock;
        navVc.didFinishPickingVideoHandle = didFinishPickingVideoHandle;
        [[CTTools rootViewController] presentViewController:navVc animated:YES completion:nil];
    };
    
    [PhotoAlbums photoWithBlock:block];
}


//multi-select
+ (void)photoMultiSelectWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id)delegate didFinishPhotoBlock:(void (^)(NSArray<UIImage*> *photos))finishBlock {
    [PhotoAlbums photoWithMaxImagesCount:maxImagesCount type:CTAlbumTypePhoto bSingleSelect:NO crop:NO delegate:delegate didFinishPhotoBlock:[finishBlock copy]];
}

//single select
+ (void)photoSingleSelectWithCrop:(BOOL)crop delegate:(id)delegate didFinishPhotoBlock:(void (^)(NSArray<UIImage*> *photos))finishBlock {
    [PhotoAlbums photoWithMaxImagesCount:1 type:CTAlbumTypePhoto bSingleSelect:YES crop:crop delegate:delegate didFinishPhotoBlock:[finishBlock copy]];
}


+ (void)photoWithMaxImagesCount:(NSInteger)maxImagesCount type:(CTAlbumType)type bSingleSelect:(BOOL)bSingleSelect crop:(BOOL)bEnableCrop delegate:(id)delegate didFinishPhotoBlock:(void (^)(NSArray<UIImage*> *photos))finishBlock {
    
    void (^block)(void) = ^{
        CTAlbumNavVC *navVc = [[CTAlbumNavVC alloc] initWithMaxImagesCount:maxImagesCount type:type bSingleSelect:bSingleSelect];
        navVc.albumDelegate = delegate;
        navVc.bEnableCrop = bEnableCrop;
        navVc.didFinishPickingPhotosHandle = finishBlock;
        [[CTTools rootViewController] presentViewController:navVc animated:YES completion:nil];
    };
    
    [PhotoAlbums photoWithBlock:block];
}


+ (void)photoWithBlock:(void(^)(void))block {
    if (![CTPhotoFetcher authorizationStatusAuthorized]) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status != PHAuthorizationStatusAuthorized) {
                    [PhotoAlbums alertAction];
                }
                else {
                    block();
                }
            });
        }];
    }
    else {
        block();
    }
}

+ (void)alertAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:_MultiLanguageFunc(@"TRIP_PHOTO_OPERATE_PRIVACY") preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:_MultiLanguageFunc(@"__key cancel") style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *set = [UIAlertAction actionWithTitle:_MultiLanguageFunc(@"__key 设置") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        //go to setting page
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alert addAction:cancel];
    [alert addAction:set];
    [[CTTools rootViewController] presentViewController:alert animated:YES completion:NULL];
}
@end
