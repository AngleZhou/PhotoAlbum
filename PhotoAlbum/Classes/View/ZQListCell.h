//
//  ZQListCell.h
//  PhotoAlbum_Example
//
//  Created by 盛杰厚 on 2019/6/11.
//  Copyright © 2019 ZhouQian. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZQAlbumModel;

@interface ZQListCell : UITableViewCell

@property (nonatomic, strong) ZQAlbumModel *model;


- (void)setModel:(ZQAlbumModel *)model indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
