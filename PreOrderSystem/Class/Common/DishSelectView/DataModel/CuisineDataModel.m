//
//  CuisineDataModel.m
//  PreOrderSystem
//
//  Created by mac on 14-6-30.
//
//

#import "CuisineDataModel.h"
@implementation CuisineDataModel
- (id)initAllDetailWithData:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        self.cookbookDataArr = [[NSMutableArray alloc]init];
        self.cuisineId = [[dic objectForKey:@"id"] integerValue];
        self.cuisineName = [dic objectForKey:@"name"];
        
        if (!self.cuisineName.length)
        {
            //房台中返回的菜系字段为"cuisineName"
            self.cuisineName = [dic objectForKey:@"cuisineName"];
            self.cuisineId = [[dic objectForKey:@"cuisineId"]integerValue];
        }
    
        self.remarkArray = [dic objectForKey:@"remark"];
        NSArray *cookbookArr = [dic objectForKey:@"cookbook"];
        for (NSDictionary *cookbookDic in cookbookArr)
        {
            //该菜系下的详细菜单
            CookbookDataClass *cookbookData = [[CookbookDataClass alloc]initWithCookbookDic:cookbookDic];
            cookbookData.cuisineName = self.cuisineName;
            cookbookData.cuisineId = self.cuisineId;
            [self.cookbookDataArr addObject:cookbookData];
        }
    }
    return self;
    
}
@end
