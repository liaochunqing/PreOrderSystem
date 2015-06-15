//
//  DtMenuShoppingTopTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-1-3.
//
//

#import "DtMenuShoppingTopTableViewtemCell.h"
#import "DiningTableImageName.h"
#import "DtMenuDataClass.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"
#import "OfflineManager.h"
#import "DtMenusCommon.h"
#import "Constants.h"

#define kTextDarkGradColor [UIColor colorWithRed:112.0/255.0 green:112.0/255.0 blue:112.0/255.0 alpha:1.0]


@interface DtMenuShoppingTopTableViewtemCell () {
    NSString *currentQuantityStr;
}

- (IBAction)quantityReduceBtnClicked:(id)sender;
- (IBAction)quantityAddBtnClicked:(id)sender;
- (IBAction)deleteBtnClicked:(id)sender;

@end

@implementation DtMenuShoppingTopTableViewtemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
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
    self.foldOrspreadStatus = dataClass.foldOrspreadStatus;
    self.spreadOrfoldButton.hidden = YES;
    
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
    

    //NSString *currentPromotePriceStr = dataClass.currentPromotePrice;
    NSString *origionPriceTitle = @"";
    if (![dataClass.currentPrice isEqualToString:dataClass.originPrice])//有优惠,
    {
        origionPriceTitle = NSLocalizedString(@"原价: ", nil);
        self.promotePrice.hidden = NO;
        NSString *promotePriceTitle = NSLocalizedString(@"优惠价:", nil);
        self.promotePrice.text = [NSString stringWithFormat:@"%@ %@ %@",promotePriceTitle,[[OfflineManager sharedOfflineManager] getCurrencySymbol],[NSString trimmingZeroInPrice:[NSString stringWithFormat:@"%.2f",dataClass.currentPrice.floatValue]]];
    }
    else
    {
        self.promotePrice.hidden = YES;
    }
    //价格
    self.priceLabel.text = [NSString stringWithFormat:@"%@%@ %@",origionPriceTitle, [[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString trimmingZeroInPrice:dataClass.originPrice]];
    
    
    self.quantityTextField.text = [NSString stringWithFormat:@"%d", dataClass.quantity];
    [self whetherQiantityBtnEnable];
    
    /*菜名 + 样式*/
    if (dataClass.isMultiStyle) {
        self.dishNameLabel.text = [NSString stringWithFormat:@"%@(%@)",dataClass.name, dataClass.currentStyle];
    } else {
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
    self.togetherLabel.text = NSLocalizedString(@"共", nil);
    self.partLabel.text = NSLocalizedString(@"份", nil);
    [self.deleteButton setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
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
        [self.spreadOrfoldButton setTitle:NSLocalizedString(@"展开", nil) forState:UIControlStateNormal];
    } else if (self.foldOrspreadStatus == 1) {
        [self.spreadOrfoldButton setTitle:NSLocalizedString(@"折叠", nil) forState:UIControlStateNormal];
    }
    
    
    if (self.foldOrspreadStatus == 0) {
        return;
    }
    
    CGFloat originX = 35, originY = kDtMenuShoppingTopTableViewCellNormalHeight, itemNameHeight = 30, fontSize = 18.0;
    BOOL isVoidPackage = YES;
    for (int i = 0; i < tempCount; i++)
    {
        DtMenuCookbookPackageDataClass *tempPackageDataClass = nil;
        tempPackageDataClass = [self getPackageDataClass:i withShoppingCarDataClass:dataClass];
        if ([self whetherShowItemName:tempPackageDataClass])
        {
            /*栏目名称*/
            isVoidPackage = NO;
            NSString *itemName = [NSString getStrWithoutWhitespace:tempPackageDataClass.itemName];
            if (0 != [itemName length])
            {
                UILabel *itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, self.frame.size.width - originX, itemNameHeight)];
                itemNameLabel.numberOfLines = 0;
                itemNameLabel.backgroundColor = [UIColor clearColor];
                itemNameLabel.textColor = kTextDarkGradColor;
                itemNameLabel.font = [UIFont systemFontOfSize:fontSize];
                itemNameLabel.textAlignment = UITextAlignmentLeft;
                itemNameLabel.text = [NSString stringWithFormat:@"%@:", itemName];
                [self addSubview:itemNameLabel];
                
                originY = originY + itemNameHeight;
            }
            else
            {
                if (0 != i)
                {
                    originY = originY +  itemNameHeight/2;
                }
            }
            /*栏目子项内容*/
            int selectedIndex = 1;
            int tempMemberCount = [tempPackageDataClass.memberArray count];
            for (int j = 0; j < tempMemberCount; j++)
            {
                DtMenuCookbookPackageMemberDataClass *tempMemberClass = [self getPackageDetailDataClass:j withPackageDataClass:tempPackageDataClass];
                if (tempMemberClass.checked)
                {
                    UILabel *memberNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX + 15, originY, self.frame.size.width - originX, itemNameHeight)];
                    memberNameLabel.numberOfLines = 0;
                    memberNameLabel.backgroundColor = [UIColor clearColor];
                    memberNameLabel.textColor = kTextDarkGradColor;
                    memberNameLabel.font = [UIFont systemFontOfSize:fontSize];
                    memberNameLabel.textAlignment = UITextAlignmentLeft;
                    memberNameLabel.text = [NSString stringWithFormat:@"%i.%@",selectedIndex, tempMemberClass.name];
                    [self addSubview:memberNameLabel];
                    
                    selectedIndex ++;
                    originY = originY + itemNameHeight;
                }
            }
        }
    }
    if (isVoidPackage)
    {
        UILabel *itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY - 35, self.frame.size.width - originX, itemNameHeight)];
        itemNameLabel.numberOfLines = 0;
        itemNameLabel.backgroundColor = [UIColor clearColor];
        itemNameLabel.textColor = kTextDarkGradColor;
        itemNameLabel.font = [UIFont systemFontOfSize:fontSize];
        itemNameLabel.textAlignment = UITextAlignmentLeft;
        itemNameLabel.text = NSLocalizedString(@"客户未选择任何子项", nil);
        [self addSubview:itemNameLabel];

    }
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
    [self executeDelegateMethodWhenDishQuantityChange:0];
}

- (IBAction)spreadOrfoldButtonClick:(UIButton *)sender
{
    if (self.foldOrspreadStatus == 1) {
        self.foldOrspreadStatus = 0;
//        [self.spreadOrfoldButton setTitle:NSLocalizedString(@"折叠", nil) forState:UIControlStateNormal];
    } else if(self.foldOrspreadStatus == 0) {
        self.foldOrspreadStatus = 1;
//        [self.spreadOrfoldButton setTitle:NSLocalizedString(@"展开", nil) forState:UIControlStateNormal];
    }
    
    if ([self.delegate respondsToSelector:@selector(dtMenuShoppingTopTableViewCellreloadCell:)]) {
        [self.delegate dtMenuShoppingTopTableViewCellreloadCell:self];
    }
}

/*更新数量*/
- (void)updateDishNumStr:(BOOL)isAddNum
{
    int dishNum = [self.quantityTextField.text integerValue];
    if (isAddNum) {
        ++dishNum;
    } else {
        if ((dishNum > self.remarkTotalQuantity) && (0 < dishNum)) {
            --dishNum;
        }
    }
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
            [PSAlertView showWithMessage:NSLocalizedString(@"菜的数量不能小于备注的数量", nil)];
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

@end
