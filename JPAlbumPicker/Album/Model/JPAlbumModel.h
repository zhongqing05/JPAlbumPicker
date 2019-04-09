//
//  JPAlbumModel.h
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "JPAssetModel.h"

@interface JPAlbumModel : NSObject
/**
 相册名
 */
@property (copy  , nonatomic) NSString *albumName;

/**
 是否是『相机胶卷』
 */
@property (assign, nonatomic) BOOL isCameraRoll;

/**
 图片个数
 */
@property (assign, nonatomic, readonly) NSUInteger count;

/**
 相册内容
 */
@property (strong, nonatomic) PHFetchResult *content;

@property (strong, nonatomic) NSArray <JPAssetModel *>*models;

@end
