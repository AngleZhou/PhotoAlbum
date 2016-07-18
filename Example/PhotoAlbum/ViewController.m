//
//  ViewController.m
//  PhotoAlbum
//
//  Created by ZhouQian on 16/7/18.
//  Copyright © 2016年 ZhouQian. All rights reserved.
//

#import "ViewController.h"
#import "ZQPhotoAlbum.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)selectPhoto:(id)sender {
    ZQPhotoAlbum* nav = [[ZQPhotoAlbum alloc] initWithMaxImagesCount:9 type:(ZQAlbumTypePhoto) bSingleSelect:NO];
    if (nav) {
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (IBAction)singleSelect:(id)sender {
    ZQPhotoAlbum* nav = [[ZQPhotoAlbum alloc] initWithType:ZQAlbumTypePhoto];
    if (nav) {
        [self presentViewController:nav animated:YES completion:nil];
    }
}
- (IBAction)selectVideo:(id)sender {
    ZQPhotoAlbum* nav = [[ZQPhotoAlbum alloc] initWithType:ZQAlbumTypeVideo];
    if (nav) {
        [self presentViewController:nav animated:YES completion:nil];
    }
}


@end
