//
//  ViewController.m
//  PhotoAlbum
//
//  Created by ZhouQian on 16/7/18.
//  Copyright © 2016年 ZhouQian. All rights reserved.
//

#import "ViewController.h"
#import "ZQAlbumNavVC.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)selectPhoto:(id)sender {
    ZQAlbumNavVC* nav = [[ZQAlbumNavVC alloc] initWithMaxImagesCount:9 type:(ZQAlbumTypePhoto) bSingleSelect:NO];
    if (nav) {
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (IBAction)singleSelect:(id)sender {
    ZQAlbumNavVC* nav = [[ZQAlbumNavVC alloc] initWithType:ZQAlbumTypePhoto];
    if (nav) {
        [self presentViewController:nav animated:YES completion:nil];
    }
}
- (IBAction)selectVideo:(id)sender {
    ZQAlbumNavVC* nav = [[ZQAlbumNavVC alloc] initWithType:ZQAlbumTypeVideo];
    if (nav) {
        [self presentViewController:nav animated:YES completion:nil];
    }
}


@end
