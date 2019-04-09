//
//  JPAlbumCollectionCell.m
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//

#import "JPAlbumCollectionCell.h"
#import "JPPhotoManager.h"


@interface JPAlbumCollectionCell()
@property (nonatomic,strong) UIImageView *imageView;
@end

@implementation JPAlbumCollectionCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
    }
    return self;
}

-(void)setAsset:(JPAssetModel *)asset
{
    _asset = asset;
    [[JPPhotoManager defaultManager] getThumbnailImageFromPHAsset:asset.asset photoWidth:CGRectGetWidth(self.contentView.frame) completionBlock:^(UIImage *result, NSDictionary *info) {
        self.imageView.image = result;
    }];
}

@end


@implementation JPPhotoGridCameraCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.image = [UIImage imageNamed:@"icon_album_camera"];
        [self.contentView addSubview:_imageView];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.cameraView startSession];
            });
        });
    }
    return self;
}

- (JPCameraView *)cameraView {
    if (!_cameraView) {
        self.cameraView = [[JPCameraView alloc] init];
        self.cameraView.frame = self.bounds;
        [_cameraView setPreviewLayerFrame:self.bounds];
        
        [self.contentView addSubview:_cameraView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = [UIImage imageNamed:@"album_paishe"];
        [self.contentView addSubview:imageView];
    }
    return _cameraView;
}

@end
