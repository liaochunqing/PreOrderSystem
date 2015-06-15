//
//  TakeAwayPhotoReviewDetailView.h
//  TestPageController
//
//  Created by YorkIT on 14-4-18.
//  Copyright (c) 2014年 teehom. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @brief 照片浏览视图。
 *
 */
@interface PhotoReviewView : UIView

/// 照片数据
@property (nonatomic, strong) UIImage *photoData;

/**
 * @brief   显示。
 */
- (void)show;

/**
 * @brief   销毁。
 */
- (void)dismiss;

@end
