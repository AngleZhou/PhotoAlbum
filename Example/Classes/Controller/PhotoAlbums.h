//
//  PhotoAlbums.h
//  Tripinsiders
//
//  Created by ZhouQian on 16/7/28.
//  Copyright © 2016年 Tripinsiders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Typedefs.h"

@protocol PhotoAlbumsDelegate <NSObject>

@optional
//返回自定义的超过最大可选张数的提示信息
- (NSString*)photoAlbumsExceedMaxImageCountMessage:(NSInteger)maxImageCount;

@end


@interface PhotoAlbums : NSObject

+ (void)photoWithMaxImagesCount:(NSInteger)maxImagesCount type:(ZQAlbumType)type bSingleSelect:(BOOL)bSingleSelect crop:(BOOL)bEnableCrop delegate:(id)delegate didFinishPhotoBlock:(void (^)(NSArray<UIImage*> *photos))finishBlock;


//single select
+ (void)photoSingleSelectWithCrop:(BOOL)crop delegate:(id)delegate didFinishPhotoBlock:(void (^)(NSArray<UIImage*> *photos))finishBlock;

//multi-select
+ (void)photoMultiSelectWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id)delegate didFinishPhotoBlock:(void (^)(NSArray<UIImage*> *photos))finishBlock;



//video
+ (void)photoVideoWithMaxDurtion:(NSTimeInterval)duration
                        Delegate:(id)delegate
      updateUIFinishPickingBlock:(void (^)(UIImage *cover))uiUpdateBlock
     didFinishPickingVideoHandle:(void (^ )(NSURL *url, UIImage *cover, id avAsset))didFinishPickingVideoHandle;
@end
