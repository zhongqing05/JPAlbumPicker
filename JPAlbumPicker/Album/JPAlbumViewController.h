//
//  JPAlbumViewController.h
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//

#import "JPImagePickerViewController.h"

@interface JPAlbumViewController : UIViewController

-(instancetype)initWithAlbumTitle:(NSString *)title;

@property (nonatomic,assign) BOOL isShowCamera;    //是否显示摄像头 默认YES
@property (nonatomic,assign) id<JPImagePickerViewDeleagte> deleagte;
@property (nonatomic,assign) CGSize cgSize;             //选择的区域

@end
