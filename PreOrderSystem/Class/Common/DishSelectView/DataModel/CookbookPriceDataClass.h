//
//  CookbookPriceDataClass.h
//  PreOrderSystem
//
//  Created by mac on 14-6-30.
//  jhh_菜品价格数据模型.
//

#import <Foundation/Foundation.h>

@interface CookbookPriceDataClass : NSObject
//价格规格
@property (nonatomic,strong)NSString *priceStyle;

//菜品价格
@property (nonatomic,assign)float price;

//优惠价格
@property (nonatomic,assign)float promotePrice;

- (id)initWithPriceDic:(NSDictionary *)priceDic;
@end
