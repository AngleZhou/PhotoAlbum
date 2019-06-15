//
//  ZQListCell.m
//  PhotoAlbum_Example
//
//  Created by 盛杰厚 on 2019/6/11.
//  Copyright © 2019 ZhouQian. All rights reserved.
//

#import "ZQListCell.h"
#import "ZQAlbumModel.h"
#import "ZQPhotoFetcher.h"

@interface ZQListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;

@property (weak, nonatomic) IBOutlet UILabel *labelName;

@property (weak, nonatomic) IBOutlet UILabel *labelCount;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewSelected;



@end

@implementation ZQListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.imageViewIcon.layer.cornerRadius = 6.0;
    self.imageViewIcon.clipsToBounds = YES;
    self.imageViewSelected.image = _image(@"selected");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(ZQAlbumModel *)model indexPath:(NSIndexPath *)indexPath type:(ZQAlbumType)type{
    _model = model;
    self.labelName.text = model.name;
    self.imageViewSelected.hidden = !model.isSelected;
    NSString *photoType = @"photos";
    if (type == ZQAlbumTypeVideo) {
        photoType = @"videos";
    }
    self.labelCount.text = [NSString stringWithFormat:@"%ld %@",(long)model.count,photoType];
    __weak __typeof(&*self) wSelf = self;
    [ZQPhotoFetcher getAlbumCoverFromAlbum:self.model completion:^(UIImage *cover, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (wSelf.tag == indexPath.row) {
                if (cover) {
                    wSelf.imageViewIcon.image = cover;
                }
            }
        });
        
    }];
}

@end
