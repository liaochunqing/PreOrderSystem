//
//  DishCardNewViewClass.m
//  PreOrderSystem
//
//  Created by SWen on 14-7-24.
//
//

#import "DishCardNewViewClass.h"

@implementation DishCardNewViewClass

- (id)init {
    self = [super init];  // Call a designated initializer here.
    if (self != nil) {
        self.isSpread = NO;
    }
    return self;
}

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
//        self.rule = [dict objectForKey:kDishCardNewRule];
//        self.ruleNumber = [[dict objectForKey:kDishCardNewRuleNumber] integerValue];
//        self.groupName = [dict objectForKey:kDishCardNewGroupName];
//        self.cookArray = [[NSMutableArray alloc] initWithArray:[dict objectForKey:kDishCardNewCookArray]];
//        self.isSpread = YES;
//        self.cuisineIndex = [[dict objectForKey:kDishCardNewCuisineIndex] intValue];
    }
    
    return self;
}

- (id)initWithOtherDish:(DishCardNewViewClass *)otherDish
{
    self = [super init];
    if (self) {
        self.choose = otherDish.choose;
        self.chooseNum = otherDish.chooseNum;
        self.chooseStringArray = [[NSMutableArray alloc] initWithArray:otherDish.chooseStringArray];
        self.groupName = [[NSMutableString alloc] initWithString:otherDish.groupName];
        self.cookArray = [NSMutableArray arrayWithArray:otherDish.cookArray];
        self.isSpread = otherDish.isSpread;
        self.cuisineID = otherDish.cuisineID;
        self.cuisineIndex = otherDish.cuisineIndex;
    }
    
    return self;
}
@end
