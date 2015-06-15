//
//  DtMenuDataClass.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-27.
//
//

#import <Foundation/Foundation.h>

@interface DtMenuListDataClass : NSObject

@property (nonatomic, strong) NSArray *dtMenuListArray;
@property (nonatomic, strong) NSArray *queueListArray;
@property (nonatomic, strong) NSDictionary *orderInfoDic;

- (id)initWithDtMenuListData:(NSDictionary *)dict;

@end

#pragma mark - DtQueueDataClass

@interface DtQueueDataClass : NSObject

@property (nonatomic, strong) NSString *queueIdStr;//排号id
@property (nonatomic, strong) NSString *tableName;//房台名称
@property (nonatomic, strong) NSString *serialNumberStr;//排号
@property (nonatomic, assign) NSInteger people;//人数
@property (nonatomic, assign) BOOL exceeded;//是否显示“以上”
@property (nonatomic, strong) NSString *mobile;//手机号
@property (nonatomic, strong) NSString *remark;//狗仔队的备注
@property (nonatomic, strong) NSArray *dishesArray;//见获取购物车的点菜数据

@property (nonatomic, strong) NSArray *originDishesArray;//见获取购物车的点菜数据
@property (nonatomic, assign) BOOL isUnfold;/*是否展开,服务器没有传这个字段过来，为了方便处理，自己加上的*/
@property (nonatomic, assign) BOOL isSelected;/*是否选中,服务器没有传这个字段过来，为了方便处理，自己加上的*/

- (id)initWithDtQueueData:(NSDictionary *)dict;

@end

#pragma mark - DtMenuDataClass

@interface DtMenuDataClass : NSObject

@property (nonatomic, strong) NSString *cuisineName;//菜系名称
@property (nonatomic, strong) NSArray *remarkArray;//备注
@property (nonatomic, strong) NSArray *cookbookArray;//菜式内容

- (id)initWithDtMenuData:(NSDictionary *)dict;

@end

#pragma mark - DtMenuCookbookDataClass

@interface DtMenuCookbookDataClass : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *cookID;//菜品编号
@property (nonatomic, strong) NSArray *priceArray;//价格样式
@property (nonatomic, strong) NSMutableArray *packageArray;//套餐
@property (nonatomic) BOOL isSoldOut;//是否沽清
@property (nonatomic, strong) NSNumber *isMultiStyle;//是否多样式
@property (nonatomic, assign) BOOL isActive;//是否沽清
@property (nonatomic, strong) NSString *packfee;//打包费

- (id)initWithDtMenuCookbookData:(NSDictionary *)dict;
+ (void)modifyCookbookData:(NSMutableArray *)packageArray withPackage:(NSDictionary *)newDict withIndex:(int)index;

@end

#pragma mark - DtMenuCookbookPriceDataClass

@interface DtMenuCookbookPriceDataClass : NSObject

@property (nonatomic, strong) NSString *style;
@property (nonatomic, strong) NSString *priceStr;
@property (nonatomic, strong) NSString *promotePrice;

- (id)initWithDtMenuPriceData:(NSDictionary *)dict;

@end

#pragma mark - DtMenuCookbookPackageDataClass

#define kDtMenuCookbookPackageDataChoiceTypeKey  @"choiceType"
#define kDtMenuCookbookPackageDataMemberKey  @"member"

@interface DtMenuCookbookPackageDataClass : NSObject

@property (nonatomic, strong) NSString *itemName;//栏目名称
@property (nonatomic, assign) int choiceType;//选择类型，0：不供选择（全选），1：必选，2：任选
@property (nonatomic, assign) int choiceNum;//可选/必选数
@property (nonatomic, strong) NSMutableArray *memberArray;//栏目成员

- (id)initWithDtMenuPackageData:(NSDictionary *)dict;
+ (void)modifyPackageData:(NSMutableArray *)memberArray withMember:(NSDictionary *)newDict withIndex:(int)index;

@end

#pragma mark - DtMenuCookbookPackageMemberDataClass

#define kDtMenuCookbookPackageMemberPriceKey  @"price"
#define kDtMenuCookbookPackageMemberCheckedKey  @"checked"

@interface DtMenuCookbookPackageMemberDataClass : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *priceStr;
@property (nonatomic, assign) int checked;

- (id)initWithDtMenuPackageMemberData:(NSDictionary *)dict;
+ (DtMenuCookbookPackageMemberDataClass *)getPackageMemberDataClass:(int)index withPackageDataClass:(DtMenuCookbookPackageDataClass *)packageDataClass;

@end

#pragma mark - DtMenuCookbookRemarkDataClass

#define kRemarkContent @"item"
#define kRemarkQuantity @"num"

@interface DtMenuCookbookRemarkDataClass : NSObject

@property (nonatomic, strong) NSMutableArray *contentArray;
@property (nonatomic, assign) int quantity;

- (id)initWithDtMenuRemarkData:(NSDictionary *)dict;
+ (void)addNewRemarkData:(NSMutableArray *)remarkArray;
+ (void)addNewRemarkDataToLast:(NSMutableArray *)remarkArray;//添加到数组末尾
+ (void)modifyRemarkData:(NSMutableArray *)remarkArray withIndex:(int)index withQuantity:(int)quantity;
+ (void)modifyRemarkData:(NSMutableArray *)remarkArray withIndex:(int)index withRemarkName:(NSString *)remarkStr;

@end

#pragma mark - DtMenuShoppingCarListDataClass

@interface DtMenuShoppingCarListDataClass : NSObject <NSCopying>

@property (nonatomic, strong) NSDictionary *corpInfoDict;
@property (nonatomic, strong) NSMutableArray *dishesArray;

- (id)initWithDtMenuShoppingCarListData:(NSDictionary *)dict;

/**
 * @brief   复制对象和其子对象（解决iOS5购物车添加备注crash的问题）。
 *
 * @param   obj 要复制的对象。
 *
 * @return  新复制的对象。
 */
+ (id)duplicateObject:(id)obj;

@end

#pragma mark - DtMenuShoppingCarDataClass

#define kDtMenuShoppingCarCurrentRemarkKey @"currentRemark"
#define kDtMenuShoppingCarQuantityKey @"quantity"
#define kDtMenuShoppingCarSeparationStr @";"

@interface DtMenuShoppingCarDataClass : NSObject

@property (nonatomic, strong) NSString *name;//菜品名称
@property (nonatomic, assign) int quantity;//数量
@property (nonatomic, strong) NSMutableArray *currentRemarkArray;//当前菜的备注
@property (nonatomic, strong) NSArray *cuisineRemarkArray;//菜系备注
@property (nonatomic, strong) NSString *currentStyle;//当前样式
@property (nonatomic, assign) BOOL isMultiStyle;//当前样式
@property (nonatomic, strong) NSString *currentPriceStr;//当前价格
@property (nonatomic, strong) NSArray *priceArray;//价格数组
@property (nonatomic, strong) NSMutableArray *packageArray;//套餐数据
@property (nonatomic, assign) int modifyable;//是否处于冻结状态
@property (nonatomic, assign) int status;// 状态，0未确认，1已确认，2已入厨，version>=2.1
@property (nonatomic, assign) int foldOrspreadStatus; // 0表示处于折叠状态 1表示处于展开状态，
//@property (nonatomic, strong) NSString *currentPromotePrice;//当前优惠价格
@property (nonatomic ,strong) NSString *currentPrice;//现价(有可能是优惠价,接口未明确)
@property (nonatomic, strong) NSString *originPrice;//原价
@property (nonatomic, strong) NSString *packfee;//打包费
- (id)initWithDtMenuShoppingCarData:(NSDictionary *)dict;

@end

