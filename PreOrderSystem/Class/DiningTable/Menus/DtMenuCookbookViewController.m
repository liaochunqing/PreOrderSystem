//
//  DtMenuCookbookViewController.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-27.
//
//

#import "DtMenuCookbookViewController.h"
#import "DtMenuDataClass.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DiningTableImageName.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"
#import "Constants.h"
#import "CustomPopoverTouchView.h"
#import "OfflineManager.h"
#import "DtMenusCommon.h"
#import "WEPopoverController.h"
#import "MainViewController.h"
#import "UITextFieldAddition.h"

#define kHeightForRowAtIndexPath 50
#define kCancelAlertViewTag 1000


@interface DtMenuCookbookViewController ()<CustomPopoverTouchViewDelegate, UIAlertViewDelegate>
{
    JsonPicker *jsonPicker;
    NSMutableArray *dishRemarkArray;
    id remarkPopController;
    DtMenuRemarkPickerViewController *remarkPickerVC;
    DtMenuCookbookStyleView *stylePickerView;
    CustomPopoverTouchView *customTouchView;
    NSString *currentQuantityStr;
    NSInteger currentStyleIndex;
    
    /// 是否修改了数据
    BOOL isModified_;
}

@end

@implementation DtMenuCookbookViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
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
    self.cookbookRemarkTableView.backgroundColor = nil;
    [self addPictureToView];
    [self addLocalizedString];
    [self addNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateDtMenuCookbookView];
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
    self.styleBgImageView.image = [UIImage imageFromMainBundleFile:kDtMenuCookbookStyleBgImageName];
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

- (void)updateDtMenuCookbookView
{
    /*菜名*/
    CGSize titleSize = [(self.dishNameLabel.text = self.cookbookDataClass.name) sizeWithFont:[UIFont boldSystemFontOfSize:22]];
    CGRect dishNameFrame = self.dishNameLabel.frame;
    dishNameFrame.size.width = titleSize.width;
    self.dishNameLabel.frame = dishNameFrame;
    self.dishNameScrollView.contentSize = CGSizeMake(titleSize.width, self.dishNameScrollView.frame.size.height);
    /*数量*/
    self.quantityTextField.text = @"1";
    /*样式,价格*/
    NSArray *priceArray = self.cookbookDataClass.priceArray;
    int priceCount = [priceArray count];
    if (kZeroNumber < priceCount)
    {
        DtMenuCookbookPriceDataClass *priceClass = [[DtMenuCookbookPriceDataClass alloc] initWithDtMenuPriceData:[priceArray firstObject]];
        currentStyleIndex = 0;
        self.styleLabel.text = [NSString cutString:priceClass.style withMaxLengthOfStr:kDtMenuCookbookMaxStyleLen];
        [self updatePriceByDishStyle];
        if ((1 != priceCount))
        {
            self.stylePullDownLogoImageView.image = [UIImage imageFromMainBundleFile:kDtMenuCookbookPullDownLogoImageName];
            self.styleButton.hidden = NO;
        }
        else
        {
            self.stylePullDownLogoImageView.image = nil;
            self.styleButton.hidden = YES;
        }
    }
    /*备注*/
    [dishRemarkArray removeAllObjects];
    if (self.cuisineRemarkArray.count)
    {
        self.remarkButton.hidden = NO;
        [DtMenuCookbookRemarkDataClass addNewRemarkData:dishRemarkArray];
    }
    else
    {
        self.remarkButton.hidden = YES;
    }
    [self.cookbookRemarkTableView reloadData];
    [self whetherRemarkBtnEnable];
    //规格view隐藏
    [stylePickerView dismissViewWithAnimated:NO];
}

/*根据样式获取价格*/
- (NSString *)getPriceStrForCurrentStyle
{
    NSString *priceStr = @"";
    NSArray *priceArray = self.cookbookDataClass.priceArray;
    int priceCount = [priceArray count];
    if (currentStyleIndex < priceCount)
    {
        DtMenuCookbookPriceDataClass *priceClass = [[DtMenuCookbookPriceDataClass alloc] initWithDtMenuPriceData:[priceArray objectAtIndex:currentStyleIndex]];
        priceStr = priceClass.priceStr;
    }
    return priceStr;
}

/*根据样式获取优惠价格*/
- (NSString *)getPromotePriceStrForCurrentStyle
{
    NSString *priceStr = @"";
    NSArray *priceArray = self.cookbookDataClass.priceArray;
    int priceCount = [priceArray count];
    if (currentStyleIndex < priceCount)
    {
        DtMenuCookbookPriceDataClass *priceClass = [[DtMenuCookbookPriceDataClass alloc] initWithDtMenuPriceData:[priceArray objectAtIndex:currentStyleIndex]];
        priceStr = priceClass.promotePrice;
    }
    return priceStr;
}

/*更新单价和优惠价*/
- (void)updatePriceByDishStyle
{
    self.priceLabel.text = [NSString stringWithFormat:@"%@ %@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], [self getPriceStrForCurrentStyle]];
    NSString *promotePrice = [self getPromotePriceStrForCurrentStyle];
    if (promotePrice.length)
    {
        self.promotePrice.hidden = NO;
        NSString *promotePriceTitle = NSLocalizedString(@"优惠价:", nil);
        self.promotePrice.text = [NSString stringWithFormat:@"%@ %@ %@",promotePriceTitle, [[OfflineManager sharedOfflineManager] getCurrencySymbol], promotePrice];
    }
    else
    {
        self.promotePrice.hidden = YES;
    }
    
    [self updateDishTotoalPrice];
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

/*更新总价*/
- (void)updateDishTotoalPrice
{
    NSString *finalPrice = @"";
    finalPrice = [self getPromotePriceStrForCurrentStyle];
    if (!finalPrice.length)
    {
        finalPrice = [self getPriceStrForCurrentStyle];
    }
    float totoalPrice = [finalPrice floatValue] * [self.quantityTextField.text integerValue];
    NSString *tempStr = [NSString stringWithFormat:@"%.2f",totoalPrice];
    self.totalPriceLabel.text = [NSString stringWithFormat:@"%@ %@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString oneDecimalOfPrice:[tempStr floatValue]]];
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
    [self.cookbookRemarkTableView reloadData];
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
        [self.cookbookRemarkTableView reloadData];
    }
    [self whetherRemarkBtnEnable];
}

- (void)tryDismissView
{
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

#pragma mark - UIButton clicked

- (IBAction)styleBtnClicked:(id)sender
{
    MainViewController *mainVC = [MainViewController getMianViewShareInstance];
    if (!customTouchView)
    {
        customTouchView = [[CustomPopoverTouchView alloc] initWithFrame:mainVC.view.frame];
    }
    customTouchView.delegate = self;
    [mainVC.view addSubview:customTouchView];
    
    
    if (!stylePickerView)
    {
        stylePickerView = [[DtMenuCookbookStyleView alloc] initWithFrame:CGRectZero];
    }
    stylePickerView.delegate = self;
    [stylePickerView showInView:mainVC.view withOriginPoint:kDtMenuCookbookStyleViewOrigin withAnimated:YES];
    stylePickerView.width = self.styleBgImageView.frame.size.width;
    [stylePickerView setTableViewWidth:self.styleBgImageView.frame.size.width];
    [stylePickerView updateDtMenuCookbookStyleView:self.cookbookDataClass.priceArray];
}

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
    if ([self.delegate respondsToSelector:@selector(DtMenuCookbookViewHavedDismiss)]) {
        [self.delegate DtMenuCookbookViewHavedDismiss];
    }
}

- (IBAction)trueBtnClicked:(id)sender
{
    if (kZeroNumber > [self.quantityTextField.text integerValue]) {
        [PSAlertView showWithMessage:kLoc(@"please_add_menu")];
        return;
    }
    [self submitDishDataToShoppingCar:YES];
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
    self.cookbookRemarkTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset - self.cookbookRemarkTableView.frame.origin.y,0.0f);
    self.cookbookRemarkTableView.scrollEnabled = NO;
    
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
    
    self.cookbookRemarkTableView.scrollEnabled = YES;
    self.cookbookRemarkTableView.contentInset = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}

#pragma mark - network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

- (void)submitDishDataToShoppingCar:(BOOL)animated
{
    NSString *styleStr = @"";
    NSArray *priceArray = self.cookbookDataClass.priceArray;
    NSInteger priceCount = [priceArray count];
    if (currentStyleIndex < priceCount)
    {
        DtMenuCookbookPriceDataClass *priceClass = [[DtMenuCookbookPriceDataClass alloc] initWithDtMenuPriceData:[priceArray objectAtIndex:currentStyleIndex]];
        styleStr = priceClass.style;
    }
    
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    NSMutableDictionary *dishDict = [NSMutableDictionary dictionary];
    [dishDict setObject:self.dishNameLabel.text forKey:@"name"];
    [dishDict setObject:self.cookbookDataClass.cookID forKey:@"cbID"];
    [dishDict setObject:self.quantityTextField.text forKey:@"quantity"];
    [dishDict setObject:dishRemarkArray forKey:@"currentRemark"];
    [dishDict setObject:self.cuisineRemarkArray forKey:@"remark"];
    [dishDict setObject:styleStr forKey:@"currentStyle"];
    
    //********上传哪个price未定***************
    NSString *finalPrice = [self getPromotePriceStrForCurrentStyle];
    if (!finalPrice.length)
    {
        finalPrice = [self getPriceStrForCurrentStyle];
    }
   // finalPrice = [self getPriceStrForCurrentStyle];
    //********上传哪个price未定***************
    
   // finalPrice = [self getPriceStrForCurrentStyle];
    [dishDict setObject:finalPrice forKey:@"currentPrice"];
    [dishDict setObject:[self getPriceStrForCurrentStyle] forKey:@"originalPrice"];
    [dishDict setObject:self.cookbookDataClass.priceArray forKey:@"price"];

    [dishDict setObject:[NSArray array] forKey:@"package"];
    [postData setObject:[NSNumber numberWithInt:self.housingId] forKey:@"tableId"];
    [postData setObject:dishDict forKey:@"dishes"];
    
    
    if (!jsonPicker) {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = YES;
    if (!animated) {
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
    static NSString *cellIdentifier = @"DtMenuRemarkTableViewCell";
	DtMenuCookbookRemarkTableViewCell *cell = (DtMenuCookbookRemarkTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"DtMenuCookbookRemarkTableViewCell"
                                              owner:self
                                            options:nil] lastObject];
	}
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    int indexRow = indexPath.row;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeightForRowAtIndexPath;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dishRemarkArray count];
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
        
        [self updateDishTotoalPrice];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.quantityTextField == textField) {
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
                // 取消编辑
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

#pragma mark - DtMenuCookbookRemarkTableViewCellDelegate

- (void)dtMenuCookbookRemarkTableViewCell:(DtMenuCookbookRemarkTableViewCell*)cell withRemarkQuantityChange:(int)quantity
{
    int index = cell.tag;
    if (index < [dishRemarkArray count]) {
        
        isModified_ = YES;
        
        if (quantity > 0) {
            [DtMenuCookbookRemarkDataClass modifyRemarkData:dishRemarkArray
                                                  withIndex:index
                                               withQuantity:quantity];
        } else {
            [dishRemarkArray removeObjectAtIndex:cell.tag];
        }
        [self whetherRemarkBtnEnable];
        [self.cookbookRemarkTableView reloadData];
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
    [self.cookbookRemarkTableView reloadData];
}

#pragma mark - DtMenuCookbookStyleViewDelegate

- (void)DtMenuCookbookStyleHavedSelected:(DtMenuCookbookStyleView *)styleView withSelectStyle:(NSString *)styleStr
{
    isModified_ = YES;
    
    self.styleLabel.text = styleStr;
    currentStyleIndex = styleView.styleIndex;
    [self updatePriceByDishStyle];
    [self customPopoverTouchView:nil touchesBegan:nil withEvent:nil];
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
                
                // 返回
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
