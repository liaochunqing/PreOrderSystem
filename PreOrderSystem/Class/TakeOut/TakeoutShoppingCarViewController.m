//
//  TakeoutShoppingCarViewController.m
//  PreOrderSystem
//
//  Created by YorkIT on 14-6-18.
//
//

#import "TakeoutShoppingCarViewController.h"
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
#import "TakeoutShoppingCarSelectedView.h"

#define kCancelAlertViewTag 1000
#define kGiveUpAlertViewTag 1001
#define kHeightForHeader 35
#define kHeightForFoot 35

#define kTimes 1.5;

@interface TakeoutShoppingCarViewController () {
    /// 数据请求对象
    JsonPicker *jsonPicker;
    /// 备注弹出框
    id remarkPopController;
    /// 备注选择视图
    DtMenuRemarkPickerViewController *remarkPickerVC;
    
    /// 是否已经修改
    BOOL isModified_;
    
    /// 备份数据源（当点击取消的时候就以这个数据为准还原）
//    DtMenuShoppingCarListDataClass *backupData_;
}

/// 背景视图
@property(nonatomic, weak) IBOutlet UIImageView *bgImageView;
/// 购物车列表视图
@property(nonatomic, weak) IBOutlet UITableView *shoppingCarTableView;
/// 总数量视图
@property(nonatomic, weak) IBOutlet UILabel *totalQuantityLabel;
/// 总价视图
@property(nonatomic, weak) IBOutlet UILabel *totalPriceLabel;
/// 返回按钮
@property(nonatomic, weak) IBOutlet UIButton *cancelButton;
/// 标题视图
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

@end

@implementation TakeoutShoppingCarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    self.titleLabel.text = kLoc(@"inventory");
}

- (void)updateShoppingCarView
{
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

    if (index < self.shoppingCarListDataClass.dishesArray.count)
    {
        NSDictionary *tempDict = [self.shoppingCarListDataClass.dishesArray objectAtIndex:index];
        tempClass = [[DtMenuShoppingCarDataClass alloc] initWithDtMenuShoppingCarData:tempDict];
    }
    
    return tempClass;
}

- (DtMenuCookbookRemarkDataClass *)getDtMenuCookbookRemarkDataClass:(int)index
                                     withDtMenuShoppingCarDataClass:(DtMenuShoppingCarDataClass *)shoppingCardataClass
{
    DtMenuCookbookRemarkDataClass *tempClass = nil;
    NSMutableArray *tempArray = shoppingCardataClass.currentRemarkArray;
    if (index < [tempArray count]) {
        tempClass = [[DtMenuCookbookRemarkDataClass alloc] initWithDtMenuRemarkData:[tempArray objectAtIndex:index]];
    }
    return tempClass;
}

/*套餐 dataClass*/
- (DtMenuCookbookPackageDataClass *)getPackageDataClass:(int)index
                               withShoppingCarDataClass:(DtMenuShoppingCarDataClass *)dataClass
{
    DtMenuCookbookPackageDataClass *tempDataClass = nil;
    NSMutableArray *tempArray = dataClass.packageArray;
    if (index < [tempArray count]) {
        tempDataClass = [[DtMenuCookbookPackageDataClass alloc] initWithDtMenuPackageData:[tempArray objectAtIndex:index]];
    }
    return tempDataClass;
}

/*套餐栏目成员 dataClass*/
- (DtMenuCookbookPackageMemberDataClass *)getPackageDetailDataClass:(int)index
                                               withPackageDataClass:(DtMenuCookbookPackageDataClass *)packageDataClass
{
    DtMenuCookbookPackageMemberDataClass *tempDataClass = nil;
    NSMutableArray *tempArray = packageDataClass.memberArray;
    if (index < [tempArray count]) {
        tempDataClass = [[DtMenuCookbookPackageMemberDataClass alloc]
                         initWithDtMenuPackageMemberData:[tempArray objectAtIndex:index]];
    }
    return tempDataClass;
}

- (BOOL)whetherShowItemName:(DtMenuCookbookPackageDataClass *)dataClass
{
    BOOL flag = NO;
    int tempMemberCount = (int)[dataClass.memberArray count];
    for (int j = 0; j < tempMemberCount; j++) {
        DtMenuCookbookPackageMemberDataClass *tempMemberClass = [self getPackageDetailDataClass:j
                                                                           withPackageDataClass:dataClass];
        if (tempMemberClass.checked) {
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
    for (int i = 0; i < tempCount; i++) {
        DtMenuCookbookRemarkDataClass *tempClass = [[DtMenuCookbookRemarkDataClass alloc]
                                                    initWithDtMenuRemarkData:[array objectAtIndex:i]];
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
    for (int i = 0; i < tempCount; i++) {
        DtMenuShoppingCarDataClass *tempClass = [self getDtMenuShoppingCarDataClass:i];
        totalNum = totalNum + tempClass.quantity;
    }
    self.totalQuantityLabel.text = [NSString stringWithFormat:@"%@ %d %@",
                                    kLoc(@"total"),
                                    totalNum,
                                    kLoc(@"part")];
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
        float packageSubPrice = 0;//套餐子项加钱.
//        if (tempClass.packageArray.count)
//        {
//            packageSubPrice = [self getSubPriceByCheck:tempClass.packageArray];
//        }
        NSString *finalPrice = tempClass.currentPrice;
        totoalPrice = totoalPrice + (tempClass.packfee.floatValue * tempClass.quantity) + (tempClass.quantity * [finalPrice floatValue]) + packageSubPrice;
    }
    NSString *tempStr = [NSString stringWithFormat:@"%.2f",totoalPrice];
    self.totalPriceLabel.text = [NSString stringWithFormat:@"%@ %@",
                                 [[OfflineManager sharedOfflineManager] getCurrencySymbol],
                                 [NSString oneDecimalOfPrice:[tempStr floatValue]]];
}

- (void)tryDismissView
{
    if (isModified_) {
        NSString *alertMessage = kLoc(@"data_is_not_saved_confirm_to_leave");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertMessage
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:kLoc(@"cancel")
                                                  otherButtonTitles:kLoc(@"confirm"), nil];
        alertView.tag = kCancelAlertViewTag;
        [alertView show];
    } else {
        // 没有修改
        if ([self.delegate respondsToSelector:@selector(takeoutShoppingCarViewHadDismiss:)]) {
            [self.delegate takeoutShoppingCarViewHadDismiss:self];
        }
    }
}

/**
 * @brief   同步数据。
 *
 */
- (void)synchronizeData
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    // 本地保存数据
    [userDefault setObject:self.shoppingCarListDataClass.corpInfoDict
                    forKey:kTakeoutByPhoneUserInfoKey];
    [userDefault setObject:self.shoppingCarListDataClass.dishesArray
                    forKey:kTakeoutByPhoneDishesListKey];
    [userDefault synchronize];
}

- (void)reload
{
    [self updateShoppingCarView];
    [self scrollTableToFoot:YES];
}

/**
 *  滚动tableView到底部
 *
 *  @param animated 是否显示滚动动画
 */
- (void)scrollTableToFoot:(BOOL)animated
{
    NSInteger s = [self.shoppingCarTableView numberOfSections];
    if (s<1) return;
    NSInteger r = [self.shoppingCarTableView numberOfRowsInSection:s-1];
    if (r<1) return;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
    
    [self.shoppingCarTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
#pragma mark -Private method

//NSDictionary转JSonStr
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

#pragma mark - UIButton Clicked

- (IBAction)cancelBtnClicked:(id)sender
{
//    // 尝试关闭
//    [self tryDismissView];
        // 直接关闭
    if ([self.delegate respondsToSelector:@selector(takeoutShoppingCarViewHadDismiss:)])
    {
            [self.delegate takeoutShoppingCarViewHadDismiss:self];
    }
}

- (void)resetButtonAction:(id)sender
{
    [self cancelBtnClicked:sender];
}

- (void)submitButtonAction:(id)sender
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (self.shoppingCarListDataClass.corpInfoDict != nil) {
        // 本地保存数据
        
        [userDefault setObject:self.shoppingCarListDataClass.corpInfoDict
                        forKey:kTakeoutByPhoneUserInfoKey];
        [userDefault setObject:self.shoppingCarListDataClass.dishesArray
                        forKey:kTakeoutByPhoneDishesListKey];
        [userDefault synchronize];
        
        // 资料齐全，提交数据
        [self submitShoppingCar];
    } else {
        // 没有填写外卖信息
        self.isWaitingForContinue = YES;
        if ([self.delegate respondsToSelector:@selector(takeoutShoppingCarViewMustInputUserInfo:)]) {
            [self.delegate takeoutShoppingCarViewMustInputUserInfo:self];
        }
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            while (self.isWaitingForContinue) {
                // 等待输入
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                         beforeDate:[NSDate distantFuture]];
                
                __block NSDictionary *userInfo = [userDefault objectForKey:kTakeoutByPhoneUserInfoKey];
                if (userInfo != nil) {
                    // 用户资料已经填完了，取消检测
                    self.isWaitingForContinue = NO;
                    // 进入主线程
                    dispatch_async(dispatch_get_main_queue(), ^{
                        userInfo = [DtMenuShoppingCarListDataClass duplicateObject:userInfo];
                        self.shoppingCarListDataClass.corpInfoDict = userInfo;
                        // 提交数据
                        [self submitShoppingCar];
                    });
                    break;
                }
            }
        });
    }
}

/**
 * @brief   提交数据。
 *
 */
- (void)submitShoppingCar
{
    NSDictionary *userInfo = self.shoppingCarListDataClass.corpInfoDict;
    NSMutableDictionary *postData = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    
    //若优惠价格不为空,则替换掉单价
    NSMutableArray *submitDishArr = [self duplicateObject:self.shoppingCarListDataClass.dishesArray];
    for (int i = 0; i < submitDishArr.count; i++)
    {
        NSDictionary *dic = [submitDishArr objectAtIndex:i];
        NSString *currentPromotePrice = [NSString stringWithFormat:@"%@",[dic objectForKey:@"currentPromotePrice"]];
        
//        NSArray *packageArr = [dic objectForKey:@"package"];
//        float packagePrice = 0.0;
//        if (packageArr.count)
//        {
//            packagePrice = [self getSubPriceByCheck:packageArr];
//        }
        
        NSMutableDictionary *finalDishDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        if (currentPromotePrice.length)
        {
            [finalDishDic setObject:currentPromotePrice forKey:@"currentPrice"];
        }
//        if (packagePrice > 0)
//        {
//            float finalCurrentPrice = [[finalDishDic objectForKey:@"currentPrice"]floatValue] + packagePrice;
//            float finalOriginalPrice = [[finalDishDic objectForKey:@"originalPrice"]floatValue] + packagePrice;
//            float finalCurrentPromotePrice = [[finalDishDic objectForKey:@"currentPromotePrice"]floatValue] + packagePrice;
//            [finalDishDic setObject:[NSNumber numberWithFloat:finalCurrentPrice] forKey:@"currentPrice"];
//            [finalDishDic setObject:[NSNumber numberWithFloat:finalOriginalPrice] forKey:@"originalPrice"];
//            [finalDishDic setObject:[NSNumber numberWithFloat:finalCurrentPromotePrice] forKey:@"currentPromotePrice"];
//        }
        [submitDishArr replaceObjectAtIndex:i withObject:finalDishDic];
    }
    
    [postData setObject:submitDishArr forKey:@"dishes"];
    if (!jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
#ifdef DEBUG
    NSString *jsonStr = [self DataTOjsonString:postData];
    NSLog(@">>>%@",jsonStr);
#endif
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowUpdateAlert = YES;
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:@"takeout/order"];
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
        static NSString *cellIdentifier = @"DtMenuShoppingTopTableViewCell";
        DtMenuShoppingTopTableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DtMenuShoppingTopTableViewCell"
                                                  owner:self
                                                options:nil] lastObject];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.tag = indexRow;
        cell.sectionIndex = indexSection;
        cell.remarkTotalQuantity = [self getRemarkTotalNum:tempClass.currentRemarkArray];
        [cell updateDtMenuShoppingCarCell:tempClass];
        
        if (indexPath.section == 0)
        {
            cell.lineImageView.hidden = YES;
        }
        else
        {
            cell.lineImageView.hidden = NO;
        }
        
        // 字体颜色
        UIColor *color = [UIColor darkGrayColor];
        cell.priceLabel.textColor = color;
        cell.dishNameLabel.textColor = color;
        cell.partLabel.textColor = color;
        cell.togetherLabel.textColor = color;
        cell.quantityTextField.textColor = color;
        
        return cell;
    }
    else if ((kTableViewSecondRow == indexRow) && (1 == tempClass.modifyable))
    {
        /*点击添加备注*/
        static NSString *cellIdentifier = @"DtMenuShoppingBottomTableViewCell";
        DtMenuShoppingBottomTableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//        if (!cell)
        {
            cell = [[DtMenuShoppingBottomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                            reuseIdentifier:cellIdentifier];
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
        DtMenuCookbookRemarkTableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DtMenuCookbookRemarkTableViewCell"
                                                  owner:self
                                                options:nil] lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.sectionIndex = indexSection;
        cell.tag = indexRow-1;
        cell.isShopCar = YES;
        cell.dishQuantity = tempClass.quantity;
        NSMutableArray *tempArray = tempClass.currentRemarkArray;
        cell.remarkQuantity = [self getRemarkTotalNum:tempArray];
        int remarkIndex = indexRow - 2;/*减去TopTableViewCell的row*/
        BOOL flag = (kZeroNumber == tempClass.modifyable) ? NO : YES;
        DtMenuCookbookRemarkDataClass *tempRemarkClass = [self getDtMenuCookbookRemarkDataClass:remarkIndex
                                                                 withDtMenuShoppingCarDataClass:tempClass];
        [cell updateDtMenuCookbookRemarkCell:tempRemarkClass withModifyFlag:flag];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == self.shoppingCarListDataClass.dishesArray.count - 1)
    {
        return kHeightForFoot;
    }
    else
    {
        return 0.1;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == self.shoppingCarListDataClass.dishesArray.count - 1)
    {
        CGFloat tableWidth = self.shoppingCarTableView.frame.size.width;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                0.0,
                                                                tableWidth,
                                                                kHeightForFoot)];
        
        // 提交
        UIButton *submitButton = nil;
        submitButton = [[UIButton alloc] initWithFrame:CGRectMake(tableWidth / 2.0 + 10.0,
                                                                  0.0,
                                                                  100.0,
                                                                  30.0)];
        [submitButton setBackgroundImage:[UIImage imageNamed:@"more_longButton.png"]
                                forState:UIControlStateNormal];
        [submitButton setTitle:kLoc(@"submit")
                      forState:UIControlStateNormal];
        submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        [submitButton addTarget:self
                         action:@selector(submitButtonAction:)
               forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:submitButton];
        
        submitButton.center = CGPointMake(tableWidth/2, 15);
        
        return view;
    }
    else
    {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.shoppingCarListDataClass.dishesArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DtMenuShoppingCarDataClass *tempClass = [self getDtMenuShoppingCarDataClass:(int)section];
    /*菜名 + 备注 + 点击备注按钮*/
    if (tempClass.cuisineRemarkArray.count)
    {
        return (1 + [tempClass.currentRemarkArray count] + ((1 == tempClass.modifyable) ? 1 : 0));
    }
    else
    {
        return (0 + ((1 == tempClass.modifyable) ? 1 : 0));
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
        heightForRow = kDtMenuShoppingTopTableViewCellNormalHeight;
        
        DtMenuShoppingCarDataClass *tempClass = [self getDtMenuShoppingCarDataClass:(int)indexPath.section];
        NSMutableArray *tempArray = tempClass.packageArray;
        int tempCount = (int)[tempArray count];
        float packFeeHeight = 0;//打包费显示栏所占的高度
        if (tempClass.packfee.floatValue && ![tempClass.originPrice isEqualToString:tempClass.currentPrice])
        {
            packFeeHeight = 40.0;
        }
        heightForRow += packFeeHeight;
        
        if (tempCount == 0)
        {
            return heightForRow;
        }
        
        if (tempClass.foldOrspreadStatus == 0)
        {
            // 初始时， 初始默认为折叠
        }
        else
        {
            // 展开状态
            TakeoutShoppingCarSelectedView *selectPackageView = [[TakeoutShoppingCarSelectedView alloc]initWithData:tempClass];
            float PackageViewheight = [selectPackageView calculateSelfHeight];
            heightForRow += PackageViewheight;
        }
    }
    return heightForRow;
}


#pragma mark - DtMenuShoppingTopTableViewCellDelegate

//菜品数量变化.
- (void)dtMenuShoppingTopTableViewCell:(DtMenuShoppingTopTableViewCell *)cell withDishQuantityChange:(int)quantity
{
    NSMutableArray *tempArray = self.shoppingCarListDataClass.dishesArray;
    int tempCount = (int)[tempArray count];
    int index = cell.sectionIndex;
    if (index < tempCount) {
        isModified_ = YES;
        
        if (kZeroNumber == quantity)
        {
            NSDictionary *temDic = (NSDictionary *)[tempArray objectAtIndex:index];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:kDelectDishFromCarNotification
             object:[temDic objectForKey:@"name"] userInfo:nil];
            [tempArray removeObjectAtIndex:index];
        }
        else
        {
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[tempArray objectAtIndex:index]];//通知左边选择栏删除掉一个菜.
            [tempDict setObject:[NSNumber numberWithInt:quantity] forKey:kDtMenuShoppingCarQuantityKey];
            [tempArray replaceObjectAtIndex:index withObject:tempDict];
        }
        [self updateShoppingCarView];
        
        // 同步数据
        [self synchronizeData];
    }
}

- (void)dtMenuShoppingTopTableViewCellreloadCell:(DtMenuShoppingTopTableViewCell *)cell
{
    // 修改折叠展开的数据源
    NSMutableDictionary *tempDict = self.shoppingCarListDataClass.dishesArray[cell.sectionIndex];
    [tempDict setObject:[NSNumber numberWithInt:cell.foldOrspreadStatus] forKey:@"foldOrspreadStatus"];
    
    [self updateShoppingCarView];
    // 同步数据
    [self synchronizeData];
}

//修改了套餐数据
- (void)dtMenuShoppingTopTableViewCell:(DtMenuShoppingTopTableViewCell *)cell
                     didChangedPackage:(NSArray *)newPackageArr
                       andChangeMember:(NSDictionary *)memberDic
{
    NSIndexPath *currentPath = [self.shoppingCarTableView indexPathForCell:cell];
    
    if (currentPath.section < self.shoppingCarListDataClass.dishesArray.count)
    {
        NSMutableDictionary *tempDict = [self.shoppingCarListDataClass.dishesArray objectAtIndex:currentPath.section];
        [tempDict setValue:newPackageArr forKey:@"package"];
        
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
            NSString *currentPromotePriceStr = [NSString stringWithFormat:@"%@",[tempDict objectForKey:@"currentPromotePrice"]];
            if (currentPromotePriceStr.length)
            {
                float currentPromotePrice = currentPromotePriceStr.floatValue + memberPrice;
                [tempDict setObject:[NSNumber numberWithFloat:currentPromotePrice] forKey:@"currentPromotePrice"];
            }

            
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
        
        [self.shoppingCarListDataClass.dishesArray replaceObjectAtIndex:currentPath.section withObject:tempDict];
       //[self.shoppingCarTableView reloadData];
        [self updateDishTotoalPrice];//更新总价
        
        // 同步数据
        [self synchronizeData];
    }
    
}

//修改了价格类型
- (void)dtMenuShoppingTopTableViewCell:(DtMenuShoppingTopTableViewCell *)cell didChangePriceStyle:(DtMenuCookbookPriceDataClass *)priceClass andIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *currentPath = [self.shoppingCarTableView indexPathForCell:cell];
    if (currentPath.section < self.shoppingCarListDataClass.dishesArray.count)
    {
        NSDictionary *tempDict = [self.shoppingCarListDataClass.dishesArray objectAtIndex:currentPath.section];
        [tempDict setValue:priceClass.style forKey:@"currentStyle"];
        [tempDict setValue:priceClass.priceStr forKey:@"currentPrice"];
        [tempDict setValue:priceClass.priceStr forKeyPath:@"originalPrice"];
        [tempDict setValue:priceClass.promotePrice forKeyPath:@"currentPromotePrice"];
        [tempDict setValue:[NSNumber numberWithInteger:indexPath.row] forKey:@"currentStyleIndex"];
        [self.shoppingCarListDataClass.dishesArray replaceObjectAtIndex:currentPath.section withObject:tempDict];

        // 同步数据
        [self synchronizeData];
        [self updateShoppingCarView];
        //[self.shoppingCarTableView reloadData];
    }
    
}

#pragma mark - DtMenuCookbookRemarkTableViewCellDelegate

- (void)dtMenuCookbookRemarkTableViewCell:(DtMenuCookbookRemarkTableViewCell *)cell withRemarkQuantityChange:(int)quantity
{
    isModified_ = YES;
    
    DtMenuShoppingCarDataClass *tempClass = [self getDtMenuShoppingCarDataClass:cell.sectionIndex];
    int remarkIndex = (int)cell.tag - 1;/*减去TopTableViewCell的row*/
    [DtMenuCookbookRemarkDataClass modifyRemarkData:tempClass.currentRemarkArray withIndex:remarkIndex withQuantity:quantity];
    [self.shoppingCarTableView reloadData];
    
    // 同步数据
    [self synchronizeData];
}

- (void)showDtMenuCookbookRemarkOptionPicker:(DtMenuCookbookRemarkTableViewCell*)cell
{
    isModified_ = YES;
    
    if (!remarkPickerVC)
    {
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
    
    // 同步数据
    [self synchronizeData];
}

#pragma mark DtMenuRemarkPickerViewControllerDelegate

- (void)DtMenuRemarkPickerViewController:(DtMenuRemarkPickerViewController *)ctrl withDishRemarkData:(NSMutableArray *)array
{
    isModified_ = YES;
    
    [self.shoppingCarTableView reloadData];
    
    // 同步数据
    [self synchronizeData];
}

#pragma mark - DtMenuShoppingBottomTableViewCellDelegate

- (void)dtMenuShoppingBottomTableViewCell:(DtMenuShoppingBottomTableViewCell *)cell
{
    isModified_ = YES;
    
    DtMenuShoppingCarDataClass *tempClass = [self getDtMenuShoppingCarDataClass:cell.sectionIndex];
    [DtMenuCookbookRemarkDataClass addNewRemarkData:tempClass.currentRemarkArray];
    [self.shoppingCarTableView reloadData];
    
    // 同步数据
    [self synchronizeData];
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
                if ([self.delegate respondsToSelector:@selector(takeoutShoppingCarViewHadDismiss:)]) {
                    [self.delegate takeoutShoppingCarViewHadDismiss:self];
                }
            }
            break;
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
            // 提交电话外卖成功
            
            // 提交数据完成之后取消修改状态
            isModified_ = NO;
            
            // 弹出提示（如果有）
            [PSAlertView showWithMessage:dataClass.alertMsg];
            
            // 回调
            if ([self.delegate respondsToSelector:@selector(takeoutShoppingCarViewSubmitted:)]) {
                [self.delegate takeoutShoppingCarViewSubmitted:self];
            }
            
            break;
        }
        case kThirdResponseStatus:
        {
            // 弹出提示（如果有）
            [PSAlertView showWithMessage:dataClass.alertMsg];
            if (self.delegate && [self.delegate respondsToSelector:@selector(takeoutShoppingCarViewSubmittedFailWithNewCookBookData:)])
            {
                [self.delegate takeoutShoppingCarViewSubmittedFailWithNewCookBookData:dataClass];
            }
            break;
        }
        default:
        {
            [PSAlertView showWithMessage:dataClass.alertMsg];
            break;
        }
    }
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
