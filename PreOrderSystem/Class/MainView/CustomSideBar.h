//
//  CustomSideBar.h
//  PreOrderSystem
//
//  Created by sWen on 13-3-25.
//
//

#import <UIKit/UIKit.h>

typedef enum
{
    kDiningTableSideBarTag = 1000,
    kTakeOutSideBarTag,
    kPreOrderSideBarTag,
    kDishCardSideBarTag,
    kQueueSideBarTag,
    kCallServiceSideBarTag,
    kMemberSideBarTag,
    kMoreSideBarTag
}kTabBarItemTag;

@class CustomBadge;
@class CustomSideBar;

@protocol CustomSideBarDelegate <NSObject>

- (void)sideBarPressed:(CustomSideBar *)sender;

@end

/**
 * @brief   功能按钮。
 *
 */
@interface CustomSideBar : UIImageView {
    /// 委托
    id <CustomSideBarDelegate> __weak delegate;
    /// 分割线视图
    UIImageView *lineImageView;
    /// 背景视图
    UIImageView *bgImageView;
    /// 事件按钮
    UIButton *sideButton;
    /// 选中状态
    BOOL bgFlag;
    /// 未读数量视图
    CustomBadge *sideBadge;
    /// 催单数量视图
    CustomBadge *remindersBadge;
}

/// 委托
@property (nonatomic, weak) id delegate;
/// 是否选中
@property (nonatomic, assign) BOOL bgFlag;
// 语言切换,需要重新加载
@property (nonatomic, assign) BOOL isReload;

/**
 * @brief   更新未读数量。
 *
 * @param   unread  未读数量。
 *
 */
- (void)updateSideBadge:(int)unread;

/**
 * @brief   更新催单数量。
 *
 * @param   reminders   催单数量。
 *
 */
- (void)updateRemindersBadge:(int)reminders;

/**
 * @brief   更新视图。
 *
 */
- (void)updateViewAfterCreateBar;

@end
