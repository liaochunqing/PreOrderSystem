//
//  PromoteCookBookGroupDataModel.m
//  PreOrderSystem
//
//  Created by mac on 14-7-17.
//
//

#import "PromoteCookBookGroupDataModel.h"

@implementation PromoteCookBookGroupDataModel
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.groupCookbookArr = [[NSMutableArray alloc]init];
    }
    return self;
}
@end
