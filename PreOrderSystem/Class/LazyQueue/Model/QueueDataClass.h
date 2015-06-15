//
//  QueueDataClass.h
//  PreOrderSystem_iPhone
//
//  Created by SWen on 13-3-8.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueueDataClass : NSObject

@property (nonatomic, strong) NSArray *arrangListArray;
@property (nonatomic, assign) NSInteger categoryId;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, assign) NSInteger maxNumber;
@property (nonatomic, assign) NSInteger queueCount;

- (id)initWithQueueData:(NSDictionary *)dict;

@end
