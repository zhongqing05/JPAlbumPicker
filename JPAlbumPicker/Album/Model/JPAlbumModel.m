//
//  JPAlbumModel.m
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//

#import "JPAlbumModel.h"
#import "JPPhotoManager.h"

@implementation JPAlbumModel

-(NSUInteger)count
{
    return self.models.count;
}

- (void)setContent:(PHFetchResult *)content {
    _content = content;
    
    [[JPPhotoManager defaultManager] getMSTAssetModelWithPHFetchResult:content completionBlock:^(NSArray<JPAssetModel *> *models) {
        self.models = models;
    }];
}

@end
