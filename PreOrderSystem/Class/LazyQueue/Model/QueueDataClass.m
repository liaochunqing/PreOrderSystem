//
//  QueueDataClass.m
//  PreOrderSystem_iPhone
//
//  Created by SWen on 13-3-8.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import "QueueDataClass.h"

@implementation QueueDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithQueueData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.categoryId = [[dict objectForKey:@"categoryId"] integerValue];
        self.maxNumber = [[dict objectForKey:@"maxNumber"] integerValue];
        self.queueCount = [[dict objectForKey:@"queueCount"] integerValue];
        self.categoryName = [dict objectForKey:@"categoryName"];
        self.arrangListArray = [dict objectForKey:@"arrangList"];
    }
    return self;
}

@end
