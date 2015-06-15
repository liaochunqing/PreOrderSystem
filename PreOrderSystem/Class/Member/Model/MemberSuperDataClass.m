//
//  MemberSuperDataClass.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-25.
//
//

#import "MemberSuperDataClass.h"

#pragma mark - MemberCouponTypeDataClass

@implementation MemberCouponTypeDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%s,%@===", __FUNCTION__, self.class);
#endif
}

- (id)initWithMemberCouponTypeData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.name = [NSString stringWithFormat:@"%@", [dict objectForKey:@"name"]];
        self.value = [NSString stringWithFormat:@"%@", [dict objectForKey:@"value"]];
        self.isChecked = [[dict objectForKey:@"checked"] boolValue];
    }
    return self;
}

@end

#pragma mark - MemberTypeCountDataClass

@implementation MemberTypeCountDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%s,%@===", __FUNCTION__, self.class);
#endif
}

- (id)initWithMemberTypeCountData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.name = [NSString stringWithFormat:@"%@", [dict objectForKey:@"name"]];
        self.quantity = [[dict objectForKey:@"quantity"] longLongValue];
        self.remain = [[dict objectForKey:@"remain"] longLongValue];
        self.used = [[dict objectForKey:@"used"] longLongValue];
    }
    return self;
}

@end

#pragma mark - MemberDishDataClass

@implementation MemberDishDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithMemberDishData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.name = [dict objectForKey:@"name"];
        self.quantity = [[dict objectForKey:@"quantity"] integerValue];
        self.currentPriceStr = [NSString stringWithFormat:@"%@", [dict objectForKey:@"currentPrice"]];
        
        NSMutableArray *currentRemarkMutableArray = [[NSMutableArray alloc] init];
        NSArray *currentRemarkArray = [dict objectForKey:@"currentRemark"];
        for (NSDictionary *remarkDict in currentRemarkArray)
        {
            QueueArrangDishRemarkDataClass *remarkClass = [[QueueArrangDishRemarkDataClass alloc] initWithQueueArrangDishRemarkData:remarkDict];
            [currentRemarkMutableArray addObject:remarkClass];
        }
        self.currentRemarkArray = currentRemarkMutableArray;
    }
    return self;
}

@end

#pragma mark - MemberUseCountDataClass

@implementation MemberUseCountDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%s,%@===", __FUNCTION__, self.class);
#endif
}

- (id)initWithMemberUseCountData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.couponAmountStr = [NSString stringWithFormat:@"%@", [dict objectForKey:@"couponAmount"]];
        self.orderCostStr = [NSString stringWithFormat:@"%@", [dict objectForKey:@"orderCost"]];
        self.usedTime = [dict objectForKey:@"usedTime"];
        self.userName = [dict objectForKey:@"userName"];
        self.userMobile = [dict objectForKey:@"userMobile"];
        self.remark = [dict objectForKey:@"remark"];
        
        NSMutableArray *dishesMutableArray = [[NSMutableArray alloc] init];
        NSArray *dishesArray = [dict objectForKey:@"dishes"];
        for (NSDictionary *dishDict in dishesArray)
        {
            MemberDishDataClass *dishClass = [[MemberDishDataClass alloc] initWithMemberDishData:dishDict];
            [dishesMutableArray addObject:dishClass];
        }
        self.dishesArray = dishesMutableArray;
    }
    return self;
}

@end

#pragma mark - MemberCurrentSortDataClass

@implementation MemberCurrentSortDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%s,%@===", __FUNCTION__, self.class);
#endif
}

- (id)initWithMemberCurrentSortData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.fieldStr = [dict objectForKey:@"field"];
        self.orderFlag = [[dict objectForKey:@"order"] boolValue];
    }
    return self;
}

@end

#pragma mark - MemberSuperDataClass

@implementation MemberSuperDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%s,%@===", __FUNCTION__, self.class);
#endif
}

- (id)initWithMemberSuperData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        MemberCurrentSortDataClass *sortClass = [[MemberCurrentSortDataClass alloc] initWithMemberCurrentSortData:[dict objectForKey:@"currentSort"]];
        
        self.currentSortClass = sortClass;
        self.sortFieldArray = [dict objectForKey:@"sortField"];
        
        NSMutableArray *couponTypeMutableArray = [[NSMutableArray alloc] init];
        NSArray *couponArray = [dict objectForKey:@"type"];
        for (NSDictionary *typeDict in couponArray)
        {
            MemberCouponTypeDataClass *typeClass = [[MemberCouponTypeDataClass alloc] initWithMemberCouponTypeData:typeDict];
            [couponTypeMutableArray addObject:typeClass];
        }
        self.couponTypeArray = couponTypeMutableArray;
        
        NSArray *dateArray = [dict objectForKey:@"date"];
        if (dateArray.count > 0) {
            self.dateTypeArray = [NSMutableArray arrayWithArray:dateArray];
        } else {
            self.dateTypeArray = [NSMutableArray array];
        }
        
        NSMutableArray *typeCountMutableArray = [[NSMutableArray alloc] init];
        NSArray *typeCountArray = [dict objectForKey:@"typeCount"];
        for (NSDictionary *typeCountDict in typeCountArray)
        {
            MemberTypeCountDataClass *typeCount = [[MemberTypeCountDataClass alloc] initWithMemberTypeCountData:typeCountDict];
            [typeCountMutableArray addObject:typeCount];
        }
        self.typeCountArray = typeCountMutableArray;
        
        NSMutableArray *useCountMutableArray = [[NSMutableArray alloc] init];
        NSArray *useCountArray = [dict objectForKey:@"useCount"];
        for (NSDictionary *useCountDict in useCountArray)
        {
            MemberUseCountDataClass *useCount = [[MemberUseCountDataClass alloc] initWithMemberUseCountData:useCountDict];
            [useCountMutableArray addObject:useCount];
        }
        self.useCountArray = useCountMutableArray;
        self.useCurrentPage = [[dict objectForKey:@"useCurrentPage"] integerValue];
        self.useTotalPage = [[dict objectForKey:@"useTotalPage"] integerValue];
        
        self.startDate = @"";
        self.endDate = @"";
        self.dateStrIndex = -1;
    }
    return self;
}

@end




