//
//  DiningTableSuperDataClass.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import <Foundation/Foundation.h>

@interface DiningTableDataClass : NSObject

@property (nonatomic, strong) NSMutableArray *diningTableDataArray;
@property (nonatomic, strong) NSDictionary *statusSettingDict;

- (id)initWithDiningTableData:(NSDictionary *)dict;

@end

#pragma mark StatusSettingDataClass

@interface StatusSettingDataClass : NSObject

@property (nonatomic, strong) NSArray *bookingArray;//订座
@property (nonatomic, strong) NSArray *clearingArray;//清空
@property (nonatomic, strong) NSArray *disablingArray;//停用
@property (nonatomic, strong) NSArray *openingArray;//开台

- (id)initWithStatusSettingData:(NSDictionary *)dict;

@end

#pragma mark AreaDataClass

#define kAreaDataClassTypeIdKey @"typeId"
#define kAreaDataClassTypeNameKey @"typeName"
#define kAreaDataClassTableKey @"table"

@interface AreaDataClass : NSObject

@property (nonatomic, assign) int typeId;//房台区域id
@property (nonatomic, strong) NSString *typeName;//房台区域名称
@property (nonatomic, strong) NSMutableArray *housingDataArray;//房台区域下所有房台

- (id)initWithAreaData:(NSDictionary *)dict;
+ (NSDictionary *)addNewAreaData:(NSString *)areaName;
+ (NSDictionary *)deleteAreaData:(NSArray *)dtArray withIndex:(int)index;
+ (void)modifyAreaData:(NSArray *)dtArray withAreaName:(NSString *)nameStr withIndex:(int)index;
+ (void)modifyAreaData:(NSArray *)dtArray withHousingData:(NSArray *)housingArray withIndex:(int)index;

@end

#pragma mark HousingDataClass

#define kHousingId @"id"
#define kHousingStatus @"status"
#define kHousingName @"name"
#define kHousingUnconfirmed @"unconfirmed"

@interface HousingDataClass : NSObject

@property (nonatomic, assign) int housingId;//房台id
@property (nonatomic, strong) NSString *housingName;//房台名称
@property (nonatomic, assign) int housingStatus;//房台状态
@property (nonatomic, assign) int unconfirmed;//房台未确认信息标识

- (id)initWithHousingData:(NSDictionary *)dict;
- (void)modifyHousingState:(NSMutableArray *)modifyArray withAddFlag:(BOOL)flag;
+ (void)addNewHousingData:(NSMutableArray *)dtArray withHousingStr:(NSString *)housingName;
+ (NSDictionary *)deleteHousingData:(NSArray *)dtArray withIndex:(int)index;
+ (void)modifyHousingData:(NSMutableArray *)dtArray withHousingName:(NSString *)housingStr withIndex:(int)index;

@end
