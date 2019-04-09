//
//  WLAssetBaseModel.h
//  WeiLiao
//
//  Created by zhongqing on 2018/7/10.
//  Copyright © 2018年 Thai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MSTAssetModelMediaType) {
    MSTAssetModelMediaTypeImage,
    MSTAssetModelMediaTypeLivePhoto,
    MSTAssetModelMediaTypeGIF,
    MSTAssetModelMediaTypeVideo,
    MSTAssetModelMediaTypeAudio,
    MSTAssetModelMediaTypeUnkown
};

@interface WLAssetBaseModel : NSObject

@property (copy, nonatomic) NSString *identifier;

@property (assign, nonatomic) MSTAssetModelMediaType type;

//只有当 type 为 video 时有值
@property (assign, nonatomic) NSTimeInterval videoDuration;

@end
