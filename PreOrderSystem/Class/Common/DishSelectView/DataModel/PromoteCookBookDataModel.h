//
//  PromoteCookBookDataModel.h
//  PreOrderSystem
//
//  Created by mac on 14-7-17.
//
//“菜式优惠组合列表、明细” +“菜谱”
///CookbookPromote/getPromoteCookBookGroup

#import <Foundation/Foundation.h>

@interface PromoteCookBookDataModel : NSObject

//所有优惠组合.数组中存放的是PromoteCookBookGroupDataModel.h数据类
@property (nonatomic,strong)NSMutableArray *promoteCookbookGroupArr;

//附带返回的所有菜系及菜品数据,数组中存放的是CuisineDataModel.h数据类
@property (nonatomic,strong)NSMutableArray *allCuisineDataArr;

- (id)initWithData:(NSDictionary *)dataDic andAllCuisineDataArr:(NSArray *)allCuisineDataArr;

@end
