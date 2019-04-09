//
//  JPImagePickerViewController.m
//  JPAlbumPicker
//
//  Created by zhongqing on 2018/12/18.
//  Copyright © 2018年 zhongqing. All rights reserved.
//

#import "JPImagePickerViewController.h"
#import "MacroDefine.h"

@interface JPImagePickerViewController ()<UIScrollViewDelegate>{
    CGRect _cropFrame;
}
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIView *overLayView;       //用于展示裁剪框的视图
@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation JPImagePickerViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.cropSize = CGSizeMake(W_Width *0.8, W_Width *0.8);
    [self createImagePickerSubviews];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    CGFloat scale;
    if (_cropSize.width/_cropSize.height > _image.size.width/_image.size.height) {
        scale = _cropSize.width/_imageView.frame.size.width;
    }else{
        scale = _cropSize.height/_imageView.frame.size.height;
    }
    self.scrollView.userInteractionEnabled = YES;
    [self.scrollView setMinimumZoomScale:scale];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)createImagePickerSubviews
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.delegate = self;
    _scrollView.scrollsToTop = NO;
    //设置缩放的最大比例和最小比例
    _scrollView.maximumZoomScale = 10;
    _scrollView.minimumZoomScale = 1;
    //初始缩放比例为1
    [_scrollView setZoomScale:1 animated:YES];
    [self.view addSubview:self.scrollView];
    
    [_scrollView addSubview:self.imageView];
    
    //用于展示裁剪框的视图
    _overLayView = [[UIView alloc]initWithFrame:self.view.frame];
    _overLayView.userInteractionEnabled = NO;
    _overLayView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [self.view addSubview:self.overLayView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40+W_StatusBarHeight, W_Width, 25)];
    _titleLabel.text = @"移动和缩放";
    _titleLabel.font = [UIFont systemFontOfSize:20];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_titleLabel];
    
    UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, W_Height - 50 - W_SurPlusHeigt, 60, 30)];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [cancleBtn addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancleBtn];
    
    UIButton *fectchBtn = [[UIButton alloc] initWithFrame:CGRectMake(W_Width - 60 , W_Height - 50 - W_SurPlusHeigt, 60, 30)];
    [fectchBtn setTitle:@"选取" forState:UIControlStateNormal];
    [fectchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    fectchBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [fectchBtn addTarget:self action:@selector(clickFetchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fectchBtn];
}

-(void)clickCancelBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickFetchBtn:(UIButton *)btn
{
    UIImage *image = [self getSubImage];
    if (_deleagte && [_deleagte respondsToSelector:@selector(fecthImageSuccess:)]) {
        [_deleagte fecthImageSuccess:image];
    }
}

-(UIImage *)getSubImage{
    //图片大小和当前imageView的缩放比例
    CGFloat scaleRatio = self.image.size.width/_imageView.frame.size.width ;
    //scrollView的缩放比例，即是ImageView的缩放比例
    CGFloat scrollScale = self.scrollView.zoomScale;
    //裁剪框的 左上、右上和左下三个点在初始ImageView上的坐标位置（注意：转换后的坐标为原始ImageView的坐标计算的，而非缩放后的）
    CGPoint leftTopPoint =  [self.view  convertPoint:_cropFrame.origin toView:_imageView];
    CGPoint rightTopPoint = [self.view convertPoint:CGPointMake(_cropFrame.origin.x + _cropSize.width, _cropFrame.origin.y) toView:_imageView];
    CGPoint leftBottomPoint =[self.view convertPoint:CGPointMake(_cropFrame.origin.x, _cropFrame.origin.y+_cropSize.height) toView:_imageView];
    
    //计算三个点在缩放后imageView上的坐标
    leftTopPoint = CGPointMake(leftTopPoint.x * scrollScale, leftTopPoint.y*scrollScale);
    rightTopPoint = CGPointMake(rightTopPoint.x * scrollScale, rightTopPoint.y*scrollScale);
    leftBottomPoint = CGPointMake(leftBottomPoint.x * scrollScale, leftBottomPoint.y*scrollScale);
    
    //计算图片的宽高
    CGFloat width = (rightTopPoint.x - leftTopPoint.x )* scaleRatio;
    CGFloat height = (leftBottomPoint.y - leftTopPoint.y) *scaleRatio;
    
    //计算裁剪区域在原始图片上的位置
    CGRect myImageRect = CGRectMake(leftTopPoint.x * scaleRatio, leftTopPoint.y*scaleRatio, width, height);
    
    //裁剪图片
    CGImageRef imageRef = self.image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();

    return smallImage;
}

-(UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

#pragma mark - Public
-(void)setCropSize:(CGSize)cropSize{
    _cropSize = cropSize;
    //设置裁剪框区域
    _cropFrame = CGRectMake((self.view.frame.size.width-cropSize.width)/2,(self.view.frame.size.height-cropSize.height)/2,cropSize.width, cropSize.height);
    if (CGRectGetMaxY(_titleLabel.frame) > CGRectGetMinY(_cropFrame)) {
        _titleLabel.frame = CGRectMake(0, CGRectGetMinY(_cropFrame) - CGRectGetHeight(_titleLabel.frame) - 15, W_Width, CGRectGetHeight(_titleLabel.frame));
    }
    [self.view setNeedsLayout];
}

-(void)setImage:(UIImage *)image{
    [self.imageView setImage:image];
    _image = image;
    [self.view setNeedsLayout];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!_image) {
        return;
    }
    [self.scrollView setFrame:CGRectMake(0, 0, W_Width, W_Height)];
    [self.scrollView setContentSize:CGSizeMake(W_Width, W_Height)];
    
    CGSize imageSize = _image.size;
    if (_cropSize.width == _cropSize.height) {
        //正方形
        if (imageSize.width > imageSize.height) {
            //宽大于高
            _imageView.frame = CGRectMake((W_Width - (_cropSize.width * (imageSize.width/imageSize.height)))/2, (W_Height - _cropSize.width)/2, _cropSize.width * (imageSize.width/imageSize.height), _cropSize.width);
            [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(_imageView.frame) + CGRectGetMinX(_cropFrame)*2, W_Height)];
            _scrollView.contentOffset = CGPointMake((CGRectGetWidth(_imageView.frame)-_cropSize.width)/2, 0);
            _imageView.center = CGPointMake(_scrollView.contentSize.width/2, _scrollView.contentSize.height/2);
        }else{
            _imageView.frame = CGRectMake((W_Width - _cropSize.width)/2, (W_Height - _cropSize.width * (imageSize.height/imageSize.width))/2, _cropSize.width, _cropSize.width * (imageSize.height/imageSize.width));
            _scrollView.contentSize = CGSizeMake(W_Width, W_Height + CGRectGetHeight(_imageView.frame)-_cropSize.width);
            _scrollView.contentOffset = CGPointMake(0, (CGRectGetHeight(_imageView.frame)-_cropSize.width)/2);
            _imageView.center = CGPointMake(_scrollView.contentSize.width/2, _scrollView.contentSize.height/2);
        }
    }else{
        //裁剪矩形
        if ((imageSize.height/imageSize.width) > (_cropSize.height/_cropSize.width)) {
            //上下移动 宽不变
            _imageView.frame = CGRectMake((W_Width - _cropSize.width)/2, (W_Height - _cropSize.width *(imageSize.height/imageSize.width))/2, _cropSize.width, _cropSize.width *(imageSize.height/imageSize.width));
            _scrollView.contentSize = CGSizeMake(W_Width, CGRectGetHeight(_imageView.frame)+CGRectGetMinY(_cropFrame) * 2);
            if (CGRectGetHeight(_imageView.frame) > _cropSize.height) {
                _scrollView.contentOffset = CGPointMake(0, (CGRectGetHeight(_imageView.frame) - _cropSize.height)/2);
            }
            _imageView.center = CGPointMake(_scrollView.contentSize.width/2, _scrollView.contentSize.height/2);
        }else{
            //左右移动 高不变
            _imageView.frame = CGRectMake((W_Width - _cropSize.height * (imageSize.width/imageSize.height))/2, (W_Height - _cropSize.height)/2, _cropSize.height * (imageSize.width/imageSize.height) , _cropSize.height);
            //图片宽度 + 2边边距
            _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_imageView.frame) + CGRectGetMinX(_cropFrame) * 2, W_Height);
            if (CGRectGetWidth(_imageView.frame) > _cropSize.width) {
                _scrollView.contentOffset = CGPointMake((CGRectGetWidth(_imageView.frame)-_cropSize.width)/2, 0);
            }
            _imageView.center = CGPointMake(_scrollView.contentSize.width/2, _scrollView.contentSize.height/2);
        }
    }
    [self transparentCutSquareArea];
}

//矩形裁剪区域
- (void)transparentCutSquareArea{
    //圆形透明区域
    UIBezierPath *alphaPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, W_Width, W_Height)];
    UIBezierPath *squarePath = [UIBezierPath bezierPathWithRect:_cropFrame];
    [alphaPath appendPath:squarePath];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = alphaPath.CGPath;
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    self.overLayView.layer.mask = shapeLayer;
    
    //裁剪框
    UIBezierPath *cropPath = [UIBezierPath bezierPathWithRect:CGRectMake(_cropFrame.origin.x-1, _cropFrame.origin.y-1, _cropFrame.size.width+2, _cropFrame.size.height+2)];
    CAShapeLayer *cropLayer = [CAShapeLayer layer];
    cropLayer.path = cropPath.CGPath;
    cropLayer.fillColor = [UIColor whiteColor].CGColor;
    cropLayer.strokeColor = [UIColor whiteColor].CGColor;
    [self.overLayView.layer addSublayer:cropLayer];
}

#pragma -mark UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    //等比例放大图片以后，让放大后的ImageView保持在ScrollView的中央
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width) *0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) *0.5 : 0.0;
    _imageView.center =CGPointMake(scrollView.contentSize.width *0.5 + offsetX,scrollView.contentSize.height *0.5 + offsetY);
    
    //设置scrollView的contentSize，最小为self.view.frame
    if (scrollView.contentSize.width >= W_Width  && scrollView.contentSize.height <= W_Height) {
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, W_Height);
    }else if(scrollView.contentSize.width <= W_Width && scrollView.contentSize.height <= W_Height){
        scrollView.contentSize = CGSizeMake(W_Width, W_Height);
    }else if(scrollView.contentSize.width <= W_Width && scrollView.contentSize.height >= W_Height){
        scrollView.contentSize = CGSizeMake(W_Width, scrollView.contentSize.height);
    }else{
        
    }
    //设置scrollView的contentInset
    CGFloat imageWidth = _imageView.frame.size.width;
    CGFloat imageHeight = _imageView.frame.size.height;
    CGFloat cropWidth = _cropSize.width;
    CGFloat cropHeight = _cropSize.height;
    
    CGFloat leftRightInset = 0.0,topBottomInset = 0.0;
    
    //imageview的大小和裁剪框大小的三种情况，保证imageview最多能滑动到裁剪框的边缘
    if (imageWidth<= cropWidth) {
        leftRightInset = 0;
    }else if (imageWidth >= cropWidth && imageWidth <= W_Width){
        leftRightInset =(imageWidth - cropWidth)*0.5;
    }else{
        leftRightInset = (W_Width-_cropSize.width)*0.5;
    }
    
    if (imageHeight <= cropHeight) {
        topBottomInset = 0;
    }else if (imageHeight >= cropHeight && imageHeight <= W_Height){
        topBottomInset = (imageHeight - cropHeight)*0.5;
    }else {
        topBottomInset = (W_Height-_cropSize.height)*0.5;
    }
    [self.scrollView setContentInset:UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset)];
}

// 返回要在ScrollView中缩放的控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView;
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
