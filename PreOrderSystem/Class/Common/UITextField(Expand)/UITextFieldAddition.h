//
//  UITextFieldAddition.h
//  PreOrderSystem
//
//  Created by YorkIT on 14-8-7.
//
//

#import <Foundation/Foundation.h>
#import "KeyBoardInputAccessoryView.h"

/**
 * @brief   输入框扩展。
 *
 */
@interface UITextField (Addition) <KeyboardInputAccessoryViewDelegate>

/**
 * @brief   绑定回收键盘的按钮（只有iPhone版有效，iPad版自己有回首键盘的按钮）。
 *
 */
- (void)bindCloseButton;

@end
