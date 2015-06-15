//
//  CookbookDataClass.m
//  PreOrderSystem
//
//  Created by mac on 14-6-30.
//  
//

#import "CookbookDataClass.h"
#import "PackageDataModel.h"
@implementation CookbookDataClass
- (id)initWithCookbookDic:(NSDictionary *)cookbookDic
{
    self = [super init];
    if (self)
    {
        self.priceArr = [[NSMutableArray alloc]init];
        self.cookbookID = [[cookbookDic objectForKey:@"id"]intValue];
        if (![cookbookDic objectForKey:@"id"])
        {
            //房台返回字段名称不一致,蛋疼
            self.cookbookID = [[cookbookDic objectForKey:@"cbID"]integerValue];
        }
        self.cookbookName = [cookbookDic objectForKey:@"name"];
        self.cookbookCode = [cookbookDic objectForKey:@"code"];
        self.cookbookPicture = [cookbookDic objectForKey:@"picture"];
        self.isSoldOut = [[cookbookDic objectForKey:@"isSoldOut"]intValue];
        self.isActive = [[cookbookDic objectForKey:@"isActive"]boolValue];
        self.isAllowTakeout = [[cookbookDic objectForKey:@"isAllowTakeout"]intValue];
        self.introduction = [cookbookDic objectForKey:@"introduction"];
        self.packfee = [[cookbookDic objectForKey:@"packfee"]intValue];
        self.dishCount = 0;
        for (NSDictionary *priceDic in (NSArray *)[cookbookDic objectForKey:@"price"])
        {
            CookbookPriceDataClass *priceData = [[CookbookPriceDataClass alloc]initWithPriceDic:priceDic];
            [self.priceArr addObject:priceData];
        }
        //以下为房台-获取菜品列表接口才有的字段:
        self.isMultiStyle = [[cookbookDic objectForKey:@"isMultiStyle"]boolValue];
        self.packageArr = [cookbookDic objectForKey:@"packages"];
        if (self.packageArr.count)
        {
            self.packageDataArr = [[NSMutableArray alloc]init];
            for (NSDictionary *packageDic in self.packageArr)
            {
                PackageDataModel *packageModel = [[PackageDataModel alloc]initWithPackageDic:packageDic];
                [self.packageDataArr addObject:packageModel];
            }
        }
    }
    return self;
}
@end
