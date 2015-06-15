//
//  TakeAwayPhotoReviewDetailView.m
//  TestPageController
//
//  Created by YorkIT on 14-4-18.
//  Copyright (c) 2014年 teehom. All rights reserved.
//

#import "PhotoReviewView.h"
#import "AsyncImageView.h"

@interface PhotoReviewView () <UIScrollViewDelegate> {
    
    /// 内容视图
    UIView *contentView_;
    
    /// 照片容器视图
    UIScrollView *photoContainerView_;
    
    /// 照片视图
    AsyncImageView *photoView_;
}

@end

@implementation PhotoReviewView

#pragma mark - memory management

- (void)dealloc
{
//    [photoView_ removeObserver:self forKeyPath:@"image"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - initlization methods

- (id)initWithFrame:(CGRect)frame
{
    // 更新frame
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    frame = keyWindow.bounds;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        frame.origin.y += 20.0;
        frame.size.height -= 20.0;
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0.238 green:0.242 blue:0.234 alpha:1.0];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // 内容视图
        contentView_ = [[UIView alloc] initWithFrame:self.bounds];
        contentView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        contentView_.backgroundColor = [UIColor clearColor];
        [self addSubview:contentView_];
        
        // 照片容器视图
        CGRect containerFrame = CGRectMake(0.0, 0.0, self.bounds.size.height, self.bounds.size.width);
        photoContainerView_ = [[UIScrollView alloc] initWithFrame:containerFrame];
        photoContainerView_.center = self.center;
        photoContainerView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        photoContainerView_.showsHorizontalScrollIndicator = NO;
        photoContainerView_.showsVerticalScrollIndicator = NO;
        photoContainerView_.scrollsToTop = NO;
        photoContainerView_.minimumZoomScale = 1.0;
        photoContainerView_.delegate = self;
        [contentView_ addSubview:photoContainerView_];
        
        // 照片视图
        photoView_ = [[AsyncImageView alloc] initWithFrame:photoContainerView_.bounds];
        photoView_.contentMode = UIViewContentModeScaleAspectFit;
        photoView_.showSourceImage = YES;
        [photoContainerView_ addSubview:photoView_];
        
        // 添加KVO
//        [photoView_ addObserver:self
//                     forKeyPath:@"image"
//                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
//                        context:NULL];
        
        // 手势监听
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [doubleTapGestureRecognizer addTarget:self action:@selector(doubleTapAction:)];
        [photoContainerView_ addGestureRecognizer:doubleTapGestureRecognizer];
        
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        [singleTapGestureRecognizer addTarget:self action:@selector(singleTapAction:)];
        [contentView_ addGestureRecognizer:singleTapGestureRecognizer];
        
        // 设置优先级
        [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
        
        // 监听通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationDidChanged:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]) {
        // 图片被设置
        UIImage *sourceImage = photoView_.image;
        if (sourceImage == nil) {
            photoView_.frame = photoContainerView_.bounds;
            return;
        }
        CGSize imageSize = sourceImage.size;
        CGSize containerSize = photoContainerView_.bounds.size;
        CGRect drawRect = CGRectZero;
        if (imageSize.width / containerSize.width > imageSize.height / containerSize.height) {
            drawRect.origin.x = 0.0;
            drawRect.size.width = containerSize.width;
            drawRect.size.height = imageSize.height * containerSize.width / imageSize.width;
            drawRect.origin.y = (containerSize.height - drawRect.size.height) / 2.0;
        } else {
            drawRect.origin.y = 0.0;
            drawRect.size.height = containerSize.height;
            drawRect.size.width = imageSize.width * containerSize.height / imageSize.height;
            drawRect.origin.x = (containerSize.width - drawRect.size.width) / 2.0;
        }
        photoView_.frame = drawRect;
        
        CGFloat maxWidthScale = (photoContainerView_.frame.size.width * 2) / drawRect.size.width;
        CGFloat maxHeightScale = (photoContainerView_.frame.size.height * 2) / drawRect.size.height;
        
        photoContainerView_.maximumZoomScale = MAX(maxWidthScale, maxHeightScale);
    }
}

#pragma mark - UIGestureRecognizer methods

- (void)doubleTapAction:(UIGestureRecognizer *)gestureRecognizer
{
    if (photoContainerView_.zoomScale == photoContainerView_.maximumZoomScale) {
        [photoContainerView_ setZoomScale:photoContainerView_.minimumZoomScale animated:YES];
    } else {
        [photoContainerView_ setZoomScale:photoContainerView_.maximumZoomScale animated:YES];
    }
}

- (void)singleTapAction:(UIGestureRecognizer *)gestureRecognizer
{
    [self dismiss];
}

#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return photoView_;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    photoView_.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - NSNotification methods

- (void)deviceOrientationDidChanged:(NSNotification *)notification
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIInterfaceOrientation orientation = keyWindow.rootViewController.interfaceOrientation;
    if (notification == nil) {
        // 第一次设置默认方向
        if (orientation == UIInterfaceOrientationLandscapeRight) {
            orientation = UIInterfaceOrientationLandscapeLeft;
        } else {
            orientation = UIInterfaceOrientationLandscapeRight;
        }
    }
    
    switch (orientation) {
        
        case UIInterfaceOrientationLandscapeLeft: {
            photoContainerView_.transform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        }
            
        case UIInterfaceOrientationLandscapeRight: {
            photoContainerView_.transform = CGAffineTransformMakeRotation(0.0 - M_PI_2);
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - private methods

/**
 * @brief   锁定屏幕。
 */
- (void)lockScreen
{
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents] == NO) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
}

/**
 * @brief   解锁屏幕。
 */
- (void)unlockScreen
{
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

#pragma mark - public methods

- (void)setPhotoData:(UIImage *)photoData
{
    if ([_photoData isEqual:photoData]) {
        return;
    }
    _photoData = photoData;
    
    // 加载图片
    photoView_.image = _photoData;
    
    // 图片被设置
    UIImage *sourceImage = _photoData;
    if (sourceImage == nil) {
        photoView_.frame = photoContainerView_.bounds;
        return;
    }
    CGSize imageSize = sourceImage.size;
    CGSize containerSize = photoContainerView_.bounds.size;
    CGRect drawRect = CGRectZero;
    if (imageSize.width / containerSize.width > imageSize.height / containerSize.height) {
        drawRect.origin.x = 0.0;
        drawRect.size.width = containerSize.width;
        drawRect.size.height = imageSize.height * containerSize.width / imageSize.width;
        drawRect.origin.y = (containerSize.height - drawRect.size.height) / 2.0;
    } else {
        drawRect.origin.y = 0.0;
        drawRect.size.height = containerSize.height;
        drawRect.size.width = imageSize.width * containerSize.height / imageSize.height;
        drawRect.origin.x = (containerSize.width - drawRect.size.width) / 2.0;
    }
    photoView_.frame = drawRect;
    
    CGFloat maxWidthScale = (photoContainerView_.frame.size.width * 2) / drawRect.size.width;
    CGFloat maxHeightScale = (photoContainerView_.frame.size.height * 2) / drawRect.size.height;
    
    photoContainerView_.maximumZoomScale = MAX(maxWidthScale, maxHeightScale);
}

- (void)show
{
    [self lockScreen];
    
    // 获取window
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.alpha = 0.0;
    contentView_.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [keyWindow addSubview:self];

    // 第一次默认根据设备方向设置
    [self deviceOrientationDidChanged:nil];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 0.8;
        contentView_.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 1.0;
            contentView_.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self unlockScreen];
        }];
    }];
}

- (void)dismiss
{
    [self lockScreen];
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 0.8;
        contentView_.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.alpha = 0.0;
            contentView_.transform = CGAffineTransformMakeScale(0.5, 0.5);
        } completion:^(BOOL finished) {
            contentView_.transform = CGAffineTransformIdentity;
            self.photoData = nil;
            [self removeFromSuperview];
            
            [self unlockScreen];
        }];
    }];
}

@end
