//
//  DtMenuShoppingTopTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-1-3.
//
//

#import "DtMenuShoppingTopTableViewCell.h"
#import "DiningTableImageName.h"
#import "DtMenuDataClass.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"
#import "OfflineManager.h"
#import "DtMenusCommon.h"
#import "Constants.h"
#import "UITextFieldAddition.h"

#define kTextDarkGradColor [UIColor colorWithRed:112.0/255.0 green:112.0/255.0 blue:112.0/255.0 alpha:1.0]


@interface DtMenuShoppingTopTableViewCell ()
{
    NSString *currentQuantityStr;
    CustomPopoverTouchView *customTouchView;
    DtMenuCookbookStyleView *stylePickerView;
    DtMenuShoppingCarDataClass *shoppingCarData;
}

- (IBAction)quantityReduceBtnClicked:(id)sender;
- (IBAction)quantityAddBtnClicked:(id)sender;
- (IBAction)deleteBtnClicked:(id)sender;

@end

@implementation DtMenuShoppingTopTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.styleBgImageView.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDtMenuShoppingCarCell:(DtMenuShoppingCarDataClass *)dataClass
{
    self.shoppingCarData = dataClass;
    //菜品数量
    self.quantityTextField.text = [NSString stringWithFormat:@"%d", dataClass.quantity];
    
    // 创建关闭按钮
    [self.quantityTextField bindCloseButton];
    
    self.foldOrspreadStatus = dataClass.foldOrspreadStatus;
    self.spreadOrfoldButton.hidden = YES;
    self.priceArr = dataClass.priceArray;
    shoppingCarData = dataClass;
    //self.styleLabel.text = dataClass.currentStyle;
    self.styleLabel.text = [NSString stringWithFormat:@"%@",dataClass.currentStyle];
    if (self.priceArr.count <= 1)
    {
        self.stylePullDownLogoImageView.hidden = YES;
        self.styleButton.userInteractionEnabled = NO;
    }

    self.backgroundColor = [UIColor clearColor];
    CGRect frame = self.contentView.frame;
    frame.origin.x -= 30;
    self.contentView.frame = frame;
    
    if (!kSystemVersionIsIOS7) {
        //取消ios6 group样式边框
        UIView *tempView = [[UIView alloc] init] ;
        [self setBackgroundView:tempView];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    [self addPictureToView];
    [self addLocalizedString];
    
    [self enableElements:dataClass.modifyable];
    
    if (!dataClass.packfee.floatValue)//没打包费
    {
        self.packFeeTitleLabel.hidden = YES;
        self.packFeeLabel.hidden = YES;
    }
    [self updatePrice];
    

    [self whetherQiantityBtnEnable];
    
    /*菜名 + 样式*/
    if (dataClass.isMultiStyle)
    {
        self.dishNameLabel.text = [NSString stringWithFormat:@"%@(%@)",dataClass.name, dataClass.currentStyle];
    }
    else
    {
        self.dishNameLabel.text = [NSString stringWithFormat:@"%@",dataClass.name];
    }
    
    CGSize titleSize = [self.dishNameLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:self.dishNameLabel.font.pointSize]];
    CGRect dishNameFrame = self.dishNameLabel.frame;
    dishNameFrame.size.width = titleSize.width;
    self.dishNameLabel.frame = dishNameFrame;
    self.dishNameScrollView.contentSize = CGSizeMake(titleSize.width, self.dishNameScrollView.frame.size.height);
    
    /*套餐*/
    [self addMemberItemToCell:dataClass];
}

- (void)updatePrice
{
    /*价格*/
    DtMenuShoppingCarDataClass *dataClass =  self.shoppingCarData;
    if ([dataClass.originPrice isEqualToString:dataClass.currentPrice])//没优惠
    {
        float totalPrice = dataClass.originPrice.floatValue ;//+ [self getSubPriceByCheck];
        self.priceLabel.text = [NSString stringWithFormat:@"%@ %@",[[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString oneDecimalOfPrice:totalPrice]];
        self.promotePriceTitleLabel.hidden = YES;
        self.promotePrice.hidden = YES;
        if (dataClass.packfee.floatValue)//有打包费
        {
            self.packFeeLabel.hidden = NO;
            self.packFeeTitleLabel.hidden = NO;
            self.packFeeTitleLabel.center = self.promotePriceTitleLabel.center;
            self.packFeeLabel.center = self.promotePrice.center;
            self.packFeeLabel.text = [NSString stringWithFormat:@"%@ %@",[[OfflineManager sharedOfflineManager] getCurrencySymbol],[NSString oneDecimalOfPrice:dataClass.packfee.floatValue]];
        }
    }
    else//有优惠
    {
        self.promotePriceTitleLabel.hidden = NO;
        self.promotePrice.hidden = NO;
        NSString *originPriceTitle = NSLocalizedString(@"原价:", nil);
        float totalOriginPrice = dataClass.originPrice.floatValue;//+ [self getSubPriceByCheck];
        float totalCurrentPrice = dataClass.currentPrice.floatValue;// + [self getSubPriceByCheck];
        self.priceLabel.text = [NSString stringWithFormat:@"%@ %@ %@",originPriceTitle, [[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString oneDecimalOfPrice:totalOriginPrice]];
        self.promotePrice.text = [NSString stringWithFormat:@"%@ %@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString oneDecimalOfPrice:totalCurrentPrice]];
        if (dataClass.packfee.floatValue)//有打包费
        {
            self.packFeeLabel.hidden = NO;
            self.packFeeTitleLabel.hidden = NO;
            self.packFeeLabel.frame = CGRectMake(78, 133, 101, 30);
            self.packFeeTitleLabel.frame = CGRectMake(14, 132, 66, 30);
            self.packFeeLabel.text = [NSString stringWithFormat:@"%@ %@",
                                      [[OfflineManager sharedOfflineManager] getCurrencySymbol],
                                      [NSString oneDecimalOfPrice:dataClass.packfee.floatValue]];
        }
    }
}



- (void)enableElements:(int)flag
{
    if (flag == 1) {
        self.quantityImageView.hidden = NO;
        self.quantityAddButton.hidden = NO;
        self.quantityReduceButton.hidden = NO;
        
        self.togetherLabel.hidden = YES;
        self.partLabel.hidden  = YES;
        
        self.quantityTextField.enabled = YES;
        self.quantityTextField.userInteractionEnabled = YES;
        
        self.deleteButton.hidden = NO;
    } else {
        self.quantityImageView.hidden = YES;
        self.quantityAddButton.hidden = YES;
        self.quantityReduceButton.hidden = YES;
        
        self.togetherLabel.hidden = NO;
        self.partLabel.hidden  = NO;
        
        self.quantityTextField.enabled = NO;
        self.quantityTextField.userInteractionEnabled = NO;
        
        self.deleteButton.hidden = YES;
    }
}

- (void)addPictureToView
{
    self.lineImageView.image = [UIImage imageNamed:kDtMenuCookbookPackageItemLineBgImageName];
    
    self.quantityImageView.image = [UIImage imageNamed:kDtMenuCookbookQuantityBgImageName];
    
    [self.quantityReduceButton setBackgroundImage:[UIImage imageNamed:kDtMenuCookbookQuantityRudeceNormalBgImageName]
                                         forState:UIControlStateNormal];
    [self.quantityAddButton setBackgroundImage:[UIImage imageNamed:kDtMenuCookbookQuantityAddNormalBgImageName]
                                      forState:UIControlStateNormal];
    [self.quantityReduceButton setBackgroundImage:[UIImage imageNamed:kDtMenuCookbookQuantityRudeceSelectedBgImageName]
                                         forState:UIControlStateHighlighted];
    [self.quantityAddButton setBackgroundImage:[UIImage imageNamed:kDtMenuCookbookQuantityAddSelectedBgImageName]
                                      forState:UIControlStateHighlighted];
}

- (void)addLocalizedString
{
    self.togetherLabel.text = kLoc(@"total");
    self.partLabel.text = kLoc(@"part");
    //[self.deleteButton setTitle:kLoc(@"删除", nil) forState:UIControlStateNormal];
}

- (void)addMemberItemToCell:(DtMenuShoppingCarDataClass *)dataClass
{
    NSMutableArray *tempArray = dataClass.packageArray;
    int tempCount = [tempArray count];
    
    // 套餐需要展开折叠按钮显示
    if (tempCount > 0) {
        self.spreadOrfoldButton.hidden = NO;
    } else {
        self.spreadOrfoldButton.hidden = YES;
    }
    
    if (self.foldOrspreadStatus == 0) {
        [self.spreadOrfoldButton setTitle:kLoc(@"unfold") forState:UIControlStateNormal];
    } else if (self.foldOrspreadStatus == 1) {
        [self.spreadOrfoldButton setTitle:kLoc(@"fold") forState:UIControlStateNormal];
    }
    
    if (self.foldOrspreadStatus == 0) {
        return;
    }
    
    //*******************
    //套餐,则添加子项选择View
    TakeoutShoppingCarSelectedView *selectPackageView = [[TakeoutShoppingCarSelectedView alloc]initWithData:dataClass];
    float height = [selectPackageView calculateSelfHeight];
    CGRect rect = CGRectMake(0, 136, 450, height);
    selectPackageView.frame = rect;
    selectPackageView.delegatqe = self;
    [self.contentView addSubview:selectPackageView];
    //*******************
}

- (BOOL)whetherShowItemName:(DtMenuCookbookPackageDataClass *)dataClass
{
    BOOL flag = NO;
    int tempMemberCount = [dataClass.memberArray count];
    for (int j = 0; j < tempMemberCount; j++) {
        DtMenuCookbookPackageMemberDataClass *tempMemberClass = nil;
        tempMemberClass = [self getPackageDetailDataClass:j withPackageDataClass:dataClass];
        if (tempMemberClass.checked) {
            flag = YES;
            break;
        }
    }
    return flag;
}

#pragma mark -- button click
//jhh_7.8
- (IBAction)styleBtnClicked:(id)sender
{
    MainViewController *mainVC = [MainViewController getMianViewShareInstance];
    if (!customTouchView) {
        customTouchView = [[CustomPopoverTouchView alloc] initWithFrame:mainVC.view.frame];
    }
    customTouchView.delegate = self;
    [mainVC.view addSubview:customTouchView];
    
    if (!stylePickerView)
    {
        stylePickerView = [[DtMenuCookbookStyleView alloc] initWithFrame:CGRectZero];
    }
    
    stylePickerView.delegate = self;
    UIButton *btn = (UIButton *)sender;
    CGPoint pickerPoint = CGPointMake(btn.frame.origin.x, btn.frame.origin.y + 38);
    CGPoint originPoint = [self convertPoint:pickerPoint toView:mainVC.view];
        
    [stylePickerView showInView:mainVC.view withOriginPoint:originPoint withAnimated:YES];
    stylePickerView.width = self.styleBgImageView.frame.size.width;
    [stylePickerView setTableViewWidth:self.styleBgImageView.frame.size.width];
    [stylePickerView updateDtMenuCookbookStyleView:self.priceArr];
}

- (IBAction)quantityReduceBtnClicked:(id)sender
{
    [self updateDishNumStr:NO];
}

- (IBAction)quantityAddBtnClicked:(id)sender
{
    [self updateDishNumStr:YES];
}

- (IBAction)deleteBtnClicked:(id)sender
{
    //通知左边选菜view,这道菜被减了多少份
    int changeNum = 0 - [self.quantityTextField.text intValue];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[NSNumber numberWithInt:changeNum] forKey:@"changeNum"];
    [dic setObject:self.dishNameLabel.text forKey:@"dishName"];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDishNumChangedFromRightTable object:dic userInfo:nil];
    
    [self executeDelegateMethodWhenDishQuantityChange:0];
}

- (IBAction)spreadOrfoldButtonClick:(UIButton *)sender
{
    if (self.foldOrspreadStatus == 1) {
        self.foldOrspreadStatus = 0;
//        [self.spreadOrfoldButton setTitle:kLoc(@"折叠", nil) forState:UIControlStateNormal];
    } else if(self.foldOrspreadStatus == 0) {
        self.foldOrspreadStatus = 1;
//        [self.spreadOrfoldButton setTitle:kLoc(@"展开", nil) forState:UIControlStateNormal];
    }
    
    if ([self.delegate respondsToSelector:@selector(dtMenuShoppingTopTableViewCellreloadCell:)]) {
        [self.delegate dtMenuShoppingTopTableViewCellreloadCell:self];
    }
}

/*更新数量*/
- (void)updateDishNumStr:(BOOL)isAddNum
{
    int changeNum = 0;
    int dishNum = [self.quantityTextField.text integerValue];
    if (isAddNum) {
        changeNum = 1;
        ++dishNum;
    } else {
        if ((dishNum > self.remarkTotalQuantity) && (0 < dishNum))
        {
            changeNum = -1;
            --dishNum;
            
        }
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[NSNumber numberWithInt:changeNum] forKey:@"changeNum"];
    [dic setObject:self.dishNameLabel.text forKey:@"dishName"];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDishNumChangedFromRightTable object:dic userInfo:nil];
    
    [self whetherQiantityBtnEnable];
    [self executeDelegateMethodWhenDishQuantityChange:dishNum];
}

- (void)executeDelegateMethodWhenDishQuantityChange:(int)dishNum
{
    if (self.quantityAddButton.enabled || self.quantityReduceButton.enabled) {
        if ([self.delegate respondsToSelector:@selector(dtMenuShoppingTopTableViewCell:withDishQuantityChange:)]) {
            [self.delegate dtMenuShoppingTopTableViewCell:self withDishQuantityChange:dishNum];
        }
    }
}

- (void)whetherQiantityBtnEnable
{
    int tempQuantity = [self.quantityTextField.text integerValue];
    if (self.remarkTotalQuantity < tempQuantity) {
        self.quantityReduceButton.enabled = YES;
    } else {
        self.quantityReduceButton.enabled = NO;
    }
    if (kSecondMaxQuantityNumber <= tempQuantity) {
        self.quantityAddButton.enabled = NO;
    } else {
        self.quantityAddButton.enabled = YES;
    }
}

/*套餐 dataClass*/

- (DtMenuCookbookPackageDataClass *)getPackageDataClass:(int)index withShoppingCarDataClass:(DtMenuShoppingCarDataClass *)dataClass
{
    DtMenuCookbookPackageDataClass *tempDataClass = nil;
    NSMutableArray *tempArray = dataClass.packageArray;
    if (index < [tempArray count]) {
        tempDataClass = [[DtMenuCookbookPackageDataClass alloc] initWithDtMenuPackageData:[tempArray objectAtIndex:index]];
    }
    return tempDataClass;
}

/*套餐栏目成员 dataClass*/

- (DtMenuCookbookPackageMemberDataClass *)getPackageDetailDataClass:(int)index withPackageDataClass:(DtMenuCookbookPackageDataClass *)packageDataClass
{
    DtMenuCookbookPackageMemberDataClass *tempDataClass = nil;
    NSMutableArray *tempArray = packageDataClass.memberArray;
    if (index < [tempArray count]) {
        tempDataClass = [[DtMenuCookbookPackageMemberDataClass alloc] initWithDtMenuPackageMemberData:[tempArray objectAtIndex:index]];
    }
    return tempDataClass;
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
        if (number < self.remarkTotalQuantity) {
            self.quantityTextField.text = currentQuantityStr;
            [PSAlertView showWithMessage:kLoc(@"dish_number_can_not_be_less_than_remark_number")];
            return;
        }
        [self executeDelegateMethodWhenDishQuantityChange:number];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.quantityTextField == textField) {
        [self performSelector:@selector(whetherQiantityBtnEnable) withObject:nil afterDelay:0.1];
        if ([NSString isValidateNumber:string]) {
            if (range.location >= kSecondMaxQuantityLength) {
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

#pragma mark - DtMenuCookbookStyleViewDelegate
//改动价格规格
- (void)DtMenuCookbookStyleHavedSelected:(DtMenuCookbookStyleView *)styleView withSelectIndex:(NSIndexPath *)indexPath
{
    [stylePickerView removeFromSuperview];
    NSArray *priceArray = shoppingCarData.priceArray;
    
    DtMenuCookbookPriceDataClass *priceClass = [[DtMenuCookbookPriceDataClass alloc] initWithDtMenuPriceData:[priceArray objectAtIndex:indexPath.row]];
    
    self.styleLabel.text = [NSString stringWithFormat:@"%@",priceClass.style];
    
    self.priceLabel.text = [NSString stringWithFormat:@"%@ %@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], priceClass.priceStr];
    
    self.promotePrice.text = [NSString stringWithFormat:@"%@ %@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], priceClass.promotePrice];
    [self customPopoverTouchView:nil touchesBegan:nil withEvent:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dtMenuShoppingTopTableViewCell:didChangePriceStyle:andIndexPath:)])
    {
        [self.delegate dtMenuShoppingTopTableViewCell:self didChangePriceStyle:priceClass andIndexPath:indexPath];
    }
    
}

#pragma mark - CustomPopoverTouchViewDelegate

- (void)customPopoverTouchView:(UIView*)view touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:customTouchView];
    CGRect touchRect = CGRectMake(kDtMenuCookbookStyleViewOrigin.x, kDtMenuCookbookStyleViewOrigin.y, stylePickerView.frame.size.width, stylePickerView.frame.size.height);
    if (!CGRectContainsPoint(touchRect, touchPoint))
    {
        [stylePickerView dismissViewWithAnimated:YES];
        [customTouchView removeFromSuperview];
    }
}

#pragma mark -private method
/**
 *  检索套餐子项,并返回子项加价
 *
 *  @return 子项价格(加**元)
 */
- (float)getSubPriceByCheck
{
    float totalSubPrice = 0.0;
    NSMutableArray *tempArray = self.shoppingCarData.packageArray;
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


#pragma mark -PackageSelectedChangeDelegate
- (void)TakeoutShoppingCarSelectedView:(TakeoutShoppingCarSelectedView *)selectView didChangedPackageArr:(NSArray *)newPackageArr withChangeMember:(NSDictionary *)memberDic
{
    [self updatePrice];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dtMenuShoppingTopTableViewCell:didChangedPackage:andChangeMember:)])
    {
        [self.delegate dtMenuShoppingTopTableViewCell:self didChangedPackage:newPackageArr andChangeMember:memberDic];
    }
}
@end
