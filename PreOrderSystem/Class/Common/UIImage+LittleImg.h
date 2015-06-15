//
//  UIImage+LittleImg.h
//  SuperFileManager
//
//  Created by mac on 14-2-19.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (LittleImg)
+ (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize;//自动缩放到指定大小
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;//保持原来的长宽比，生成一个缩略图
@end
