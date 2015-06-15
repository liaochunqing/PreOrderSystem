//
//  DtMenuDataClass.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-27.
//
//

#import "DtMenuDataClass.h"
#import "QueueArrangDataClass.h"

@implementation DtMenuListDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithDtMenuListData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        NSLog(@"^^^^^^^^^%@",dict);
        self.dtMenuListArray = [dict objectForKey:@"list"];
        NSMutableArray *queueListMutableArray = [[NSMutableArray alloc] init];
        NSArray *queueListArray = [dict objectForKey:@"qlist"];
       // NSLog(@">>>QQQ%@",[queueListArray objectAtIndex:0]);
        self.orderInfoDic = [dict objectForKey:@"orderInfo"];
        NSLog(@"****oooo%@",self.orderInfoDic);
        for (NSDictionary *queueDict in queueListArray)
        {
            DtQueueDataClass *dtQueueClass = [[DtQueueDataClass alloc] initWithDtQueueData:queueDict];
            [queueListMutableArray addObject:dtQueueClass];
        }
        self.queueListArray = queueListMutableArray;
    }
    return self;
}

@end

#pragma mark - DtQueueDataClass

@implementation DtQueueDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithDtQueueData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.queueIdStr = [NSString stringWithFormat:@"%@", [dict objectForKey:@"queueId"]];
        self.tableName = [dict objectForKey:@"table"];
        self.serialNumberStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"number"]];
        self.people = [[dict objectForKey:@"people"] integerValue];
        self.exceeded = [[dict objectForKey:@"exceeded"] boolValue];
        self.mobile = [NSString stringWithFormat:@"%@",[dict objectForKey:@"mobile"]];
        self.remark = [dict objectForKey:@"remark"];
        
        
        NSMutableArray *dishMutableArray = [[NSMutableArray alloc] init];
        NSArray *dishArray = [dict objectForKey:@"dishes"];
        for (NSDictionary *dishDict in dishArray)
        {
            QueueArrangDishDataClass *dishClass = [[QueueArrangDishDataClass alloc] initWithArrangDishData:dishDict];
            [dishMutableArray addObject:dishClass];
        }
        self.dishesArray = dishMutableArray;
        self.originDishesArray = dishArray;
    }
    return self;
}

@end

#pragma mark - DtMenuDataClass

@implementation DtMenuDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithDtMenuData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.cuisineName = [dict objectForKey:@"cuisineName"];
        self.remarkArray = [dict objectForKey:@"remark"];
        self.cookbookArray = [dict objectForKey:@"cookbook"];
    }
    return self;
}

@end

#pragma mark - DtMenuCookbookDataClass

@implementation DtMenuCookbookDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithDtMenuCookbookData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.cookID = [dict objectForKey:@"cbId"];
        self.name = [dict objectForKey:@"name"];
        self.priceArray = [dict objectForKey:@"price"];
        self.packageArray = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"package"]];
        self.isSoldOut = [[dict objectForKey:@"isSoldOut"] boolValue];
        self.isMultiStyle = [dict objectForKey:@"isMultiStyle"];
        self.isActive = [[dict objectForKey:@"isActive"]boolValue];
        self.packfee = [NSString stringWithFormat:@"%@",[dict objectForKey:@"packfee"]];
    }
    return self;
}

+ (void)modifyCookbookData:(NSMutableArray *)packageArray withPackage:(NSDictionary *)newDict withIndex:(int)index
{
    if (index < [packageArray count])
    {
        [packageArray replaceObjectAtIndex:index withObject:newDict];
    }
}

@end

#pragma mark - DtMenuCookbookPriceDataClass

@implementation DtMenuCookbookPriceDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithDtMenuPriceData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.promotePrice = [NSString stringWithFormat:@"%@",[dict objectForKey:@"promotePrice"]];
        self.style = [dict objectForKey:@"style"];
        self.priceStr = [NSString stringWithFormat:@"%@", [dict objectForKey:@"price"]];
    }
    return self;
}

@end

#pragma mark - DtMenuCookbookPackageDataClass

@implementation DtMenuCookbookPackageDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithDtMenuPackageData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.itemName = [dict objectForKey:@"itemName"];
        self.choiceType = [[dict objectForKey:@"choiceType"] integerValue];
        self.choiceNum = [[dict objectForKey:@"choiceNum"] integerValue];
        self.memberArray = [[NSMutableArray alloc] initWithArray:[dict objectForKey:kDtMenuCookbookPackageDataMemberKey]];
    }
    return self;
}

+ (void)modifyPackageData:(NSMutableArray *)memberArray withMember:(NSDictionary *)newDict withIndex:(int)index
{
    if (index < [memberArray count])
    {
        [memberArray replaceObjectAtIndex:index withObject:newDict];
    }
}

@end

#pragma mark - DtMenuCookbookPackageMemberDataClass

@implementation DtMenuCookbookPackageMemberDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithDtMenuPackageMemberData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.name = [dict objectForKey:@"name"];
        self.priceStr = [NSString stringWithFormat:@"%@", [dict objectForKey:kDtMenuCookbookPackageMemberPriceKey]];
        self.checked = [[dict objectForKey:kDtMenuCookbookPackageMemberCheckedKey] integerValue];
    }
    return self;
}

/*套餐栏目成员 dataClass*/

+ (DtMenuCookbookPackageMemberDataClass *)getPackageMemberDataClass:(int)index withPackageDataClass:(DtMenuCookbookPackageDataClass *)packageDataClass
{
    DtMenuCookbookPackageMemberDataClass *tempDataClass = nil;
    NSMutableArray *tempArray = packageDataClass.memberArray;
    if (index < [tempArray count])
    {
        tempDataClass = [[DtMenuCookbookPackageMemberDataClass alloc] initWithDtMenuPackageMemberData:[tempArray objectAtIndex:index]];
    }
    return tempDataClass;
}

@end

#pragma mark - DtMenuCookbookRemarkDataClass

@implementation DtMenuCookbookRemarkDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithDtMenuRemarkData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.contentArray = [[NSMutableArray alloc] initWithArray:[dict objectForKey:kRemarkContent]];
        self.quantity = [[dict objectForKey:kRemarkQuantity] integerValue];
    }
    return self;
}

+ (void)addNewRemarkData:(NSMutableArray *)remarkArray
{
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
    [newDict setObject:[NSNumber numberWithInt:1] forKey:kRemarkQuantity];
    [newDict setObject:[NSMutableArray array] forKey:kRemarkContent];
    [remarkArray insertObject:newDict atIndex:0];
}

+ (void)addNewRemarkDataToLast:(NSMutableArray *)remarkArray
{
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
    [newDict setObject:[NSNumber numberWithInt:1] forKey:kRemarkQuantity];
    [newDict setObject:[NSMutableArray array] forKey:kRemarkContent];
    [remarkArray addObject:newDict];
}


+ (void)modifyRemarkData:(NSMutableArray *)remarkArray withIndex:(int)index withQuantity:(int)quantity
{
    NSMutableArray *tempArray = remarkArray;
    int tempCount = [tempArray count];
    if (index < tempCount)
    {
        if (0 == quantity)
        {
            [remarkArray removeObjectAtIndex:index];
        }
        else
        {
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[remarkArray objectAtIndex:index]];
            [tempDict setObject:[NSNumber numberWithInt:quantity] forKey:kRemarkQuantity];
            [remarkArray replaceObjectAtIndex:index withObject:tempDict];
        }
    }
}

+ (void)modifyRemarkData:(NSMutableArray *)remarkArray withIndex:(int)index withRemarkName:(NSString *)remarkStr
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[remarkArray objectAtIndex:index]];
    [tempDict setObject:remarkStr forKey:kRemarkContent];
    [remarkArray replaceObjectAtIndex:index withObject:tempDict];
}

@end

#pragma mark - DtMenuShoppingCarListDataClass

@implementation DtMenuShoppingCarListDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithDtMenuShoppingCarListData:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.corpInfoDict = [dict objectForKey:@"corpInfo"];
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"dishes"]];
        
        for (NSMutableDictionary *tempDict in tempArray)
        {
            [tempDict setObject:[NSNumber numberWithInt:0] forKey:@"foldOrspreadStatus"];
        }
        self.dishesArray = [[NSMutableArray alloc] initWithArray:tempArray];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    DtMenuShoppingCarListDataClass *copy = [[[self class] allocWithZone:zone] init];
    copy.corpInfoDict = [[self class] duplicateObject:self.corpInfoDict];
    copy.dishesArray = [[self class] duplicateObject:self.dishesArray];
    return copy;
}

+ (id)duplicateObject:(id)obj
{
    if ([obj isKindOfClass:[NSArray class]] || [[obj class] isSubclassOfClass:[NSArray class]]) {
        // 数组
        NSMutableArray *duplicateArray = [[NSMutableArray alloc] init];
        for (NSObject *child in (NSArray *)obj) {
            [duplicateArray addObject:[self duplicateObject:child]];
        }
        return duplicateArray;
    } else if ([obj isKindOfClass:[NSDictionary class]] ||
               [[obj class] isSubclassOfClass:[NSDictionary class]]) {
        // 字典
        NSMutableDictionary *duplicateDictionary = [[NSMutableDictionary alloc] init];
        NSArray *allKeys = [(NSDictionary *)obj allKeys];
        for (NSString *keyStr in allKeys) {
            id keyObject = [self duplicateObject:[(NSDictionary *)obj objectForKey:keyStr]];
            [duplicateDictionary setObject:keyObject forKey:keyStr];
        }
        return duplicateDictionary;
    } else if ([obj isKindOfClass:[NSString class]] || [[obj class] isSubclassOfClass:[NSString class]]) {
        // 字符串
        return [[NSMutableString alloc] initWithString:(NSString *)obj];
    } else {
        // 其他不处理
        return obj;
    }
}

@end

#pragma mark - DtMenuShoppingCarDataClass

@implementation DtMenuShoppingCarDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithDtMenuShoppingCarData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.name = [dict objectForKey:@"name"];
        self.quantity = [[dict objectForKey:kDtMenuShoppingCarQuantityKey] integerValue];
        self.currentRemarkArray = [dict objectForKey:kDtMenuShoppingCarCurrentRemarkKey];
        if (!self.currentRemarkArray)
        {
            self.currentRemarkArray = [[NSMutableArray alloc]init];
        }
        self.cuisineRemarkArray = [dict objectForKey:@"remark"];
        self.currentStyle = [dict objectForKey:@"currentStyle"];
        self.isMultiStyle = [[dict objectForKey:@"isMultiStyle"] intValue];
        self.currentPriceStr = [NSString stringWithFormat:@"%@", [dict objectForKey:@"currentPrice"]];
        self.priceArray = [dict objectForKey:@"price"];
        self.packageArray = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"package"]];
        self.modifyable = [[dict objectForKey:@"modifiable"] integerValue];
        self.status = [[dict objectForKey:@"status"] integerValue];
        self.foldOrspreadStatus = [[dict objectForKey:@"foldOrspreadStatus"] intValue];
        self.currentPrice = [NSString stringWithFormat:@"%@",[dict objectForKey:@"currentPrice"]];
        self.originPrice = [NSString stringWithFormat:@"%@",[dict objectForKey:@"originalPrice"]];
        //self.currentPromotePrice = [dict objectForKey:@"currentPromotePrice"];
        self.packfee = [NSString stringWithFormat:@"%@",[dict objectForKey:@"packfee"]];
        
        
        
        /*
            丫的获取购物车不直接返回"currentPromotePrice",需要自己去找.
            若有优惠价,入厨房后,返回的currentPrice是优惠价,所以同时要更新原价(currentPriceStr).
         */
//        if (!self.currentPromotePrice && self.priceArray.count)
//        {
//            for (NSDictionary *priceDic in self.priceArray)
//            {
//                NSString *style = [priceDic objectForKey:@"style"];
//                if ([style isEqualToString:self.currentStyle])
//                {
//                    self.currentPromotePrice = [NSString stringWithFormat:@"%@",[priceDic objectForKey:@"promotePrice"]];
//                    
//                    //更新原价:
//                    self.currentPriceStr = [NSString stringWithFormat:@"%@",[priceDic objectForKey:@"price"]];
//                    
//                    break;
//                }
//            }
//        }
    }
    return self;
}

@end
