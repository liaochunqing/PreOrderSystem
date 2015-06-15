//
//  QueueArrangDataClass.h
//  PreOrderSystem_iPhone
//
//  Created by SWen on 13-3-8.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueueArrangDataClass : NSObject

@property (nonatomic, assign) NSInteger arrangId;
@property (nonatomic, assign) NSInteger peopleNumber;
@property (nonatomic, strong) NSString *serialNumberStr;
@property (nonatomic, assign) NSInteger statusValue;
@property (nonatomic, strong) NSString *mobileNumber;//手机号
@property (nonatomic, strong) NSString *remark;//狗仔队的备注
@property (nonatomic, strong) NSArray *dishesArray;//点菜数据

- (id)initWithArrangData:(NSDictionary *)dict;

@end

#pragma mark - QueueArrangDishDataClass

@interface QueueArrangDishDataClass : NSObject

@property (nonatomic, strong) NSString *name;//菜品名称
@property (nonatomic, assign) NSInteger quantity;//数量
@property (nonatomic, strong) NSArray *currentRemarkArray;//当前备注
@property (nonatomic, strong) NSString *currentPriceStr;//当前价格
@property (nonatomic, strong) NSString *originalPriceStr;

/*
@property (nonatomic, strong) NSArray *cuisineRemarkArray;//备注
@property (nonatomic, strong) NSString *currentStyle;//当前样式
@property (nonatomic, strong) NSArray *priceArray;
@property (nonatomic, strong) NSArray *packageArray;
 */

- (id)initWithArrangDishData:(NSDictionary *)dict;

@end

#pragma mark - QueueArrangDishRemarkDataClass

@interface QueueArrangDishRemarkDataClass : NSObject

@property (nonatomic, strong) NSArray *contentArray;
@property (nonatomic, assign) NSInteger quantity;

- (id)initWithQueueArrangDishRemarkData:(NSDictionary *)dict;

@end
