//
//  CookbookPath.h
//  PreOrderSystem
//
//  Created by mac on 14-7-10.
//
//

#import <Foundation/Foundation.h>

@interface CookbookPath : NSObject
//菜系在数组中的位置
@property (nonatomic,assign)int cuisineIndex;
//菜品所在菜系中的位置.
@property (nonatomic,assign)int cookbookIndex;

- (id)initWithCuisineIndex:(int)cuisineIndex andCookbookIndex:(int)cookbookIndex;

@end
