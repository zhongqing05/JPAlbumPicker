//
//  JPAlbumCollectionCell.h
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPAssetModel.h"
#import "JPCameraView.h"

@interface JPAlbumCollectionCell : UICollectionViewCell

@property (nonatomic,strong) JPAssetModel *asset;

@end


@interface JPPhotoGridCameraCell : UICollectionViewCell

//@property (strong, nonatomic) UIImage *cameraImage;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) JPCameraView *cameraView;
@end
