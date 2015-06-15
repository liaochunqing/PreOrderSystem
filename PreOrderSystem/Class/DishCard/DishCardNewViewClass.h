//
//  DishCardNewViewClass.h
//  PreOrderSystem
//
//  Created by SWen on 14-7-24.
//
//

#import <Foundation/Foundation.h>

#define kDishCardNewRule @"rule"
#define kDishCardNewRuleNumber @"ruleNumber"
#define kDishCardNewGroupName @"groupName"
#define kDishCardNewCookArray @"cookArray"
#define kDishCardNewCuisineIndex @"cuisineIndex"

@interface DishCardNewViewClass : NSObject
@property (nonatomic)NSInteger choose;// 规则  （0全选，1必选，2任选）
@property (nonatomic)NSInteger chooseNum;// 份数
@property (nonatomic, strong)NSMutableArray *chooseStringArray;//（全选，必选，任选）
@property (nonatomic, strong)NSMutableString *groupName;// 菜系名
@property (nonatomic, strong)NSMutableArray *cookArray;// 被选中菜品数组(放类CookbookDataClass或PackageMemberDataModel)
@property (nonatomic)BOOL isSpread;// 是否展开
@property (nonatomic,assign)int cuisineIndex;//当前的菜系在allCuisineArr数组中的位置.
@property (nonatomic,assign)int cuisineID;//当前的菜系id
- (id)initWithDict:(NSDictionary *)dict;
- (id)initWithOtherDish:(DishCardNewViewClass *)otherDish;
@end
