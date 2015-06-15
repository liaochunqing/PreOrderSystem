//
//  DtMenuListTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-28.
//
//

#import "DtMenuCookbookRemarkTableViewCell.h"
#import "DtMenuDataClass.h"
#import "DiningTableImageName.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"
#import "DtMenusCommon.h"
#import "Constants.h"
#import "UITextFieldAddition.h"

#define kRemarkLabelFrameWidth 190
#define kRemarkBgLabelFrameWidth 210


@interface DtMenuCookbookRemarkTableViewCell ()
{
    NSString *currentQuantityStr;
}

-(IBAction)remarkBtnClicked:(UIButton*)sender;
-(IBAction)reduceBtnClicked:(UIButton*)sender;
-(IBAction)addBtnClicked:(UIButton*)sender;
-(IBAction)deleteBtnClicked:(UIButton*)sender;

@end

@implementation DtMenuCookbookRemarkTableViewCell

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

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (void)updateDtMenuCookbookRemarkCell:(DtMenuCookbookRemarkDataClass *)dataClass withModifyFlag:(BOOL)flag
{
    self.backgroundColor = [UIColor clearColor];
    
    // 创建关闭按钮
    [self.quantityTextField bindCloseButton];
    
    if (!kSystemVersionIsIOS7) {
        //取消ios6 group样式边框
        UIView *tempView = [[UIView alloc] init] ;
        [self setBackgroundView:tempView];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    [self addPictureToView];
    [self addLocalizedString];
    NSString *remarkStr = [self getDishRemarkStr:dataClass.contentArray];
    if ([NSString strIsEmpty:remarkStr])
    {
        self.remarkLabel.hidden = YES;
        self.remarkBgLabel.hidden = YES;
        self.remarkScrollView.hidden = YES;
    }
    else
    {
        self.remarkBgLabel.hidden = NO;
        self.remarkLabel.hidden = NO;
        self.remarkScrollView.hidden = NO;
        self.remarkLabel.text = remarkStr;
        
        UIFont *titleFont = [UIFont systemFontOfSize:16.0];
        CGSize titleSize = [remarkStr sizeWithFont:titleFont];
        CGFloat titleWidth = titleSize.width;
        
        CGRect remarkFrame = self.remarkLabel.frame;
        remarkFrame.size.width = titleWidth + 15;
        self.remarkLabel.frame = remarkFrame;
        self.remarkScrollView.contentSize = CGSizeMake(remarkFrame.size.width, remarkFrame.size.height);
        
        CGRect remarkBgFrame = self.remarkBgLabel.frame;
        remarkBgFrame.size.width = remarkFrame.size.width + 20;
        if (remarkBgFrame.size.width > kRemarkBgLabelFrameWidth)
        {
            remarkBgFrame.size.width = kRemarkBgLabelFrameWidth;
        }
        self.remarkBgLabel.frame = remarkBgFrame;
    }
    self.quantityTextField.text = [NSString stringWithFormat:@"%d", dataClass.quantity];
    [self whetherAddBtnEnable];
    self.lineImageView.hidden = YES;//flag;
    self.remarkBgImageView.hidden = self.remarkButton.hidden = self.reduceButton.hidden = self.addButton.hidden = self.deleteButton.hidden = !flag;
}

- (NSString *)getDishRemarkStr:(NSArray *)array
{
    NSMutableString *tempStr = [NSMutableString string];
    int tempCount = [array count];
    for (int i = 0; i < tempCount; i++)
    {
        [tempStr appendString:[array objectAtIndex:i]];
        if ((tempCount - 1) != i)
        {
            [tempStr appendString:@"/"];
        }
    }
    return tempStr;
}

- (void)addPictureToView
{
    self.remarkBgImageView.image = [UIImage imageFromMainBundleFile:kDtMenuCookbookRemarkCellBgImageName];
    self.lineImageView.image = [UIImage imageFromMainBundleFile:kDtMenuCookbookPackageItemLineBgImageName];
    [self.reduceButton setBackgroundImage:[UIImage imageFromMainBundleFile:kDtMenuCookbookQuantityRudeceNormalBgImageName] forState:UIControlStateNormal];
    [self.addButton setBackgroundImage:[UIImage imageFromMainBundleFile:kDtMenuCookbookQuantityAddNormalBgImageName] forState:UIControlStateNormal];
    [self.reduceButton setBackgroundImage:[UIImage imageFromMainBundleFile:kDtMenuCookbookQuantityRudeceSelectedBgImageName] forState:UIControlStateHighlighted];
    [self.addButton setBackgroundImage:[UIImage imageFromMainBundleFile:kDtMenuCookbookQuantityAddSelectedBgImageName] forState:UIControlStateHighlighted];
}

- (void)addLocalizedString
{
    [self.deleteButton setTitle:kLoc(@"delete") forState:UIControlStateNormal];
}

- (void)remarkQuantityChange:(int)quantity
{
    if ([self.delegate respondsToSelector:@selector(dtMenuCookbookRemarkTableViewCell:withRemarkQuantityChange:)])
    {
        [self.delegate dtMenuCookbookRemarkTableViewCell:self withRemarkQuantityChange:quantity];
    }
}

- (void)whetherAddBtnEnable
{
    if (self.remarkQuantity < self.dishQuantity)
    {
        self.addButton.enabled = YES;
        if ((self.isShopCar?kSecondMaxQuantityNumber:kFirstMaxQuantityNumber) <= self.remarkQuantity)
        {
            self.addButton.enabled = NO;
        }
        else
        {
            self.addButton.enabled = YES;
        }
    }
    else
    {
        self.addButton.enabled = NO;
    }
}

- (void)updateDishNumStr:(BOOL)isAddNum
{
    int remarkNum = [self.quantityTextField.text integerValue];
    if (isAddNum)
    {
        if (self.remarkQuantity < self.dishQuantity)
        {
            remarkNum = remarkNum + 1;
        }
    }
    else
    {
        if (0 < remarkNum)
        {
            remarkNum = remarkNum - 1;
        }
    }
    [self whetherAddBtnEnable];
    [self remarkQuantityChange:remarkNum];
}

-(IBAction)remarkBtnClicked:(UIButton *)sender
{
    [self.quantityTextField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(showDtMenuCookbookRemarkOptionPicker:)])
    {
        [self.delegate showDtMenuCookbookRemarkOptionPicker:self];
    }
}

-(IBAction)reduceBtnClicked:(UIButton *)sender
{
    [self.quantityTextField resignFirstResponder];
    [self updateDishNumStr:NO];
}

-(IBAction)addBtnClicked:(UIButton *)sender
{
    [self.quantityTextField resignFirstResponder];
    [self updateDishNumStr:YES];
}

-(IBAction)deleteBtnClicked:(UIButton *)sender
{
    [self.quantityTextField resignFirstResponder];
    [self remarkQuantityChange:0];
}

#pragma mark UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.quantityTextField == textField)
    {
        currentQuantityStr = self.quantityTextField.text;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
{
    if (self.quantityTextField == textField)
    {
        int inputNum = [self.quantityTextField.text integerValue];
        int number = self.remarkQuantity - [currentQuantityStr integerValue] + inputNum;
        if (number > self.dishQuantity)
        {
            self.quantityTextField.text = currentQuantityStr;
            [PSAlertView showWithMessage:kLoc(@"dish_number_can_not_be_less_than_remark_number")];
        }
        else
        {
            [self remarkQuantityChange:inputNum];
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.quantityTextField == textField)
    {
        [self performSelector:@selector(whetherAddBtnEnable) withObject:nil afterDelay:0.1];
        if ([NSString isValidateNumber:string])
        {
            if (range.location >= (self.isShopCar?kSecondMaxQuantityLength:kFirstMaxQuantityLength))
            {
                return NO;
            }
            return YES;
        }
        else
        {
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

