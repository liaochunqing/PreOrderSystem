//
//  PrintManagementTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-1-6.
//
//

#import "PrintManagementTableViewCell.h"
#import "Constants.h"
#import "PrinterDataClass.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"
#import "SocketPrinterFunctions.h"
#import "PrinterFunctions.h"

#define kTypeFirstBtnTag 1000
#define kTypeSecondBtnTag 2000


@interface PrintManagementTableViewCell ()
{
    int printerType;
    SocketPrinterFunctions *printerClass;
}

- (IBAction)queueBtnClick:(UIButton *)sender;
- (IBAction)typeBtnClicked:(UIButton *)sender;
-(IBAction)deleteBtnClicked:(UIButton*)sender;
- (IBAction)testBtnClicked:(UIButton *)sender;
- (IBAction)orderDishesBtnClick:(UIButton *)sender;
- (IBAction)kitchenBtnClick:(UIButton *)sender;
- (IBAction)takeoutBtnClick:(UIButton *)sender;

@end

@implementation PrintManagementTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.printerNameTextField.delegate = self;;
        self.IPTextField.delegate = self;
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
    NSLog(@"===%s,%@===", __FUNCTION__, self.class);
#endif
}

- (void)updatePrinterCell:(NSDictionary *)dataDict
{
    [self addLocalizedString];
    [self addPictureToView];
    PrinterDataClass *tempClass = [[PrinterDataClass alloc] initWithPrinterData:dataDict];
    self.printerNameTextField.text = tempClass.printerName;
    self.IPTextField.text = tempClass.printerIPStr;
    printerType = tempClass.printerType;
    self.orderDishesBtn.selected = [[dataDict objectForKey:kisOrderdishBtnCheck] boolValue];
    self.kitchenBtn.selected = [[dataDict objectForKey:kisKitchenBtnCheck] boolValue];
    self.takeoutBtn.selected = [[dataDict objectForKey:kisTakeoutBtnCheck] boolValue];
    self.queueBtn.selected = [[dataDict objectForKey:kisQueueBtnCheck] boolValue];
    
    NSString *string = [dataDict objectForKey:kPrinterStar];
    if (string && [string compare:@"starPrinter"] == NSOrderedSame)
    {
        self.isStarPrinter = YES;
        [self.IPTextField setEnabled:NO];
        self.IPTextFieldBg.hidden = YES;
    }
    else
    {
        self.isStarPrinter = NO;
        [self.IPTextField setEnabled:YES];
        self.IPTextFieldBg.hidden = NO;
    }

    [self updatePrinterTypeImage:printerType];
}

- (void)addLocalizedString
{
    self.IPLabel.text = [NSString stringWithFormat:@"%@ :",kLoc(@"printer_ip")];
    self.typeLabel.text = [NSString stringWithFormat:@"%@ :",kLoc(@"printer_type")];
    self.printerNameLabel.text = [NSString stringWithFormat:@"%@ :",kLoc(@"printer_name")];
    
    [self.testButton setTitle:kLoc(@"test") forState:UIControlStateNormal];
    
    self.checkLabel.text = [NSString stringWithFormat:@"%@:",kLoc(@"applicable")];
    self.orderDisherLabel.text = kLoc(@"confirm_dish");
    self.kitchLabel.text = kLoc(@"kitchen");
    self.takeoutLabel.text = kLoc(@"takeout_order");
    self.queueLabel.text = kLoc(@"queue");
}

- (void)addPictureToView
{
    self.bottomLineImageView.image = [UIImage imageNamed:@"more_printerItemLineBg.png"];
    self.topLineImageView.image = (0 == self.tag)?self.bottomLineImageView.image:nil;
    [self.testButton setBackgroundImage:[UIImage imageNamed:@"more_testBtn.png"] forState:UIControlStateNormal];
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"more_printerDelete.png"] forState:UIControlStateNormal];
    self.nameTextFieldBg.image = self.IPTextFieldBg.image = [UIImage imageNamed:@"more_textFieldBg.png"];
    
    //点菜
    [self.orderDishesBtn setBackgroundImage:[UIImage imageNamed:@"more_item_unchecked.png"] forState:UIControlStateNormal];
    [self.orderDishesBtn setImage:[UIImage imageNamed:@"more_item_checked.png"] forState:UIControlStateSelected];
    [self.orderDishesBtn setBackgroundImage:[UIImage imageNamed:@"more_item_unchecked.png"] forState:UIControlStateSelected];
    
    //厨房
    [self.kitchenBtn setBackgroundImage:[UIImage imageNamed:@"more_item_unchecked.png"] forState:UIControlStateNormal];
    [self.kitchenBtn setImage:[UIImage imageNamed:@"more_item_checked.png"] forState:UIControlStateSelected];
    [self.kitchenBtn setBackgroundImage:[UIImage imageNamed:@"more_item_unchecked.png"] forState:UIControlStateSelected];
    
    //外卖订单
    [self.takeoutBtn setBackgroundImage:[UIImage imageNamed:@"more_item_unchecked.png"] forState:UIControlStateNormal];
    [self.takeoutBtn setImage:[UIImage imageNamed:@"more_item_checked.png"] forState:UIControlStateSelected];
    [self.takeoutBtn setBackgroundImage:[UIImage imageNamed:@"more_item_unchecked.png"] forState:UIControlStateSelected];
    
    //排队
    [self.queueBtn setBackgroundImage:[UIImage imageNamed:@"more_item_unchecked.png"] forState:UIControlStateNormal];
    [self.queueBtn setImage:[UIImage imageNamed:@"more_item_checked.png"] forState:UIControlStateSelected];
    [self.queueBtn setBackgroundImage:[UIImage imageNamed:@"more_item_unchecked.png"] forState:UIControlStateSelected];
}

- (void)updatePrinterTypeImage:(int)type
{
    NSString *type1ImageName = nil;
    NSString *type2ImageName = nil;
    switch (type)
    {
        case kTypeFirstBtnTag:
        {
            type1ImageName = @"order_by_phone_area_selected.png";
            type2ImageName = @"order_by_phone_area_unselected.png";
            
            break;
        }
        case kTypeSecondBtnTag:
        {
            type1ImageName = @"order_by_phone_area_unselected.png";
            type2ImageName = @"order_by_phone_area_selected.png";
            
            break;
        }
        default:
        {
            type1ImageName = @"order_by_phone_area_unselected.png";
            type2ImageName = @"order_by_phone_area_unselected.png";
            
            break;
        }
    }
    [self.typeFirstButton setImage:[UIImage imageNamed:type1ImageName] forState:UIControlStateNormal];
    [self.typeSecondButton setImage:[UIImage imageNamed:type2ImageName] forState:UIControlStateNormal];
}

- (void)hidePrintManagementCellKeyBoard
{
    [self.printerNameTextField resignFirstResponder];
    [self.IPTextField resignFirstResponder];
}

#pragma mark - Button Clicked

- (IBAction)typeBtnClicked:(UIButton *)sender
{
    [self hidePrintManagementCellKeyBoard];
    int type = sender.tag;
    printerType = type;
    [self updatePrinterTypeImage:type];
    if ([self.delegate respondsToSelector:@selector(printManagementTableViewCell:withPrinterType:)])
    {
        [self.delegate printManagementTableViewCell:self withPrinterType:type];
    }
}

-(IBAction)deleteBtnClicked:(UIButton*)sender
{
    [self hidePrintManagementCellKeyBoard];
    if ([self.delegate respondsToSelector:@selector(printManagementTableViewCell:withDeleteIndex:)])
    {
        [self.delegate printManagementTableViewCell:self withDeleteIndex:self.tag];
    }
}

- (IBAction)testBtnClicked:(UIButton *)sender
{
    [self hidePrintManagementCellKeyBoard];
    NSString *nameStr = [NSString getStrWithoutWhitespace:self.printerNameTextField.text];
    if ([NSString strIsEmpty:nameStr])
    {
        [PSAlertView showWithMessage:kLoc(@"printer_name_can_not_be_empty")];
        return;
    }
    NSString *ipStr = [NSString getStrWithoutWhitespace:self.IPTextField.text];
    if ([NSString strIsEmpty:ipStr])
    {
        [PSAlertView showWithMessage:kLoc(@"printer_ip_can_not_be_empty")];
        return;
    }
    
    //打印
    printerClass = [[SocketPrinterFunctions alloc] initSocketPrinter:nameStr withPrinterIP:ipStr withPrinterType:printerType withPrinterBrand:self.isStarPrinter withErrorFlag:YES];
    [printerClass printTestReceipt];

}

- (IBAction)orderDishesBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if ([self.delegate respondsToSelector:@selector(printManagementTableViewCell:)])
    {
        [self.delegate printManagementTableViewCell:self];
    }
}

- (IBAction)kitchenBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(printManagementTableViewCell:)])
    {
        [self.delegate printManagementTableViewCell:self];
    }
}

- (IBAction)takeoutBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(printManagementTableViewCell:)])
    {
        [self.delegate printManagementTableViewCell:self];
    }
}

- (IBAction)queueBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(printManagementTableViewCell:)])
    {
        [self.delegate printManagementTableViewCell:self];
    }
}

#pragma mark UITextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.printerNameTextField == textField)
    {
        NSString *nameStr = [NSString getStrWithoutWhitespace:self.printerNameTextField.text];
        if ([self.delegate respondsToSelector:@selector(printManagementTableViewCell:withPrinterName:)])
        {
            [self.delegate printManagementTableViewCell:self withPrinterName:nameStr];
        }
    }
    else if (self.IPTextField == textField)
    {
        NSString *hostStr = [NSString getStrWithoutWhitespace:self.IPTextField.text];
        if ([self.delegate respondsToSelector:@selector(printManagementTableViewCell:withPrinterIP:)])
        {
            [self.delegate printManagementTableViewCell:self withPrinterIP:hostStr];
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
