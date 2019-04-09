//
//  JPAssetModel.m
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//

#import "JPAssetModel.h"

@implementation JPAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset {
    JPAssetModel *model = [JPAssetModel new];
    
    model.asset = asset;
    
    return model;
}

- (NSString *)identifier {
    return self.asset.localIdentifier;
}

- (MSTAssetModelMediaType)type {
    if (@available(iOS 9.1, *)) {
        if (self.asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) return MSTAssetModelMediaTypeLivePhoto;
    }
    if (self.asset.mediaType == PHAssetMediaTypeImage) return MSTAssetModelMediaTypeImage;
    
    if (self.asset.mediaType == PHAssetMediaTypeVideo) return MSTAssetModelMediaTypeVideo;
    
    if (self.asset.mediaType == PHAssetMediaTypeAudio) return MSTAssetModelMediaTypeAudio;
    
    return MSTAssetModelMediaTypeUnkown;
}

- (NSTimeInterval)videoDuration {
    if (self.type == MSTAssetModelMediaTypeVideo)
        return self.asset.duration;
    else
        return 0.f;
}

- (NSString *)description {
    return self.debugDescription;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> identifier:%@ | type: %zi", [self class], self, self.identifier, self.type];
}

@end
