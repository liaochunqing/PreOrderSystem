//
//  PromotionDishSelectView.h
//  PreOrderSystem
//
//  Created by SWen on 14-7-22.
//
//
#import <UIKit/UIKit.h>
#import "UITableView+DataSourceBlocks.h"
#import "TableViewWithBlock.h"
#import "UIGridView.h"
#import "UIGridViewDelegate.h"
#import "CookbookPath.h"
#import "NumPicker.h"
#import "DishCardNewViewClass.h"

@class PromotionDishSelectView;
#define kDelectDishFromCarNotification @"DelectDishFromCarNotification"
#define kEditDishFromDishCardNotification @"EditDishFromDishCardNotification"


@protocol PromotionDishSelectViewDelegate <NSObject>
//选中某一个或一组菜
- (void)PromotionDishSelectView:(PromotionDishSelectView *)disSelectView didSelectedCookbookPathArr:(NSMutableArray *)indexArr;
// 取消一个或多个菜的选中状态
- (void)PromotionDishSelectView:(PromotionDishSelectView *)disSelectView didRemovedCookbookPathArr:(NSMutableArray *)indexArr;
// 点击确定按钮
- (void)PromotionDishSelectView:(PromotionDishSelectView *)dishSelectView pressSureButtonWithClass:(DishCardNewViewClass *)dict;
@end

@interface PromotionDishSelectView: UIView <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic,weak)id <PromotionDishSelectViewDelegate> delegate;

//输入菜系名称
@property (nonatomic, strong)UITextField *cuisinesNameTextField;

//显示菜系下拉列表按钮
@property (nonatomic, strong)UIButton *showCuisineListBtn;

//菜系下拉列表.
//@property (nonatomic,strong)TableViewWithBlock *showCuisineTableView;
@property (nonatomic,strong)UITableView *comboxTableView;

//供选择的List风格菜单
@property (nonatomic,strong)UITableView *originalMenuTableView;

//加工后的数据源,菜系&&菜品
@property (nonatomic,strong)NSMutableArray *allCuisineArr;

//被选中的菜品
@property (nonatomic,strong)NSMutableArray *selectedArr;

//标记当前选中的菜系在allCuisineArr数组中的位置.
@property (nonatomic,assign)int selectedCuisineIndex;

//菜系明细列表
@property (nonatomic,strong)NSMutableArray *detailArray;
//是否使用九宫格风格的cell
@property (nonatomic,assign)BOOL isUseStyleBoxCell;

/*
 在电话外卖中,isAddDishOnly为YES,点击左边菜单,没有勾选图片,点击一次就相当于添加一道菜,没有全选选项.
 
 其他地方则默认isAddDishOnly为NO,即点击一次添加,再次点击则为删除.
 */
@property (nonatomic,assign)BOOL isAddDishOnly;

@property (nonatomic,assign)BOOL isEdit;


//数据有变动时,刷新
- (void)reloadData;

/**
 *  建立数据模型
 *
 *  @param dataArr 服务器返回的所有菜系菜品数组.
 */
- (void)setSelectDataModel:(NSArray *)dataArr selectedDishCardDict:(NSDictionary *)dishCardDict;
@end
