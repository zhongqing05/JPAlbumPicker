//
//  JPPhoneManager.h
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "JPAlbumModel.h"

@interface JPPhotoManager : NSObject

+ (instancetype)defaultManager;

/**
 读取『相机胶卷』的信息
 
 @param isDesc          是否为倒序
 @param isShowEmpty     是否显示为空的情况
 @param isOnlyShowImage 是否只显示图片
 @param completionBlock 返回数组<MSTAlbumModel>
 */
- (void)loadCameraRollInfoisDesc:(BOOL)isDesc isShowEmpty:(BOOL)isShowEmpty isOnlyShowImage:(BOOL)isOnlyShowImage CompletionBlock:(void (^)(JPAlbumModel *result))completionBlock;

/**
 读取所有相册的信息
 
 @param isShowEmpty     是否显示空相册
 @param isDesc          是否为倒序
 @param isOnlyShowImage 是否只显示图片
 @param completionBlock 返回数组<MSTAlbumModel>
 */
- (void)loadAlbumInfoIsShowEmpty:(BOOL)isShowEmpty isDesc:(BOOL)isDesc isOnlyShowImage:(BOOL)isOnlyShowImage CompletionBlock:(void(^)(PHFetchResult *customAlbum, NSArray *albumModelArray)) completionBlock;


/**
 根据相册封装 assetModel
 
 @param fetchResult     相册信息
 @param completionBlock 回调
 */
- (void)getMSTAssetModelWithPHFetchResult:(PHFetchResult *)fetchResult completionBlock:(void(^)(NSArray <JPAssetModel *>*models))completionBlock;


/**
 读取缩略图
 
 @param asset           图片内容
 @param width           图片宽度，宽高比为 1:1，scale 默认为 2.0
 @param completionBlock 回调
 */
- (void)getThumbnailImageFromPHAsset:(PHAsset *)asset photoWidth:(CGFloat)width completionBlock:(void(^)(UIImage *result, NSDictionary *info))completionBlock;

/**
 读取预览图片，宽度默认为屏幕宽度
 
 @param asset           图片内容
 @param isHighQuality   是否是高质量，为 YES 时，scale 为设备屏幕的 scale， NO 时 scale 为 0.1
 @param completionBlock 回调
 */
- (void)getPreviewImageFromPHAsset:(PHAsset *)asset isHighQuality:(BOOL)isHighQuality completionBlock:(void(^)(UIImage *result, NSDictionary *info, BOOL isDegraded))completionBlock;

/**
 读取 Live Photo
 
 @param asset           live photo 内容
 @param completionBlock 回调
 */
- (void)getLivePhotoFromPHAsset:(PHAsset *)asset completionBlock:(void (^)(PHLivePhoto *, BOOL))completionBlock  API_AVAILABLE(ios(9.1));

/**
 读取选定照片
 
 @param asset           图片内容
 @param isFullImage     是否为原图
 @param width           最大图片宽度，isFullImage 为 NO 时生效
 @param completionBlock 回调
 */
- (void)getPickingImageFromPHAsset:(PHAsset *)asset isFullImage:(BOOL)isFullImage maxImageWidth:(CGFloat)width completionBlock:(void(^)(UIImage *result, NSDictionary *info, BOOL isDegraded))completionBlock;

/**
 获取图片的大小
 
 @param models 图片内容
 @param completionBlock 回调
 */
- (void)getImageBytesWithArray:(NSArray <JPAssetModel *>*)models completionBlock:(void(^)(NSString *result))completionBlock;

/**
 读取视频
 
 @param asset 视频内容
 @param completionBlock 回调
 */
- (void)getAVPlayerItemFromPHAsset:(PHAsset *)asset completionBlock:(void(^)(AVPlayerItem *item))completionBlock;


+ (BOOL)checkCameraPermission:(UIViewController *)control;

@end
