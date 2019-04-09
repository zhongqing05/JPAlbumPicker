//
//  JPImagePickerViewController.h
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JPImagePickerViewDeleagte <NSObject>
@optional
-(void)fecthImageSuccess:(UIImage *)image;

@end

@interface JPImagePickerViewController : UIViewController

/**
 裁剪区域
 */
@property(nonatomic,assign)CGSize cropSize;
/**
 裁剪的图片
 */
@property(nonatomic,strong)UIImage *image;

@property(nonatomic,assign) id<JPImagePickerViewDeleagte>deleagte;

@end
