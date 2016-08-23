//
//  ZQAlbumCell.m
//  PhotoAlbum
//
//  Created by ZhouQian on 16/6/24.
//  Copyright © 2016年 ZhouQian. All rights reserved.
//

#import "ZQAlbumCell.h"
#import "ZQPhotoFetcher.h"
#import "ZQPublic.h"
#import "ZQAlbumNavVC.h"

@interface ZQAlbumCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *ivSelect;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UIView *vVideoMask;

@property (nonatomic, strong) UIButton *vTap;
@end

@implementation ZQAlbumCell


- (void)awakeFromNib {
    self.frame = CGRectMake(0, 0, kAlbumCellWidth, kAlbumCellWidth);
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.masksToBounds = YES;
    
    UIImage *image = _image(@"photo_def_photoPickerVC");
    self.ivSelect.image = image;
    CGFloat vTapWidth = image.size.width*2;
    self.vTap = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-vTapWidth, 0, vTapWidth, vTapWidth)];
    [self.vTap addTarget:self action:@selector(tapppp) forControlEvents:(UIControlEventTouchUpInside)];
    [self.contentView addSubview:self.vTap];
    self.vTap.backgroundColor = [UIColor clearColor];
    
}

- (void)tapppp {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZQAlbumCell:changeSelection:)]) {
        if ([self.delegate ZQAlbumCell:self changeSelection:self.model]) {
            self.bSelected = !_bSelected;
        }
    }
}
- (void)setModel:(ZQPhotoModel *)model {
    _model = model;
    self.bSelected = model.bSelected;
    self.lblDuration.text = [NSString stringWithFormat:@"%02d:%02d", ((int)model.duration)/60, ((int)model.duration)%60];
    self.vVideoMask.hidden = self.model.asset.mediaType == PHAssetMediaTypeImage ? YES : NO;
}

- (void)setBSingleSelection:(BOOL)bSingleSelection {
    _bSingleSelection = bSingleSelection;
    self.ivSelect.hidden = bSingleSelection;
    self.vTap.hidden = bSingleSelection;
}

- (void)setBSelected:(BOOL)bSelected {
    _bSelected = bSelected;
    self.ivSelect.image = bSelected ? _image(@"photo_sel_photoPickerVc") : _image(@"photo_def_photoPickerVC");
    self.model.bSelected = bSelected;
}


- (void)display:(NSIndexPath *)indexPath {
    __weak __typeof(&*self) wSelf = self;
    if (!self.cancelLoad && self.tag == indexPath.row) {
        [ZQPhotoFetcher getPhotoFastWithAssets:self.model.asset photoWidth:kAlbumCellWidth completionHandler:^(UIImage *image, NSDictionary *info) {
            if (!wSelf.cancelLoad && wSelf.tag == indexPath.row) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        wSelf.imageView.image = image;
                    }
                });
            }
        }];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.cancelLoad = YES;
    self.model = nil;
}
@end
