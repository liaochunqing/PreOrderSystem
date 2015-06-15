//
//  TakeoutShoppingCarSelectedView.h
//  PreOrderSystem
//
//  Created by mac on 14-7-16.
//
//

#import <UIKit/UIKit.h>
#import "DtMenuCookbookPackageTableViewCell.h"
#import "DtMenuDataClass.h"
@class TakeoutShoppingCarSelectedView;
@protocol  PackageSelectedChangeDelegate<NSObject>

/**
 *  编辑了套餐成员
 *
 *  @param selectView    self
 *  @param newPackageArr 编辑后的套餐成员数组
 *  @param memberDic     被改变勾选状态的某套餐子项.
 */
- (void)TakeoutShoppingCarSelectedView:(TakeoutShoppingCarSelectedView *)selectView didChangedPackageArr:(NSArray *)newPackageArr withChangeMember:(NSDictionary *)memberDic;

@end

@interface TakeoutShoppingCarSelectedView : UIView <UITableViewDataSource,UITableViewDelegate,DtMenuCookbookPackageTableViewCellDelegate,UIScrollViewDelegate>

@property (nonatomic,weak)id <PackageSelectedChangeDelegate> delegatqe;

///套餐详情选择
@property (nonatomic,strong)UITableView *packageSelectTableView;


///
@property (nonatomic,strong) DtMenuShoppingCarDataClass *shoppingCarDataClass;

/// 套餐数据过多则需要显示可滚动提示图.
@property (nonatomic,assign) BOOL isNeedScroll;

/// 可滚动提示图
@property (nonatomic,strong) UIImageView *canScrollImv;

///已滚动到最底部
@property (nonatomic,assign) BOOL isScrollToBottom;


///计算self高度.
- (CGFloat)calculateSelfHeight;

- (id)initWithData:(DtMenuShoppingCarDataClass *)data;
@end
