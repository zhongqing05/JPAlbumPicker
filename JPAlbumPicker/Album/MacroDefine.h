//
//  MacroDefine.h
//  JPAlbumPicker
//
//  Created by zhongqing on 2019/4/8.
//  Copyright © 2019 zhongqing. All rights reserved.
//

#ifndef MacroDefine_h
#define MacroDefine_h

#define W_Width [UIScreen mainScreen].bounds.size.width
#define W_Height [UIScreen mainScreen].bounds.size.height
#define W_SurPlusHeigt (IPHONEX? 34:0)       //iPhoneX多余的高度
#define IPHONEX    (W_Height == 812 && W_Width == 375)
#define W_StatusBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define RGBColor(rgbValue, a)       [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#endif /* MacroDefine_h */
