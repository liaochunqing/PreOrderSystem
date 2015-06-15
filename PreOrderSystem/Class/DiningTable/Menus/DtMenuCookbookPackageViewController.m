//
//  DtMenuCookbookPackageViewController.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-27.
//
//

#import "DtMenuCookbookPackageViewController.h"
#import "DtMenuDataClass.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DiningTableImageName.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"
#import "Constants.h"
#import "NsstringAddOn.h"
#import "OfflineManager.h"
#import "DtMenusCommon.h"
#import "WEPopoverController.h"
#import "MainViewController.h"
#import "UITextFieldAddition.h"

#define kHeightForRowAtIndexPath 50
#define kHeightForHeaderInSection 40
#define kFontSizeForItemName 18
#define kCancelAlertViewTag 1000


/*套餐栏目 + 备注选项*/
#define kNumberOfSectionsInTableView ([self.cookbookDataClass.packageArray count] + 1)

@interface DtMenuCookbookPackageViewController ()<UIAlertViewDelegate>
{
    JsonPicker *jsonPicker;
    NSMutableArray *dishRemarkArray;
    id remarkPopController;
    DtMenuRemarkPickerViewController *remarkPickerVC;
    NSString *currentQuantityStr;
    NSMutableArray *originPackageArray;
    
    /// 是否修改了数据
    BOOL isModified_;
}

@end

@implementation DtMenuCookbookPackageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 创建关闭按钮
    [self.quantityTextField bindCloseButton];
    
    dishRemarkArray = [[NSMutableArray alloc] init];
    self.cookbookPackageTableView.backgroundColor = nil;
    [self addPictureToView];
    [self addLocalizedString];
    [self addNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self revertPackageData];
    [self updateDtMenuCookbookPackageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self removeNotification];
#ifdef DEBUG
    NSLog(@"===%@,%s===", self.class, __FUNCTION__);
#endif
}

- (void)addPictureToView
{
    self.bgImageView.image = [UIImage imageFromMainBundleFile:kDtMenuCookbookBgImageName];
    self.quantityBgImageView.image = [UIImage imageFromMainBundleFile:kDtMenuCookbookQuantityBgImageName];
    self.handleBtnBgImageView.image = [UIImage imageFromMainBundleFile:kDtMenuCookbookHandleBtnBgImageName];
    [self.quantityReduceButton setBackgroundImage:[UIImage imageFromMainBundleFile:kDtMenuCookbookQuantityRudeceNormalBgImageName] forState:UIControlStateNormal];
    [self.quantityAddButton setBackgroundImage:[UIImage imageFromMainBundleFile:kDtMenuCookbookQuantityAddNormalBgImageName] forState:UIControlStateNormal];
    [self.quantityReduceButton setBackgroundImage:[UIImage imageFromMainBundleFile:kDtMenuCookbookQuantityRudeceSelectedBgImageName] forState:UIControlStateHighlighted];
    [self.quantityAddButton setBackgroundImage:[UIImage imageFromMainBundleFile:kDtMenuCookbookQuantityAddSelectedBgImageName] forState:UIControlStateHighlighted];
    [self.cancelButton setImage:[UIImage imageFromMainBundleFile:@"order_arrowButtonImage.png"]
                       forState:UIControlStateNormal];
}

- (void)addLocalizedString
{
    self.priceTitleLabel.text = [NSString stringWithFormat:@"%@ : ", kLoc(@"unit_price")];
    [self.remarkButton setTitle:kLoc(@"click_to_add_remark") forState:UIControlStateNormal];
    [self.trueButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
    [self.trueButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
}

- (void)updateDtMenuCookbookPackageView
{
    originPackageArray = [[NSMutableArray alloc] initWithArray:self.cookbookDataClass.packageArray];
    /*菜名*/
    CGSize titleSize = [(self.dishNameLabel.text = self.cookbookDataClass.name) sizeWithFont:[UIFont boldSystemFontOfSize:22]];
    CGRect dishNameFrame = self.dishNameLabel.frame;
    dishNameFrame.size.width = titleSize.width;
    self.dishNameLabel.frame = dishNameFrame;
    self.dishNameScrollView.contentSize = CGSizeMake(titleSize.width, self.dishNameScrollView.frame.size.height);
    /*数量*/
    self.quantityTextField.text = @"1";
    /*价格*/
    [self updatePriceByStyleAndCheck];
    /*备注*/
    
    /*若可选备注为零,则隐藏添加备注按钮*/
    self.remarkButton.hidden = (!self.cuisineRemarkArray.count)? YES:NO;
    [dishRemarkArray removeAllObjects];
    if (self.cuisineRemarkArray.count)
    {
        [DtMenuCookbookRemarkDataClass addNewRemarkData:dishRemarkArray];
    }
    [self.cookbookPackageTableView reloadData];
    [self whetherRemarkBtnEnable];
}

/*还原套餐数据*/
- (void)revertPackageData
{
    NSMutableArray *tempArray = self.cookbookDataClass.packageArray;
    int tempCount = [tempArray count];
    for (int i = 0; i < tempCount; i++) {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[tempArray objectAtIndex:i]];
        int choiceType = [[tempDict objectForKey:kDtMenuCookbookPackageDataChoiceTypeKey] integerValue];
        if (0 != choiceType)
        {
            NSMutableArray *tempMemberArray = [[NSMutableArray alloc]initWithArray:[tempDict objectForKey:kDtMenuCookbookPackageDataMemberKey]];
            int tempMemberCount = [tempMemberArray count];
            for (int j = 0; j < tempMemberCount; j++)
            {
                NSMutableDictionary *memberDict = [[NSMutableDictionary alloc] initWithDictionary:[tempMemberArray objectAtIndex:j]];
                [memberDict setObject:@"0" forKey:kDtMenuCookbookPackageMemberCheckedKey];
                [tempMemberArray replaceObjectAtIndex:j withObject:memberDict];
            }
            [tempDict setObject:tempMemberArray forKey:kDtMenuCookbookPackageDataMemberKey];
            [tempArray replaceObjectAtIndex:i withObject:tempDict];
        }
    }
}

/*根据样式获取价格*/
- (NSString *)getPriceStrForCurrentStyle
{
    NSString *priceStr = @"";
    NSArray *priceArray = self.cookbookDataClass.priceArray;
    int priceCount = [priceArray count];
    for (int i = 0; i < priceCount; i++)
    {
        DtMenuCookbookPriceDataClass *priceClass = [[DtMenuCookbookPriceDataClass alloc] initWithDtMenuPriceData:[priceArray objectAtIndex:i]];
        priceStr = priceClass.priceStr;
    }
    return priceStr;
}

/*根据样式获取优惠价格*/
- (NSString *)getPromotePriceStrForCurrentStyle
{
    NSString *promotePriceStr = @"";
    NSArray *priceArray = self.cookbookDataClass.priceArray;
    NSUInteger priceCount = [priceArray count];
    for (int i = 0; i < priceCount; i++)
    {
        DtMenuCookbookPriceDataClass *priceClass = [[DtMenuCookbookPriceDataClass alloc] initWithDtMenuPriceData:[priceArray objectAtIndex:i]];
        promotePriceStr = priceClass.promotePrice;
    }
    return promotePriceStr;
}

- (float)getSubPriceByCheck
{
    float totalSubPrice = 0.0;
    NSMutableArray *tempArray = self.cookbookDataClass.packageArray;
    int tempCount = [tempArray count];
    for (int i = 0; i < tempCount; i++)
    {
        NSMutableDictionary *tempDict = [tempArray objectAtIndex:i];
        NSMutableArray *tempMemberArray = [tempDict objectForKey:kDtMenuCookbookPackageDataMemberKey];
        int tempMemberCount = [tempMemberArray count];
        for (int j = 0; j < tempMemberCount; j++)
        {
            NSMutableDictionary *memberDict = [tempMemberArray objectAtIndex:j];
            int checked = [[memberDict objectForKey:kDtMenuCookbookPackageMemberCheckedKey] integerValue];
            if (checked)
            {
                float subPrice = [[memberDict objectForKey:kDtMenuCookbookPackageMemberPriceKey] floatValue];
                totalSubPrice = totalSubPrice + subPrice;
            }
        }
    }
    return totalSubPrice;
}

/*更新单价*/
- (void)updatePriceByStyleAndCheck
{
    float stylePrice = [[self getPriceStrForCurrentStyle] floatValue];
    NSString *promotePriceStr = [self getPromotePriceStrForCurrentStyle];
    if (promotePriceStr.length)//存在优惠价
    {
        float promotePrice = [promotePriceStr floatValue];
        self.promotePrice.hidden = NO;
        NSString *primotePriceTitle = NSLocalizedString(@"优惠价:", nil);
        self.promotePrice.text = [NSString stringWithFormat:@"%@ %@ %@",primotePriceTitle, [[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString trimmingZeroInPrice:[NSString stringWithFormat:@"%.2f", (promotePrice + [self getSubPriceByCheck])]]];
    }
    else//不存在优惠价
    {
        self.promotePrice.hidden = YES;
    }
    self.priceLabel.text = [NSString stringWithFormat:@"%@ %@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString trimmingZeroInPrice:[NSString stringWithFormat:@"%.2f", (stylePrice + [self getSubPriceByCheck])]]];
    [self updateDishTotoalPrice];
}

/*更新总价*/
- (void)updateDishTotoalPrice
{
    NSString *finalPrice = [self getPromotePriceStrForCurrentStyle];
    if (!finalPrice.length)
    {
        finalPrice = [self getPriceStrForCurrentStyle];
    }
    
    float totoalPrice = ([finalPrice floatValue] + [self getSubPriceByCheck]) * [self.quantityTextField.text integerValue];
    NSString *tempStr = [NSString stringWithFormat:@"%.2f",totoalPrice];
    self.totalPriceLabel.text = [NSString stringWithFormat:@"%@ %@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString oneDecimalOfPrice:[tempStr floatValue]]];
}

/*更新数量*/
- (void)updateDishNumStr:(BOOL)isAddNum
{
    int dishNum = [self.quantityTextField.text integerValue];
    if (isAddNum)
    {
        ++dishNum;
    }
    else
    {
        if ((dishNum > [dishRemarkArray count]) && (1 < dishNum))
        {
            --dishNum;
        }
    }
    self.quantityTextField.text = [NSString stringWithFormat:@"%d", dishNum];
    [self updateDishTotoalPrice];
}

- (void)whetherRemarkBtnEnable
{
    int tempQuantity = [self.quantityTextField.text integerValue];
    if ([self getRemarkTotalNum] < tempQuantity && (1 < tempQuantity))
    {
        self.quantityReduceButton.enabled = ([dishRemarkArray count] < [self.quantityTextField.text integerValue])? YES : NO;
    }
    else
    {
        self.quantityReduceButton.enabled = NO;
    }
    if ([self getRemarkTotalNum] < tempQuantity && (0 < tempQuantity))
    {
        self.remarkButton.enabled = ([dishRemarkArray count] < [self.quantityTextField.text integerValue])? YES : NO;
    }
    else
    {
        self.remarkButton.enabled = NO;
    }
    if (kFirstMaxQuantityNumber <= tempQuantity)
    {
        self.quantityAddButton.enabled = NO;
    }
    else
    {
        self.quantityAddButton.enabled = YES;
    }
    [self.remarkButton setTitleColor:(self.remarkButton.enabled ? kTitleSecondColor:kTitleFirstColor) forState:UIControlStateNormal];
    [self.cookbookPackageTableView reloadData];
}

- (int)getRemarkTotalNum
{
    int totalNum = 0;
    int tempCount = [dishRemarkArray count];
    for (int i = 0; i < tempCount; i++)
    {
        DtMenuCookbookRemarkDataClass *tempClass = [[DtMenuCookbookRemarkDataClass alloc] initWithDtMenuRemarkData:[dishRemarkArray objectAtIndex:i]];
        totalNum = totalNum + tempClass.quantity;
    }
    return totalNum;
}

- (void)addRemarkData
{
    if (self.remarkButton.enabled) {
    
        isModified_ = YES;
        
        [DtMenuCookbookRemarkDataClass addNewRemarkData:dishRemarkArray];
        [self.cookbookPackageTableView reloadData];
    }
    [self whetherRemarkBtnEnable];
}

- (int)getMemberSelectedNum:(int)itemIndex
{
    int totalNum = 0;
    NSMutableArray *tempArray = self.cookbookDataClass.packageArray;
    int tempCount = [tempArray count];
    if (itemIndex < tempCount)
    {
        NSMutableDictionary *tempDict = [tempArray objectAtIndex:itemIndex];
        NSMutableArray *tempMemberArray = [tempDict objectForKey:kDtMenuCookbookPackageDataMemberKey];
        int tempMemberCount = [tempMemberArray count];
        for (int j = 0; j < tempMemberCount; j++)
        {
            NSMutableDictionary *memberDict = [tempMemberArray objectAtIndex:j];
            int checked = [[memberDict objectForKey:kDtMenuCookbookPackageMemberCheckedKey] integerValue];
            if (checked)
            {
                totalNum++;
            }
        }
    }
    return totalNum;
}

/*套餐 dataClass*/

- (DtMenuCookbookPackageDataClass *)getPackageDataClass:(int)index
{
    DtMenuCookbookPackageDataClass *tempDataClass = nil;
    NSMutableArray *tempArray = self.cookbookDataClass.packageArray;
    if (index < [tempArray count]) {
        tempDataClass = [[DtMenuCookbookPackageDataClass alloc] initWithDtMenuPackageData:[tempArray objectAtIndex:index]];
    }
    return tempDataClass;
}

/*套餐栏目成员 dataClass*/

- (DtMenuCookbookPackageMemberDataClass *)getPackageMemberDataClass:(int)index withPackageData:(NSMutableArray *)memberArray
{
    DtMenuCookbookPackageMemberDataClass *tempDataClass = nil;
    if (index < [memberArray count]) {
        tempDataClass = [[DtMenuCookbookPackageMemberDataClass alloc] initWithDtMenuPackageMemberData:[memberArray objectAtIndex:index]];
    }
    return tempDataClass;
}

#pragma mark - UIButton clicked

- (IBAction)quantityReduceBtnClicked:(id)sender
{
    isModified_ = YES;
    
    [self updateDishNumStr:NO];
    [self whetherRemarkBtnEnable];
}

- (IBAction)quantityAddBtnClicked:(id)sender
{
    isModified_ = YES;
    
    [self updateDishNumStr:YES];
    [self whetherRemarkBtnEnable];
}

- (IBAction)remarkBtnClicked:(id)sender
{
    [self addRemarkData];
}

- (IBAction)cancelBtnClicked:(id)sender
{
    // 尝试关闭
    [self tryDismissView];
}

- (void)executeDismissViewDelegateMethod
{
    if ([self.delegate respondsToSelector:@selector(DtMenuCookbookPackageViewHavedDismiss)])
    {
        [self.delegate DtMenuCookbookPackageViewHavedDismiss];
    }
}

- (IBAction)trueBtnClicked:(id)sender
{
    [self.quantityTextField resignFirstResponder];
    if (kZeroNumber >= [self.quantityTextField.text integerValue])
    {
        [PSAlertView showWithMessage:kLoc(@"please_add_menu")];
        return;
    }
    NSMutableArray *tempArray = self.cookbookDataClass.packageArray;
    int tempCount = [tempArray count];
    for (int i = 0; i < tempCount; i++)
    {
        DtMenuCookbookPackageDataClass *tempPackageClass = [self getPackageDataClass:i];
        if (kPackageSecondChoiceType == tempPackageClass.choiceType)
        {
            int memberSelectedNum = 0;
            NSMutableArray *tempMemberArray = tempPackageClass.memberArray;
            int tempMemberCount = [tempMemberArray count];
            for (int j = 0; j < tempMemberCount; j++)
            {
                DtMenuCookbookPackageMemberDataClass *memberClass = [self getPackageMemberDataClass:j withPackageData:tempMemberArray];
                if (1 == memberClass.checked)
                {
                    memberSelectedNum++;
                }
            }
            if (tempPackageClass.choiceNum != memberSelectedNum)
            {
                NSString *itemNameStr = [NSString getStrWithoutWhitespace:tempPackageClass.itemName];
                if ([NSString strIsEmpty:itemNameStr])
                {
                    itemNameStr = [NSString stringWithFormat:@"%@%d%@", kLoc(@"the"),(i + 1), kLoc(@"column")];
                }
                NSString *wartStr = [NSString stringWithFormat:@"%@%@%d%@",itemNameStr, kLoc(@"required"), tempPackageClass.choiceNum, kLoc(@"item")];
                [PSAlertView showWithMessage:wartStr];
                return;
            }
        }
    }
    [self submitDishDataToShoppingCar:YES];
}

- (void)tryDismissView
{
    [self.quantityTextField resignFirstResponder];
    
    if (isModified_) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kLoc(@"data_is_not_saved_confirm_to_leave")
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
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
    self.cookbookPackageTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset - self.cookbookPackageTableView.frame.origin.y,0.0f);
    self.cookbookPackageTableView.scrollEnabled = NO;
    
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
    
    self.cookbookPackageTableView.scrollEnabled = YES;
    self.cookbookPackageTableView.contentInset = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}

#pragma mark - network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

- (void)submitDishDataToShoppingCar:(BOOL)animated
{
    DtMenuCookbookPriceDataClass *priceClass = [[DtMenuCookbookPriceDataClass alloc] initWithDtMenuPriceData:[self.cookbookDataClass.priceArray firstObject]];
    float currentPrice = [[self getPriceStrForCurrentStyle] floatValue] + [self getSubPriceByCheck];
    float promotePrice = [[self getPromotePriceStrForCurrentStyle]floatValue];
    float finalPrce = 0.0;
    if (promotePrice)
    {
        finalPrce = promotePrice + [self getSubPriceByCheck];
    }
    else
    {
        finalPrce = currentPrice;
    }
    
    
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    NSMutableDictionary *dishDict = [NSMutableDictionary dictionary];
    [dishDict setObject:[NSNumber numberWithFloat:currentPrice] forKey:@"originalPrice"];
    [dishDict setObject:self.dishNameLabel.text forKey:@"name"];
    [dishDict setObject:self.quantityTextField.text forKey:@"quantity"];
    [dishDict setObject:dishRemarkArray forKey:@"currentRemark"];
    [dishDict setObject:self.cuisineRemarkArray forKey:@"remark"];
    [dishDict setObject:self.cookbookDataClass.cookID forKey:@"cbID"];
    [dishDict setObject:priceClass.style forKey:@"currentStyle"];
    [dishDict setObject:[NSNumber numberWithFloat:finalPrce] forKey:@"currentPrice"];
    [dishDict setObject:self.cookbookDataClass.priceArray forKey:@"price"];
    [dishDict setObject:self.cookbookDataClass.packageArray forKey:@"package"];
    [postData setObject:[NSNumber numberWithInt:self.housingId] forKey:@"tableId"];
    [postData setObject:dishDict forKey:@"dishes"];
    
    if (!jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = YES;
    if (!animated)
    {
        jsonPicker.loadingMessage = nil;
    }
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:@"diningtable/addCart"];
    
#ifdef DEBUG
    NSLog(@"===%s,%@===",__FUNCTION__,postData);
#endif
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int indexSection = indexPath.section;
    int indexRow = indexPath.row;
    if ((kNumberOfSectionsInTableView - 1) != indexSection) {
        /*套餐内容*/
        static NSString *cellIdentifier = @"DtMenuPackageTableViewCell";
        DtMenuCookbookPackageTableViewCell *cell = (DtMenuCookbookPackageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DtMenuCookbookPackageTableViewCell"
                                                  owner:self
                                                options:nil] lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.sectionIndex = indexSection;
        cell.tag = indexRow;
        cell.selectedTotalNum = [self getMemberSelectedNum:indexSection];
        
        DtMenuCookbookPackageDataClass *tempClass = [self getPackageDataClass:indexSection];
        NSDictionary *firstDict = nil;
        NSDictionary *secondDict = nil;
        NSMutableArray *tempArray = tempClass.memberArray;
        int tempCount = [tempArray count];
        int indexForCell = indexRow * kDtMenuPackageCellNum;
        const int firstIndex = indexForCell;
        const int secondIndex = firstIndex + 1;
        if (secondIndex < tempCount) {
            firstDict = [tempArray objectAtIndex:firstIndex];
            secondDict = [tempArray objectAtIndex:secondIndex];
        } else if(firstIndex < tempCount) {
            firstDict = [tempArray objectAtIndex:firstIndex];
        }
        cell.choiceType = tempClass.choiceType;
        cell.choiceNum = tempClass.choiceNum;
        [cell updateDtMenuCookbookPackageCell:firstDict withSecondItemDict:secondDict];
        
        return cell;
    } else {
        /*备注*/
        static NSString *cellIdentifier = @"DtMenuRemarkTableViewCell";
        DtMenuCookbookRemarkTableViewCell *cell = (DtMenuCookbookRemarkTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DtMenuCookbookRemarkTableViewCell"
                                                  owner:self
                                                options:nil] lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.tag = indexRow;
        cell.isShopCar = NO;
        cell.dishQuantity = [self.quantityTextField.text integerValue];
        cell.remarkQuantity = [self getRemarkTotalNum];
        if (indexRow < [dishRemarkArray count]) {
            DtMenuCookbookRemarkDataClass *tempClass = [[DtMenuCookbookRemarkDataClass alloc] initWithDtMenuRemarkData:[dishRemarkArray objectAtIndex:indexRow]];
            [cell updateDtMenuCookbookRemarkCell:tempClass withModifyFlag:YES];
        }
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSectionsInTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((kNumberOfSectionsInTableView - 1) == section) {
        return [dishRemarkArray count];
    } else {
        int tempCount = [[self getPackageDataClass:section].memberArray count];
        int number = 0;
        if ( 0 == tempCount % kDtMenuPackageCellNum) {
            number = tempCount / kDtMenuPackageCellNum;
        } else {
            number = tempCount / kDtMenuPackageCellNum + 1;
        }
        return number;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeightForRowAtIndexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    float tempHeight = kZeroNumber;
    if ((kNumberOfSectionsInTableView - 1) != section) {
        NSString *tempStr = [NSString getStrWithoutWhitespace:[self getTitleForHeaderInSection:section]];
        if (![NSString strIsEmpty:tempStr]) {
            tempHeight = kHeightForHeaderInSection;
        }
    }
    return tempHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = nil;
    if ((kNumberOfSectionsInTableView - 1) != section) {
        headView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                            0.0,
                                                            self.cookbookPackageTableView.frame.size.width,
                                                            kHeightForHeaderInSection)];
        headView.backgroundColor = [UIColor colorWithRed:242.0/255.0
                                                   green:243.0/255.0
                                                    blue:239.0/255.0
                                                   alpha:1.0];
        
        if (0 != section) {
            UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0,
                                                                                  0.0,
                                                                                  headView.frame.size.width - 30.0,
                                                                                  5.0)];
            lineView.backgroundColor = [UIColor clearColor];
            lineView.image = [UIImage imageFromMainBundleFile:kDtMenuCookbookPackageItemLineBgImageName];
            [headView addSubview:lineView];
        }
        
        NSString *tempStr = [NSString getStrWithoutWhitespace:[self getTitleForHeaderInSection:section]];
        if (![NSString strIsEmpty:tempStr]) {
            UILabel *itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.cookbookPackageTableView.frame.size.width - 30, kHeightForHeaderInSection)];
            itemNameLabel.backgroundColor = [UIColor clearColor];
            itemNameLabel.textAlignment = UITextAlignmentLeft;
            itemNameLabel.font = [UIFont systemFontOfSize:kFontSizeForItemName];
            itemNameLabel.textColor = [UIColor colorWithRed:92.0/255.0 green:92.0/255.0 blue:94.0/255.0 alpha:1.0];
            itemNameLabel.adjustsFontSizeToFitWidth = YES;
            itemNameLabel.text = tempStr;
            [headView addSubview:itemNameLabel];
        }
    }
    return headView;
}

- (NSString *)getTitleForHeaderInSection:(NSInteger)section
{
    NSString *tempStr = nil;
    DtMenuCookbookPackageDataClass *tempClass = [self getPackageDataClass:section];
    switch (tempClass.choiceType) {
        case 1: {
            tempStr = [NSString stringWithFormat:@"(%@%d%@)", kLoc(@"required"),
                       tempClass.choiceNum, kLoc(@"item")];
            break;
        }
        case 2: {
            tempStr = [NSString stringWithFormat:@"(%@)", kLoc(@"optional_choose")];
            break;
        }
        default: {
            tempStr = @"";
            break;
        }
    }
    return [NSString stringWithFormat:@"%@%@",tempClass.itemName, tempStr];
}

#pragma mark UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.quantityTextField == textField) {
        currentQuantityStr = self.quantityTextField.text;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    if (self.quantityTextField == textField) {
        int number = [self.quantityTextField.text integerValue];
        if (number < [self getRemarkTotalNum]) {
            self.quantityTextField.text = currentQuantityStr;
            [PSAlertView showWithMessage:kLoc(@"dish_number_can_not_be_less_than_remark_number")];
            return;
        }
        if (number < 1) {
            self.quantityTextField.text = currentQuantityStr;
            [PSAlertView showWithMessage:kLoc(@"dish_number_must_be_greater_than_one")];
            return;
        }
        
        isModified_ = YES;
        
        [self updatePriceByStyleAndCheck];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.quantityTextField]) {
        [self performSelector:@selector(whetherRemarkBtnEnable) withObject:nil afterDelay:0.1];
        if ([NSString isValidateNumber:string]) {
            if (range.location >= kFirstMaxQuantityLength) {
                return NO;
            }
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
        default:
            break;
    }
}

#pragma mark - DtMenuCookbookPackageTableViewCellDelegate

- (void)dtMenuCookbookPackageTableViewCell:(DtMenuCookbookPackageTableViewCell *)cell withMemberDict:(NSDictionary *)selectedDict withMemberIndex:(int)index
{
    int sectionIndex = cell.sectionIndex;
    DtMenuCookbookPackageDataClass *tempClass = [self getPackageDataClass:sectionIndex];
    if (1 == cell.choiceNum && kPackageSecondChoiceType == cell.choiceType) {
        NSMutableArray *tempMemberArray = tempClass.memberArray;
        int tempCount = [tempMemberArray count];
        for (int i = 0; i < tempCount; i++) {
            if (i != index) {
                NSMutableDictionary *memberDict = [[NSMutableDictionary alloc] initWithDictionary:[tempMemberArray objectAtIndex:i]];
                [memberDict setObject:[NSNumber numberWithInt:0]
                               forKey:kDtMenuCookbookPackageMemberCheckedKey];
                [DtMenuCookbookPackageDataClass modifyPackageData:tempMemberArray
                                                       withMember:memberDict
                                                        withIndex:i];
            } else {
                [DtMenuCookbookPackageDataClass modifyPackageData:tempMemberArray
                                                       withMember:selectedDict
                                                        withIndex:index];
            }
        }
    } else {
        [DtMenuCookbookPackageDataClass modifyPackageData:tempClass.memberArray
                                               withMember:selectedDict
                                                withIndex:index];
    }
    NSMutableArray *tempArray = self.cookbookDataClass.packageArray;
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[tempArray objectAtIndex:sectionIndex]];
    [tempDict setObject:tempClass.memberArray forKey:kDtMenuCookbookPackageDataMemberKey];
    [tempArray replaceObjectAtIndex:sectionIndex withObject:tempDict];
    
    isModified_ = YES;
    
    [self updatePriceByStyleAndCheck];
    [self.cookbookPackageTableView reloadData];
}

#pragma mark - DtMenuCookbookRemarkTableViewCellDelegate

- (void)dtMenuCookbookRemarkTableViewCell:(DtMenuCookbookRemarkTableViewCell *)cell withRemarkQuantityChange:(int)quantity
{
    int index = cell.tag;
    if (index < [dishRemarkArray count]) {
        if (quantity > 0) {
            [DtMenuCookbookRemarkDataClass modifyRemarkData:dishRemarkArray
                                                  withIndex:index
                                               withQuantity:quantity];
        } else {
            [dishRemarkArray removeObjectAtIndex:cell.tag];
        }
        
        isModified_ = YES;
        
        [self whetherRemarkBtnEnable];
        [self.cookbookPackageTableView reloadData];
    }
}

- (void)showDtMenuCookbookRemarkOptionPicker:(DtMenuCookbookRemarkTableViewCell*)cell
{
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
    remarkPickerVC.vcTag = cell.tag;
    remarkPickerVC.delegate = self;
    remarkPickerVC.cuisineRemarkArray = self.cuisineRemarkArray;
    remarkPickerVC.dishRemarkArray = dishRemarkArray;
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
    
    dishRemarkArray = array;
    [self.cookbookPackageTableView reloadData];
}

#pragma mark - JsonPickerDelegate

- (void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
#ifdef DEBUG
    NSLog(@"===%s,dict:%@===",__FUNCTION__,dict);
#endif
    
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    if (kJsonPickerFirstTag == picker.tag) {
        switch (dataClass.responseStatus) {
            case kFirstResponseStatus: {
                
                isModified_ = NO;
                
                [PSAlertView showWithMessage:dataClass.alertMsg];
                
                // 通知主页面更新UI
                [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateDinningTableList
                                                                    object:nil
                                                                  userInfo:nil];
                
                [self performSelector:@selector(executeDismissViewDelegateMethod)
                           withObject:nil
                           afterDelay:kSuccessfulShowTime];
                break;
            }
                
            default: {
                [PSAlertView showWithMessage:dataClass.alertMsg];
                break;
            }
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
