//
//  JPAssetModel.h
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPAssetBaseModel.h"
#import <Photos/Photos.h>

@interface JPAssetModel : NSObject

@property (strong, nonatomic) PHAsset *asset;

@property (assign, nonatomic, getter=isSelected) BOOL selected;

+ (instancetype)modelWithAsset:(PHAsset *)asset;

@end
