//
//  QueueCategoryDataClass.h
//  PreOrderSystem_iPhone
//
//  Created by SWen on 13-3-8.
//  Copyright (c) 2013年 sWen. All rights reserved.
//  排号类别

#import <Foundation/Foundation.h>

#define kQueueCategoryDataClassIdKey @"id"
#define kQueueCategoryDataClassNameKey @"name"
#define kQueueCategoryDataClassMinCapacityKey @"minCapacity"
#define kQueueCategoryDataClassMaxCapacityKey @"maxCapacity"

@interface QueueCategoryDataClass : NSObject

@property (nonatomic, assign) int categoryId;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, assign) int maxCapacity;
@property (nonatomic, assign) int minCapacity;

- (id)initWithQueueCategoryData:(NSDictionary *)dict;

@end
