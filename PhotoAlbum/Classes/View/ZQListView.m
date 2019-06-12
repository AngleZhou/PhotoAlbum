//
//  ZQListView.m
//  PhotoAlbum_Example
//
//  Created by 盛杰厚 on 2019/6/11.
//  Copyright © 2019 ZhouQian. All rights reserved.
//

#import "ZQListView.h"
#import "ZQAlbumListCell.h"
#import "ZQPhotoFetcher.h"
#import "ZQListCell.h"
#import "ZQAlbumVC.h"
#import "ZQAlbumNavVC.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "ZQAlbumModel.h"
#import "ZQPublic.h"
#import "NSString+Size.h"
#import "ViewUtils.h"

#define screenWidth  [UIScreen mainScreen].bounds.size.width
#define screenHeight  [UIScreen mainScreen].bounds.size.height
#define IS_IPHONE_X [[UIApplication sharedApplication] statusBarFrame].size.height>20
#define iPhoneX_BOTTOM_HEIGHT (IS_IPHONE_X ? 34 : 0)
#define HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height>20?[UIScreen mainScreen].bounds.size.height-34:[UIScreen mainScreen].bounds.size.height)
#define kSCRATIO(x)   ceil(((x) * ([UIScreen mainScreen].bounds.size.width / 375)))
#define kStatusBarHeight (IS_IPHONE_X ? 44 : 20)

static NSString *const identifier = @"ZQListCell";

@interface ZQListView ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIView *ivAlpha;

@property (weak, nonatomic) IBOutlet UIView *viewMark;

@property (nonatomic, strong) NSArray *arrData;


@end

@implementation ZQListView{
    NSInteger _maxImagesCount;
    BOOL _bSingleSelection;
    ZQAlbumModel *seletedModel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithType:(ZQAlbumType)type maxImagesCount:(NSInteger)maxImagesCount bSingleSelection:(BOOL)bSingleSelection{
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ZQListView class]) owner:nil options:nil] firstObject];
    self.type  = type;
    _maxImagesCount = maxImagesCount;
    _bSingleSelection = bSingleSelection;
     [self loadAllAlbums];
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.ivAlpha = [[UIView alloc] init];
    self.ivAlpha.backgroundColor = [UIColor clearColor];
    self.viewMark.layer.cornerRadius = 2.5;
    self.viewMark.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ZQListCell class]) bundle:nil] forCellReuseIdentifier:identifier];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [self addGestureRecognizer:pan];
   
}

- (void)loadAllAlbums {
    NSArray<ZQAlbumModel *> *albums = [ZQPhotoFetcher getAllAlbumsWithType:self.type];
    self.arrData = albums;
    if (albums.count == 0) {
        [self noPhoto];
    }
    
//    if (self.dataLoaded) {
//        self.dataLoaded(albums);
//    }
    [self.tableView reloadData];
    
}

- (void)noPhoto {
    UILabel *lblNoPhoto = [[UILabel alloc] init];
    lblNoPhoto.textColor = [UIColor colorWithWhite:0.8 alpha:1];
    lblNoPhoto.font = [UIFont systemFontOfSize:17];
    lblNoPhoto.text = _LocalizedString(@"NO_PHOTOS");
    lblNoPhoto.textAlignment = NSTextAlignmentCenter;
    lblNoPhoto.numberOfLines = 0;
    lblNoPhoto.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [lblNoPhoto.text textSizeWithFont:lblNoPhoto.font constrainedToSize:CGSizeMake(kTPScreenWidth-2*ZQSide_X, 999) lineBreakMode:NSLineBreakByWordWrapping];
    lblNoPhoto.size = size;
    [self.tableView addSubview:lblNoPhoto];
    
    lblNoPhoto.frame = CGRectMake((kTPScreenWidth-size.width)/2, (kTPScreenHeight-size.height)/2, size.width, size.height);
    
}

#pragma mark -  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZQListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.row < self.arrData.count) {
        [cell setModel:self.arrData[indexPath.row] indexPath:indexPath];
        cell.tag = indexPath.row;
    }
    return cell;
}

#pragma mark -  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 84;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZQAlbumModel *model = self.arrData[indexPath.row];
    if (seletedModel) {
        seletedModel.isSelected = NO;
    }
    model.isSelected = YES;
    seletedModel = model;
    [self.tableView reloadData];
    [self hiddenAnimation];
    ZQAlbumType type =  [model.name isEqualToString:_LocalizedString(@"Videos")] ? ZQAlbumTypeVideo : ZQAlbumTypePhoto;
    if (self.listViewCallBack) {
        self.listViewCallBack(model, type,_maxImagesCount, _bSingleSelection);
    }
//    if (self.seletedCircleCallBack) {
//        CircleModel *model = self.arrData[indexPath.row];
//        self.seletedCircleCallBack(model);
//    }
    
}

- (void)move:(UIPanGestureRecognizer *)pan{
    CGPoint offSet = [pan translationInView:pan.view];
    if (offSet.y > 0) {
        CGRect fra = self.frame;
        CGFloat originY = fra.origin.y;
        originY = originY + offSet.y;
        fra.origin.y = originY;
        self.frame = fra;
    }
    [pan setTranslation:CGPointZero inView:pan.view];
    if (pan.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [pan velocityInView:pan.view];
        if (self.frame.origin.y > 60 || velocity.y > 10) {
            [self hiddenAnimation];
        }
    }
    
}

- (void)show{
    if (self.superview) {
        self.hidden = NO;
        self.ivAlpha.hidden = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                self.ivAlpha.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
                self.frame = CGRectMake(0, kStatusBarHeight, screenWidth,screenHeight - kStatusBarHeight);
            }];
        });
        return;
    }
    UIWindow *wd  = [UIApplication sharedApplication].keyWindow;
    self.ivAlpha.frame = wd.bounds;
    [wd addSubview:self.ivAlpha];
    
    self.frame = CGRectMake(0, screenHeight, screenWidth,screenHeight - kStatusBarHeight);
    [wd addSubview:self];
    
    UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerTopRight;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(18, 18)];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:bezierPath.CGPath];
    self.layer.mask = shape;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            self.ivAlpha.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
             self.frame = CGRectMake(0, kStatusBarHeight, screenWidth,screenHeight - kStatusBarHeight);
        }];
    });
    
}

- (void)hiddenAnimation{
    [UIView animateWithDuration:0.25 animations:^{
        self.ivAlpha.backgroundColor = [UIColor clearColor];
         self.frame = CGRectMake(0, screenHeight, screenWidth,screenHeight - kStatusBarHeight);
    } completion:^(BOOL finished) {
        self.ivAlpha.hidden = YES;
        self.hidden = YES;
//        [self.ivAlpha removeFromSuperview];
//        [self removeFromSuperview];
    }];
}


@end
