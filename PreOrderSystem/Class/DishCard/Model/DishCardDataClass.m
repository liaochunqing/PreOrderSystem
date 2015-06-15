//
//  DishCardDataClass.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-28.
//
//

#import "DishCardDataClass.h"

@implementation DishCardDataClass

@end

#pragma mark DishCardRemarkListDataClass

@implementation DishCardRemarkListDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithDishCardRemarkListData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.remarkListArray = [dict objectForKey:@"remarkList"];
    }
    return self;
}

@end

#pragma mark DishCardRemarkDataClass

@implementation DishCardRemarkDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithDishCardRemarkData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.cuisineId = [[dict objectForKey:@"cuisineId"] integerValue];
        self.cuisineName = [dict objectForKey:@"cuisineName"];
        self.remarkArray = [dict objectForKey:@"remark"];
        self.deleteRemarkArray = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"kMenuRemarkDataClassDeleteRemarkKey"]];
    }
    return self;
}

@end

#pragma mark DishCardRemarkDetailDataClass

@implementation DishCardRemarkDetailDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithDishCardRemarkDetailData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.id = [[dict objectForKey:kRemarkId] integerValue];
        self.name = [dict objectForKey:kRemarkName];
    }
    return self;
}

+ (void)addNewRemarkDetailData:(NSMutableArray *)dtArray withRemarkStr:(NSString *)remarkName
{
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
    [newDict setObject:@"0" forKey:kRemarkId];
    [newDict setObject:remarkName forKey:kRemarkName];
    [dtArray insertObject:newDict atIndex:0];
}

+ (NSDictionary *)deleteRemarkData:(NSArray *)dtArray withIndex:(int)index
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[dtArray objectAtIndex:index]];
    [tempDict setObject:@"" forKey:kRemarkName];
    return tempDict;
}

+ (void)modifyRemarkData:(NSMutableArray *)dtArray withRemarkName:(NSString *)remarkStr withIndex:(int)index
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[dtArray objectAtIndex:index]];
    [tempDict setObject:remarkStr forKey:kRemarkName];
    [dtArray replaceObjectAtIndex:index withObject:tempDict];
}

@end

