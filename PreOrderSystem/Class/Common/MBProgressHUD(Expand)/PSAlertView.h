//
//  PSAlertView.h
//  PreOrderSystem
//
//  Created by YorkIT on 14-5-9.
//
//

#import <UIKit/UIKit.h>

/**
 * @brief   提示弹出框。
 *
 *
 */
@interface PSAlertView : UIAlertView

/**
 * @brief   弹出信息。
 *
 * @param   message 信息内容。
 */
+ (void)showWithMessage:(NSString *)message;

/**
 * @brief   弹出信息。
 *
 * @param   message 信息内容。
 * @param   buttonTitle 按钮的标题。
 */
+ (void)showWithMessage:(NSString *)message buttonTitle:(NSString *)buttonTitle;

@end
