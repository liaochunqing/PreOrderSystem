//
//  ShoppingCarViewController.h
//  PreOrderSystem
//
//  Created by SWen on 14-1-3.
//
//

#import <UIKit/UIKit.h>
#import "JsonPicker.h"
#import "DtMenuShoppingTopTableViewCell.h"
#import "DtMenuShoppingTopTableViewtemCell.h"
#import "DtMenuShoppingBottomTableViewCell.h"
#import "DtMenuCookbookRemarkTableViewCell.h"
#import "DtMenuRemarkPickerViewController.h"
#import "DiningTableCommon.h"

@class DtMenuShoppingCarListDataClass;
@class HousingDataClass;
@class DtMenuShoppingCarViewController;
@protocol DtMenuShoppingCarViewControllerDelegate <NSObject>

- (void)dtMenuShoppingCarViewHavedDismiss;

/**
 *  价格变动导致入厨房/确认失败则返回新菜品数据,供上层UI刷新
 *
 *  @param dic 新菜品数据
 */
- (void)submitFailWithNewDishData:(NSDictionary *)dic;

@end

@interface DtMenuShoppingCarViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, JsonPickerDelegate, DtMenuShoppingTopTableViewCellDelegate, DtMenuShoppingBottomTableViewCellDelegate, DtMenuCookbookRemarkTableViewCellDelegate, DtMenuRemarkPickerViewControllerDelegate>

@property(nonatomic, weak) id <DtMenuShoppingCarViewControllerDelegate> delegate;
@property(nonatomic, strong) HousingDataClass *housingDataClass;
@property(nonatomic, strong) DtMenuShoppingCarListDataClass *shoppingCarListDataClass;
@property(nonatomic, strong) NSString *areaName;
@property(nonatomic, assign) kHousingStateType housingStateType;

//入座时间
@property(nonatomic, strong) NSString *seatingTime;

//会员编号
@property(nonatomic, strong) NSString *userNumber;

//人数
@property(nonatomic, strong) NSString *numberOfPeople;


// 是否已经修改
@property(nonatomic, assign)BOOL isModified_;

// 是否添加了新菜且未提交.
@property(nonatomic, assign)BOOL isAddNewDish_;

/**
 * @brief   尝试关闭视图。
 *
 */
- (void)tryDismissView;

/**
 *  添加新菜品
 *
 *  @param newDishDic 新菜品数据(未解析)
 *  @param dishIsPackage 是否套餐
 */
- (void)addNewDish:(NSDictionary *)newDishDic dishIsPackage:(BOOL)flag;

@end
