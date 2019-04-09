//
//  JPAlbumViewController.m
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//

#import "JPAlbumViewController.h"
#import "JPPhotoManager.h"
#import "JPAlbumCollectionCell.h"
#import "NSIndexSet+Utils.h"
#import "JPAlbumListView.h"
#import "MacroDefine.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define AlbumViewCollecionCell  @"albumViewCellIndentify"
#define PhoneGridIndentify      @"phonegridIndentify"

@interface JPAlbumViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PHPhotoLibraryChangeObserver,JPImagePickerViewDeleagte>{
    NSString *_title;
    JPAlbumModel *_albumModel;
}
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) JPAlbumListView *albumListView;
@property (nonatomic,strong) UIButton *nearBtn;             //最近照片

@end

@implementation JPAlbumViewController

-(instancetype)initWithAlbumTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _title = title;
        _isShowCamera = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:_title];
    
    UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(5, W_StatusBarHeight, 44, 44)];
    [close setImage:[UIImage imageNamed:@"video_upload_close"] forState:UIControlStateNormal];
    [close addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:close];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, W_Height - 44 - W_SurPlusHeigt, W_Width, 44 + W_SurPlusHeigt)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bottomView];
    
    NSString *title = @"最近照片";
    CGFloat width = [title boundingRectWithSize:CGSizeMake(0, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.width + 30;
    _nearBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    [_nearBtn setImage:[UIImage imageNamed:@"album_triangle"] forState:UIControlStateNormal];
    [_nearBtn setTitle:title forState:UIControlStateNormal];
    _nearBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_nearBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_nearBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_nearBtn];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((W_Width-25)/4, (W_Width-25)/4);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), W_Width, W_Height - CGRectGetHeight(_bottomView.frame)-CGRectGetMaxY(self.navigationController.navigationBar.frame)) collectionViewLayout:layout];
    _collectionView.showsVerticalScrollIndicator = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[JPAlbumCollectionCell class] forCellWithReuseIdentifier:AlbumViewCollecionCell];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.bounces = YES;
    if (_isShowCamera) {
        [_collectionView registerClass:[JPPhotoGridCameraCell class] forCellWithReuseIdentifier:PhoneGridIndentify];
    }
    [self.view addSubview:_collectionView];
    [self.view bringSubviewToFront:_collectionView];
    [self fetchCameraRollPhotos];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    // Do any additional setup after loading the view.
}
    
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
    
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)clickCloseBtn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)clickButton:(UIButton *)button
{
    if (!_albumListView) {
        _albumListView = [[JPAlbumListView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_bottomView.frame), W_Width, 0) albumName:_albumModel.albumName];
        _albumListView.listHeight = CGRectGetHeight(_collectionView.frame);
        [self.view addSubview:_albumListView];
        WS(ws)
        [_albumListView setDidSelet:^(JPAlbumModel *model) {
            self->_albumModel = model;
            [ws setTitle:model.albumName];
            [ws.collectionView reloadData];
            [ws rotationAnimate:button];
            button.selected = NO;
        }];
    }
    button.selected ? [_albumListView hideAlbumListView] : [_albumListView showAlbumListView];
    [self rotationAnimate:button];
    button.selected = !button.selected;
}

-(void)rotationAnimate:(UIButton *)button
{
    CGAffineTransform transform;
    if (!button.selected) {
        transform = CGAffineTransformMakeRotation(-90 * M_PI/180.0);
    }else{
        transform = CGAffineTransformRotate(button.transform, 0 * M_PI/180.0);
    }
    [UIView animateWithDuration:0.5 animations:^{
        button.imageView.transform = transform;
    }];
}

-(void)fetchCameraRollPhotos
{
    WS(ws)
    [[JPPhotoManager defaultManager] loadCameraRollInfoisDesc:YES isShowEmpty:YES isOnlyShowImage:YES CompletionBlock:^(JPAlbumModel *result) {
        if (result) {
            self->_albumModel = result;
            [ws setTitle:self->_albumModel.albumName];
            [ws.collectionView reloadData];
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_isShowCamera) {
        return _albumModel.count + 1;
    }
    return _albumModel.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JPAssetModel *model = nil;
    if (_isShowCamera) {
        if (indexPath.row == 0) {
            JPPhotoGridCameraCell *phoneGridCell = [collectionView dequeueReusableCellWithReuseIdentifier:PhoneGridIndentify forIndexPath:indexPath];
            return phoneGridCell;
        }else{
            model = [_albumModel.models objectAtIndex:(indexPath.row-1)];
        }
    }else{
        model = [_albumModel.models objectAtIndex:indexPath.row];
    }
    JPAlbumCollectionCell *cell = (JPAlbumCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:AlbumViewCollecionCell forIndexPath:indexPath];
    cell.asset = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    JPAssetModel *model = nil;
    if (_isShowCamera) {
        if (indexPath.row == 0) {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if (![JPPhotoManager checkCameraPermission:self]) {
                return;
            }
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate                 = self;
            imagePickerController.allowsEditing            = NO;
            imagePickerController.sourceType               = sourceType;
            imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
            if (@available(iOS 11.0,*)) {
                [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAutomatic];
            }
            if ([[[UIDevice currentDevice] systemVersion ]floatValue ] > 8.0) {
                imagePickerController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            }
            [self presentViewController:imagePickerController animated:YES completion:^{}];
            return;
        }else{
            model = [_albumModel.models objectAtIndex:(indexPath.row-1)];
        }
    }else{
        model = [_albumModel.models objectAtIndex:indexPath.row];
    }
    if (model) {
        WS(ws)
        [[JPPhotoManager defaultManager] getPreviewImageFromPHAsset:model.asset isHighQuality:YES completionBlock:^(UIImage *result, NSDictionary *info, BOOL isDegraded) {
            if (result) {
                JPImagePickerViewController *pickerVC = [[JPImagePickerViewController alloc] init];
                pickerVC.image = result;
                pickerVC.deleagte = ws;
                if (self.cgSize.width > 0 && self.cgSize.height > 0) {
                    pickerVC.cropSize = self.cgSize;
                }
                [ws.navigationController pushViewController:pickerVC animated:YES];
            }
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        if (@available(iOS 11.0,*)) {
            [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
    }];
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImageOrientation imageOrientation=image.imageOrientation;
    if (imageOrientation!=UIImageOrientationUp) {
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    JPImagePickerViewController *pickerVC = [[JPImagePickerViewController alloc] init];
    pickerVC.image = image;
    pickerVC.deleagte = self;
    if (self.cgSize.width > 0 && self.cgSize.height > 0) {
        pickerVC.cropSize = self.cgSize;
    }
    [self.navigationController pushViewController:pickerVC animated:YES];
    //保存照片
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        if (@available(iOS 11.0,*)) {
            [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
       NSLog(@"SaveImageSuccess");
    }
}

-(void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma -mark PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:_albumModel.content];
    if (!collectionChanges) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        _albumModel.content = [collectionChanges fetchResultAfterChanges];
        UICollectionView *collectionView = self.collectionView;
  
        if ([collectionChanges hasIncrementalChanges]) {
            BOOL isCamera = _isShowCamera;
            
            NSArray <NSIndexPath *>*removedPaths = nil;
            NSArray <NSIndexPath *>*insertedPaths = nil;
            NSArray <NSIndexPath *>*changedPaths = nil;
            
            NSIndexSet *removedIndexes = collectionChanges.removedIndexes;
            if (removedIndexes.count > 0)
                removedPaths = [removedIndexes indexPathsFromIndexesWithSection:0 isShowCamera:isCamera];
            
            NSIndexSet *insertedIndexes = collectionChanges.insertedIndexes;
            if (insertedIndexes.count > 0)
                insertedPaths = [insertedIndexes indexPathsFromIndexesWithSection:0 isShowCamera:isCamera];
            
            NSIndexSet *changedIndexes = collectionChanges.changedIndexes;
            if (changedIndexes.count > 0)
                changedPaths = [changedIndexes indexPathsFromIndexesWithSection:0 isShowCamera:isCamera];
            
            
            BOOL shouldReload = NO;
            if (changedPaths && removedPaths) {
                for (NSIndexPath *changedPath in changedPaths) {
                    if ([removedPaths containsObject:changedPath]) {
                        shouldReload = YES;
                        break;
                    }
                }
            }
            
            NSInteger item = _isShowCamera ? removedPaths.lastObject.item - 1 : removedPaths.lastObject.item;
            if (removedPaths.lastObject && item >= _albumModel.count) shouldReload = YES;
            
            if (shouldReload) {
                [collectionView reloadData];
            } else {
                [collectionView performBatchUpdates:^{
                    if (removedPaths) [collectionView deleteItemsAtIndexPaths:removedPaths];
                    if (insertedIndexes) [collectionView insertItemsAtIndexPaths:insertedPaths];
                    if (changedPaths) [collectionView reloadItemsAtIndexPaths:changedPaths];
                    
                    if (collectionChanges.hasMoves) {
                        [collectionChanges enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                            NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:fromIndex inSection:0];
                            NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
                            [collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                        }];
                    }
                } completion:nil];
            }
        } else {
            [collectionView reloadData];
        }
    });
}

#pragma -mark JPImagePickerViewDeleagte
-(void)fecthImageSuccess:(UIImage *)image
{
    if (_deleagte && [_deleagte respondsToSelector:@selector(fecthImageSuccess:)]) {
        [_deleagte fecthImageSuccess:image];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
