//
//  CookbookDataClass.h
//  PreOrderSystem
//
//  Created by mac on 14-6-30.
//
//  jhh_单个菜品数据模型.

#import <Foundation/Foundation.h>
#import "CuisineDataModel.h"
#import "CookbookPriceDataClass.h"


@interface CookbookDataClass : NSObject

//菜品id
@property (nonatomic,assign)NSUInteger cookbookID;

//菜品名称
@property (nonatomic,strong)NSString *cookbookName;

//菜品代码
@property (nonatomic,strong)NSString *cookbookCode;

//菜品图片
@property (nonatomic,strong)NSString *cookbookPicture;

//是否沽清
@property (nonatomic,assign)NSUInteger isSoldOut;

//是否暂停
@property (nonatomic,assign)BOOL isActive;

//是否允许外卖
@property (nonatomic,assign)NSUInteger isAllowTakeout;

//介绍
@property (nonatomic,strong)NSString *introduction;

//打包费
@property (nonatomic,assign)NSInteger packfee;

//价格
@property (nonatomic,strong)NSMutableArray *priceArr;

//菜系id,菜品字段中本无此项,加上方便些,
@property (nonatomic, assign) int cuisineId;

//菜系名称 菜品字段中本无此项,加上方便些,
@property (nonatomic, strong) NSString *cuisineName;

//该菜系在所有菜系数组中的index,(仅在EditDiscountViewController.m 中启用)
@property (nonatomic,assign) NSInteger cuisineIndex;

//是否被选中(服务器并未返回该项,自己添加,用于标记该菜是否被放进某优惠活动中.)
@property (nonatomic,assign)BOOL isSelected;

//设置优惠套餐组合时,用户自定义的价格,仅在优惠套餐组合接口中用到.
@property (nonatomic,strong)NSString *userDefinedPrice;

//这道菜被点了多少份,(服务器并未返回该项,自己添加,用于标记点菜时该菜点了几份)
@property (nonatomic,assign)int dishCount;

//份数(菜牌套餐设置使用)
@property (nonatomic, assign) NSInteger quantity;
//**********************以下为房台-获取菜品列表接口才有的字段:**********************

//价格是否多样式
@property (nonatomic,assign)BOOL isMultiStyle;

//套餐"package"字段原始数据，未解析,非套餐则数组为0个数据.
@property (nonatomic,strong)NSArray *packageArr;

//存放套餐数据模型(PackageDataModel *),已解析.非套餐则数组为0个数据
@property (nonatomic,strong)NSMutableArray *packageDataArr;

- (id)initWithCookbookDic:(NSDictionary *)cookbookDic;

@end
