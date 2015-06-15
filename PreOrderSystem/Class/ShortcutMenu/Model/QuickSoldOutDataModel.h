//
//  QuickSoldOutDataModel.h
//  PreOrderSystem
//
//  Created by mac on 14-8-7.
//
//

#import <Foundation/Foundation.h>
#import "CuisineDataModel.h"
#import "CookbookDataClass.h"

@interface QuickSoldOutDataModel : NSObject

//所有菜系菜品
@property (nonatomic,strong)NSMutableArray *allCuisineArr;

//已在快捷沽清列表的菜系菜品
@property (nonatomic,strong)NSMutableArray *quickSoldOutArr;


/**
 *  初始化快捷沽清数据源
 *
 *  @param soldOutListDic 已在快捷沽清栏的菜品ID(原始数据未解析)
 *  @param allCookArr     所有菜系菜品数据(已解析为CuisineDataModel->cookbookData....)
 *
 *  @return self
 */
- (id)initWithQuickSoldOutList:(NSDictionary *)soldOutListDic andAllCook:(NSArray *)allCookArr;

@end
