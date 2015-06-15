//
//  PSPopoverBckgroundView.h
//  PreOrderSystem
//
//  Created by YorkIT on 14-5-9.
//
//

#import <UIKit/UIKit.h>

/**
 * @brief   自定义UIPopoverViewController背景视图（用于在iOS7上显示iOS6的UIPopoverViewController样式）。
 *
 */
@interface PSPopoverBckgroundView : UIPopoverBackgroundView {
    /// 边框视图
    UIImageView *frameImageView_;
    /// 内容背景视图
    UIImageView *contentBgImageView_;
    /// 箭头视图
    UIImageView *arrowImageView_;
    /// 箭头位置
    CGFloat arrowOffset_;
    /// 箭头方向
    UIPopoverArrowDirection arrowDirection_;
}
    
@end
