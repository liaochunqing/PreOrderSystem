//
//  DishCardDataClass.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-28.
//
//

#import <Foundation/Foundation.h>
#import "SuperDataClass.h"


@interface DishCardDataClass : NSObject


@end

#pragma mark - DishCardRemarkListDataClass

@interface DishCardRemarkListDataClass : NSObject

@property (nonatomic, strong) NSMutableArray *remarkListArray;

- (id)initWithDishCardRemarkListData:(NSDictionary *)dict;

@end

#pragma mark - DishCardRemarkDataClass

#define kDishCardRemarkDataClassRemarkKey @"remark"
#define kDishCardRemarkDataClassDeleteRemarkKey @"deleteRemark"

@interface DishCardRemarkDataClass : NSObject

@property (nonatomic, assign) int cuisineId;//菜系id
@property (nonatomic, strong) NSString *cuisineName;//菜系名称
@property (nonatomic, strong) NSMutableArray *remarkArray;

@property (nonatomic, strong) NSMutableArray *deleteRemarkArray;/*这个时间服务器并没有传过来，为了方便处理数据，自己加上的*/

- (id)initWithDishCardRemarkData:(NSDictionary *)dict;

@end

#pragma mark - DishCardRemarkDetailDataClass

#define kRemarkId @"id"
#define kRemarkName @"name"

@interface DishCardRemarkDetailDataClass : NSObject

@property (nonatomic, assign) int id;
@property (nonatomic, strong) NSString *name;

- (id)initWithDishCardRemarkDetailData:(NSDictionary *)dict;
+ (void)addNewRemarkDetailData:(NSMutableArray *)dtArray withRemarkStr:(NSString *)remarkName;
+ (NSDictionary *)deleteRemarkData:(NSArray *)dtArray withIndex:(int)index;
+ (void)modifyRemarkData:(NSMutableArray *)dtArray withRemarkName:(NSString *)remarkStr withIndex:(int)index;

@end

