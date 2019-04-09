//
//  ViewController.m
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//

#import "ViewController.h"
#import "JPAlbumViewController.h"

@interface ViewController ()<JPImagePickerViewDeleagte>

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton  *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, 100, 30)];
    testBtn.backgroundColor = [UIColor orangeColor];
    [testBtn setTitle:@"自定义相册" forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(clickTestBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)clickTestBtn:(UIButton *)btn
{
    JPAlbumViewController *albumvc = [[JPAlbumViewController alloc] initWithAlbumTitle:@"我的相册"];
    albumvc.deleagte = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:albumvc];
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)fecthImageSuccess:(UIImage *)image
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.view addSubview:_imageView];
    }
    _imageView.frame = CGRectMake((CGRectGetWidth(self.view.frame) - 300)/2, (CGRectGetHeight(self.view.frame) - 300)/2 , 300, 300);
    _imageView.image = image;
}


@end
