//
//  PackageDataModel.m
//  PreOrderSystem
//
//  Created by mac on 14-7-24.
//
//

#import "PackageDataModel.h"
#import "PackageMemberDataModel.h"
@implementation PackageDataModel
- (instancetype)init
{
    self = [super init];
    if (self)
    {
//        self.memberArr = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (id)initWithPackageDic:(NSDictionary *)packageDic
{
    self = [super init];
    if (self)
    {
        self.cuisineID = [[packageDic objectForKey:@"cb_cuisineID"] integerValue];
        self.pID = [[packageDic objectForKey:@"pID"] integerValue];
        self.itemName = [packageDic objectForKey:@"pName"];
        self.choiceNum = [[packageDic objectForKey:@"chooseNum"]intValue];
        self.choiceType = [[packageDic objectForKey:@"choose"]intValue];
        NSArray *memberArr = [packageDic objectForKey:@"item"];
        self.memberArr = [[NSMutableArray alloc] init];
        for (NSDictionary *memDic in memberArr)
        {
            PackageMemberDataModel *memberModel = [[PackageMemberDataModel alloc] initWithMemberDic:memDic];
            [self.memberArr addObject:memberModel];
        }
        
    }
    
    return self;
}

@end
