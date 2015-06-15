//
//  AsyncImageView.m
//  TestPageController
//
//  Created by YorkIT on 14-3-13.
//  Copyright (c) 2014年 teehom. All rights reserved.
//

#import "AsyncImageView.h"
#import "OfflineManager.h"
#import "MyMD5.h"

@interface AsyncImageView () <NSURLConnectionDataDelegate>

/// 当前加载的图片地址
@property (nonatomic, strong) NSString *imageUrl;

/// 数据请求对象
@property (nonatomic, strong) NSURLConnection *urlConnection;

/// 下载的图片数据
@property (nonatomic, strong) NSMutableData *receiveData;

@end

@implementation AsyncImageView

#pragma mark - memory management

- (void)dealloc
{
    // 取消下载
    if (self.urlConnection != nil) {
        [self.urlConnection cancel];
        self.urlConnection = nil;
    }
    
    self.receiveData = nil;
}

#pragma mark - initlization methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.failureImageName = @"search_failure";
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 追加数据
    [self.receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.receiveData.length == 0) {
        if (self.failureImageName.length > 0) {
            [self performSelectorOnMainThread:@selector(setImage:)
                                   withObject:[UIImage imageNamed:self.failureImageName]
                                waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(setImage:)
                                   withObject:nil
                                waitUntilDone:NO];
        }
    } else {
        [self performSelectorInBackground:@selector(downloadDone:)
                               withObject:[NSData dataWithData:self.receiveData]];
        
        self.receiveData = nil;
        self.urlConnection = nil;
    }
}

#pragma mark - private methods

/**
 * @brief   加载小图，如果不存在则创建小图。
 *
 * @param   sourceImage 大图资源。
 */
- (void)loadThumbnail:(UIImage *)sourceImage
{
    if (sourceImage == nil) {
        return;
    }
    
    // 生成小图名称
    NSString *thumbnailUrl = [NSString stringWithFormat:@"%@_%@", self.imageUrl, NSStringFromCGSize(self.frame.size)];
    
    // 检查小图是否存在
    OfflineManager *offlineManager = [OfflineManager sharedOfflineManager];
    UIImage *thumbnailImage = [offlineManager offlinePhotoWithFileName:[MyMD5 getMD5Str:thumbnailUrl]];
    if (thumbnailImage == nil) {
        // 生成小图
        thumbnailImage = [[self class] image:sourceImage fitInSize:self.frame.size];
        // 缓存小图片
        [offlineManager saveOfflinePhoto:thumbnailImage andPhotoFileName:[MyMD5 getMD5Str:thumbnailUrl]];
    }
    
    // 显示小图
    self.image = thumbnailImage;
}

/**
 * @brief   下载图片。
 */
- (void)downloadImage
{
    // 请求图片数据
    self.receiveData = [[NSMutableData alloc] init];
    
    NSURL *downloadURL = [NSURL URLWithString:self.imageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10];
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

/**
 * @brief   图片下载完成回调。
 *
 * @param   receiveData 下载接受的数据。
 *
 */
- (void)downloadDone:(NSData *)receiveData
{
    UIImage *sourceImage = [UIImage imageWithData:receiveData];
    if (sourceImage != nil) {
        // 加载图片成功，缓存大图
        OfflineManager *offlineManager = [OfflineManager sharedOfflineManager];
        [offlineManager saveOfflinePhoto:sourceImage andPhotoFileName:[MyMD5 getMD5Str:self.imageUrl]];
        
        if (self.showSourceImage) {
            self.image = sourceImage;
        } else {
            // 加载小图
            [self loadThumbnail:sourceImage];
        }
    } else {
        // 获取图片失败，显示失败图片
        if (self.failureImageName.length > 0) {
            self.image = [UIImage imageNamed:self.failureImageName];
        } else {
            self.image = nil;
        }
    }
}

#pragma mark - public methods

- (void)loadImageWithURLString:(NSString *)urlString
{
    // 取消下载
    if (self.urlConnection != nil) {
        [self.urlConnection cancel];
        self.urlConnection = nil;
    }
    
    self.receiveData = nil;
    
    if (urlString == nil || urlString.length == 0) {
        // 显示失败图片
        if (self.failureImageName.length > 0) {
            self.image = [UIImage imageNamed:self.failureImageName];
        } else {
            self.image = nil;
        }
        self.imageUrl = @"";
        return;
    }
    
    if ([self.imageUrl isEqualToString:urlString]) {
        return;
    }
    
    // 先清空之前的旧图片
    self.image = nil;
    
    self.imageUrl = urlString;
    
    // 判断图片是否存在
    OfflineManager *offlineManager = [OfflineManager sharedOfflineManager];
    UIImage *sourceImage = [offlineManager offlinePhotoWithFileName:[MyMD5 getMD5Str:urlString]];
    if (sourceImage) {
        if (self.showSourceImage) {
            // 显示原图
            self.image = sourceImage;
        } else {
            // 加载小图
            [self loadThumbnail:sourceImage];
        }
    } else {
        // 下载大图
        [self downloadImage];
    }
}

+ (UIImage *)image:(UIImage *)sourceImage fitInSize:(CGSize)containerSize
{
    if (sourceImage == nil) {
        return nil;
    }
    
    CGSize imageSize = sourceImage.size;
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
    
    CGFloat scale = 1.0;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [UIScreen mainScreen].scale;
    }
    UIGraphicsBeginImageContextWithOptions(containerSize, NO, scale);
    [[UIColor whiteColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(),
                      CGRectMake(0.0, 0.0, containerSize.width, containerSize.height));
    
    [sourceImage drawInRect:drawRect];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

@end
