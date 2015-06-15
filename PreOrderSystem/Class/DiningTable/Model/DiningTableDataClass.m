//
//  DiningTableSuperDataClass.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import "DiningTableDataClass.h"


@implementation DiningTableDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithDiningTableData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.diningTableDataArray = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"diningTable"]];
        self.statusSettingDict = [dict objectForKey:@"statusSetting"];
    }
    return self;
}

@end

#pragma mark StatusSettingDataClass

@implementation StatusSettingDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithStatusSettingData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.bookingArray = [dict objectForKey:@"booking"];
        self.disablingArray = [dict objectForKey:@"disabling"];
        self.clearingArray = [dict objectForKey:@"clearing"];
        self.openingArray = [dict objectForKey:@"opening"];
    }
    return self;
}

@end

#pragma mark AreaDataClass

@implementation AreaDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithAreaData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.typeId = [[dict objectForKey:kAreaDataClassTypeIdKey] integerValue];
        self.typeName = [dict objectForKey:kAreaDataClassTypeNameKey];
        self.housingDataArray = [dict objectForKey:kAreaDataClassTableKey];
    }
    return self;
}

+ (NSDictionary *)addNewAreaData:(NSString *)areaName
{
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
    [newDict setObject:@"0" forKey:@"typeId"];
    [newDict setObject:areaName forKey:@"typeName"];
    [newDict setObject:[NSArray array] forKey:@"table"];
    return newDict;
}

+ (NSDictionary *)deleteAreaData:(NSArray *)dtArray withIndex:(int)index
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[dtArray objectAtIndex:index]];
    [tempDict setObject:@"" forKey:@"typeName"];
    return tempDict;
}

+ (void )modifyAreaData:(NSMutableArray *)dtArray withAreaName:(NSString *)nameStr  withIndex:(int)index
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[dtArray objectAtIndex:index]];
    [tempDict setObject:nameStr forKey:@"typeName"];
    [dtArray replaceObjectAtIndex:index withObject:tempDict];
}

+ (void)modifyAreaData:(NSMutableArray *)dtArray withHousingData:(NSArray *)housingArray  withIndex:(int)index
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[dtArray objectAtIndex:index]];
    [tempDict setObject:housingArray forKey:@"table"];
    [dtArray replaceObjectAtIndex:index withObject:tempDict];
}

@end

#pragma mark HousingDataClass

@implementation HousingDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithHousingData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.housingId = [[dict objectForKey:kHousingId] integerValue];
        self.housingStatus = [[dict objectForKey:kHousingStatus] integerValue];
        self.housingName = [dict objectForKey:kHousingName];
        self.unconfirmed = [[dict objectForKey:kHousingUnconfirmed] integerValue];
    }
    return self;
}

- (void)modifyHousingState:(NSMutableArray *)modifyArray withAddFlag:(BOOL)flag
{
    if (flag)
    {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        [newDict setObject:[NSNumber numberWithInt:self.housingId] forKey:kHousingId];
        [newDict setObject:[NSNumber numberWithInt:self.housingStatus] forKey:kHousingStatus];
        [modifyArray addObject:newDict];
    }
    else
    {
        for (int i = 0; i < [modifyArray count]; i++)
        {
            NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:[modifyArray objectAtIndex:i]];
            int tempId = [[newDict objectForKey:kHousingId] integerValue];
            if (tempId == self.housingId)
            {
                [modifyArray removeObject:newDict];
                break;
            }
        }
    }
}

+ (void)addNewHousingData:(NSMutableArray *)dtArray withHousingStr:(NSString *)housingName
{
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
    [newDict setObject:@"0" forKey:kHousingId];
    [newDict setObject:housingName forKey:kHousingName];
    [dtArray addObject:newDict];
}

+ (NSDictionary *)deleteHousingData:(NSArray *)dtArray withIndex:(int)index
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[dtArray objectAtIndex:index]];
    [tempDict setObject:@"" forKey:kHousingName];
    return tempDict;
}

+ (void)modifyHousingData:(NSMutableArray *)dtArray withHousingName:(NSString *)housingStr withIndex:(int)index
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[dtArray objectAtIndex:index]];
    [tempDict setObject:housingStr forKey:kHousingName];
    [dtArray replaceObjectAtIndex:index withObject:tempDict];
}

@end
