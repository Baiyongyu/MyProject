//
//  QMPictureView.m
//  inongtian
//
//  Created by KevinCao on 2016/10/26.
//  Copyright © 2016年 qianmo. All rights reserved.
//

#import "QMPictureView.h"
#import "QMPictureProgressView.h"

@interface QMPictureView()<UIScrollViewDelegate>

@property (nonatomic, assign) CGSize showPictureSize;

@property (nonatomic, assign) BOOL doubleClicks;

@property (nonatomic, assign) CGPoint lastContentOffset;

@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, assign) CGFloat offsetY;

@property (nonatomic, weak) QMPictureProgressView *progressView;

@property (nonatomic, assign, getter=isShowAnim) BOOL showAnim;

@end

@implementation QMPictureView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.delegate = self;
    self.alwaysBounceVertical = true;
    self.backgroundColor = [UIColor clearColor];
    self.showsHorizontalScrollIndicator = false;
    self.showsVerticalScrollIndicator = false;
    self.maximumZoomScale = 2;
    
    // 添加 imageView
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.clipsToBounds = true;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = self.bounds;
    imageView.userInteractionEnabled = true;
    _imageView = imageView;
    [self addSubview:imageView];
    
    // 添加进度view
    QMPictureProgressView *progressView = [[QMPictureProgressView alloc] init];
    [self addSubview:progressView];
    self.progressView = progressView;
    
    // 添加监听事件
    UITapGestureRecognizer *doubleTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
    doubleTapGes.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:doubleTapGes];
}

#pragma mark - 外部方法

- (void)animationShowWithFromRect:(CGRect)rect animationBlock:(void (^)())animationBlock completionBlock:(void (^)())completionBlock {
    _imageView.frame = rect;
    self.showAnim = true;
    [self.progressView setHidden:true];
    [UIView animateWithDuration:0.25 animations:^{
        if (animationBlock != nil) {
            animationBlock();
        }
        self.imageView.frame = [self getImageActualFrame:self.showPictureSize];
    } completion:^(BOOL finished) {
        if (finished) {
            if (completionBlock) {
                completionBlock();
            }
        }
        self.showAnim = false;
    }];
}

- (void)animationDismissWithToRect:(CGRect)rect animationBlock:(void (^)())animationBlock completionBlock:(void (^)())completionBlock {
    
    // 隐藏进度视图
    self.progressView.hidden = true;
    [UIView animateWithDuration:0.25 animations:^{
        if (animationBlock) {
            animationBlock();
        }
        CGRect toRect = rect;
        toRect.origin.y += self.offsetY;
        // 这一句话用于在放大的时候去关闭
        toRect.origin.x += self.contentOffset.x;
        self.imageView.frame = toRect;
    } completion:^(BOOL finished) {
        if (finished) {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

#pragma mark - 私有方法

- (void)layoutSubviews {
    [super layoutSubviews];
    self.progressView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
}

- (void)setShowAnim:(BOOL)showAnim {
    _showAnim = showAnim;
    self.progressView.hidden = true;
//    if (showAnim == true || !self.urlString.length) {
//        self.progressView.hidden = true;
//    }else {
//        self.progressView.hidden = self.progressView.progress == 1;
//    }
}

- (void)setUrlString:(NSString *)urlString {
    _urlString = urlString;
    [self.imageView sd_cancelCurrentImageLoad];
    self.progressView.progress = 0.01;
    self.progressView.hidden = true;
    // 如果没有在执行动画，那么就显示出来
//    if (self.isShowAnim == false && self.urlString.length) {
//        // 显示出来
//        self.progressView.hidden = false;
//    }
    // 取消上一次的下载
    self.userInteractionEnabled = false;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:self.placeholderImage options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        CGFloat progress = (CGFloat)receivedSize / expectedSize ;
        self.progressView.progress = progress;
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error != nil) {
            self.progressView.hidden = true;
            [self.progressView showError];
        }else {
            self.progressView.hidden = true;
            self.userInteractionEnabled = true;
            if (image != nil) {
                // 计算图片的大小
                [self setPictureSize:image.size];
            }else {
                [self.progressView showError];
            }
            // 当下载完毕设置为1，因为如果直接走缓存的话，是不会走进度的 block 的
            // 解决在执行动画完毕之后根据值去判断是否要隐藏
            // 在执行显示的动画过程中：进度视图要隐藏，而如果在这个时候没有下载完成，需要在动画执行完毕之后显示出来
            self.progressView.progress = 1;
        }
    }];
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    if (self.zoomScale == 1) {
        [UIView animateWithDuration:0.25 animations:^{
            CGPoint center = self.imageView.center;
            center.x = self.contentSize.width * 0.5;
            self.imageView.center = center;
        }];
    }
}

- (void)setLastContentOffset:(CGPoint)lastContentOffset {
    // 如果用户没有在拖动，并且绽放比 > 0.15
    if (!(self.dragging == false && _scale > 0.15)) {
        _lastContentOffset = lastContentOffset;
    }
}

- (void)setPictureSize:(CGSize)pictureSize {
    _pictureSize = pictureSize;
    if (CGSizeEqualToSize(pictureSize, CGSizeZero)) {
        return;
    }
    // 计算实际的大小
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    if (screenW<screenH) {
        CGFloat scale = screenW / pictureSize.width;
        CGFloat height = scale * pictureSize.height;
        self.showPictureSize = CGSizeMake(screenW, height);
    } else {
        CGFloat scale = screenH / pictureSize.height;
        CGFloat width = scale * pictureSize.width;
        self.showPictureSize = CGSizeMake(width, screenH);
    }
}

- (void)setShowPictureSize:(CGSize)showPictureSize {
    _showPictureSize = showPictureSize;
    self.imageView.frame = [self getImageActualFrame:_showPictureSize];
    self.contentSize = self.imageView.frame.size;
}

- (CGRect)getImageActualFrame:(CGSize)imageSize {
    CGFloat x = 0;
    CGFloat y = 0;
    
    if (imageSize.height < [UIScreen mainScreen].bounds.size.height) {
        y = ([UIScreen mainScreen].bounds.size.height - imageSize.height) / 2;
    }
    if (imageSize.width < [UIScreen mainScreen].bounds.size.width) {
        x = ([UIScreen mainScreen].bounds.size.width - imageSize.width) / 2;
    }
    return CGRectMake(x, y, imageSize.width, imageSize.height);
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    zoomRect.size.height =self.frame.size.height / scale;
    zoomRect.size.width  =self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

#pragma mark - 监听方法

- (void)doubleClick:(UITapGestureRecognizer *)ges {
    CGFloat newScale = 2;
    if (_doubleClicks) {
        newScale = 1;
    }
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[ges locationInView:ges.view]];
    [self zoomToRect:zoomRect animated:YES];
    _doubleClicks = !_doubleClicks;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset;
    // 保存 offsetY
    _offsetY = scrollView.contentOffset.y;
    
    // 正在动画
    if ([self.imageView.layer animationForKey:@"transform"] != nil) {
        return;
    }
    // 用户正在缩放
    if (self.zoomBouncing || self.zooming) {
        return;
    }
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    // 滑动到中间
    if (scrollView.contentSize.height > screenH) {
        // 代表没有滑动到底部
        if (_lastContentOffset.y > 0 && _lastContentOffset.y <= scrollView.contentSize.height - screenH) {
            return;
        }
    }
    _scale = fabs(_lastContentOffset.y) / screenH;
    
    // 如果内容高度 > 屏幕高度
    // 并且偏移量 > 内容高度 - 屏幕高度
    // 那么就代表滑动到最底部了
    if (scrollView.contentSize.height > screenH &&
        _lastContentOffset.y > scrollView.contentSize.height - screenH) {
        _scale = (_lastContentOffset.y - (scrollView.contentSize.height - screenH)) / screenH;
    }
    
    // 条件1：拖动到顶部再继续往下拖
    // 条件2：拖动到顶部再继续往上拖
    // 两个条件都满足才去设置 scale -> 针对于长图
    if (scrollView.contentSize.height > screenH) {
        // 长图
        if (scrollView.contentOffset.y < 0 || _lastContentOffset.y > scrollView.contentSize.height - screenH) {
            [_pictureDelegate pictureView:self scale:_scale];
        }
    }else {
        [_pictureDelegate pictureView:self scale:_scale];
    }
    
    // 如果用户松手
    if (scrollView.dragging == false) {
        if (_scale > 0.15 && _scale <= 1) {
            // 关闭
            [_pictureDelegate pictureViewTouch:self];
            // 设置 contentOffset
            [scrollView setContentOffset:_lastContentOffset animated:false];
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGPoint center = _imageView.center;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    center.y = scrollView.contentSize.height * 0.5 + offsetY;
    _imageView.center = center;
    
    // 如果是缩小，保证在屏幕中间
    if (scrollView.zoomScale < scrollView.minimumZoomScale) {
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        center.x = scrollView.contentSize.width * 0.5 + offsetX;
        _imageView.center = center;
    }
}

@end