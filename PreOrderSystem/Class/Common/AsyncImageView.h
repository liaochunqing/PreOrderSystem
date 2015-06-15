//
//  AsyncImageView.h
//  TestPageController
//
//  Created by YorkIT on 14-3-13.
//  Copyright (c) 2014年 teehom. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @brief   异步加载图片视图。
 */
@interface AsyncImageView : UIImageView

/// 加载失败显示的图片
@property (nonatomic, strong) NSString *failureImageName;

// 是否显示原图
@property (nonatomic, assign) BOOL showSourceImage;

/**
 * @brief   加载网络图品。
 *
 * @param   urlString   图片地址。
 */
- (void)loadImageWithURLString:(NSString *)urlString;

@end
