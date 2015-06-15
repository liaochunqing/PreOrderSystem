//
//  QueueArrangDataClass.m
//  PreOrderSystem_iPhone
//
//  Created by SWen on 13-3-8.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import "QueueArrangDataClass.h"

@implementation QueueArrangDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithArrangData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.arrangId = [[dict objectForKey:@"arrangId"] integerValue];
        self.peopleNumber = [[dict objectForKey:@"peopleNumber"] integerValue];
        self.serialNumberStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"serialNumber"]];
        self.mobileNumber = [NSString stringWithFormat:@"%@",[dict objectForKey:@"mobileNumber"]];
        self.statusValue = [[dict objectForKey:@"statusValue"] integerValue];
        self.remark = [dict objectForKey:@"remark"];

        NSMutableArray *dishMutableArray = [[NSMutableArray alloc] init];
        NSArray *dishArray = [dict objectForKey:@"dishes"];
        for (NSDictionary *dishDict in dishArray)
        {
            QueueArrangDishDataClass *dishClass = [[QueueArrangDishDataClass alloc] initWithArrangDishData:dishDict];
            [dishMutableArray addObject:dishClass];
        }
        self.dishesArray = dishMutableArray;
    }
    return self;
}

@end

#pragma mark - QueueArrangDishDataClass

@implementation QueueArrangDishDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithArrangDishData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.name = [dict objectForKey:@"name"];
        self.quantity = [[dict objectForKey:@"quantity"] integerValue];
        self.currentPriceStr = [NSString stringWithFormat:@"%@", [dict objectForKey:@"currentPrice"]];
        self.originalPriceStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"originalPrice"]];

        NSMutableArray *currentRemarkMutableArray = [[NSMutableArray alloc] init];
        NSArray *currentRemarkArray = [dict objectForKey:@"currentRemark"];
        for (NSDictionary *remarkDict in currentRemarkArray)
        {
            QueueArrangDishRemarkDataClass *remarkClass = [[QueueArrangDishRemarkDataClass alloc] initWithQueueArrangDishRemarkData:remarkDict];
            [currentRemarkMutableArray addObject:remarkClass];
        }
        self.currentRemarkArray = currentRemarkMutableArray;
        
        /*
        self.cuisineRemarkArray = [dict objectForKey:@"remark"];
        self.currentStyle = [dict objectForKey:@"currentStyle"];
        self.priceArray = [dict objectForKey:@"price"];
        self.packageArray = [dict objectForKey:@"package"];
         */
    }
    return self;
}

@end

#pragma mark - QueueArrangDishRemarkDataClass

@implementation QueueArrangDishRemarkDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithQueueArrangDishRemarkData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.contentArray = [dict objectForKey:@"item"];
        self.quantity = [[dict objectForKey:@"num"] integerValue];
    }
    return self;
}

@end
