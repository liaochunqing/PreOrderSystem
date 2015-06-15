//
//  CuisineDataModel.h
//  PreOrderSystem
//
//  Created by mac on 14-6-30.
//  jhh_菜系(包括详细菜名)数据模型.
//

#import <Foundation/Foundation.h>
#import "CookbookDataClass.h"

@interface CuisineDataModel : NSObject

//菜系id
@property (nonatomic, assign) int cuisineId;

//菜系名称
@property (nonatomic, strong) NSString *cuisineName;

//菜系备注
@property (nonatomic, strong) NSArray *remarkArray;

//该菜系中的所有菜品(CookbookDataClass)
@property (nonatomic, strong) NSMutableArray *cookbookDataArr;

//服务器并未返回该项,自己添加的,用于标记该菜系下的菜品是否被全选.
@property (nonatomic,assign)BOOL isSelectedAllCookbook;

//服务器并未返回该项,自己添加的,用于保存菜牌套餐设置下 被选规则的索引.
@property (nonatomic,assign)NSInteger choose;

//服务器并未返回该项,自己添加的,用于保存菜牌套餐设置下 被选规则的数量.
@property (nonatomic,assign)NSInteger chooseNum;


/**
 *  jhh_解析出某个菜系下所有信息,包括菜品详细信息,价格信息
 *
 *  @param dic 菜系字典
 *
 *  @return self
 */
- (id)initAllDetailWithData:(NSDictionary *)dic;
@end
