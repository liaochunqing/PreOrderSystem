//
//  PromoteCookBookDataModel.m
//  PreOrderSystem
//
//  Created by mac on 14-7-17.
//
//

#import "PromoteCookBookDataModel.h"
#import "PromoteCookBookGroupDataModel.h"
#import "CuisineDataModel.h"
#import "CookbookDataClass.h"


@implementation PromoteCookBookDataModel
//- (id)initWithData:(NSArray *)promoteCookbookGroupArr andAllCuisineDataArr:(NSArray *)allCuisineDataArr
- (id)initWithData:(NSDictionary *)dataDic andAllCuisineDataArr:(NSArray *)allCuisineDataArr
{
    self = [super init];
    if (self)
    {
        NSArray *temPromoteCookbookGroupArr = [dataDic objectForKey:@"promoteCookbookGroup"];
        self.promoteCookbookGroupArr = [[NSMutableArray alloc]init];
        self.allCuisineDataArr = [[NSMutableArray alloc]init];
        //解析出所有菜系菜品.
        if (allCuisineDataArr.count)
        {
            for (NSDictionary *dic in allCuisineDataArr)
            {
                CuisineDataModel *cuisineDataModel = [[CuisineDataModel alloc]initAllDetailWithData:dic];
                [self.allCuisineDataArr addObject:cuisineDataModel];
            }
        }

        //解析出所有优惠组合.效率低,待优化
        if (temPromoteCookbookGroupArr.count)
        {
            for (NSDictionary *dic in temPromoteCookbookGroupArr)
            {
                PromoteCookBookGroupDataModel *groupData = [[PromoteCookBookGroupDataModel alloc]init];
                groupData.promoteKey = [dic objectForKey:@"key"];
                groupData.promoteName = [dic objectForKey:@"name"];
                groupData.promoteNumber = [dic objectForKey:@"number"];
                groupData.isActive = [[dic objectForKey:@"isActive"]boolValue];
                NSArray *includeCookArr = [dic objectForKey:@"cookbook"];
                for (NSDictionary *cookDic in includeCookArr)
                {
                    NSString *cookID = [cookDic objectForKey:@"cb_id"];
                    //遍历所有菜系,挖出相应菜品,dflask
                    for (CuisineDataModel *temCuisineData in self.allCuisineDataArr)
                    {
                        BOOL isFound = NO;
                        for (CookbookDataClass *temCookbooData in temCuisineData.cookbookDataArr)
                        {
                            NSString *cbID = [NSString stringWithFormat:@"%lu",(unsigned long)temCookbooData.cookbookID];
                            if ([cbID isEqualToString:cookID])
                            {
                                CookbookDataClass *promoteCookBookData = temCookbooData;
                                id obj = [cookDic objectForKey:@"cb_price_userDefined"];
                                promoteCookBookData.userDefinedPrice = obj;
                                [groupData.groupCookbookArr addObject:promoteCookBookData];
                                isFound = YES;
                                break;
                            }
                        }
                        if (isFound)
                        {
                            isFound = NO;
                            break;
                        }
                    }
                }
                [self.promoteCookbookGroupArr addObject:groupData];
            }
        }
    }
    return self;
}

@end
