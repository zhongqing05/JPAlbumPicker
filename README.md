### JPAlbumPicker

自定义相册是通过苹果Photos.Framework框架、快速的读取手机本地相册，以平面的形式呈现给用户。本地照片预览和手机拍照功能完美的融合在一起，让用户可以简单高效的选择自己喜欢的照片或者重新拍照。用户照片过多时还可以根据分类来快速筛选照片。选取照片时，你可以根据自己喜欢的区域移动或放大自动裁剪照片。

![](https://github.com/zhongqing05/JPAlbumPicker/blob/fe00930ec4782a66650f6571cf6fc715b056f93d/JPAlbumPicker/Screenshot/IMG_0635.PNG?raw=true)

![](https://raw.githubusercontent.com/zhongqing05/JPAlbumPicker/bb656eb3a8ecef1f739ead7371826a8d889f9b76/JPAlbumPicker/Screenshot/IMG_0634.PNG)

![](https://raw.githubusercontent.com/zhongqing05/JPAlbumPicker/bb656eb3a8ecef1f739ead7371826a8d889f9b76/JPAlbumPicker/Screenshot/IMG_0634.PNG)

### 依赖库

导入 Photos.Framework

iOS 8.0+

### 注意

 info.plist 要配置相关的相机和相册的访问权限,否则访问权限期间会奔溃
 
 ```
 	<key>NSCameraUsageDescription</key>
	<string>自定义相册要用到相机权限</string>
	<key>NSPhotoLibraryAddUsageDescription</key>
	<string>保存图片到相册需要相册权限</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>保存图片</string>
 ```
