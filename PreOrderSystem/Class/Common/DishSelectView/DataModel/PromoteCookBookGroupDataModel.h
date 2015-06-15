//
//  PromoteCookBookGroupDataModel.h
//  PreOrderSystem
//
//  Created by mac on 14-7-17.
//
//菜式优惠组合数据模型.

#import <Foundation/Foundation.h>

@interface PromoteCookBookGroupDataModel : NSObject

//优惠Key(用于获取"groupCookbook"字段.
@property (nonatomic,strong)NSString *promoteKey;

//优惠number(编号)
@property (nonatomic,strong)NSString *promoteNumber;

//优惠名称
@property (nonatomic,strong)NSString *promoteName;

//优惠组合中的所有菜式
@property (nonatomic,strong)NSMutableArray *groupCookbookArr;

//是否被启用
@property (nonatomic,assign)BOOL isActive;

//优惠组合是否被选中
@property (nonatomic)BOOL isSelected;

//优惠组合是否展开
@property (nonatomic)BOOL isSpread;

@end
