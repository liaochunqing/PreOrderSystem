//
//  CookbookPath.m
//  PreOrderSystem
//
//  Created by mac on 14-7-10.
//
//

#import "CookbookPath.h"

@implementation CookbookPath
- (id)initWithCuisineIndex:(int)cuisineIndex andCookbookIndex:(int)cookbookIndex
{
    self = [super init];
    if (self)
    {
        self.cuisineIndex = cuisineIndex;
        self.cookbookIndex = cookbookIndex;
    }
    return self;
}
@end
