//
//  ShoppingCarViewController.m
//  PreOrderSystem
//
//  Created by SWen on 14-1-3.
//
//

#import "DtMenuShoppingCarViewController.h"
#import "DiningTableImageName.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DtMenuDataClass.h"
#import "DtMenuCookbookRemarkTableViewCell.h"
#import "PSAlertView.h"
#import "Constants.h"
#import "NsstringAddOn.h"
#import "SocketPrinterFunctions.h"
#import "DiningTableDataClass.h"
#import "OfflineManager.h"
#import "WEPopoverController.h"
#import "MainViewController.h"
#import "DtMenuMainViewController.h"

#define kCancelAlertViewTag 1000
#define kGiveUpAlertViewTag 1001
#define kHeightForHeader 35
#define kHeightForFoot 35


@interface DtMenuShoppingCarViewController ()
{
    JsonPicker *jsonPicker;
    id remarkPopController;
    DtMenuRemarkPickerViewController *remarkPickerVC;
    NSMutableArray *socketObjectArray;
    
    /// 全部状态数据集合（制作参考，修改无效）
    NSMutableArray *resortArray;
    
    /// 入厨房数据集合（制作参考，修改无效）
    NSMutableArray *intoKitchenArray;
    /// 已确认数据集合（制作参考，修改无效）
    NSMutableArray *sureArray;
    /// 未确认数据集合（制作参考，修改无效）
    NSMutableArray *unsureArray;
    
    /// 提交成功之后是否返回
    BOOL backWhileSubmit_;
    /// 当前提交类型
    NSInteger currentSubmitType_;
    
    /// 备份数据源（当点击取消的时候就以这个数据为准还原）
    DtMenuShoppingCarListDataClass *backupData_;
    
    /// 本地添加的菜品,临时保存,
    NSMutableArray *dishAddFromLocalArr_;
}

@property(nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property(nonatomic, weak) IBOutlet UITableView *shoppingCarTableView;
@property(nonatomic, weak) IBOutlet UILabel *totalQuantityLabel;
@property(nonatomic, weak) IBOutlet UILabel *totalPriceLabel;
@property(nonatomic, weak) IBOutlet UIButton *cancelButton;
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation DtMenuShoppingCarViewController
@synthesize isAddNewDish_;
@synthesize isModified_;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentSubmitType_ = -1;
    
    self.shoppingCarTableView.backgroundColor = [UIColor clearColor];
    self.shoppingCarTableView.backgroundView = nil;
    self.shoppingCarTableView.sectionHeaderHeight = 0.0;
    self.shoppingCarTableView.sectionFooterHeight = 0.0;
    [self addPictureToView];
    [self addLocalizedString];
    [self addNotifications];
    
    if (kSystemVersionOfCurrentDevice < 7.0) {
        // ios6下group样式的适配
        CGRect frame = CGRectInset(self.shoppingCarTableView.frame, -20.0, 0.0);
        frame.origin.x -= 10.0;
        self.shoppingCarTableView.frame = frame;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 备份数据
    backupData_ = [self.shoppingCarListDataClass copy];
    
    [self updateShoppingCarView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self removeNotification];
#ifdef DEBUG
    NSLog(@"===%s,dealloc===", __FUNCTION__);
#endif
}

- (void)addPictureToView
{
    self.bgImageView.image = [UIImage imageFromMainBundleFile:kDtMenuCookbookBgImageName];
    [self.cancelButton setImage:[UIImage imageFromMainBundleFile:@"order_arrowButtonImage.png"]
                       forState:UIControlStateNormal];
}

- (void)addLocalizedString
{
    self.titleLabel.text = kLoc(@"shopping_car_detail");
}

- (void)updateShoppingCarView
{
    NSMutableArray *tempArray = self.shoppingCarListDataClass.dishesArray;
    int tempCount = (int)[tempArray count];
    
    if (tempCount > 0)
    {
        if (!unsureArray)
            unsureArray = [[NSMutableArray alloc] init];
        else
            [unsureArray removeAllObjects];
        if (!intoKitchenArray)
            intoKitchenArray = [[NSMutableArray alloc] init];
        else
            [intoKitchenArray removeAllObjects];
        if (!sureArray)
            sureArray = [[NSMutableArray alloc] init];
        else
            [sureArray removeAllObjects];
        
        for (NSDictionary *dict in tempArray)
        {
            if (dict)
            {
                int status = [[dict objectForKey:@"status"] intValue];
                if (status == 0)
                {
                    [unsureArray addObject:dict];
                }
                else if (status == 1)
                {
                    [sureArray addObject:dict];
                }
                else if (status == 2)
                {
                    [intoKitchenArray addObject:dict];
                }
            }
        }
    }
    
    if ([self.shoppingCarListDataClass.dishesArray count])
    {
        self.totalQuantityLabel.hidden = NO;
        self.totalPriceLabel.hidden = NO;
        [self updateDishTotoalNum];
        [self updateDishTotoalPrice];
    }
    else
    {
        self.totalQuantityLabel.hidden = YES;
        self.totalPriceLabel.hidden = YES;
    }
    [self.shoppingCarTableView reloadData];
}

- (DtMenuShoppingCarDataClass *)getDtMenuShoppingCarDataClass:(int)index
{
    DtMenuShoppingCarDataClass *tempClass = nil;
    //    NSMutableArray *tempArray = self.shoppingCarListDataClass.dishesArray;
    //    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:intoKitchenArray];
    if (!resortArray)
    {
        resortArray = [[NSMutableArray alloc] initWithArray:intoKitchenArray];
    }
    else
    {
        [resortArray removeAllObjects];
        [resortArray addObjectsFromArray:intoKitchenArray];
    }
    
    [resortArray addObjectsFromArray:sureArray];
    [resortArray addObjectsFromArray:unsureArray];
    int tempCount = (int)[resortArray count];
    
    if (index < tempCount)
    {
        tempClass = [[DtMenuShoppingCarDataClass alloc] initWithDtMenuShoppingCarData:[resortArray objectAtIndex:index]];
    }
    
    return tempClass;
}

- (DtMenuCookbookRemarkDataClass *)getDtMenuCookbookRemarkDataClass:(int)index withDtMenuShoppingCarDataClass:(DtMenuShoppingCarDataClass *)shoppingCardataClass
{
    DtMenuCookbookRemarkDataClass *tempClass = nil;
    NSMutableArray *tempArray = shoppingCardataClass.currentRemarkArray;
    if (index < [tempArray count])
    {
        tempClass = [[DtMenuCookbookRemarkDataClass alloc] initWithDtMenuRemarkData:[tempArray objectAtIndex:index]];
    }
    return tempClass;
}

/*套餐 dataClass*/

- (DtMenuCookbookPackageDataClass *)getPackageDataClass:(int)index withShoppingCarDataClass:(DtMenuShoppingCarDataClass *)dataClass
{
    DtMenuCookbookPackageDataClass *tempDataClass = nil;
    NSMutableArray *tempArray = dataClass.packageArray;
    if (index < [tempArray count])
    {
        tempDataClass = [[DtMenuCookbookPackageDataClass alloc] initWithDtMenuPackageData:[tempArray objectAtIndex:index]];
    }
    return tempDataClass;
}

/*套餐栏目成员 dataClass*/

- (DtMenuCookbookPackageMemberDataClass *)getPackageDetailDataClass:(int)index withPackageDataClass:(DtMenuCookbookPackageDataClass *)packageDataClass
{
    DtMenuCookbookPackageMemberDataClass *tempDataClass = nil;
    NSMutableArray *tempArray = packageDataClass.memberArray;
    if (index < [tempArray count])
    {
        tempDataClass = [[DtMenuCookbookPackageMemberDataClass alloc] initWithDtMenuPackageMemberData:[tempArray objectAtIndex:index]];
    }
    return tempDataClass;
}

- (BOOL)whetherShowItemName:(DtMenuCookbookPackageDataClass *)dataClass
{
    BOOL flag = NO;
    int tempMemberCount = (int)[dataClass.memberArray count];
    for (int j = 0; j < tempMemberCount; j++)
    {
        DtMenuCookbookPackageMemberDataClass *tempMemberClass = [self getPackageDetailDataClass:j withPackageDataClass:dataClass];
        if (tempMemberClass.checked)
        {
            flag = YES;
            break;
        }
    }
    return flag;
}

- (int)getRemarkTotalNum:(NSArray *)array
{
    int totalNum = 0;
    int tempCount = (int)[array count];
    for (int i = 0; i < tempCount; i++)
    {
        DtMenuCookbookRemarkDataClass *tempClass = [[DtMenuCookbookRemarkDataClass alloc] initWithDtMenuRemarkData:[array objectAtIndex:i]];
        totalNum = totalNum + tempClass.quantity;
    }
    return totalNum;
}

/*更新总份数*/
- (void)updateDishTotoalNum
{
    int totalNum = 0;
    NSMutableArray *tempArray = self.shoppingCarListDataClass.dishesArray;
    int tempCount = (int)[tempArray count];
    for (int i = 0; i < tempCount; i++)
    {
        DtMenuShoppingCarDataClass *tempClass = [self getDtMenuShoppingCarDataClass:i];
        totalNum = totalNum + tempClass.quantity;
    }
    self.totalQuantityLabel.text = [NSString stringWithFormat:@"%@ %d %@", kLoc(@"total"), totalNum, kLoc(@"part")];
}

/*更新总价*/
- (void)updateDishTotoalPrice
{
    float totoalPrice = 0;
    NSMutableArray *tempArray = self.shoppingCarListDataClass.dishesArray;
    int tempCount = (int)[tempArray count];
    for (int i = 0; i < tempCount; i++)
    {
        DtMenuShoppingCarDataClass *tempClass = [self getDtMenuShoppingCarDataClass:i];
        NSString *finalPriceStr = @"";
        finalPriceStr = tempClass.currentPrice;
        if (!finalPriceStr.length)
        {
            finalPriceStr = tempClass.originPrice;
        }
        float packageSubPrice = 0;
//        if (tempClass.packageArray.count && tempClass.status != 2)//套餐入厨房后子项加钱已包含在单价中
//        {
//            packageSubPrice = [self getSubPriceByCheck:tempClass.packageArray];
//        }
        totoalPrice = totoalPrice + tempClass.quantity * ([finalPriceStr floatValue] + packageSubPrice);
    }
    NSString *tempStr = [NSString stringWithFormat:@"%.2f",totoalPrice];
    self.totalPriceLabel.text = [NSString stringWithFormat:@"%@ %@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString oneDecimalOfPrice:[tempStr floatValue]]];
}

- (void)executeDismissViewDelegateMethod
{
    if ([self.delegate respondsToSelector:@selector(dtMenuShoppingCarViewHavedDismiss)])
    {
        [self.delegate dtMenuShoppingCarViewHavedDismiss];
    }
}

/**
 * @brief   打印小票。
 *
 * @param   status  状态
 *                  0为厨房重印
 *                  1为已确认入厨房
 *                  2为已确认重印
 *                  3为未确认确认
 */
-(void)printByStatus:(int)status
{
    if (!socketObjectArray) {
        socketObjectArray = [[NSMutableArray alloc] init];
    }
    
    int dishesStatus = 0;
    kPrinterMode mode = 0;
    
    if (status == 0) {
        // 操作入厨房的菜
        dishesStatus = 2;
        // 厨房打印模式
        mode = kPrinterModeKitch;
    } else if (status == 1) {
        // 操作已确认的菜
        dishesStatus = 1;
        // 厨房打印模式
        mode = kPrinterModeKitch;
    } else if (status == 2) {
        // 操作已确认的菜
        dishesStatus = 1;
        // 点菜确认打印模式
        mode = kPrinterModeOrderdish;
    } else if (status == 3) {
        // 操作未确认的菜
        dishesStatus = 0;
        // 点菜确认打印模式
        mode = kPrinterModeOrderdish;
    } else {
        return;
    }
    
    [socketObjectArray removeAllObjects];
    [SocketPrinterFunctions getSocketPrinterObject:socketObjectArray mode:mode];
    int printerCount = (int)[socketObjectArray count];
    
    NSMutableArray *printArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.shoppingCarListDataClass.dishesArray) {
        if (dict && [[dict objectForKey:@"status"] intValue] == dishesStatus) {
            [printArray addObject:dict];
        }
    }
    
    for (int i = 0; i < printerCount && printArray.count > 0; i++) {
        SocketPrinterFunctions *socket = [socketObjectArray objectAtIndex:i];
        [socket printDtMenuShoppingCarDishReceipt:printArray
                                   withDtAreaName:self.areaName
                                withDtHousingName:self.housingDataClass.housingName
                                      operateType:status];
    }
}

- (void)tryDismissView
{
    if (isModified_ || isAddNewDish_) {
        NSString *alertMessage = kLoc(@"data_is_not_saved_confirm_to_leave");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertMessage
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:kLoc(@"cancel")
                                                  otherButtonTitles:kLoc(@"confirm"), nil];
        alertView.tag = kCancelAlertViewTag;
        [alertView show];
    } else {
        [self executeDismissViewDelegateMethod];
    }
}

- (id)duplicateObject:(id)obj
{
    if ([obj isKindOfClass:[NSArray class]] || [[obj class] isSubclassOfClass:[NSArray class]]) {
        // 数组
        NSMutableArray *duplicateArray = [[NSMutableArray alloc] init];
        for (NSObject *child in (NSArray *)obj) {
            [duplicateArray addObject:[self duplicateObject:child]];
        }
        return duplicateArray;
    } else if ([obj isKindOfClass:[NSDictionary class]] ||
               [[obj class] isSubclassOfClass:[NSDictionary class]]) {
        // 字典
        NSMutableDictionary *duplicateDictionary = [[NSMutableDictionary alloc] init];
        NSArray *allKeys = [(NSDictionary *)obj allKeys];
        for (NSString *keyStr in allKeys) {
            id keyObject = [self duplicateObject:[(NSDictionary *)obj objectForKey:keyStr]];
            [duplicateDictionary setObject:keyObject forKey:keyStr];
        }
        return duplicateDictionary;
    } else if ([obj isKindOfClass:[NSString class]] || [[obj class] isSubclassOfClass:[NSString class]]) {
        // 字符串
        return [[NSMutableString alloc] initWithString:(NSString *)obj];
    } else {
        // 其他不处理
        return obj;
    }
}
#pragma mark -private method
/**
 *  计算套餐中有要加钱的勾选项
 *
 *  @param tempArray 套餐数组
 *
 *  @return 需要加多少钱.
 */
- (float)getSubPriceByCheck:(NSArray *)tempArray
{
    float totalSubPrice = 0.0;
    int tempCount = (int)[tempArray count];
    for (int i = 0; i < tempCount; i++)
    {
        NSMutableDictionary *tempDict = [tempArray objectAtIndex:i];
        NSMutableArray *tempMemberArray = [tempDict objectForKey:kDtMenuCookbookPackageDataMemberKey];
        int tempMemberCount = (int)[tempMemberArray count];
        for (int j = 0; j < tempMemberCount; j++)
        {
            NSMutableDictionary *memberDict = [tempMemberArray objectAtIndex:j];
            int checked = [[memberDict objectForKey:kDtMenuCookbookPackageMemberCheckedKey] intValue];
            if (checked)
            {
                float subPrice = [[memberDict objectForKey:kDtMenuCookbookPackageMemberPriceKey] floatValue];
                totalSubPrice = totalSubPrice + subPrice;
            }
        }
    }
    return totalSubPrice;
}
#pragma mark -public method
/**
 *  添加新菜品
 *
 *  @param newDishDic 新菜品数据(未解析)
 *  @param dishIsPackage 是否套餐
 */
- (void)addNewDish:(NSDictionary *)newDishDic dishIsPackage:(BOOL)flag
{
    isAddNewDish_ = YES;
    /*将菜品数据包装成与/diningtable/getCart接口返回的菜品数据格式一致,然后添加进购物车数组.*/
    NSMutableArray *tempArray = self.shoppingCarListDataClass.dishesArray;
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:newDishDic];
    //标记该菜品是从本地添加的(未提交服务器)
    [tempDict setObject:[NSNumber numberWithBool:YES] forKey:@"isAddFromLocal"];
    //设是否可修改:
    [tempDict setObject:[NSNumber numberWithInt:1] forKey:@"modifiable"];
    //设状态为已确认:
    [tempDict setObject:[NSNumber numberWithInt:1] forKey:@"status"];
    //将打包费置零:
    [tempDict setObject:[NSNumber numberWithInt:0] forKey:@"packfee"];
    //非套餐:
    if (!flag)
    {
        //设数量为1(若为套餐则不设,待改)
        [tempDict setObject:[NSNumber numberWithInt:1] forKey:@"quantity"];
        
        //设当前备注
        NSMutableArray *currentRemarks = [[NSMutableArray alloc]init];
        [tempDict setObject:currentRemarks forKey:@"currentRemark"];
        
        //当前价&&规格&&优惠价(默认取价格数组第一个元素)
        NSDictionary *priceDic = [[newDishDic objectForKey:@"price"]objectAtIndex:0];
        [tempDict setObject:[priceDic objectForKey:@"price"] forKey:@"originalPrice"];
        [tempDict setObject:[priceDic objectForKey:@"style"] forKey:@"currentStyle"];
        NSString *currentPriceStr = [NSString stringWithFormat:@"%@",[priceDic objectForKey:@"promotePrice"]];
        if (!currentPriceStr.length)//无优惠价,则设当前价与原始价相等.
        {
            currentPriceStr = [NSString stringWithFormat:@"%@",[priceDic objectForKey:@"price"]];
        }
        [tempDict setObject:currentPriceStr forKey:@"currentPrice"];
    }

    /*
     从世文代码看,服务器返回的购物车菜品数据数组应该是按 已入厨->已确认->未确认排序,
     新加菜品数据应遵守这个顺序插入:
     */
    if (!tempArray.count)
    {
        [tempArray addObject:tempDict];
    }
    else
    {
        for (int i = 0; i<tempArray.count; i++)
        {
            NSDictionary *dishDic = [tempArray objectAtIndex:i];
            int dishStatus = [[dishDic objectForKey:@"status"]intValue];
            if (dishStatus == 0)
            {
                [tempArray insertObject:tempDict atIndex:i];
                break;
            }
            else
            {
                if (i == tempArray.count - 1)
                {
                    [tempArray addObject:tempDict];
                    break;
                }
            }
        }
    }
    // 备份数据
    backupData_ = [self.shoppingCarListDataClass copy];
    [self updateShoppingCarView];
}

#pragma mark - UIButton Clicked

- (IBAction)cancelBtnClicked:(id)sender
{
    // 尝试关闭
    [self tryDismissView];
}

/**
 * @brief   厨房重印事件。
 *
 */
- (void)kitchenReprintBtnClick:(UIButton *)btn
{
    [self printByStatus:0];
}

/**
 * @brief   入厨房事件。
 *
 */
- (void)intoKitchenBtnClick:(UIButton *)btn
{
    [self submitShoppingCarWithDishesStatus:1 submitStatus:2];
}

/**
 * @brief   已确认重印事件。
 *
 */
- (void)alreadyReprintBtnClick:(UIButton *)btn
{
    [self printByStatus:2];
}

/**
 * @brief   已确认确认事件。
 *
 *
 */
- (void)alreadyComfirnBtnClick:(UIButton *)btn
{
    [self submitShoppingCarWithDishesStatus:1 submitStatus:5];
}

/**
 * @brief   已确认取消事件。
 *
 *
 */
- (void)alreadyCancelBtnClick:(UIButton *)btn
{
    // 还原数据
    self.shoppingCarListDataClass = [backupData_ copy];
    [self updateShoppingCarView];
    [self.shoppingCarTableView reloadData];
    
    // 清空修改状态
    isModified_ = NO;
}

/**
 * @brief   已确认放弃事件。
 *
 *
 */
- (void)alreadyGiveUpBtnClick:(UIButton *)btn
{
    currentSubmitType_ = 4;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:kLoc(@"confirm_to_give_up")
                                                       delegate:self
                                              cancelButtonTitle:kLoc(@"cancel")
                                              otherButtonTitles:kLoc(@"confirm"), nil];
    alertView.tag = kGiveUpAlertViewTag;
    [alertView show];
}

/**
 * @brief   未确认确认事件。
 *
 *
 */
- (void)unsureConfirmBtnClick:(UIButton *)btn
{
    [self submitShoppingCarWithDishesStatus:0 submitStatus:1];
}

/**
 * @brief   未确认放弃事件。
 *
 *
 */
- (void)unsureGiveUpBtnClick:(UIButton *)btn
{
    currentSubmitType_ = 3;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:kLoc(@"confirm_to_give_up")
                                                       delegate:self
                                              cancelButtonTitle:kLoc(@"cancel")
                                              otherButtonTitles:kLoc(@"confirm"), nil];
    alertView.tag = kGiveUpAlertViewTag;
    [alertView show];
}


/**
 * @brief   提交数据。
 *
 * @param   dishesStatus    要提交菜的状态（已入厨房、已确认还是未确认）。
 * @param   submiStatus 提交数据的类型。
 *                      0：回复（确认变为未确认）
 *                      1：确认
 *                      2：入厨
 *                      3：放弃未确认的数据
 *                      4：放弃已确认的数据
 *                      5：修改已确认的数据
 */
- (void)submitShoppingCarWithDishesStatus:(int)dishesStatus submitStatus:(int)submitStatus
{
    if (dishesStatus == 1)
    {
        isAddNewDish_ = NO;
    }
    NSMutableArray *dishesList = [[NSMutableArray alloc] init];
    if (!dishAddFromLocalArr_)
    {
        dishAddFromLocalArr_ = [[NSMutableArray alloc]init];
    }
    [dishAddFromLocalArr_ removeAllObjects];
    
    for (NSDictionary *dict in self.shoppingCarListDataClass.dishesArray)
    {
        if ([dict objectForKey:@"isAddFromLocal"])
        {
            if (submitStatus == 4 && dishesStatus == 1)//放弃已确认数据
            {
                continue;
            }
            else if (submitStatus == 3 && dishesStatus == 0)//放弃未确认数据
            {
                [dishAddFromLocalArr_ addObject:dict];
                continue;
            }
            else if (submitStatus == 1 && dishesStatus == 0)//确认未确认数据
            {
                [dishAddFromLocalArr_ addObject:dict];
                continue;
            }
            
        }
        if (dict && [[dict objectForKey:@"status"] intValue] == dishesStatus)
        {
            //复制出一份待提交数据,更改价格(如有优惠价)
            NSMutableDictionary *cookDic = [self duplicateObject:dict];
            NSString *styleStr = [cookDic objectForKey:@"currentStyle"];
            NSArray *priceArr = [cookDic objectForKey:@"price"];
            if ([cookDic objectForKey:@"cbId"])
            {
                [cookDic setObject:[cookDic objectForKey:@"cbId"] forKey:@"cbID"];
            }
            
            //找出promotePrice和currentStyleIndex
            for (int i = 0; i<priceArr.count; i++)
            {
                NSDictionary *dic = [priceArr objectAtIndex:i];
                NSString *temStyle = [dic objectForKey:@"style"];
                if ([temStyle isEqualToString:styleStr])
                {
                    //[cookDic setObject:[dic objectForKey:@"price"] forKey:@"originalPrice"];
                    NSString *promotePrice = [NSString stringWithFormat:@"%@",[dic objectForKey:@"promotePrice"]];
                    if (promotePrice.length)//如果存在优惠价格,则替换当前单价.
                    {
                        //[cookDic setObject:[dic objectForKey:@"promotePrice"] forKey:@"currentPrice"];
                    }
                    [cookDic setObject:[NSNumber numberWithInt:i]forKey:@"currentStyleIndex"];
                    break;
                }
            }
//            NSArray *packageArr = [cookDic objectForKey:@"package"];
//            if (packageArr.count && submitStatus == 2)//计算套餐中有无要加价项,仅当submitStatus为入厨房时才处理
//            {
//                float packageSubPrice = [self getSubPriceByCheck:packageArr];
//                if (packageSubPrice)
//                {
//                    float finalCurrentPrice = [[cookDic objectForKey:@"currentPrice"]floatValue] + packageSubPrice;
//                    float finalOriginalPrice = [[cookDic objectForKey:@"originalPrice"]floatValue] + packageSubPrice;
//                    float finalCurrentPromotePrice = [[cookDic objectForKey:@"currentPromotePrice"]floatValue] + packageSubPrice;
//                    [cookDic setObject:[NSNumber numberWithFloat:finalCurrentPrice] forKey:@"currentPrice"];
//                    [cookDic setObject:[NSNumber numberWithFloat:finalOriginalPrice] forKey:@"originalPrice"];
//                    [cookDic setObject:[NSNumber numberWithFloat:finalCurrentPromotePrice] forKey:@"currentPromotePrice"];
//                }
//            }
            [dishesList addObject:cookDic];
        }
    }
    // 保存提交类型
    currentSubmitType_ = submitStatus;
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    [postData setObject:[NSNumber numberWithInt:self.housingDataClass.housingId] forKey:@"tableId"];
    [postData setObject:dishesList forKey:@"dishes"];
    [postData setObject:self.seatingTime forKey:@"seatingTime"];
    [postData setObject:self.numberOfPeople forKey:@"numberOfPeople"];
    [postData setObject:self.userNumber forKey:@"userNumber"];
    [postData setObject:[NSNumber numberWithInt:submitStatus] forKey:@"status"];
    
    if (!jsonPicker) {
        jsonPicker = [[JsonPicker alloc] init];
    }
    
#ifdef DEBUG
    NSString *jsonStr = [self DataTOjsonString:postData];
    NSLog(@">>>>%@",jsonStr);
#endif
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowUpdateAlert = YES;
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:@"diningtable/order"];
}

//NSDictionary转JSonStr,仅为查看数据
-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

#pragma mark - Notifications

- (void)addNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification*)notify
{
    NSDictionary *userInfo = [notify userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    keyboardRect = [self.view convertRect:keyboardRect fromView:window];
    CGRect intersectionOfKeyboardRectAndWindowRect = CGRectIntersection(window.frame, keyboardRect);
    CGFloat bottomInset = intersectionOfKeyboardRectAndWindowRect.size.height;
    self.shoppingCarTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset,0.0f);
    self.shoppingCarTableView.scrollEnabled = NO;
    
    [UIView commitAnimations];
    
#ifdef DEBUG
    NSLog(@"===%@,keyboardWillShow:%@",self.class,NSStringFromCGRect(keyboardRect));
#endif
}

- (void)keyboardWillHide:(NSNotification*)notify
{
    NSDictionary *userInfo = [notify userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    self.shoppingCarTableView.scrollEnabled = YES;
    self.shoppingCarTableView.contentInset = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int indexSection = (int)indexPath.section;
    int indexRow = (int)indexPath.row;
    DtMenuShoppingCarDataClass *tempClass = [self getDtMenuShoppingCarDataClass:indexSection];
    
    if (kTableViewFirstRow == indexRow)
    {
        /*线 + 价格 + 菜名 + 数量*/
        
        if (tempClass.status == 1)//状态，0未确认，1已确认，2已入厨，
        {
            DtMenuShoppingTopTableViewCell* cell;
            static NSString *cellIdentifier = @"DtMenuShoppingTopTableViewCell";
            cell = (DtMenuShoppingTopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (!cell)
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"DtMenuShoppingTopTableViewCell" owner:self options:nil] lastObject];
                //            cell.spreadOrfoldStatus = 2;//默认处于折叠状态
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            cell.tag = indexRow;
            cell.sectionIndex = indexSection;
            cell.remarkTotalQuantity = [self getRemarkTotalNum:tempClass.currentRemarkArray];
            [cell updateDtMenuShoppingCarCell:tempClass];
            
            if (indexSection < intoKitchenArray.count)
            {
                UIColor *color = [UIColor blackColor];
                cell.priceLabel.textColor = color;
                cell.dishNameLabel.textColor = color;
                cell.partLabel.textColor = color;
                cell.togetherLabel.textColor = color;
                cell.quantityTextField.textColor = color;
            }
            else if (intoKitchenArray.count <= indexSection && indexSection < intoKitchenArray.count + sureArray.count) // 已确认的颜色更改
            {
                UIColor *color = [UIColor colorWithRed:0.313 green:0.313 blue:0.867 alpha:1.0];
                cell.priceLabel.textColor = color;
                cell.dishNameLabel.textColor = color;
                cell.partLabel.textColor = color;
                cell.togetherLabel.textColor = color;
                cell.quantityTextField.textColor = color;
            }
            else if (intoKitchenArray.count + sureArray.count <= indexSection)
            {
                UIColor *color = [UIColor colorWithRed:0.852 green:0.645 blue:0.125 alpha:1.0];
                cell.priceLabel.textColor = color;
                cell.dishNameLabel.textColor = color;
                cell.partLabel.textColor = color;
                cell.togetherLabel.textColor = color;
                cell.quantityTextField.textColor = color;
            }
            return cell;
        }
        else
        {
            DtMenuShoppingTopTableViewtemCell* cell;
            static NSString *cellIdentifier = @"DtMenuShoppingTopTableViewtemCell";
            cell = (DtMenuShoppingTopTableViewtemCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (!cell)
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"DtMenuShoppingTopTableViewtemCell" owner:self options:nil] lastObject];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            cell.tag = indexRow;
            cell.sectionIndex = indexSection;
            cell.remarkTotalQuantity = [self getRemarkTotalNum:tempClass.currentRemarkArray];
            [cell updateDtMenuShoppingCarCell:tempClass];
            
            if (indexSection < intoKitchenArray.count)
            {
                UIColor *color = [UIColor blackColor];
                cell.priceLabel.textColor = color;
                cell.dishNameLabel.textColor = color;
                cell.partLabel.textColor = color;
                cell.togetherLabel.textColor = color;
                cell.quantityTextField.textColor = color;
            }
            else if (intoKitchenArray.count <= indexSection && indexSection < intoKitchenArray.count + sureArray.count) // 已确认的颜色更改
            {
                UIColor *color = [UIColor colorWithRed:0.313 green:0.313 blue:0.867 alpha:1.0];
                cell.priceLabel.textColor = color;
                cell.dishNameLabel.textColor = color;
                cell.partLabel.textColor = color;
                cell.togetherLabel.textColor = color;
                cell.quantityTextField.textColor = color;
            }
            else if (intoKitchenArray.count + sureArray.count <= indexSection)
            {
                UIColor *color = [UIColor colorWithRed:0.852 green:0.645 blue:0.125 alpha:1.0];
                cell.priceLabel.textColor = color;
                cell.dishNameLabel.textColor = color;
                cell.partLabel.textColor = color;
                cell.togetherLabel.textColor = color;
                cell.quantityTextField.textColor = color;
            }
            return cell;
            
        }
        

    }
    else if ((1 == indexRow) && (1 == tempClass.modifyable))
    {
        /*点击添加备注*/
        static NSString *cellIdentifier = @"DtMenuShoppingBottomTableViewCell";
        DtMenuShoppingBottomTableViewCell *cell = (DtMenuShoppingBottomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell)
        {
            cell = [[DtMenuShoppingBottomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.tag = indexRow;
        cell.dishQuantity = tempClass.quantity;
        cell.remarkQuantity = [self getRemarkTotalNum:tempClass.currentRemarkArray];
        cell.sectionIndex = indexSection;
        
        [cell updateDtMenuShoppingBottomCell];
        
        return cell;
    }
    else
    {
        /*备注*/
        static NSString *cellIdentifier = @"DtMenuRemarkTableViewCell";
        DtMenuCookbookRemarkTableViewCell *cell = (DtMenuCookbookRemarkTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DtMenuCookbookRemarkTableViewCell" owner:self options:nil] lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.sectionIndex = indexSection;
        cell.tag = indexRow-1;
        cell.isShopCar = YES;
        cell.dishQuantity = tempClass.quantity;
        NSMutableArray *tempArray = tempClass.currentRemarkArray;
        cell.remarkQuantity = [self getRemarkTotalNum:tempArray];
        int indexOffset = 0;
        if (2 == tempClass.status)//2已入厨
        {
            indexOffset = 1;
        }
        else
        {
            if (0 == tempClass.status)
            {
                indexOffset = 1;
            }
            else
            {
                indexOffset = 2;
            }
        }
        int remarkIndex = indexRow - indexOffset;/*减去TopTableViewCell的row*/
        BOOL flag = (kZeroNumber == tempClass.modifyable)?NO:YES;
        DtMenuCookbookRemarkDataClass *tempRemarkClass = [self getDtMenuCookbookRemarkDataClass:remarkIndex withDtMenuShoppingCarDataClass:tempClass];
        [cell updateDtMenuCookbookRemarkCell:tempRemarkClass withModifyFlag:flag];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (resortArray.count <= section) {
        return 0.1;
    }
    NSDictionary *dict = resortArray[section];
    int status = 0;
    
    if (dict)
    {
        status = [[dict objectForKey:@"status"] intValue];
    }
    
    switch (status)
    {
        case 0:
            if (unsureArray.count && section == intoKitchenArray.count + sureArray.count)
            {
                return kHeightForHeader;
            }
            else
            {
                return 0.1;
            }
            break;
            
        case 1:
            if (sureArray.count && section == intoKitchenArray.count)
            {
                return kHeightForHeader;
            }
            else
            {
                return 0.1;
            }
            break;
            
        case 2:
            if (intoKitchenArray.count && section == 0)
            {
                return kHeightForHeader;
            }
            else
            {
                return 0.1;
            }
            break;
            
        default:
            break;
    }
    
    return kHeightForHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (resortArray.count <= section) {
        return 0.1;
    }
    NSDictionary *dict = resortArray[section];
    int status = 0;
    
    if (dict)
    {
        status = [[dict objectForKey:@"status"] intValue];
    }
    
    switch (status)
    {
        case 0://未确认
        {
            if (unsureArray.count && section == intoKitchenArray.count + sureArray.count + unsureArray.count -1)
            {
                return kHeightForFoot;
            }
            else
            {
                return 0.1;
            }
            break;
        }
            
        case 1://已确认
        {
            if (sureArray.count && section == intoKitchenArray.count + sureArray.count -1)
            {
                return kHeightForFoot;
            }
            else
            {
                return 0.1;
            }
            break;
        }
            
        case 2://入厨房
        {
            if (intoKitchenArray.count && section == intoKitchenArray.count - 1)
            {
                return kHeightForFoot;
            }
            else
            {
                return 0.1;
            }
            break;
        }
            
        default:
            break;
    }
    
    return kHeightForFoot;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (resortArray.count <= section) {
        return nil;
    }
    UIView *view = [[UIView alloc] init];
    
    UILabel *label = [[UILabel alloc] init];
    CGFloat xPos = kSystemVersionOfCurrentDevice < 7.0 ? 35.0 : 10.0;
    label.frame = CGRectMake(xPos,
                             (kHeightForHeader - 20.0) / 2.0,
                             tableView.bounds.size.width - xPos * 2,
                             20.0);
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:23.0];
    
    NSDictionary *dict = resortArray[section];
    int status = 0;
    
    if (dict) {
        status = [[dict objectForKey:@"status"] intValue];
    }
    
    switch (status) {
        case 0: {
            label.textColor = [UIColor colorWithRed:0.852 green:0.645 blue:0.125 alpha:1.0];
            label.text = kLoc(@"unrecognized");
            if (unsureArray.count && section == intoKitchenArray.count + sureArray.count) {
                [view addSubview:label];
            } else {
                return nil;
            }
            break;
        }
        case 1: {
            label.textColor = [UIColor colorWithRed:0.313 green:0.313 blue:0.867 alpha:1.0];
            label.text = kLoc(@"recognized");
            if (sureArray.count && section == intoKitchenArray.count) {
                [view addSubview:label];
            }
            break;
        }
        case 2: {
            label.textColor = [UIColor blackColor];
            label.text = kLoc(@"into_kitchen");
            
            if (intoKitchenArray.count && section == 0) {
                [view addSubview:label];
            } else {
                return nil;
            }
            break;
        }
        default:
            break;
    }
    
    
    return view;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (resortArray.count <= section)
    {
        return nil;
    }
    
    CGFloat tableWidth = self.shoppingCarTableView.frame.size.width;
    
    UIView *view = nil;
    
    NSDictionary *dict = resortArray[section];
    int status = 0;
    
    if (dict) {
        status = [[dict objectForKey:@"status"] intValue];
    }
    
    switch (status)
    {
        case 0: {
            if (unsureArray.count &&
                section == intoKitchenArray.count + sureArray.count + unsureArray.count -1) {
                
                view = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                0.0,
                                                                tableWidth,
                                                                kHeightForFoot)];
                
                // 未确认，显示“放弃”、“确认”按钮
                
                // 确认
                UIButton *confirmButton = nil;
                confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(tableWidth / 2.0 - 110.0,
                                                                           0.0,
                                                                           100.0,
                                                                           30.0)];
                [confirmButton setBackgroundImage:[UIImage imageNamed:@"more_longButton.png"]
                                         forState:UIControlStateNormal];
                [confirmButton setTitle:kLoc(@"confirm")
                               forState:UIControlStateNormal];
                confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
                [confirmButton addTarget:self
                                  action:@selector(unsureConfirmBtnClick:)
                        forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:confirmButton];
                
                // 放弃
                UIButton *giveUpButton = nil;
                giveUpButton = [[UIButton alloc] initWithFrame:CGRectMake(tableWidth / 2.0 + 10.0,
                                                                          0.0,
                                                                          100.0,
                                                                          30.0)];
                [giveUpButton setBackgroundImage:[UIImage imageNamed:@"more_longButton.png"]
                                        forState:UIControlStateNormal];
                [giveUpButton setTitle:kLoc(@"give_up")
                              forState:UIControlStateNormal];
                giveUpButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
                [giveUpButton addTarget:self
                                 action:@selector(unsureGiveUpBtnClick:)
                       forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:giveUpButton];
                
                
            }
            break;
        }
            
        case 1: {
            // 已确认
            if (sureArray.count && section == intoKitchenArray.count + sureArray.count -1) {
                
                view = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                0.0,
                                                                tableWidth,
                                                                kHeightForFoot)];
                
                // 放弃
                UIButton *giveUpButton = nil;
                giveUpButton = [[UIButton alloc] initWithFrame:CGRectMake(tableWidth / 2.0 - 170.0,
                                                                          0.0,
                                                                          100.0,
                                                                          30.0)];
                [giveUpButton setBackgroundImage:[UIImage imageNamed:@"more_longButton.png"]
                                        forState:UIControlStateNormal];
                [giveUpButton setTitle:kLoc(@"give_up")
                              forState:UIControlStateNormal];
                giveUpButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
                [giveUpButton addTarget:self
                                 action:@selector(alreadyGiveUpBtnClick:)
                       forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:giveUpButton];
            
                if (isModified_)
                {
                    giveUpButton.hidden = YES;
                    // 确认
                    UIButton *confirmButton = nil;
                    confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(tableWidth / 2.0 - 115,
                                                                               0.0,
                                                                               100.0,
                                                                               30.0)];
                    [confirmButton setBackgroundImage:[UIImage imageNamed:@"more_longButton.png"]
                                             forState:UIControlStateNormal];
                    [confirmButton setTitle:kLoc(@"confirm")
                                   forState:UIControlStateNormal];
                    confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
                    [confirmButton addTarget:self
                                      action:@selector(alreadyComfirnBtnClick:)
                            forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:confirmButton];
                    
                    // 取消
                    UIButton *cancelButton = nil;
                    cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(tableWidth / 2.0 + 15,
                                                                              0.0,
                                                                              100.0,
                                                                              30.0)];
                    [cancelButton setBackgroundImage:[UIImage imageNamed:@"more_longButton.png"]
                                            forState:UIControlStateNormal];
                    [cancelButton setTitle:kLoc(@"cancel")
                                  forState:UIControlStateNormal];
                    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
                    [cancelButton addTarget:self
                                     action:@selector(alreadyCancelBtnClick:)
                           forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:cancelButton];
                }
                else
                {
                    // 重印
                    UIButton *reprintButton = nil;
                    reprintButton = [[UIButton alloc] initWithFrame:CGRectMake(tableWidth / 2.0 - 50.0,
                                                                               0.0,
                                                                               100.0,
                                                                               30.0)];
                    [reprintButton setBackgroundImage:[UIImage imageNamed:@"more_longButton.png"]
                                             forState:UIControlStateNormal];
                    [reprintButton setTitle:kLoc(@"reprint")
                                   forState:UIControlStateNormal];
                    reprintButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
                    [reprintButton addTarget:self
                                      action:@selector(alreadyReprintBtnClick:)
                            forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:reprintButton];

                    // 入厨房
                    UIButton *kitchenButton = nil;
                    kitchenButton = [[UIButton alloc] initWithFrame:CGRectMake(tableWidth / 2.0 + 70.0,
                                                                               0.0,
                                                                               100.0,
                                                                               30.0)];
                    [kitchenButton setBackgroundImage:[UIImage imageNamed:@"more_longButton.png"]
                                             forState:UIControlStateNormal];
                    [kitchenButton setTitle:kLoc(@"into_kitchen")
                                   forState:UIControlStateNormal];
                    kitchenButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
                    [kitchenButton addTarget:self
                                      action:@selector(intoKitchenBtnClick:)
                            forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:kitchenButton];
                }
            }
            break;
        }
            
        case 2: {
            // 入厨房
            if (intoKitchenArray.count && section == intoKitchenArray.count - 1) {
                view = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                0.0,
                                                                tableWidth,
                                                                kHeightForFoot)];
            
                UIButton *reprintButton = nil;
                reprintButton = [[UIButton alloc] initWithFrame:CGRectMake(tableWidth / 2.0 - 50.0,
                                                                           0.0,
                                                                           100.0,
                                                                           30.0)];
                [reprintButton setBackgroundImage:[UIImage imageNamed:@"more_longButton.png"]
                                         forState:UIControlStateNormal];
                [reprintButton setTitle:kLoc(@"reprint")
                               forState:UIControlStateNormal];
                reprintButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
                [reprintButton addTarget:self
                                  action:@selector(kitchenReprintBtnClick:)
                        forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:reprintButton];
            }

            break;
        }
            
        default: {
            
            break;
        }
    }
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.shoppingCarListDataClass.dishesArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DtMenuShoppingCarDataClass *tempClass = [self getDtMenuShoppingCarDataClass:(int)section];
    /*菜名 + 备注 + 点击备注按钮*/
    if (tempClass.cuisineRemarkArray.count || 2 == tempClass.status)
    {
        return (1 + [tempClass.currentRemarkArray count] + ((1 == tempClass.modifyable)?1:0));
    }
    else
    {
        return (0 + [tempClass.currentRemarkArray count] + ((1 == tempClass.modifyable)?1:0));
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRow = kZeroNumber;
    if (kZeroNumber != indexPath.row)
    {
        heightForRow = 50;
    }
    else
    {
        DtMenuShoppingCarDataClass *tempClass = [self getDtMenuShoppingCarDataClass:(int)indexPath.section];
        NSMutableArray *tempArray = tempClass.packageArray;
        int tempCount = (int)[tempArray count];
        if (1 != tempClass.status)//状态，0未确认，1已确认，2已入厨，
        {
            heightForRow = 100;
        }
        else
        {
            heightForRow = kDtMenuShoppingTopTableViewCellNormalHeight;
        }
        
        if (tempCount == 0)
        {
            return heightForRow;
        }
        
        if (tempClass.foldOrspreadStatus == 0)//初始时， 初始默认为折叠
        {
            //nothing
        }
        else//展开状态
        {
            if (tempClass.status != 1)//状态，0未确认，1已确认，2已入厨，
            {
                heightForRow += 40.0;
                for (int i = 0; i < tempCount; i++)
                {
                    DtMenuCookbookPackageDataClass *tempPackageDataClass =[self getPackageDataClass:i withShoppingCarDataClass:tempClass];
                    if ([self whetherShowItemName:tempPackageDataClass])
                    {
                        /*栏目名称*/
                        NSString *itemName = [NSString getStrWithoutWhitespace:tempPackageDataClass.itemName];
                        if (kZeroNumber != [itemName length])
                        {
                            heightForRow = heightForRow + kDtMenuPackageItemNameHeight;
                        }
                        else
                        {
                            if (0 != i)
                            {
                                heightForRow = heightForRow +  kDtMenuPackageItemNameHeight/2;
                            }
                        }
                        
                        int tempMemberCount = (int)[tempPackageDataClass.memberArray count];
                        for (int j = 0; j < tempMemberCount; j++)
                        {
                            DtMenuCookbookPackageMemberDataClass *tempMemberClass = [self getPackageDetailDataClass:j withPackageDataClass:tempPackageDataClass];
                            if (tempMemberClass.checked)
                            {
                                heightForRow = heightForRow + kDtMenuPackageItemNameHeight;
                            }
                        }
                    }
                }
            }
            else//已确认
            {
                // 展开状态
                TakeoutShoppingCarSelectedView *selectPackageView = [[TakeoutShoppingCarSelectedView alloc]initWithData:tempClass];
                float PackageViewheight = [selectPackageView calculateSelfHeight];
                heightForRow += PackageViewheight;
            }
        }
     }
    
    return heightForRow;
}

#pragma mark - DtMenuShoppingTopTableViewCellDelegate

- (void)dtMenuShoppingTopTableViewCell:(DtMenuShoppingTopTableViewCell *)cell withDishQuantityChange:(int)quantity
{
    NSMutableArray *tempArray = self.shoppingCarListDataClass.dishesArray;
    int tempCount = (int)[tempArray count];
    int index = cell.sectionIndex;
    if (index < tempCount)
    {
        isModified_ = YES;
        
        if (kZeroNumber == quantity)
        {
            [tempArray removeObjectAtIndex:index];
        }
        else
        {
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[tempArray objectAtIndex:index]];
            [tempDict setObject:[NSNumber numberWithInt:quantity] forKey:kDtMenuShoppingCarQuantityKey];
            [tempArray replaceObjectAtIndex:index withObject:tempDict];
        }
        [self updateShoppingCarView];
    }
}

- (void)dtMenuShoppingTopTableViewCellreloadCell:(DtMenuShoppingTopTableViewCell *)cell
{
    // 修改折叠展开的数据源
    if (self.shoppingCarListDataClass.dishesArray.count > cell.sectionIndex)
    {
        NSMutableDictionary *tempDict = self.shoppingCarListDataClass.dishesArray[cell.sectionIndex];
        [tempDict setObject:[NSNumber numberWithInt:cell.foldOrspreadStatus] forKey:@"foldOrspreadStatus"];
        [self updateShoppingCarView];
    }

//    [self.shoppingCarTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:cell.tag inSection:cell.sectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
}

/**
 *  更改了价格规格
 *
 *  @param priceClass 新的价格(style + price)
 *  @param indexPath  新价格样式的序号.第几个.
 */
- (void)dtMenuShoppingTopTableViewCell:(DtMenuShoppingTopTableViewCell *)cell didChangePriceStyle:(DtMenuCookbookPriceDataClass *)priceClass andIndexPath:(NSIndexPath *)indexPath
{
    isModified_ = YES;
    NSMutableDictionary *tempDict = self.shoppingCarListDataClass.dishesArray[cell.sectionIndex];
    [tempDict setObject:priceClass.style forKey:@"currentStyle"];
    [tempDict setObject:priceClass.priceStr forKey:@"originalPrice"];
    NSString *currentPriceStr = priceClass.promotePrice;
    if (!currentPriceStr.length)
    {
        currentPriceStr = priceClass.priceStr;
    }
    [tempDict setObject:currentPriceStr forKey:@"currentPrice"];
    [self updateShoppingCarView];
}

/**
 *  在购物车中编辑了套餐任选/多选/必选项
 *
 *  @param newPackageArr 编辑后的新套餐数据.
 */
- (void)dtMenuShoppingTopTableViewCell:(DtMenuShoppingTopTableViewCell *)cell didChangedPackage:(NSArray *)newPackageArr andChangeMember:(NSDictionary *)memberDic
{
    isModified_ = YES;
    NSMutableDictionary *tempDict = self.shoppingCarListDataClass.dishesArray[cell.sectionIndex];
    [tempDict setObject:newPackageArr forKey:@"package"];
    float memberPrice = [[memberDic objectForKey:@"price"]floatValue];
    if (memberPrice)
    {
        if (![[memberDic objectForKey:@"checked"]boolValue])
        {
            memberPrice = 0 - memberPrice;
        }
        float currentPrice = [[tempDict objectForKey:@"currentPrice"]floatValue] + memberPrice;
        float originalPrice = [[tempDict objectForKey:@"originalPrice"]floatValue] + memberPrice;
        [tempDict setObject:[NSNumber numberWithFloat:currentPrice] forKey:@"currentPrice"];
        [tempDict setObject:[NSNumber numberWithFloat:originalPrice] forKey:@"originalPrice"];
        
//        NSMutableArray *priceArr = [NSMutableArray arrayWithArray:[tempDict objectForKey:@"price"]];
//        NSMutableDictionary *priceDic = [NSMutableDictionary dictionaryWithDictionary:[priceArr lastObject]];
//        float price = [[priceDic objectForKey:@"price"]floatValue] + memberPrice;
//        [priceDic setObject:[NSNumber numberWithFloat:price] forKey:@"price"];
//        NSString *promotePriceStr = [NSString stringWithFormat:@"%@",[priceDic objectForKey:@"promotePrice"]];
//        if (promotePriceStr.length)
//        {
//            float promotePrice = promotePriceStr.floatValue + memberPrice;
//            [priceDic setObject:[NSNumber numberWithFloat:promotePrice] forKey:@"promotePrice"];
//        }
//        [priceArr replaceObjectAtIndex:0 withObject:priceDic];
//        [tempDict setObject:priceArr forKey:@"price"];
    }
    [self updateShoppingCarView];
}


#pragma mark - DtMenuCookbookRemarkTableViewCellDelegate

- (void)dtMenuCookbookRemarkTableViewCell:(DtMenuCookbookRemarkTableViewCell *)cell withRemarkQuantityChange:(int)quantity
{
    isModified_ = YES;
    
    DtMenuShoppingCarDataClass *tempClass = [self getDtMenuShoppingCarDataClass:cell.sectionIndex];
    int remarkIndex = (int)cell.tag - 1;/*减去TopTableViewCell的row*/
    [DtMenuCookbookRemarkDataClass modifyRemarkData:tempClass.currentRemarkArray withIndex:remarkIndex withQuantity:quantity];
    [self.shoppingCarTableView reloadData];
}

- (void)showDtMenuCookbookRemarkOptionPicker:(DtMenuCookbookRemarkTableViewCell*)cell
{
    isModified_ = YES;
    
    if (!remarkPickerVC) {
        remarkPickerVC = [[DtMenuRemarkPickerViewController alloc] initWithNibName:@"DtMenuRemarkPickerViewController" bundle:nil];
    }
    if (!remarkPopController) {
        if (kIsiPhone) {
            remarkPopController = [[WEPopoverController alloc] initWithContentViewController:remarkPickerVC];
        } else {
            remarkPopController = [[UIPopoverController alloc] initWithContentViewController:remarkPickerVC];
        }
    }
    DtMenuShoppingCarDataClass *tempClass = [self getDtMenuShoppingCarDataClass:cell.sectionIndex];
    int remarkIndex = (int)cell.tag - 1;/*减去TopTableViewCell的row*/
    remarkPickerVC.vcTag = remarkIndex;
    remarkPickerVC.delegate = self;
    remarkPickerVC.cuisineRemarkArray = tempClass.cuisineRemarkArray;
    remarkPickerVC.dishRemarkArray = tempClass.currentRemarkArray;
    if (kIsiPhone) {
        MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
        WEPopoverController *popCtrl = remarkPopController;
        popCtrl.popoverContentSize = CGSizeMake(remarkPickerVC.view.frame.size.width,
                                                remarkPickerVC.view.frame.size.height);
        // 设置父视图，防止变形，更可以缩放视图
        popCtrl.parentView = mainCtrl.view;
        
        CGRect popRect = [cell convertRect:cell.bounds toView:mainCtrl.view];
        [popCtrl presentPopoverFromRect:popRect
                                 inView:mainCtrl.view
               permittedArrowDirections:UIPopoverArrowDirectionAny
                               animated:YES];
    } else {
        UIPopoverController *popCtrl = remarkPopController;
        popCtrl.popoverContentSize = CGSizeMake(remarkPickerVC.view.frame.size.width,
                                                remarkPickerVC.view.frame.size.height);
        [popCtrl presentPopoverFromRect:cell.frame
                                 inView:cell.superview
               permittedArrowDirections:UIPopoverArrowDirectionAny
                               animated:YES];
    }
}

#pragma mark DtMenuRemarkPickerViewControllerDelegate

- (void)DtMenuRemarkPickerViewController:(DtMenuRemarkPickerViewController *)ctrl withDishRemarkData:(NSMutableArray *)array
{
    isModified_ = YES;
    
    [self.shoppingCarTableView reloadData];
}

#pragma mark - DtMenuShoppingBottomTableViewCellDelegate

- (void)dtMenuShoppingBottomTableViewCell:(DtMenuShoppingBottomTableViewCell *)cell
{
    isModified_ = YES;
    
    DtMenuShoppingCarDataClass *tempClass = [self getDtMenuShoppingCarDataClass:cell.sectionIndex];
    [DtMenuCookbookRemarkDataClass addNewRemarkData:tempClass.currentRemarkArray];
    [self.shoppingCarTableView reloadData];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kCancelAlertViewTag: {
            if (buttonIndex == alertView.cancelButtonIndex) {
                
                // 通知sliderBar停止继续
                [MainViewController getMianViewShareInstance].breakPressAction = YES;

            } else if (1 == buttonIndex) {
                // 取消修改
                isModified_ = NO;
                
                // 返回
                [self executeDismissViewDelegateMethod];
            }
            break;
        }
            
        case kGiveUpAlertViewTag: {
            // 放弃
            if (buttonIndex != alertView.cancelButtonIndex) {
                if (currentSubmitType_ == 3) {
                    // 放弃未确认数据
                    [self submitShoppingCarWithDishesStatus:0 submitStatus:3];
                } else {
                    // 放弃已确认数据
                    [self submitShoppingCarWithDishesStatus:1 submitStatus:4];
                }
            } else {
                currentSubmitType_ = -1;
            }
        }
        default:
            break;
    }
}

#pragma mark - JsonPickerDelegate

- (void)handleFirstJsonPicker:(SuperDataClass *)dataClass
{
    switch (dataClass.responseStatus)
    {
        case kFirstResponseStatus:
        {
            
            // 打印数据
            switch (currentSubmitType_)
            {
                case 1:
                {
                    // 确认未确认的数据需要打印确认订单
                    [self printByStatus:3];
                    break;
                }
                    
                case 2:
                {
                    // 入厨房需要打印厨房订单
                    [self printByStatus:1];
                    break;
                }
                    
                default:
                    break;
            }
            
            // 餐厅名称、地址
            if (dataClass.dataDict != nil && [dataClass.dataDict isKindOfClass:[NSDictionary class]])
            {
                
                if ([dataClass.dataDict objectForKey:@"corpInfo"] != nil)
                {
                    NSDictionary *corpInfoDict = [dataClass.dataDict objectForKey:@"corpInfo"];
                    AccountManager *accountMgr = [AccountManager sharedAccountManager];
                    [accountMgr saveRestaurantName:[corpInfoDict objectForKey:@"name"]];
                    [accountMgr saveRestaurantAddress:[corpInfoDict objectForKey:@"addr"]];
                }
                
                // 更新数据源
                self.shoppingCarListDataClass = [[DtMenuShoppingCarListDataClass alloc] initWithDtMenuShoppingCarListData:dataClass.dataDict];
            }
            else
            {
                // 更新数据源
                if (self.shoppingCarListDataClass.dishesArray != nil)
                {
                    [self.shoppingCarListDataClass.dishesArray removeAllObjects];
                }
                else
                {
                    self.shoppingCarListDataClass.dishesArray = [NSMutableArray array];
                }
            }
            
            if (currentSubmitType_ == 3 || currentSubmitType_ == 1)
            {
                if (dishAddFromLocalArr_.count)
                {
                    /*
                    从世文代码看,服务器返回的购物车菜品数据数组应该是按 已入厨->已确认->未确认排序,
                    保存的本地添加菜品数据应遵守这个顺序插入:
                    */
                    NSMutableArray *tempArray = self.shoppingCarListDataClass.dishesArray;
                    if (!tempArray.count)
                    {
                        [tempArray addObjectsFromArray:dishAddFromLocalArr_];
                    }
                    else
                    {
                        for (int i = 0; i<tempArray.count; i++)
                        {
                            NSDictionary *dishDic = [tempArray objectAtIndex:i];
                            int dishStatus = [[dishDic objectForKey:@"status"]intValue];
                            if (dishStatus == 0)
                            {
                                NSRange range = NSMakeRange(i, dishAddFromLocalArr_.count);
                                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                                [tempArray insertObjects:dishAddFromLocalArr_ atIndexes:indexSet];
                                break;
                            }
                            else
                            {
                                if (i == tempArray.count - 1)
                                {
                                    [tempArray addObjectsFromArray:dishAddFromLocalArr_];
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            
            
            // 备份数据
            backupData_ = [self.shoppingCarListDataClass copy];
            
            // 更新房台状态
            self.housingStateType = kHousingHavedDish;
            
            [self updateShoppingCarView];
            
            // 弹出提示（如果有）
            [PSAlertView showWithMessage:dataClass.alertMsg];
            
            if (currentSubmitType_ == 1 || currentSubmitType_ == 3) {
                // 1确认未确认数据，3放弃未确认数据，通知主页面更新UI
                [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateDinningTableList
                                                                    object:nil
                                                                  userInfo:nil];
            }
            
            currentSubmitType_ = -1;

            if (backWhileSubmit_) {
                backWhileSubmit_ = NO;
                // 返回
                [self executeDismissViewDelegateMethod];
            }
            
            // 提交数据完成之后取消修改状态
            isModified_ = NO;
            
            break;
        }
        case kFourthResponseStatus:
        {
            NSMutableDictionary *temDic = [[NSMutableDictionary alloc]init];
            [temDic setObject:[dataClass.dataDict objectForKey:@"cookbook"] forKey:@"list"];
            if (self.delegate && [self.delegate respondsToSelector:@selector(submitFailWithNewDishData:)])
            {
                [self.delegate submitFailWithNewDishData:temDic];//刷新菜谱
            }
            [self updateCarData:temDic];
            [PSAlertView showWithMessage:dataClass.alertMsg];
            break;
        }
        default: {
            [PSAlertView showWithMessage:dataClass.alertMsg];
            break;
        }
    }
}

/**
 *  价格变动后,提交失败,服务器带回最新的菜品数据,利用该数据检索并刷新购物车中的价格.
 *
 *  @param dic 服务器返回的菜品数据.
 */
- (void)updateCarData:(NSMutableDictionary *)dic
{
    NSArray *cuisArr = [dic objectForKey:@"list"];
    for (int i = 0;i<self.shoppingCarListDataClass.dishesArray.count;i++)
    {
        NSDictionary *dict = [self.shoppingCarListDataClass.dishesArray objectAtIndex:i];
        if (dict && [[dict objectForKey:@"status"] intValue] != 2)//已入厨房的数据不管.
        {
            NSMutableDictionary *newDishDic = [NSMutableDictionary dictionaryWithDictionary:dict];
            NSString *cookID = [NSString stringWithFormat:@"%@",[dict objectForKey:@"cbId"]];
            NSString *currentStyle = [dict objectForKey:@"currentStyle"];
            for (NSDictionary *cuiDic in cuisArr)
            {
                BOOL isFound = NO;
                NSArray *cookArr = [cuiDic objectForKey:@"cookbook"];
                for (NSDictionary *cookDic in cookArr)
                {
                    NSString *temCookID = [NSString stringWithFormat:@"%@",[cookDic objectForKey:@"cbId"]];
                    if ([cookID isEqualToString:temCookID])
                    {
                        NSArray *priceArr = [cookDic objectForKey:@"price"];
                        [newDishDic setObject:priceArr forKey:@"price"];
                        //根据价格样式找出最新价格,NND
                        for (int j = 0;j < priceArr.count;j++)
                        {
                            NSDictionary *priceDic = [priceArr objectAtIndex:j];
                            NSString *temStyle = [priceDic objectForKey:@"style"];
                            if ([temStyle isEqualToString:currentStyle])
                            {
                                [newDishDic setObject:[priceDic objectForKey:@"price"] forKey:@"currentPrice"];
                                [newDishDic setObject:[NSNumber numberWithInt:j] forKey:@"currentStyleIndex"];
                                break;
                            }
                        }
                        [self.shoppingCarListDataClass.dishesArray replaceObjectAtIndex:i withObject:newDishDic];
                        isFound = YES;
                        break;
                    }
                }
                if (isFound)
                {
                    break;
                }
            }
        }
    }
   [self updateShoppingCarView];
}

- (void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
#ifdef DEBUG
    NSLog(@"===%s,dict:%@===",__FUNCTION__,dict);
#endif
    
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    switch (picker.tag)
    {
        case kJsonPickerFirstTag:
        {
            NSLog(@"****%@",dict);
            [self handleFirstJsonPicker:dataClass];
            break;
        }
            
        default:
        {
            [PSAlertView showWithMessage:dataClass.alertMsg];
            break;
        }
    }
}

// JSON解释错误时返回
- (void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error
{
    
}

// 网络连接失败时返回（无网络的情况）
- (void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error
{
    
}

@end
