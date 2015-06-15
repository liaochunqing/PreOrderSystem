//
//  DishSelectView.h
//  PreOrderSystem
//
//  Created by mac on 14-7-4.
//
//

#import <UIKit/UIKit.h>
#import "UITableView+DataSourceBlocks.h"
#import "TableViewWithBlock.h"
#import "UIGridView.h"
#import "UIGridViewDelegate.h"
#import "CookbookPath.h"
#import "NumPicker.h"
#import "EGORefreshTableHeaderView.h"

#define kDelectDishFromCarNotification @"DelectDishFromCarNotification"

@class DishSelectView;
@protocol DishSelectViewDelegate <NSObject>
@optional
/**
 *  选中某一个或一组菜
 *
 *  @param disSelectView self
 *  @param indexArr      菜的索引
 */
- (void)DishSelectVieW:(DishSelectView *)disSelectView didSelectedCookbookPathArr:(NSMutableArray *)indexArr;

/**
 *  取消一个或多个菜的选中状态
 *
 *  @param disSelectView self
 *  @param indexArr      菜的索引.
 */
- (void)DishSelectVieW:(DishSelectView *)disSelectView didRemovedCookbookPathArr:(NSMutableArray *)indexArr;

/**
 *  下拉刷新,通知父视图重新获取数据.
 *
 *  @param disSelectView self
 *  @param view          下拉刷新界面
 */
- (void)DishSelectView:(DishSelectView *)disSelectView DidTriggerRefresh:(EGORefreshTableHeaderView*)view;

@end

@interface DishSelectView : UIView <UITableViewDataSource,UITableViewDelegate,UIGridViewDelegate,UITextFieldDelegate,EGORefreshTableHeaderDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>


@property (nonatomic,weak)id <DishSelectViewDelegate> delegate;

//输入菜系名称
@property (nonatomic, strong)UITextField *cuisinesNameTextField;

//显示菜系下拉列表按钮
@property (nonatomic, strong)UIButton *showCuisineListBtn;

//菜系下拉列表.
@property (nonatomic,strong)TableViewWithBlock *showCuisineTableView;

//切换九宫格按钮
@property (nonatomic,strong)UIButton *styleBoxBtn;

//切换列表按钮
@property (nonatomic,strong)UIButton *styleListBtn;

//供选择的List风格菜单
@property (nonatomic,strong)UITableView *originalMenuTableView;

//供选择的九宫格菜单
@property (nonatomic,strong)UIGridView *styleBoxGridView;

//加工后的数据源,菜系&&菜品
@property (nonatomic,strong)NSMutableArray *allCuisineArr;

//被选中的菜品
@property (nonatomic,strong)NSMutableArray *selectedArr;

//标记当前选中的菜系在allCuisineArr数组中的位置.
@property (nonatomic,assign)int selectedCuisineIndex;

//是否使用九宫格风格的cell
@property (nonatomic,assign)BOOL isUseStyleBoxCell;

// originalMenuTableView中的下拉刷新视图
@property (nonatomic,strong)EGORefreshTableHeaderView *originalRefreshHeaderView;

//下拉刷新用到的一个变量,作用未知
@property (nonatomic,assign)BOOL reloading;


/*
    在电话外卖中,isAddDishOnly为YES,点击左边菜单,没有勾选图片,点击一次就相当于添加一道菜,没有全选选项.
 
    其他地方则默认isAddDishOnly为NO,即点击一次添加,再次点击则为删除.
*/
@property (nonatomic,assign)BOOL isAddDishOnly;

//切换输入菜品ID/常规头部视图按钮,
@property (nonatomic,strong)UISwitch *switchHeadViewBtn;

//默认的头部视图,装载菜系选择/九宫格/列表按钮
@property (nonatomic,strong)UIView *commonHeadView;

//通过输入菜品ID添加菜式,当按下switchHeadViewBtn时显示.
@property (nonatomic,strong)UIView *addDishByIDView;

//cookbookID输入框(放进addDishByIDView中)
@property (nonatomic,strong)UITextField *cookbookIDTextFied;

//数据有变动时,刷新
- (void)reloadData;

/**
 *  建立数据模型
 *
 *  @param dataArr 服务器返回的所有菜系菜品数组.
 */
- (void)setSelectDataModel:(NSArray *)dataArr;

/**
 *  设置下拉刷新
 */
- (void)setEGORefreshView;

/**
 *  删除通知
 */
- (void)removeNotification;


/**
 *  设置通过ID输入ID直接添加菜品的UI,
 */
- (void)addDishByID;



@end


