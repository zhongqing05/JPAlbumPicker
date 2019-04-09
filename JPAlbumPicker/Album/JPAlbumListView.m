//
//  JPAlbumListView.m
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//

#import "JPAlbumListView.h"
#import "JPPhotoManager.h"
#import "MacroDefine.h"

#define AlbumListIndentify    @"AlbumListIndentify"
@interface JPAlbumListView()<UITableViewDelegate,UITableViewDataSource,PHPhotoLibraryChangeObserver>{
    PHFetchResult *_fecthResult;
}
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,copy) NSString *selectAlbum;
@end

@implementation JPAlbumListView

-(instancetype)initWithFrame:(CGRect)frame albumName:(NSString *)albumName;
{
    if (self = [super initWithFrame:frame]) {
        self.selectAlbum = albumName;
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        _dataSource = [NSMutableArray new];
        _tableview = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableview.showsVerticalScrollIndicator = YES;
        _tableview.showsHorizontalScrollIndicator = NO;
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.rowHeight = 100;
        _tableview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_tableview];
        [self getLoaclPhotolistData];
        self.hidden = YES;
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    return self;
}

-(void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

-(void)getLoaclPhotolistData
{
    WS(ws)
    [[JPPhotoManager defaultManager] loadAlbumInfoIsShowEmpty:NO isDesc:YES isOnlyShowImage:YES CompletionBlock:^(PHFetchResult *customAlbum, NSArray *albumModelArray) {
        _fecthResult = customAlbum;
        if (albumModelArray) {
            [ws.dataSource removeAllObjects];
            [ws.dataSource addObjectsFromArray:albumModelArray];
            [ws.tableview reloadData];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AlbumListIndentify];
    [self tableCellContentAddsubviews:cell.contentView index:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JPAlbumModel *model = _dataSource[indexPath.row];
    if (_didSelet) {
        _didSelet(model);
        [self hideAlbumListView];
        if (![model.albumName isEqualToString:_selectAlbum]) {
            _selectAlbum = model.albumName;
            [_tableview reloadData];
        }
    }
}

-(void)tableCellContentAddsubviews:(UIView *)contentView index:(NSInteger)index
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    JPAlbumModel *model = _dataSource[index];
    JPAssetModel *asset = [model.models firstObject];
    [[JPPhotoManager defaultManager] getThumbnailImageFromPHAsset:asset.asset photoWidth:_tableview.rowHeight completionBlock:^(UIImage *result, NSDictionary *info) {
        if (result) {
            imageView.image = result;
        }
    }];
    [contentView addSubview:imageView];
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 30, 100, 18);
    nameLabel.text = model.albumName;
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = RGBColor(0x333333, 1);
    [contentView addSubview:nameLabel];
    
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 5, CGRectGetMaxY(nameLabel.frame) + 8, 100, 18);
    countLabel.text = [NSString stringWithFormat:@"共%lu",(unsigned long)model.count];
    countLabel.font = [UIFont systemFontOfSize:13];
    countLabel.textColor = RGBColor(0x333333, 1);
    [contentView addSubview:countLabel];
    
    if ([self.selectAlbum isEqualToString:model.albumName]) {
        UIImageView *selectImage = [[UIImageView alloc] initWithFrame:CGRectMake(W_Width - 42, (100-30)/2, 30, 30)];
        selectImage.image = [UIImage imageNamed:@"album_sleected"];
        [contentView addSubview:selectImage];
    }
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws getLoaclPhotolistData];
    });
}

-(void)showAlbumListView
{
    self.hidden = NO;
    CGRect rect = self.frame;
    rect.size.height = _listHeight;
    rect.origin.y = rect.origin.y - _listHeight;
    WS(ws)
    [UIView animateWithDuration:0.3 animations:^{
        ws.frame = rect;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideAlbumListView
{
    WS(ws)
    CGRect rect = self.frame;
    rect.size.height = 0;
    rect.origin.y = rect.origin.y + _listHeight;
    [UIView animateWithDuration:0.2 animations:^{
        ws.frame = rect;
    } completion:^(BOOL finished) {
        ws.hidden = YES;
    }];
}

@end
