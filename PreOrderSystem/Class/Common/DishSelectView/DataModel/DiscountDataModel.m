//
//  DiscountDataModel.m
//  PreOrderSystem
//
//  Created by mac on 14-7-3.
//  
//

#import "DiscountDataModel.h"

@implementation DiscountDataModel
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.discountDishArr = [[NSMutableArray alloc]init];
    }
    return self;
}
@end
