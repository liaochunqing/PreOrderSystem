//
//  PackageMemberDataModel.m
//  PreOrderSystem
//
//  Created by mac on 14-7-24.
//
//

#import "PackageMemberDataModel.h"

@implementation PackageMemberDataModel

- (id)initWithMemberDic:(NSDictionary *)memDic
{
    self = [super init];
    if (self)
    {
        self.memberName = [memDic objectForKey:@"pName"];
        self.memberPrice = [[memDic objectForKey:@"price"]intValue];
        self.isChecked = [[memDic objectForKey:@"checked"]boolValue];
        self.quantity = [[memDic objectForKey:@"quantity"] integerValue];
        self.cbID = [[memDic objectForKey:@"cb_cbID"] integerValue];
    }
    return self;
}
@end
