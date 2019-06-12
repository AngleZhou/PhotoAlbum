//
//  ZQAlbumVC.m
//  PhotoAlbum
//
//  Created by ZhouQian on 16/5/29.
//  Copyright © 2016年 ZhouQian. All rights reserved.
//

#import "ZQAlbumVC.h"
#import "ZQAlbumModel.h"
#import "ZQAlbumCell.h"
#import "ZQPhotoFetcher.h"
#import "ZQPhotoModel.h"
#import "ZQBottomToolbarView.h"
#import "ZQPhotoPreviewVC.h"
#import "ZQVideoPlayVC.h"
#import "Typedefs.h"
#import "ZQTools.h"
#import "ZQPublic.h"
#import "NSString+Size.h"
#import "ZQAlbumNavVC.h"
#import "ZQListView.h"
#import "ProgressHUD.h"

static CGFloat kButtomBarHeight = 48;

@interface ZQAlbumVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ZQAlbumCellDelegate, ZQPhotoPreviewVCDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ZQBottomToolbarView *tbButtom;

@property (nonatomic, strong) NSMutableArray<ZQPhotoModel *> *selected;
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *selectedIdx;//selection changed cell
@property (nonatomic, strong) NSArray<PHAsset *> *assets;
@property (nonatomic, strong) NSArray<ZQPhotoModel *> *models;

//for scrollView
@property (nonatomic, assign) CGPoint lastOffset;
@property (nonatomic, assign) NSTimeInterval lastOffsetCapture;
@property (nonatomic, assign) BOOL isScrollingFast;

@property (nonatomic, strong) NSCache *cacheThumb;
@property (nonatomic, strong) NSCache *cache;

@property (nonatomic, strong) ZQListView *listView;

@property (nonatomic, strong) UILabel *labelTitle;

@property (nonatomic, strong) UIView *viewTitle;
@property (nonatomic, strong) UIImageView *imageViewDown;

@end
@implementation ZQAlbumVC{
    UIButton* btnRight;
    ZQAlbumModel *priSeleted;
}


#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self loadData];
    
    [self scrollToBottom];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    [self p_loadVisibleCellImage];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.cache removeAllObjects];
    [self.cacheThumb removeAllObjects];
}

- (void)scrollToBottom {
    if (self.models.count >= 1) {
        NSIndexPath *idxPath = [NSIndexPath indexPathForItem:self.models.count-1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:idxPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    
    CGFloat contentHeight = ((CGRectGetWidth(self.view.frame)-3)/4+2)*(self.models.count+3)/4;
    CGFloat frameHeightWithoutInset = self.collectionView.frame.size.height - (self.collectionView.contentInset.top+self.collectionView.contentInset.bottom);
    if (contentHeight > frameHeightWithoutInset) {
        [self.collectionView setContentOffset:CGPointMake(0, contentHeight-self.collectionView.frame.size.height) animated:NO];
    }
}

- (void)initUI {
//    self.navigationItem.title = self.mAlbum.name;
    
    _viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 81, 44)];
    UIButton *btn = [[UIButton alloc] init];
    btn.frame = _viewTitle.bounds;
    [btn addTarget:self action:@selector(showList) forControlEvents:UIControlEventTouchUpInside];
    [_viewTitle addSubview:btn];
    _labelTitle = [[UILabel alloc] init];
    _labelTitle.textColor = [UIColor darkTextColor];
    _labelTitle.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    _labelTitle.frame = CGRectMake(0, 10, 70, 24);
    _labelTitle.text = @"所有照片";
    [_viewTitle addSubview:_labelTitle];
    _imageViewDown = [[UIImageView alloc] initWithFrame:CGRectMake(74, 17, 10, 10)];
    _imageViewDown.image = _image(@"down");
    [_viewTitle addSubview:_imageViewDown];
    self.navigationItem.titleView = _viewTitle;
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton* btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btnLeft addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    //[ZQTools image:_image(@"close") withTintColor:ZQChoosePhotoNavBtnColor]
    [btnLeft setImage:_image(@"close") forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    
    NSString* title =  @"确定" ;//_LocalizedString(@"OPERATION_CANCEL");
    CGSize s = [title textSizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(999, 999) lineBreakMode:NSLineBreakByWordWrapping];
    btnRight = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, s.width+32, 30)];
    btnRight.backgroundColor = [UIColor colorWithRed:251 / 255.0 green:225 / 255.0 blue:89 / 255.0 alpha:1.0];
    btnRight.layer.cornerRadius = 15.0;
    [btnRight setTitleColor:ZQChoosePhotoNavBtnColor forState:UIControlStateNormal];
    btnRight.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [btnRight setTitle:@"完成" forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = kLineSpacing;
    layout.minimumInteritemSpacing = kLineSpacing;
    layout.itemSize = CGSizeMake(kAlbumCellWidth, kAlbumCellWidth);
    
    CGFloat topMargin = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    CGRect rect = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+topMargin, self.view.frame.size.width, kTPScreenHeight -topMargin);
    self.collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsZero;
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsZero;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerNib:[UINib nibWithNibName:@"ZQAlbumCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([ZQAlbumCell class])];
    [self.view addSubview:self.collectionView];
    
//    CGFloat y = kTPScreenHeight - kButtomBarHeight;
//    self.tbButtom = [[ZQBottomToolbarView alloc] initWithFrame:CGRectMake(0, y, kTPScreenWidth, kButtomBarHeight)];
//    [self.view addSubview:self.tbButtom];
}

- (void)showList{
    if (!self.listView) {
        _listView = [[ZQListView alloc] initWithType:self.type maxImagesCount:self.maxImagesCount bSingleSelection:self.bSingleSelection];
    }
    __weak typeof(self) weakSelf = self;
    self.listView.listViewCallBack = ^(ZQAlbumModel * _Nonnull albumModel, ZQAlbumType type, NSInteger maxImagesCount, BOOL bSingleSelection) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (priSeleted && priSeleted != albumModel) {
            [strongSelf.selected removeAllObjects];
            CGSize s = [@"完成" textSizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(999, 999) lineBreakMode:NSLineBreakByWordWrapping];
            [btnRight setTitle:@"完成" forState:UIControlStateNormal];
            btnRight.frame = CGRectMake(0, 0, s.width+32, 30);
        }
        strongSelf.labelTitle.text = albumModel.name;
        priSeleted = albumModel;
        CGFloat viewTitleWidth = [strongSelf.labelTitle sizeThatFits:CGSizeMake(200, 14)].width + 4 + 10;
        strongSelf.labelTitle.frame = CGRectMake(0, 10, viewTitleWidth - 14, 24);
        strongSelf.viewTitle.frame= CGRectMake(0, 0, viewTitleWidth, 44);
        strongSelf.imageViewDown.frame = CGRectMake(viewTitleWidth - 10, 17, 10, 10);
//        strongSelf.type = type;
//        strongSelf.maxImagesCount = maxImagesCount;
//        strongSelf.bSingleSelection = bSingleSelection;
        strongSelf.mAlbum = albumModel;
        [strongSelf.cache removeAllObjects];
        [strongSelf.cacheThumb removeAllObjects];
        [strongSelf loadData];
        [strongSelf.collectionView reloadData];
        [strongSelf scrollToBottom];
        
    };
    [self.listView show];
}


- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)loadData {
    self.models = [ZQPhotoFetcher getAllPhotosInAlbum:self.mAlbum];
}


#pragma mark - UICollectionView Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ZQAlbumCell";
    ZQAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.cancelLoad = NO;
    if (!cell) {
        cell = [[ZQAlbumCell alloc] init];
    }
    cell.type = self.type;
    cell.model = self.models[indexPath.row];
    cell.delegate = self;
    cell.tag = indexPath.row;
    if ([self.mAlbum.name isEqualToString:_LocalizedString(@"Videos")]) {
        cell.bSingleSelection = YES;
    }
    else {
        cell.bSingleSelection = self.bSingleSelection;
    }
      [cell display:indexPath cache:self.cache];
    
    
    return cell;
}

//- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    ZQAlbumCell *ce = (ZQAlbumCell *)cell;
//    ce.cancelLoad = NO;
////    - (void)display:(NSIndexPath *)indexPath cache:(NSCache *)cache
////    [ce displayThumb:indexPath cache:self.cacheThumb];
//}

//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    ZQAlbumCell *ce = (ZQAlbumCell *)cell;
//    ce.cancelLoad = YES;
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.type == ZQAlbumTypeVideo) {
//        ZQVideoPlayVC *vc = [[ZQVideoPlayVC alloc] init];
//        vc.model = self.models[indexPath.row];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
//    else {
//        ZQPhotoPreviewVC *vc = [[ZQPhotoPreviewVC alloc] init];
//        vc.currentIdx = indexPath.row;
//        vc.models = self.models;
//        vc.selected = self.selected;
//        vc.delegate = self;
//        vc.maxImagesCount = self.maxImagesCount;
//        vc.bSingleSelect = self.bSingleSelection;
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
}

#pragma mark - 选择图片后获取图片

- (void)finish {
    [ProgressHUD show];
    ______WS();
    
    NSMutableArray *resultImg = [NSMutableArray new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __block dispatch_group_t group = dispatch_group_create();
        for (int i=0; i<wSelf.selected.count; i++) {
            dispatch_group_enter(group);
            ZQPhotoModel *model = wSelf.selected[i];
            
            //先调一次返回小图，再调一次返回大图
            [ZQPhotoFetcher getPhotoWithAssets:model.asset photoWidth:kTPScreenWidth completion:^(UIImage *image, NSDictionary *info) {
                NSLog(@"isMain: %d", [NSThread isMainThread]);
                if (info) {
                    //只存大图，可能没有requestID，但是有图
                    if ([[info objectForKey:PHImageResultIsDegradedKey] integerValue] == 0) {
                        if (image) {//可能为nil
                            [resultImg addObject:image];
                        }
                        dispatch_group_leave(group);
                    }
                    
                }
                else {
                    //info也没有是什么情况
                    //如果没有回调大图，group出不去，整个group会在超时时间60s后结束并返回
                }
            }];
            
        }
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC));
        long ret = dispatch_group_wait(group, timeout);
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressHUD hide];
            UIViewController *vc = [wSelf firstViewController];
            ZQAlbumNavVC *nav = (ZQAlbumNavVC *)vc;
            [nav dismissViewControllerAnimated:YES completion:^{
                if (nav.didFinishPickingPhotosHandle) {
                    NSArray *images = resultImg;
                    if (images.count == 0 || ret != 0) {
                        NSString *msg = _LocalizedString(@"FETCH_PHOTO_ERROR");
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:(UIAlertControllerStyleAlert)];
                        UIAlertAction *ok = [UIAlertAction actionWithTitle:_LocalizedString(@"OPERATION_OK") style:(UIAlertActionStyleDefault) handler:nil];
                        [alert addAction:ok];
                        [[ZQTools rootViewController] presentViewController:alert animated:YES completion:nil];
                    }
                    nav.didFinishPickingPhotosHandle(images);
                }
            }];
            
            
        });
    });
}

- (UIViewController *)firstViewController
{
    id responder = self;
    while ((responder = [responder nextResponder]))
    {
        if ([responder isKindOfClass:[UIViewController class]])
        {
            return responder;
        }
    }
    return nil;
}
#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint currentOffset = scrollView.contentOffset;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSTimeInterval timeDiff = currentTime - self.lastOffsetCapture;
    if (timeDiff > 0.1) {
        CGFloat distance = currentOffset.y - self.lastOffset.y;
        CGFloat scrollSpeed = fabs((distance*10)/1000);
        
        if (scrollSpeed > 0.4) {
            self.isScrollingFast = YES;
        }
        else {
            self.isScrollingFast = NO;
//            [self p_loadVisibleCellImage];
        }
        self.lastOffset = currentOffset;
        self.lastOffsetCapture = currentTime;
    }
}
////快速滚才会调这个
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self p_loadVisibleCellImage];
//}
//慢慢地滚调这个
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    [self p_loadVisibleCellImage];
}

#pragma mark - Private method

- (void)p_loadVisibleCellImage {
    NSArray *visibleCells = [self.collectionView visibleCells];
    for (ZQAlbumCell *cell in visibleCells) {
//        [cell display:[self.collectionView indexPathForCell:cell]];
        [cell display:[self.collectionView indexPathForCell:cell] cache:self.cache];
    }
}

#pragma mark - ZQPhotoPreviewVC Delegate - 多选

- (void)ZQPhotoPreviewVC:(ZQPhotoPreviewVC *)vc changeSelection:(NSArray<ZQPhotoModel *> *)selection {
    [self.collectionView reloadData];
    self.selected = [selection mutableCopy];
    [self.tbButtom selectionChange:self.selected];
    
}
#pragma mark - CTAlbumCellDelegate - 多选

- (BOOL)ZQAlbumCell:(ZQAlbumCell *)cell changeSelection:(ZQPhotoModel *)model {
    if (self.selected.count >= self.maxImagesCount && model.bSelected == NO) {
        if (self.bSingleSelection) {
            if (self.selected.count > 0) {
                ZQPhotoModel *priModel = self.selected[0];
                priModel.bSelected = NO;
                [self.selected removeObject:priModel];
                NSInteger index = [self.models indexOfObject:priModel];
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            }
            model.bSelected = YES;
            [self.selected addObject:model];
            NSInteger index = [self.models indexOfObject:model];
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            NSString *str = [NSString stringWithFormat:@"完成%ld",self.selected.count];
            CGSize s = [str textSizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(999, 999) lineBreakMode:NSLineBreakByWordWrapping];
            [btnRight setTitle:str forState:UIControlStateNormal];
            btnRight.frame = CGRectMake(0, 0, s.width+32, 30);
            return YES;
        }
        [ZQPhotoFetcher exceedMaxImagesCountAlert:self.maxImagesCount presentingVC:self navVC:((ZQAlbumNavVC*)self.navigationController)];
        return NO;
    }
    else {
        NSIndexPath *idx = [self.collectionView indexPathForCell:cell];
        ZQPhotoModel *m = self.models[idx.row];
        m.bSelected = model.bSelected;
        [self.selectedIdx addObject:idx];
        if (cell.bSelected) {
            [self.selected removeObject:model];
        }
        else {
            [self.selected addObject:model];
        }
//        [self.tbButtom selectionChange:self.selected];
        NSString *str;
        if (self.selected.count > 0) {
            str = [NSString stringWithFormat:@"完成%ld",self.selected.count];
        }else{
            str = @"完成";
        }
        
        CGSize s = [str textSizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(999, 999) lineBreakMode:NSLineBreakByWordWrapping];
        [btnRight setTitle:str forState:UIControlStateNormal];
        btnRight.frame = CGRectMake(0, 0, s.width+32, 30);
        
        return YES;
    }
}



- (NSMutableArray<ZQPhotoModel *> *)selected {
    if (!_selected) {
        _selected = [[NSMutableArray alloc] init];
    }
    return _selected;
}
- (NSMutableArray<NSIndexPath *> *)selectedIdx {
    if (!_selectedIdx) {
        _selectedIdx = [[NSMutableArray alloc] init];
    }
    return _selectedIdx;
}


- (NSCache *)cache {
    if (!_cache) {
        _cache = [[NSCache alloc] init];
        _cache.totalCostLimit = cacheLimit;
    }
    return _cache;
}
- (NSCache *)cacheThumb {
    if (!_cacheThumb) {
        _cacheThumb = [[NSCache alloc] init];
        _cacheThumb.totalCostLimit = cacheThumbLimit;
    }
    return _cacheThumb;
}

@end
