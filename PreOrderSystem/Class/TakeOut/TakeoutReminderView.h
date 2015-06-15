//
//  TakeoutReminderView.h
//  PreOrderSystem
//
//  Created by YorkIT on 14-6-21.
//
//

#import <UIKit/UIKit.h>

/**
 * @brief   外卖回应催单视图。
 *
 *
 */
@interface TakeoutReminderView : UIView

/// 数据源
@property (nonatomic, strong) NSArray *dataSource;

/// 当前选择的索引
@property (nonatomic, readonly) NSInteger selectedIndex;

@end
