//
//  JPPhoneManager.m
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//

#import "JPPhotoManager.h"
#import "UIImage+WLUtiles.h"

@interface JPPhotoManager()
@property (strong, nonatomic) PHImageManager *imageManager;
@end

@implementation JPPhotoManager

+ (instancetype)defaultManager
{
    static JPPhotoManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JPPhotoManager alloc] init];
    });
    
    return instance;
}

- (void)loadCameraRollInfoisDesc:(BOOL)isDesc isShowEmpty:(BOOL)isShowEmpty isOnlyShowImage:(BOOL)isOnlyShowImage CompletionBlock:(void (^)(JPAlbumModel *result))completionBlock
{
    PHFetchResult *albumCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    [albumCollection enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:!isDesc]];
        if (isOnlyShowImage) {
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
        }
        
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj options:fetchOptions];
        
        JPAlbumModel *model = nil;
        
        if (result.count > 0 || isShowEmpty) {
            model = [JPAlbumModel new];
            model.isCameraRoll = YES;
            model.albumName = obj.localizedTitle;//相册名
            model.content = result;//保存这个相册的内容
        }
        completionBlock ? completionBlock(model) : nil;
    }];
}

- (void)loadAlbumInfoIsShowEmpty:(BOOL)isShowEmpty isDesc:(BOOL)isDesc isOnlyShowImage:(BOOL)isOnlyShowImage CompletionBlock:(void(^)(PHFetchResult *customAlbum, NSArray *albumModelArray)) completionBlock
{
    //用来存放每个相册的model
    NSMutableArray *albumModelsArray = [NSMutableArray array];
    
    //获取所有的系统相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    //将smartAlbums中的相册添加到数组中(最近添加，相机胶卷,视频...)
    for (PHAssetCollection *collection in smartAlbums) {
        
        //最近添加 喜欢 相机交卷 截屏
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded || collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumFavorites || collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary || collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumScreenshots) {
            //遍历所有相册，只显示有视频或照片的相册
            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
          //  fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d || mediaType == %d", PHAssetMediaTypeImage,PHAssetMediaTypeVideo];
            //按创建时间排序
            fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:!isDesc]];
            if (isOnlyShowImage) {
                fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
            }
            
            PHFetchResult *assetResults = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
            if (assetResults.count>0) {
                if (assetResults.count > 0 || isShowEmpty) {
                    JPAlbumModel *model = [JPAlbumModel new];
                    model.isCameraRoll = NO;
                    model.albumName = collection.localizedTitle;
                    model.content = assetResults;
                    [albumModelsArray addObject:model];
                }
            }
        }
    }
    completionBlock ? completionBlock(smartAlbums, albumModelsArray) : nil;
}

- (void)getMSTAssetModelWithPHFetchResult:(PHFetchResult *)fetchResult completionBlock:(void(^)(NSArray <JPAssetModel *>*models))completionBlock
{
    NSMutableArray *modelsArray = [NSMutableArray arrayWithCapacity:fetchResult.count];
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        JPAssetModel *model = [JPAssetModel modelWithAsset:obj];
        [modelsArray addObject:model];
    }];
    completionBlock ? completionBlock(modelsArray) : completionBlock(nil);
}

- (void)getThumbnailImageFromPHAsset:(PHAsset *)asset photoWidth:(CGFloat)width completionBlock:(void(^)(UIImage *result, NSDictionary *info))completionBlock
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = NO;
    [self mp_getImageFromPHAsset:asset imageSize:CGSizeMake(width * 2.f, width * 2.f) options:options isFixOrientation:NO completionBlock:^(UIImage *result, NSDictionary *info) {
        completionBlock ? completionBlock(result, info) : nil;
    }];
}


- (void)getPreviewImageFromPHAsset:(PHAsset *)asset isHighQuality:(BOOL)isHighQuality completionBlock:(void (^)(UIImage *, NSDictionary *, BOOL))completionBlock {
    CGFloat scale = isHighQuality ? [UIScreen mainScreen].scale : .1f;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = width * scale;
    CGFloat pixelHeight = width / aspectRatio;
    CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = isHighQuality ? PHImageRequestOptionsDeliveryModeHighQualityFormat : PHImageRequestOptionsDeliveryModeFastFormat;
    options.synchronous = NO;
    options.networkAccessAllowed = YES;
    
    [self mp_getImageFromPHAsset:asset imageSize:imageSize options:options isFixOrientation:YES completionBlock:^(UIImage *result, NSDictionary *info) {
        completionBlock ? completionBlock(result, info, [info[PHImageResultIsDegradedKey] boolValue]) : nil;
    }];
}

- (void)mp_getImageFromPHAsset:(PHAsset *)asset imageSize:(CGSize)imageSize options:(PHImageRequestOptions *)options isFixOrientation:(BOOL)fixOrientation completionBlock:(void(^)(UIImage *result, NSDictionary *info))completionBlock {
    [self.imageManager requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL finished = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (finished && result) {
            if (fixOrientation) result = [UIImage fixOrientation:result];
            
            //回调
            completionBlock ? completionBlock(result, info) : nil;
        }
    }];
}

- (void)getPickingImageFromPHAsset:(PHAsset *)asset isFullImage:(BOOL)isFullImage maxImageWidth:(CGFloat)width completionBlock:(void (^)(UIImage *, NSDictionary *, BOOL))completionBlock {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    CGSize targetSize;

    if (isFullImage) {
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;

        targetSize = PHImageManagerMaximumSize;
    } else {
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        //        targetSize = PHImageManagerMaximumSize;
        if (width > asset.pixelWidth) {
            targetSize = PHImageManagerMaximumSize;
        } else {
            CGFloat scale = [UIScreen mainScreen].scale;
            CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
            CGFloat pixelWidth = width * scale;
            CGFloat pixelHeight = width / aspectRatio;
            targetSize = CGSizeMake(pixelWidth, pixelHeight);
        }
    }

    [self.imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        result = [UIImage fixOrientation:result];
        if (!isFullImage) {
            result = [result scaleImageWithMaxWidth:width];
        }

        NSData *data = UIImageJPEGRepresentation(result, .45);
        result = [UIImage imageWithData:data];

        completionBlock ? completionBlock(result, info, [info[PHImageResultIsDegradedKey] boolValue]) : nil;
    }];
   
}

- (void)getLivePhotoFromPHAsset:(PHAsset *)asset completionBlock:(void (^)(PHLivePhoto *, BOOL))completionBlock  API_AVAILABLE(ios(9.1)){
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = width * scale;
    CGFloat pixelHeight = width / aspectRatio;
    CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
    
    if (@available(iOS 9.1, *)) {
        PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        [self.imageManager requestLivePhotoForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
            completionBlock ? completionBlock(livePhoto, [info[PHImageResultIsDegradedKey] boolValue]) : nil;
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)getImageBytesWithArray:(NSArray <JPAssetModel *>*)models completionBlock:(void(^)(NSString *result))completionBlock
{
    __block NSUInteger dataLength = 0;
    __block NSUInteger count = models.count;

    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    options.synchronous = YES;

    for (JPAssetModel *model in models) {
        [self.imageManager requestImageDataForAsset:model.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            count--;
            dataLength += imageData.length;
            if (count <= 0) {
                completionBlock ? completionBlock([NSByteCountFormatter stringFromByteCount:dataLength countStyle:NSByteCountFormatterCountStyleFile]) : nil;
            }
        }];
    }
}

- (void)getAVPlayerItemFromPHAsset:(PHAsset *)asset completionBlock:(void(^)(AVPlayerItem *item))completionBlock
{
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = NO;
    options.version = PHVideoRequestOptionsVersionOriginal;
    
    [self.imageManager requestPlayerItemForVideo:asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        completionBlock ? completionBlock(playerItem) : nil;
    }];

}

#pragma mark - Lazy Load
- (PHImageManager *)imageManager {
    if (!_imageManager) {
        self.imageManager = [PHImageManager defaultManager];
    }
    return _imageManager;
}

+ (BOOL)checkCameraPermission:(UIViewController *)control {
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (videoStatus == AVAuthorizationStatusAuthorized) {
        return YES;
    }
    
    if (videoStatus ==AVAuthorizationStatusRestricted || videoStatus == AVAuthorizationStatusDenied) {
        UIAlertController *alertvc = [UIAlertController alertControllerWithTitle:nil message:@"您未打开相机权限，是否去设置中开启?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [alertvc addAction:cancle];
        UIAlertAction *okbtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication]openURL:url];
            }
        }];
        [alertvc addAction:okbtn];
        [control presentViewController:alertvc animated:YES completion:nil];
    }
    else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        }];
    }
    return NO;
}
@end
