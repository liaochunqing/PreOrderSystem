//
//  DiscountDataModel.h
//  PreOrderSystem
//
//  Created by mac on 14-7-3.
//  优惠套餐数据模型.
//

#import <Foundation/Foundation.h>

@interface DiscountDataModel : NSObject
//优惠套餐ID
@property (nonatomic, strong)NSString *discountID;

//优惠套餐名
@property (nonatomic, strong)NSString *discountName;

//该优惠套餐包含的菜品.数组保存的是CookbookPriceDataClass菜品数据类型
@property (nonatomic, strong)NSMutableArray *discountDishArr;

@end
