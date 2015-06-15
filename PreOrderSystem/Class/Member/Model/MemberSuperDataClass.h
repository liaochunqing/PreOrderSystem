//
//  MemberSuperDataClass.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-25.
//
//

#import <Foundation/Foundation.h>
#import "QueueArrangDataClass.h"


#pragma mark - MemberCouponTypeDataClass

@interface MemberCouponTypeDataClass : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) BOOL isChecked;

- (id)initWithMemberCouponTypeData:(NSDictionary *)dict;

@end

#pragma mark - MemberFilterSettingDataClass

@interface MemberTypeCountDataClass : NSObject

@property (nonatomic, strong) NSString *name;//优惠券名称
@property (nonatomic, assign) NSInteger quantity;//总数
@property (nonatomic, assign) NSInteger remain;//剩余数
@property (nonatomic, assign) NSInteger used;//使用数

- (id)initWithMemberTypeCountData:(NSDictionary *)dict;

@end

#pragma mark - MemberDishDataClass

@interface MemberDishDataClass : NSObject

@property (nonatomic, strong) NSString *name;//菜品名称
@property (nonatomic, assign) NSInteger quantity;//数量
@property (nonatomic, strong) NSArray *currentRemarkArray;//当前备注
@property (nonatomic, strong) NSString *currentPriceStr;//当前价格

- (id)initWithMemberDishData:(NSDictionary *)dict;

@end

#pragma mark - MemberUseCountDataClass

@interface MemberUseCountDataClass : NSObject

@property (nonatomic, strong) NSString *couponAmountStr;//优惠券金额
@property (nonatomic, strong) NSString *orderCostStr;//订单总价
@property (nonatomic, strong) NSString *usedTime;//使用时间
@property (nonatomic, strong) NSString *userName;//用户名
@property (nonatomic, strong) NSString *userMobile;// 手机号
@property (nonatomic, strong) NSString *remark;//备注
@property (nonatomic, strong) NSArray *dishesArray;// 所点菜，结构同房台－获取购物车 

- (id)initWithMemberUseCountData:(NSDictionary *)dict;

@end

#pragma mark - MemberCurrentSortDataClass

@interface MemberCurrentSortDataClass : NSObject

@property (nonatomic, strong) NSString *fieldStr;
@property (nonatomic, assign) BOOL orderFlag;//0升序，1降序

- (id)initWithMemberCurrentSortData:(NSDictionary *)dict;

@end

#pragma mark - MemberSuperDataClass

@interface MemberSuperDataClass : NSObject

/// 排序
@property (nonatomic, strong) MemberCurrentSortDataClass *currentSortClass;
/// 优惠券类型列表
@property (nonatomic, strong) NSArray *couponTypeArray;
/// 时间选择列表
@property (nonatomic, strong) NSArray *dateTypeArray;
/// 可排序的字段
@property (nonatomic, strong) NSArray *sortFieldArray;
/// 优惠券类型统计
@property (nonatomic, strong) NSArray *typeCountArray;
/// 优惠券使用记录
@property (nonatomic, strong) NSArray *useCountArray;
/// 开始时间
@property (nonatomic, strong) NSString *startDate;
/// 结束时间
@property (nonatomic, strong) NSString *endDate;
/// 时间字符串索引
@property (nonatomic, assign) NSInteger dateStrIndex;
/// 当前页
@property (nonatomic, assign) NSInteger useCurrentPage;/*优惠券使用记录列表，当前页*/
/// 总页数
@property (nonatomic, assign) NSInteger useTotalPage;/*优惠券使用记录列表，总页数*/

- (id)initWithMemberSuperData:(NSDictionary *)dict;

@end



