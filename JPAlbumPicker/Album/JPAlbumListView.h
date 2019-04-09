//
//  JPAlbumListView.h
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPAlbumModel.h"

typedef void(^listTableViewDidSelect) (JPAlbumModel *model);

@interface JPAlbumListView : UIView

@property (nonatomic,assign) CGFloat listHeight;
@property (nonatomic,copy) listTableViewDidSelect didSelet;

-(instancetype)initWithFrame:(CGRect)frame albumName:(NSString *)albumName;

-(void)showAlbumListView;

-(void)hideAlbumListView;

@end
