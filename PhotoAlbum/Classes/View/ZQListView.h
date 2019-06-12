//
//  ZQListView.h
//  PhotoAlbum_Example
//
//  Created by 盛杰厚 on 2019/6/11.
//  Copyright © 2019 ZhouQian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Typedefs.h"

NS_ASSUME_NONNULL_BEGIN

@class ZQAlbumModel;

typedef void(^ZQListViewCallBack)(ZQAlbumModel *albumModel,ZQAlbumType type,NSInteger maxImagesCount,BOOL bSingleSelection);
@interface ZQListView : UIView

@property (nonatomic, assign) ZQAlbumType type;

@property (nonatomic, copy) ZQListViewCallBack  listViewCallBack;

- (id)initWithType:(ZQAlbumType)type maxImagesCount:(NSInteger)maxImagesCount bSingleSelection:(BOOL)bSingleSelection;

- (void)show;

@end

NS_ASSUME_NONNULL_END
