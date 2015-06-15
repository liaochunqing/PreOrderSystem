//
//  CookbookPriceDataClass.m
//  PreOrderSystem
//
//  Created by mac on 14-6-30.
//
//

#import "CookbookPriceDataClass.h"

@implementation CookbookPriceDataClass
- (id)initWithPriceDic:(NSDictionary *)priceDic
{
    self = [super init];
    if (self)
    {
        self.priceStyle = [priceDic objectForKey:@"style"];
        self.price = [[priceDic objectForKey:@"price"]floatValue];
        self.promotePrice = [[priceDic objectForKey:@"promotePrice"]floatValue];
    }
    return self;
}
@end
