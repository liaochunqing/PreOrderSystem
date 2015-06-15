//
//  LoadPicture.m
//  PreOrderSystem_iPhone
//
//  Created by sWen on 13-7-31.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import "LoadPicture.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "Constants.h"

@implementation LoadPicture

//加载网络图片
+ (void)loadPicFromNetword:(NSURL *)imageURL withImageView:(UIImageView *)currentImagaView
{
    __block UIActivityIndicatorView *activityIndicator;
    __weak UIImageView *weakImageView = currentImagaView;
    [currentImagaView setImageWithURL:imageURL placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         if (!activityIndicator)
         {
             [weakImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
             activityIndicator.center = CGPointMake(weakImageView.frame.size.width/2, weakImageView.frame.size.height/2);
             [activityIndicator startAnimating];
         }
     }
    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         [activityIndicator removeFromSuperview];
         activityIndicator = nil;
     }];
}

@end
