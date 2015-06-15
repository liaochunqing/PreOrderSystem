//
//  QueueCategoryDataClass.m
//  PreOrderSystem_iPhone
//
//  Created by SWen on 13-3-8.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import "QueueCategoryDataClass.h"

@implementation QueueCategoryDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithQueueCategoryData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.categoryId = [[dict objectForKey:kQueueCategoryDataClassIdKey] integerValue];
        self.categoryName = [NSString stringWithFormat:@"%@",[dict objectForKey:kQueueCategoryDataClassNameKey]];
        self.minCapacity = [[dict objectForKey:kQueueCategoryDataClassMinCapacityKey] integerValue];
        self.maxCapacity = [[dict objectForKey:kQueueCategoryDataClassMaxCapacityKey] integerValue];
    }
    return self;
}

@end
