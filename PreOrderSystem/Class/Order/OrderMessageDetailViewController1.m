//
//  PreorderMessageDetailViewController.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OrderMessageDetailViewController.h"
#import "NsstringAddOn.h"
#import "DisplayHelper.h"
#import "DateAndTimePicker.h"
#import "NumPicker.h"
#import "DeskPicker.h"
#import "DeskPickerWithSummary.h"
#import "UILabel+AdjustFontSize.h"
#import "Constants.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "UIViewController+MJPopupViewController.h"
#import "NsstringAddOn.h"
#import "SocketPrinterFunctions.h"
#import "MainViewController.h"
#import "OfflineManager.h"

#define kTableViewWidth self.detailTableview.frame.size.width
#define kAddressTextViewTag 1000
#define kTextDarkGradColor [UIColor colorWithRed:112.0/255.0 green:112.0/255.0 blue:112.0/255.0 alpha:1.0]
#define kDishDetailTitleViewTag 2000

@interface OrderMessageDetailViewController ()
{
    NSMutableArray *socketObjectArray;
}

- (IBAction)leftSideButtonPressed:(UIButton *)sender;
- (IBAction)editButtonPressed:(UIButton *)sender;
- (IBAction)saveEditButtonPressed:(UIButton *)sender;
- (IBAction)cancelEditButtonPressed:(UIButton *)sender;
- (IBAction)cancelOrderButtonPressed:(UIButton*)sender;
- (IBAction)checkInButtonPressed:(UIButton*)sender;
- (IBAction)confirmOrderButtonPressed:(UIButton*)sender;
- (IBAction)deliveryDinnerButtonPressed:(UIButton*)sender;
- (IBAction)reasonButtonPressed:(UIButton*)sender;
- (IBAction)printBtnClicked:(id)sender;
//修改订单为“己查看”
- (void)orderIsChecked:(BOOL)animated;
- (UIView *)dishesDetailView;

@end

@implementation OrderMessageDetailViewController
@synthesize delegate;
@synthesize leftSideButton;
@synthesize editButton;
@synthesize editCancelButton;
@synthesize editSaveButton;
@synthesize detailTableview;
@synthesize tag;
@synthesize popoverController;
@synthesize stateLabel;
@synthesize nameLabel;
@synthesize phoneLabel;
@synthesize orderTypeInfoLabel;
@synthesize handleBtnBG,handleBtnBG2,bgImageView,tableHeadBgImageView,gradualImageView;
@synthesize cancelButton,trueButton,signButton,deliveryButton,checkInButton,cancelButton2,reasonButton;

#pragma mark LIFE CYCLE
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addNotifications];
    [self addPictureToView];
    
    
    /* 模拟看内存警告时是否有问题
     [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(didReceiveMemoryWarning) userInfo:nil repeats:YES];
     */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.popoverController = nil;
    
    orderDetailInfo = nil;
    msgDetailInfo = nil;
    jsonPicker = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ((kSystemVersionOfCurrentDevice >= 6.0) && [self isViewLoaded] && ![self.view window])
    {
        [self viewDidUnload];
        [self setView:nil];
    }
}

- (void)dealloc
{
    [self removeNotifications];
#ifdef DEBUG
    NSLog(@"===OrderMessageDetailViewController,dealloc===");
#endif
}

#pragma mark PUBLIC METHODS

-(void)showInView:(UIView*)aView
{
    self.isShowingView = YES;
    self.view.alpha = 0.0f;
    
    CGRect frame = self.view.frame;
    frame.origin.x = 700;
    frame.origin.y = kSystemVersionIsIOS7 ? 65:50;
    self.view.frame = frame;
    [self.view removeFromSuperview];
    
    [aView addSubview:self.view];
    
    [UIView beginAnimations:@"animationID" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationRepeatAutoreverses:NO];
    
    self.view.alpha = 1.0f;
    frame.origin.x = 370;
    self.view.frame = frame;
    
	[UIView commitAnimations];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	[self.view removeFromSuperview];
}

-(void)dismissView
{
    self.isShowingView = NO;
    
    self.view.alpha = 1.0f;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    CGRect aFrame = self.view.frame;
    aFrame.origin.x = 800;
    self.view.frame = aFrame;
    
    self.view.alpha = 0.0f;
    [UIView commitAnimations];
}

#pragma mark PRIVATE METHODS

//刷新订单数据
-(void)updateInfo:(NSDictionary*)info
{
    msgDetailInfo = [[NSDictionary alloc] initWithDictionary:info];
    orderDetailInfo = [[NSMutableDictionary alloc] initWithDictionary:info];
    isEditing = NO;
    isEdited = NO;
    isOpenDetailDish = NO;
//    paymentWay = [msgDetailInfo objectForKey:@"paymentWay"];
    orderType = [[msgDetailInfo objectForKey:@"orderType"] intValue];
    orderStatus =[[msgDetailInfo objectForKey:@"status"] intValue];
    deliveryType = [[msgDetailInfo objectForKey:@"takeoutDeliveryType"] intValue];
    self.orderId = [[msgDetailInfo objectForKey:@"orderId"] intValue];
    [detailTableview setContentOffset:CGPointMake(0, 0) animated:NO];
    [self orderIsChecked:NO];
    [self addLocalizedString];
    [self updateViewAfterData];
    [detailTableview reloadData];
}

- (void)addLocalizedString
{
    self.stateTitleLabel.text = [NSString stringWithFormat:@"%@ ：",NSLocalizedString(@"状态", nil)];
    self.nameTitleLabel.text = [NSString stringWithFormat:@"%@ ：",NSLocalizedString(@"称呼", nil)];
    self.phoneTitleLabel.text = [NSString stringWithFormat:@"%@ ：",NSLocalizedString(@"手机", nil)];
    [self.cancelButton setTitle:NSLocalizedString(@"取消订单", nil) forState:UIControlStateNormal];
    [self.cancelButton2 setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [self.trueButton setTitle:NSLocalizedString(@"确认订单", nil) forState:UIControlStateNormal];
    [self.signButton setTitle:NSLocalizedString(@"客人签到", nil) forState:UIControlStateNormal];
    [self.deliveryButton setTitle:((1 == deliveryType)?NSLocalizedString(@"已取餐", nil):NSLocalizedString(@"送餐", nil)) forState:UIControlStateNormal];
    [self.checkInButton setTitle:NSLocalizedString(@"签收", nil) forState:UIControlStateNormal];
    if (1 == orderType)
    {
        self.orderTypeInfoLabel.text = NSLocalizedString(@"订座信息", nil);
    }
    else
    {
        self.orderTypeInfoLabel.text = NSLocalizedString(@"外卖信息", nil);
    }
}

- (void)addPictureToView
{
    bgImageView.image = [UIImage imageFromMainBundleFile:@"order_detailBg.png"];
    tableHeadBgImageView.image = [UIImage imageFromMainBundleFile:@"order_leftDismissBg.png"];
    gradualImageView.image = [UIImage imageFromMainBundleFile:@"order_gradual.png"];
    handleBtnBG.image = [UIImage imageFromMainBundleFile:@"order_detailHandleBtn.png"];
    handleBtnBG2.image = [UIImage imageFromMainBundleFile:@"order_takeawayHandleBg.png"];
    //繁体
    if (![kCurrentLanguageOfDevice isEqualToString:kChineseFamiliarStyle])
    {
        [self.printButton setImage:[UIImage imageFromMainBundleFile:@"order_print_traditional.png"] forState:UIControlStateNormal];
    }
}

- (void)updateViewAfterData
{
    nameLabel.adjustsFontSizeToFitWidth = YES;
    stateLabel.adjustsFontSizeToFitWidth = YES;
    phoneLabel.adjustsFontSizeToFitWidth = YES;
    
    //名称
    NSString *nameStr = [msgDetailInfo objectForKey:@"guestName"];
    if ([NSString strIsEmpty:nameStr])
    {
        nameLabel.text = @"";
    }
    else
    {
        nameLabel.text = [NSString firstNameWithTitle:[msgDetailInfo objectForKey:@"guestName"] withSex:[[msgDetailInfo objectForKey:@"guestSex"]integerValue]];
    }
    
    stateLabel.text = [msgDetailInfo objectForKey:@"statusString"];
    phoneLabel.text = [msgDetailInfo objectForKey:@"guestPhone"];
    reasonButton.hidden = [[msgDetailInfo objectForKey:@"message"]length]?NO:YES;
    editButton.hidden = YES;
    editCancelButton.hidden = YES;
    editSaveButton.hidden = YES;
    self.printButton.hidden = YES;
    
    switch (orderType)
    {
        case 1:
        {
            if (0 == orderStatus)
            {
                handleBtnBG.hidden = NO;
                cancelButton.hidden = NO;
                trueButton.hidden = NO;
                signButton.hidden = YES;
            }
            else if (1 == orderStatus)
            {
                editButton.hidden = NO;
                trueButton.hidden = YES;
                handleBtnBG.hidden = NO;
                cancelButton.hidden = NO;
                signButton.hidden = NO;
            }
            else
            {
                handleBtnBG.hidden = YES;
                cancelButton.hidden = YES;
                trueButton.hidden = YES;
                signButton.hidden = YES;
            }
            
            break;
        }
        case 2:
        {
            self.printButton.hidden = NO;
            handleBtnBG.hidden = NO;
            handleBtnBG2.hidden = YES;
            checkInButton.hidden = YES;
            if (0 == orderStatus)
            {
                cancelButton.hidden = NO;
                trueButton.hidden = NO;
                deliveryButton.hidden = YES;
                cancelButton2.hidden = YES;
            }
            else if (1 == orderStatus)
            {
                cancelButton.hidden = YES;
                trueButton.hidden = YES;
                deliveryButton.hidden = NO;
                cancelButton2.hidden = NO;
                deliveryButton.enabled = YES;
                cancelButton2.enabled = YES;
                [deliveryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [cancelButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else
            {
                handleBtnBG.hidden = YES;
                cancelButton.hidden = YES;
                trueButton.hidden = YES;
                deliveryButton.hidden = YES;
                cancelButton2.hidden = YES;
            }
            
            //0没有修改，1表示已经修改
            int carryfeeStatus =[[msgDetailInfo objectForKey:@"isCarryfeeChanged"] intValue];
            //配送费按钮
            if (1 == carryfeeStatus)
            {
                trueButton.enabled = NO;
                [trueButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
            else
            {
                trueButton.enabled = YES;
                [trueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            
            break;
        }
    }
}

- (IBAction)leftSideButtonPressed:(UIButton *)sender
{
    if ([delegate respondsToSelector:@selector(OrderMessageDetailViewController:didDismissView:)])
    {
        [delegate OrderMessageDetailViewController:self didDismissView:sender];
    }
}

//“签收”按钮点击
- (IBAction)checkInButtonPressed:(UIButton*)sender
{
    NSString *titleStr = @"";
    if (1 == orderType)
    {
        titleStr = NSLocalizedString(@"您确认签到吗？", nil);
    }
    else
    {
        titleStr = NSLocalizedString(@"您确认签收吗？", nil);
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleStr message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    alert.tag = 4;
    [alert show];
}

//取消订单
- (IBAction)cancelOrderButtonPressed:(UIButton*)sender
{
    ReasonViewController *reasonCtrl = [[ReasonViewController alloc] init];
    reasonCtrl.delegate = self;
    reasonCtrl.reasonOptionsArray = self.reasonOptionsArray;
    [[MainViewController getMianViewShareInstance] presentPopupViewController:reasonCtrl animationType:MJPopupViewAnimationSlideBottomBottom];
}

//"确认订单"按钮点击
- (IBAction)confirmOrderButtonPressed:(UIButton*)sender
{
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(confirmOrder) userInfo:nil repeats:NO];
}

//"出餐"按钮点击
- (void)finishedDinnerButtonPressed:(UIButton*)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"您确认出餐吗？", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    alert.tag = 2;
    [alert show];
}

//"送餐"按钮点击
- (IBAction)deliveryDinnerButtonPressed:(UIButton*)sender
{
    NSString *titleStr = (1 == deliveryType)?NSLocalizedString(@"您确认已取餐？", nil):NSLocalizedString(@"您确认送餐吗？", nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleStr message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    alert.tag = 3;
    [alert show];
}

//“修改订单”按钮点击
- (IBAction)editButtonPressed:(UIButton*)sender
{
    isEditing = YES;
    isEdited = NO;
    
    editCancelButton.hidden = NO;
    editSaveButton.hidden = NO;
    editButton.hidden = YES;
    [detailTableview reloadData];
}


//“取消修改”按钮点击
- (IBAction)cancelEditButtonPressed:(UIButton*)sender
{
    orderDetailInfo = [[NSMutableDictionary alloc] initWithDictionary:msgDetailInfo];
    isEditing = NO;
    editCancelButton.hidden = YES;
    editSaveButton.hidden = YES;
    editButton.hidden = NO;
    [detailTableview reloadData];
}

//“保存修改”按钮点击
- (IBAction)saveEditButtonPressed:(UIButton*)sender
{
    editCancelButton.hidden = YES;
    editSaveButton.hidden = YES;
    editButton.hidden = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(saveEdit) userInfo:nil repeats:NO];
    if (isEdited)
    {
        
    }
    else
    {
        isEditing = NO;
    }
}

- (IBAction)reasonButtonPressed:(UIButton*)sender
{
    NSString *tempStr = NSLocalizedString(@"取消原因", nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@：%@",tempStr,[msgDetailInfo objectForKey:@"message"]] message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
    [alert show];
}

//打印
- (IBAction)printBtnClicked:(id)sender
{
    if (!socketObjectArray)
    {
        socketObjectArray = [[NSMutableArray alloc] init];
    }
    [socketObjectArray removeAllObjects];
    [SocketPrinterFunctions getSocketPrinterObject:socketObjectArray mode:kPrinterModeTakeout];
    int printerCount = [socketObjectArray count];
    for (int i = 0; i < printerCount; i++)
    {
        [[socketObjectArray objectAtIndex:i] printDishReceipt:orderDetailInfo];
    }
}

- (void)dishDetailBtnPressed:(UIButton*)sender
{
    isOpenDetailDish = !isOpenDetailDish;
    switch (orderType)
    {
        case 1:
        {
            [detailTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
        }
        case 2:
        {
            [detailTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
        }
    }
}

- (void)handleOrderDetailBtnPressed:(UIButton *)sender
{
    int index = sender.tag;
    isEditing = YES;
    isEdited = NO;
    
    //设置订单的“时间”
    if (index == 1)
    {
        DateAndTimePicker *picker = [[DateAndTimePicker alloc] init];
        picker.delegate = self;
        picker.tag = tag;
        NSString *date = [orderDetailInfo objectForKey:@"mealTimes"];
        picker.date = [date stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
        
        if (nil == popoverController)
        {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        }
        popoverController.contentViewController = picker;
        popoverController.popoverContentSize = CGSizeMake(346, 280);
        UITableViewCell *cell = [detailTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [popoverController presentPopoverFromRect:sender.frame inView:cell.contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
    
    //设置订座的“人数”
    if (index == 2)
    {
        NumPicker *picker = [[NumPicker alloc] init];
        picker.tag = index;
        picker.delegate = self;
        picker.pickerType = NumPickerTypeNormal;
        picker.minimumNum = 1;
        picker.maximumNum = 500;
        picker.numberText = [orderDetailInfo objectForKey:@"peopleNum"];
        
        if (nil == popoverController)
        {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        }
        popoverController.contentViewController = picker;
        popoverController.popoverContentSize = picker.pickerSize;
        
        UITableViewCell *cell = [detailTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        
        [popoverController presentPopoverFromRect:sender.frame inView:cell.contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
    //设置订座的“选台”
    if (index == 3)
    {
        NSMutableArray *diningTable = [[NSMutableArray alloc] init];
        for (NSDictionary *seat in [orderDetailInfo objectForKey:@"seatsList"])
        {
            [diningTable addObject:[seat objectForKey:@"seatsId"]];
        }
        DeskPickerWithSummary *picker = [[DeskPickerWithSummary alloc] initWithSelectedList:diningTable];
        picker.delegate = self;
        picker.deskPickerType = DeskPickerWithSummaryMultiple;
        
        if (nil == popoverController)
        {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        }
        popoverController.contentViewController = picker;
        popoverController.popoverContentSize = picker.pickerSize;
        UITableViewCell *cell = [detailTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [popoverController presentPopoverFromRect:sender.frame inView:cell.contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

//菜的详细视图
- (UIView *)dishesDetailView
{
    UIView *dishesDetailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 42)];
    dishesDetailView.backgroundColor = [UIColor clearColor];
    
    NSArray *dishes = [msgDetailInfo objectForKey:@"dishesList"];
    if ([dishes count]>0)
    {
        int originY = 0;
        for (int i=0; i<[dishes count]; i++)
        {
            NSDictionary *dish = [dishes objectAtIndex:i];
            
            //数量
            int qty = [[dish objectForKey:@"quantity"] intValue];
            UILabel *dishesQtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(175, originY + 22, 60, 20)];
            dishesQtyLabel.backgroundColor = [UIColor clearColor];
            dishesQtyLabel.textColor = kTextDarkGradColor;
            dishesQtyLabel.font = [UIFont systemFontOfSize:20];
            dishesQtyLabel.adjustsFontSizeToFitWidth = YES;
            dishesQtyLabel.textAlignment = UITextAlignmentRight;
            dishesQtyLabel.text = [NSString stringWithFormat:@"X%i", qty];
            [dishesDetailView addSubview:dishesQtyLabel];
            
            //金额
            UILabel *dishesSumLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, originY + 22, 150, 20)];
            dishesSumLabel.backgroundColor = [UIColor clearColor];
            dishesSumLabel.textColor = kTextDarkGradColor;
            dishesSumLabel.font = [UIFont systemFontOfSize:20];
            dishesSumLabel.adjustsFontSizeToFitWidth = YES;
            dishesSumLabel.textAlignment = UITextAlignmentRight;
            
            CGFloat price = [[dish objectForKey:@"currentPrice"] floatValue];
            //去掉.00,.50中的0
            NSString *tempString = [NSString stringWithFormat:@"%.2f", price * qty];
            dishesSumLabel.text = [NSString stringWithFormat:@"%@%@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString trimmingZeroInPrice:tempString]];
            [dishesDetailView addSubview:dishesSumLabel];
            
            if (orderType == 2)
            {
                dishesQtyLabel.frame = CGRectMake(200, originY + 10, 85, 20);
                dishesSumLabel.frame = CGRectMake(290, originY + 10, 125, 20);
            }

            //菜名
            UILabel *dishesNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY + 20, 150, 20)];
            dishesNameLabel.backgroundColor = [UIColor clearColor];
            dishesNameLabel.textColor = kTextDarkGradColor;
            dishesNameLabel.font = [UIFont systemFontOfSize:20];
            dishesNameLabel.textAlignment = UITextAlignmentLeft;
            dishesNameLabel.numberOfLines = 0;
            NSString *dishesName = [dish objectForKey:@"dishesName"];
            NSString *currentStyle = [[dish objectForKey:@"currentStyle"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //是否为多样式
            BOOL isMultiStyle = [[dish objectForKey:@"isMultiStyle"] intValue];
            if ([currentStyle length]>0 && isMultiStyle == YES)//只有是多样式条件为真时才显示
            {
                dishesNameLabel.text = [NSString stringWithFormat:@"%@(%@)", dishesName, currentStyle];
            }
            else
            {
                dishesNameLabel.text = dishesName;
            }
            if (2 == orderType)
            {
                dishesNameLabel.frame = CGRectMake(0, originY + 8, 195, 20);
            }
            //自动换行
            originY = originY + [dishesNameLabel adjustLabelHeight] + 20;
            [dishesDetailView addSubview:dishesNameLabel];
            
            //若该菜品为套餐，则显示其详细内容
            int isPackage = [[dish objectForKey:@"isPackage"] intValue];
            NSArray *packageItem = [dish objectForKey:@"packageData"];
            if (isPackage==1 && 0 != [packageItem count])
            {
                originY = originY - 10;
                for (int i=0; i<[packageItem count]; i++)
                {
                    NSDictionary *package = [packageItem objectAtIndex:i];
                    
                    //套餐的某个子项
                    NSString *subTitle = [[package objectForKey:@"title"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if (0 != [subTitle length])
                    {
                        UILabel *subOpTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, originY, 330, 15)];
                        subOpTitleLabel.numberOfLines = 0;
                        subOpTitleLabel.backgroundColor = [UIColor clearColor];
                        subOpTitleLabel.textColor = kTextDarkGradColor;
                        subOpTitleLabel.font = [UIFont systemFontOfSize:18];
                        subOpTitleLabel.textAlignment = UITextAlignmentLeft;
                        subOpTitleLabel.text = [NSString stringWithFormat:@"%@:", subTitle];
                        originY = originY + [subOpTitleLabel adjustLabelHeight] +  5;
                        [dishesDetailView addSubview:subOpTitleLabel];
                    }
                    else
                    {
                        if (0 != i)
                        {
                            originY = originY +  15;
                        }
                    }
                    
                    //某个子项的详细内容
                    int selectedIndex = 0;
                    NSArray *subList = [package objectForKey:@"list"];
                    for (int j=0; j<[subList count]; j++)
                    {
                        NSDictionary *sub = [subList objectAtIndex:j];
                        if ([[sub objectForKey:@"isSelected"]integerValue] == 1)
                        {
                            selectedIndex ++;
                            
                            UILabel *subOpLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, originY, 330, 15)];
                            subOpLabel.numberOfLines = 0;
                            subOpLabel.backgroundColor = [UIColor clearColor];
                            subOpLabel.textColor = kTextDarkGradColor;
                            subOpLabel.font = [UIFont systemFontOfSize:18];
                            subOpLabel.textAlignment = UITextAlignmentLeft;
                            subOpLabel.text = [NSString stringWithFormat:@"%i.%@",selectedIndex, [sub objectForKey:@"name"]];
                            
                            originY = originY + [subOpLabel adjustLabelHeight]+5;
                            [dishesDetailView addSubview:subOpLabel];
                        }
                    }
                }
            }
            
            NSString *remark = [dish objectForKey:@"remark"];
            if ([remark length]>0)
            {
                //备注(标题)
                UILabel *remarkLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(40, originY, 60, 30)];
                remarkLabel1.backgroundColor = [UIColor clearColor];
                remarkLabel1.textColor = kTextDarkGradColor;
                remarkLabel1.font = [UIFont systemFontOfSize:18];
                remarkLabel1.textAlignment = UITextAlignmentLeft;
                remarkLabel1.text = NSLocalizedString(@"备注 :", nil);
                [dishesDetailView addSubview:remarkLabel1];
                
                //备注(内容)
                UILabel *remarkLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(90, originY + 5, 325, 30)];
                remarkLabel2.numberOfLines = 0;
                remarkLabel2.backgroundColor = [UIColor clearColor];
                remarkLabel2.textColor = kTextDarkGradColor;
                remarkLabel2.font = [UIFont systemFontOfSize:18];
                remarkLabel2.textAlignment = UITextAlignmentLeft;
                remarkLabel2.text = [dish objectForKey:@"remark"];
                
                originY = originY + [remarkLabel2 adjustLabelHeight]+10;
                
                [dishesDetailView addSubview:remarkLabel2];
            }
            else
            {
                int isPackage = [[dish objectForKey:@"isPackage"] intValue];
                if (isPackage == 1)
                {
                    originY = originY+5;
                }
            }
        }
        
        //调整heigth
        if (orderType == 1)
        {
            dishesDetailView.frame = CGRectMake(32, 42, 395, originY + 20);
        }
        if (orderType == 2)
        {
            int originX = 0,priceOriginX = 245;
            int spaceY = 40;
            int discountSpaceY = 0;
            int carryfeeSpaceY = 0;
            int favorableSpaceY = 0;
            int totalQty = 0;//总份数
            CGFloat totalSum = 0;//总金额
            CGFloat discount = [[msgDetailInfo objectForKey:@"takeoutDiscount"]floatValue];//打折
            NSArray *dishes = [msgDetailInfo objectForKey:@"dishesList"];
            int dishNum = [dishes count];
            for (int i=0; i < dishNum; i++)
            {
                NSDictionary *dish = [dishes objectAtIndex:i];
                //数量
                int qty = [[dish objectForKey:@"quantity"] intValue];
                totalQty += qty;
                //价格
                CGFloat price = [[dish objectForKey:@"currentPrice"] floatValue];
                totalSum += price*qty;
            }
            
            if (0 != dishNum)
            {
                //总共份数
                UILabel *totalQtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY + 8, 100, 20)];
                totalQtyLabel.backgroundColor = [UIColor clearColor];
                totalQtyLabel.textColor = [UIColor brownColor];
                totalQtyLabel.font = [UIFont systemFontOfSize:20];
                totalQtyLabel.textAlignment = UITextAlignmentLeft;
                totalQtyLabel.adjustsFontSizeToFitWidth = YES;
                NSString *tempStr1 = NSLocalizedString(@"共", nil);
                NSString *tempStr2 = NSLocalizedString(@"份", nil);
                totalQtyLabel.text = [NSString stringWithFormat:@"%@%i%@",tempStr1,totalQty,tempStr2];
                [dishesDetailView addSubview:totalQtyLabel];
                
                //总金额
                UILabel *totalSumLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceOriginX, originY + 8, 170, 20)];
                totalSumLabel.backgroundColor = [UIColor clearColor];
                totalSumLabel.textColor = [UIColor brownColor];
                totalSumLabel.font = [UIFont systemFontOfSize:20];
                totalSumLabel.textAlignment = UITextAlignmentRight;
                totalSumLabel.adjustsFontSizeToFitWidth = YES;
                NSString *tempString = [NSString stringWithFormat:@"%.2f", totalSum];
                NSString *tempStr3 = NSLocalizedString(@"预估总价", nil);
                totalSumLabel.text = [NSString stringWithFormat:@"%@%@%@", tempStr3, [[OfflineManager sharedOfflineManager] getCurrencySymbol],[NSString trimmingZeroInPrice:tempString]];
                [dishesDetailView addSubview:totalSumLabel];

                
                if (0 < discount)
                {
                    discountSpaceY = 40;
                    //打折
                    UILabel *discountLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY + 8 + spaceY, 100, 20)];
                    discountLabel.backgroundColor = [UIColor clearColor];
                    discountLabel.textColor = [UIColor brownColor];
                    discountLabel.font = [UIFont systemFontOfSize:20];
                    discountLabel.textAlignment = UITextAlignmentLeft;
                    discountLabel.adjustsFontSizeToFitWidth = YES;
                    NSString *tempString2 = [NSString stringWithFormat:@"%.2f", discount * 10];
                    NSString *tempStr1 = NSLocalizedString(@"全单", nil);
                    NSString *tempStr2 = NSLocalizedString(@"折", nil);
                    discountLabel.text = [NSString stringWithFormat:@"%@%@%@",tempStr1,[NSString trimmingZeroInPrice:tempString2],tempStr2];
                    [dishesDetailView addSubview:discountLabel];
                    
                    //打折后的总金额
                    UILabel *discountSumLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceOriginX, originY + 8 + spaceY, 170, 20)];
                    discountSumLabel.backgroundColor = [UIColor clearColor];
                    discountSumLabel.textColor = [UIColor brownColor];
                    discountSumLabel.font = [UIFont systemFontOfSize:20];
                    discountSumLabel.textAlignment = UITextAlignmentRight;
                    discountSumLabel.adjustsFontSizeToFitWidth = YES;
                    NSString *tempString3 = [NSString stringWithFormat:@"%.2f", totalSum * discount];
                    NSString *tempStr3 = NSLocalizedString(@"折后总价", nil);
                    discountSumLabel.text = [NSString stringWithFormat:@"%@%@%@",tempStr3 , [[OfflineManager sharedOfflineManager] getCurrencySymbol],[NSString trimmingZeroInPrice:tempString3]];
                    [dishesDetailView addSubview:discountSumLabel];
                }
            }
            //配送费
            double carryfee = [[msgDetailInfo objectForKey:@"carryfee"] doubleValue];
            if (carryfee > 0)
            {
                carryfeeSpaceY = 40;
                
                UILabel *carryfeeLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY + 8 + spaceY + discountSpaceY, 100, 20)];
                carryfeeLabel.backgroundColor = [UIColor clearColor];
                carryfeeLabel.textColor = [UIColor brownColor];
                carryfeeLabel.font = [UIFont systemFontOfSize:20];
                carryfeeLabel.adjustsFontSizeToFitWidth = YES;
                carryfeeLabel.textAlignment = UITextAlignmentLeft;
                carryfeeLabel.text = NSLocalizedString(@"配送费", nil);
                [dishesDetailView addSubview:carryfeeLabel];
                
                UILabel *carryfeeSumLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceOriginX, originY + 8 + spaceY + discountSpaceY, 170, 20)];
                carryfeeSumLabel.backgroundColor = [UIColor clearColor];
                carryfeeSumLabel.textColor = [UIColor brownColor];
                carryfeeSumLabel.font = [UIFont systemFontOfSize:20];
                carryfeeSumLabel.adjustsFontSizeToFitWidth = YES;
                carryfeeSumLabel.textAlignment = UITextAlignmentRight;
                NSString *tempString = [NSString stringWithFormat:@"%.2f", carryfee];
                carryfeeSumLabel.text = [NSString stringWithFormat:@"%@%@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString trimmingZeroInPrice:tempString]];
                [dishesDetailView addSubview:carryfeeSumLabel];
            }
            //优惠
            double couponAmount = [[msgDetailInfo objectForKey:@"couponAmount"] doubleValue];
            if (couponAmount > 0)
            {
                favorableSpaceY = 40;
                
                UILabel *favorableLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY + 8 + spaceY + discountSpaceY + carryfeeSpaceY, 100, 20)];
                favorableLabel.backgroundColor = [UIColor clearColor];
                favorableLabel.textColor = [UIColor brownColor];
                favorableLabel.font = [UIFont systemFontOfSize:20];
                favorableLabel.adjustsFontSizeToFitWidth = YES;
                favorableLabel.textAlignment = UITextAlignmentLeft;
                favorableLabel.text = NSLocalizedString(@"优惠", nil);
                [dishesDetailView addSubview:favorableLabel];
                
                UILabel *favorableSumLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceOriginX, originY + 8 + spaceY + discountSpaceY + carryfeeSpaceY, 170, 20)];
                favorableSumLabel.backgroundColor = [UIColor clearColor];
                favorableSumLabel.textColor = [UIColor brownColor];
                favorableSumLabel.font = [UIFont systemFontOfSize:20];
                favorableSumLabel.adjustsFontSizeToFitWidth = YES;
                favorableSumLabel.textAlignment = UITextAlignmentRight;
                NSString *tempString = [NSString stringWithFormat:@"%.2f", couponAmount];
                favorableSumLabel.text = [NSString stringWithFormat:@"%@%@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString trimmingZeroInPrice:tempString]];
                [dishesDetailView addSubview:favorableSumLabel];
            }
             
            //总价 = 折后价 + 配送费 + 优惠
            UILabel *finalLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY + 8 + spaceY + discountSpaceY + carryfeeSpaceY + favorableSpaceY, 100, 20)];
            finalLabel.backgroundColor = [UIColor clearColor];
            finalLabel.textColor = [UIColor brownColor];
            finalLabel.font = [UIFont systemFontOfSize:20];
            finalLabel.adjustsFontSizeToFitWidth = YES;
            finalLabel.textAlignment = UITextAlignmentLeft;
            finalLabel.text = NSLocalizedString(@"总价", nil);
            [dishesDetailView addSubview:finalLabel];
            
            UILabel *finalSumLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceOriginX, originY + 8 + spaceY + discountSpaceY + carryfeeSpaceY + favorableSpaceY, 170, 20)];
            finalSumLabel.backgroundColor = [UIColor clearColor];
            finalSumLabel.textColor = [UIColor brownColor];
            finalSumLabel.font = [UIFont systemFontOfSize:20];
            finalSumLabel.adjustsFontSizeToFitWidth = YES;
            finalSumLabel.textAlignment = UITextAlignmentRight;
            CGFloat finalSum = 0;
            if (0 < discount)
            {
                finalSum = totalSum * discount + carryfee;
            }
            else
            {
                finalSum = totalSum + carryfee;
            }
            if (0 < couponAmount)
            {
                finalSum = finalSum - couponAmount;
                if (0 > finalSum)
                {
                    finalSum = 0;
                }
            }
            NSString *finalSumStr = [NSString stringWithFormat:@"%.2f", finalSum];
            finalSumLabel.text = [NSString stringWithFormat:@"%@%@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString oneDecimalOfPrice:[finalSumStr floatValue]]];
            [dishesDetailView addSubview:finalSumLabel];
            
            // 付款方式
            NSMutableArray *paymentWay = [msgDetailInfo objectForKey:@"paymentWay"];
            CGFloat onePaymentWayHight = 40;
            if (paymentWay && paymentWay.count > 0)
            {
                UILabel *paymentLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY + 8 + spaceY + discountSpaceY + carryfeeSpaceY + favorableSpaceY + onePaymentWayHight, 100, 20)];
                paymentLabel.backgroundColor = [UIColor clearColor];
                paymentLabel.textColor = [UIColor brownColor];
                paymentLabel.font = [UIFont systemFontOfSize:20];
                paymentLabel.adjustsFontSizeToFitWidth = YES;
                paymentLabel.textAlignment = UITextAlignmentLeft;
                paymentLabel.text = NSLocalizedString(@"付款方式", nil);
                [dishesDetailView addSubview:paymentLabel];
                
                for (int i = 0; i < paymentWay.count; i++)
                {
                    UILabel *wayLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceOriginX, originY + 8 + spaceY + discountSpaceY + carryfeeSpaceY + favorableSpaceY + onePaymentWayHight * (i+1), 170, 20)];
                    wayLabel.backgroundColor = [UIColor clearColor];
                    wayLabel.textColor = [UIColor brownColor];
                    wayLabel.font = [UIFont systemFontOfSize:20];
                    wayLabel.adjustsFontSizeToFitWidth = YES;
                    wayLabel.textAlignment = UITextAlignmentRight;
                    wayLabel.text = NSLocalizedString(paymentWay[i], nil);
                    [dishesDetailView addSubview:wayLabel];
                }
            }
            
            
            //总高度 = 起点 + 共几份 + 折后价 + 配送费 + 优惠 + 总价  + 付款方式
            originY = originY + spaceY + discountSpaceY + carryfeeSpaceY + favorableSpaceY + onePaymentWayHight * paymentWay.count + spaceY;
            
            //调整heigth
            dishesDetailView.frame = CGRectMake(10, 42, 420, originY + 5);
        }
    }
    return dishesDetailView;
}

//选台内容，箭头，透明按钮
- (UIView *)seatDetailView:(int)cellRow
{
    int originX = 135;
    int lineWidth = 270;
    UIView *seatsView = [[UIView alloc]initWithFrame:CGRectZero];
    seatsView.backgroundColor = [UIColor clearColor];
    
    UILabel *seatsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 30)];
    seatsLabel.backgroundColor = [UIColor clearColor];
    seatsLabel.textColor = kTextDarkGradColor;
    seatsLabel.textAlignment = UITextAlignmentLeft;
    seatsLabel.font = [UIFont systemFontOfSize:20];
    seatsLabel.adjustsFontSizeToFitWidth = YES;
    seatsLabel.numberOfLines = 0;
    
    NSArray *seatsArray = nil;
    if (isEditing)
    {
        seatsArray = [orderDetailInfo objectForKey:@"seatsList"];
    }
    else
    {
        seatsArray = [msgDetailInfo objectForKey:@"seatsList"];
    }
    if (0 == [seatsArray count] || [seatsArray isKindOfClass:[NSNull class]])
    {
        seatsLabel.text = @"待定";
    }
    else
    {
        int seatsCount = [seatsArray count];
        NSMutableString *deskStr = [[NSMutableString alloc] init];
        for (int i=0; i < seatsCount; i++)
        {
            NSDictionary *seatDict = [seatsArray objectAtIndex:i];
            [deskStr appendFormat:@"%@/%@", [seatDict objectForKey:@"seatsAreaName"], [seatDict objectForKey:@"seatsName"]];
            
            if (i < [seatsArray count]-1)
            {
                [deskStr appendString:@"\n"];
            }
        }
        seatsLabel.text = deskStr;
    }
    [seatsLabel adjustLabelHeight];
    [seatsView addSubview:seatsLabel];
    
    CGFloat seatsHeight = seatsLabel.frame.size.height;
    CGFloat seatsWidth = seatsLabel.frame.size.width;
    
    //加上一条线
    int space = 10;
    UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, seatsHeight + space, lineWidth, 1)];
    lineImageView.backgroundColor = [UIColor lightGrayColor];
    [seatsView addSubview:lineImageView];
    
    //加上一个箭头
    if (0 == orderStatus || isEditing)
    {
        UIImageView *arrowImageView = [[UIImageView alloc]initWithFrame:CGRectMake(seatsWidth, (seatsHeight - 19)/2, 12, 19)];
        arrowImageView.image = [UIImage imageFromMainBundleFile:@"order_detailRightArrow.png"];
        [seatsView addSubview:arrowImageView];
        
        UIButton *arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        arrowBtn.frame = CGRectMake(0, 5, lineWidth + 10, seatsHeight + space);
        arrowBtn.tag = cellRow;
        [arrowBtn addTarget:self action:@selector(handleOrderDetailBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [seatsView addSubview:arrowBtn];
    }
    
    [seatsView setFrame:CGRectMake(originX, 15, seatsLabel.frame.size.width, seatsLabel.frame.size.height)];
    
    return seatsView;
}

- (UIView *)addAddressToViewWithCustomSpace
{
    CGFloat upX = 0,upY = 0,X = 0,Y = 0,maxWidth = 280;
    UIView *addressView = [[UIView alloc]initWithFrame:CGRectZero];
    NSString *addressString = [msgDetailInfo objectForKey:@"takeoutAddress"];
    int stringlenght = [addressString length];
    for (int i = 0; i < stringlenght; i++)
    {
        NSString *temp = [addressString substringWithRange:NSMakeRange(i, 1)];
        //文字的行距
        CGFloat textSpace = 50;
        if (upX >= maxWidth)
        {
            upY = upY + textSpace;
            upX = 0;
            X = maxWidth;
            Y =upY;
        }
        CGSize size=[temp sizeWithFont:[UIFont systemFontOfSize:20] constrainedToSize:CGSizeMake(maxWidth, 30)];
        UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
        la.font = [UIFont systemFontOfSize:20];
        la.textAlignment = UITextAlignmentLeft;
        la.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
        la.backgroundColor = [UIColor clearColor];
        la.text = temp;
        [addressView addSubview:la];
        upX = upX + la.frame.size.width;
        if (X < maxWidth)
        {
            X = upX;
        }
        //加上一条线
        UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, upY + 35, 300, 1)];
        lineImageView.backgroundColor = [UIColor lightGrayColor];
        [addressView addSubview:lineImageView];
    }
    addressView.frame = CGRectMake(110,15, X, Y);
    
    return addressView;
}

#pragma mark netWork

-(void)cancelOrder:(NSTimer *)timer
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = NSLocalizedString(@"正在取消订单，请稍候...", nil);
    jsonPicker.showSuccessfulMessageInterval = 1.0f;
    jsonPicker.loadedSuccessfulMessage = NSLocalizedString(@"取消成功", nil);
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[msgDetailInfo objectForKey:@"orderId"] forKey:@"orderId"];
    [postData setObject:[msgDetailInfo objectForKey:@"orderType"] forKey:@"orderType"];
    [postData setObject:@"2" forKey:@"statusValue"];
    NSString *cancelMsg = [timer.userInfo objectForKey:@"message"];
    [postData setObject:cancelMsg forKey:@"message"];
    [postData setObject:[NSNumber numberWithInt:orderStatus] forKey:@"oldStatusValue"];
    [jsonPicker postData:postData withBaseRequest:@"OrderStatus"];
}

-(void)confirmOrder
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 1;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = NSLocalizedString(@"正在确认订单，请稍候...", nil);
    jsonPicker.showSuccessfulMessageInterval = 1.0f;
    jsonPicker.loadedSuccessfulMessage = NSLocalizedString(@"确认成功", nil);
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[orderDetailInfo objectForKey:@"orderId"] forKey:@"orderId"];
    [postData setObject:[orderDetailInfo objectForKey:@"orderType"] forKey:@"orderType"];
    [postData setObject:@"1" forKey:@"statusValue"];
    [postData setObject:[NSNumber numberWithInt:orderStatus] forKey:@"oldStatusValue"];
    if (1 == orderType)
    {
        [postData setObject:[orderDetailInfo objectForKey:@"mealTimes"] forKey:@"mealTimes"];
        [postData setObject:[orderDetailInfo objectForKey:@"peopleNum"] forKey:@"peopleNum"];
        [postData setObject:[orderDetailInfo objectForKey:@"seatsList"] forKey:@"seats"];
    }
    [jsonPicker postData:postData withBaseRequest:@"OrderStatus"];
#ifdef DEBUG
    NSLog(@"===%@,postData:%@===",[self class],postData);
#endif
}

//"出餐"
-(void)finishedDinner
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 2;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = NSLocalizedString(@"处理中，请稍候...", nil);
    jsonPicker.showSuccessfulMessageInterval = 1.0f;
    jsonPicker.loadedSuccessfulMessage = NSLocalizedString(@"己出餐", nil);
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[msgDetailInfo objectForKey:@"orderId"] forKey:@"orderId"];
    [postData setObject:[msgDetailInfo objectForKey:@"orderType"] forKey:@"orderType"];
    [postData setObject:@"7" forKey:@"statusValue"];
    [postData setObject:[NSNumber numberWithInt:orderStatus] forKey:@"oldStatusValue"];
    [jsonPicker postData:postData withBaseRequest:@"OrderStatus"];
}

//送餐/已取餐
-(void)deliveryDinner
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 2;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = NSLocalizedString(@"处理中，请稍候...", nil);
    jsonPicker.showSuccessfulMessageInterval = 1.0f;
    jsonPicker.loadedSuccessfulMessage = (0 == deliveryType)?NSLocalizedString(@"己送餐", nil): NSLocalizedString(@"操作成功", nil);
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[msgDetailInfo objectForKey:@"orderId"] forKey:@"orderId"];
    [postData setObject:[msgDetailInfo objectForKey:@"orderType"] forKey:@"orderType"];
    [postData setObject:(0 == deliveryType)?@"3":@"4" forKey:@"statusValue"];
    [postData setObject:[NSNumber numberWithInt:orderStatus] forKey:@"oldStatusValue"];
    [jsonPicker postData:postData withBaseRequest:@"OrderStatus"];
}

//客人签到
-(void)checkInOrder
{
    /* 暂时隐藏选台，所以...
     if (orderType==1)
     {
     NSArray *seats = [msgDetailInfo objectForKey:@"seatsList"];
     if ([seats count]==0)
     {
     [[DisplayHelper shareDisplayHelper] displayWarningAlert:@"签到失败，请先选台" onHUD:promptHUD];
     return;
     }
     }
     */
    
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 2;
    jsonPicker.showActivityIndicator = YES;
    if (1 == orderType)
    {
        jsonPicker.loadingMessage = NSLocalizedString(@"正在为客人签到，请稍候...", nil);
        jsonPicker.loadedSuccessfulMessage = NSLocalizedString(@"签到成功", nil);
    }
    else
    {
        jsonPicker.loadingMessage = NSLocalizedString(@"正在等待客人签收，请稍候...", nil);
        jsonPicker.loadedSuccessfulMessage = NSLocalizedString(@"签收成功", nil);
    }
    
    jsonPicker.showSuccessfulMessageInterval = 1.0f;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[msgDetailInfo objectForKey:@"orderId"] forKey:@"orderId"];
    [postData setObject:[msgDetailInfo objectForKey:@"orderType"] forKey:@"orderType"];
    [postData setObject:@"3" forKey:@"statusValue"];
    [postData setObject:[NSNumber numberWithInt:orderStatus] forKey:@"oldStatusValue"];
    [jsonPicker postData:postData withBaseRequest:@"OrderStatus"];
}

//“保存修改”
-(void)saveEdit
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 3;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = NSLocalizedString(@"正在修改订单信息，请稍候...", nil);
    jsonPicker.showSuccessfulMessageInterval = 1.0f;
    jsonPicker.loadedSuccessfulMessage = NSLocalizedString(@"修改成功", nil);
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[orderDetailInfo objectForKey:@"orderId"] forKey:@"orderId"];
    [postData setObject:[orderDetailInfo objectForKey:@"mealTimes"] forKey:@"mealTimes"];
    [postData setObject:[NSNumber numberWithInt:orderStatus] forKey:@"oldStatusValue"];
    
    //判断哪项修改了
    
    NSMutableArray *editedId = [[NSMutableArray alloc] init];
    if (orderType==1)
    {
        [postData setObject:[orderDetailInfo objectForKey:@"peopleNum"] forKey:@"peopleNum"];
        [postData setObject:[orderDetailInfo objectForKey:@"seatsList"] forKey:@"seats"];
        
        //订座时间
        NSString *orderDate1 = [orderDetailInfo objectForKey:@"mealTimes"];
        NSString *orderDate2 = [msgDetailInfo objectForKey:@"mealTimes"];
        if (![orderDate1 isEqualToString:orderDate2])
        {
            [editedId addObject:[NSNumber numberWithInt:1]];
        }
        
        //人数
        int peopleNum1 = [[orderDetailInfo objectForKey:@"peopleNum"] intValue];
        int peopleNum2 = [[msgDetailInfo objectForKey:@"peopleNum"] intValue];
        if (peopleNum1!=peopleNum2)
        {
            [editedId addObject:[NSNumber numberWithInt:2]];
        }
        
        //选台
        NSArray *seats1 =  [orderDetailInfo objectForKey:@"seatsList"];
        NSArray *seats2 =  [msgDetailInfo objectForKey:@"seatsList"];
        if ([seats1 count]!=[seats2 count])
        {
            [editedId addObject:[NSNumber numberWithInt:3]];
        }
        else
        {
            for (int i=0; i<[seats1 count] && i<[seats2 count]; i++)
            {
                int seatsId1 = [[[seats1 objectAtIndex:i] objectForKey:@"seatsId"] intValue];
                int seatsId2 = [[[seats2 objectAtIndex:i] objectForKey:@"seatsId"] intValue];
                if (seatsId1!=seatsId2) {
                    [editedId addObject:[NSNumber numberWithInt:3]];
                    break;
                }
            }
        }
    }
    else
    {
        //外卖时间
        NSString *orderDate1 = [orderDetailInfo objectForKey:@"mealTimes"];
        NSString *orderDate2 = [msgDetailInfo objectForKey:@"mealTimes"];
        if (![orderDate1 isEqualToString:orderDate2])
        {
            [editedId addObject:[NSNumber numberWithInt:5]];
        }
        
        //地址
        NSString *takeoutAddress1 = [orderDetailInfo objectForKey:@"takeoutAddress"];
        NSString *takeoutAddress2 = [msgDetailInfo objectForKey:@"takeoutAddress"];
        if (![takeoutAddress1 isEqualToString:takeoutAddress2])
        {
            [editedId addObject:[NSNumber numberWithInt:4]];
        }
        [postData setObject:[orderDetailInfo objectForKey:@"takeoutAddress"] forKey:@"takeoutAddress"];
    }
    [jsonPicker postData:postData withBaseRequest:@"OrderUpdate"];
}

//修改订单为“己查看”
-(void)orderIsChecked:(BOOL)animated
{
    if (1 == [[msgDetailInfo objectForKey:@"isChecked"] intValue])
    {
        return;
    }
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 4;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.loadingMessage = nil;
    jsonPicker.showSuccessfulMessageInterval = 0.0f;
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[msgDetailInfo objectForKey:@"orderId"] forKey:@"orderId"];
    [jsonPicker postData:postData withBaseRequest:@"OrderChecked"];
}

- (void)commitCarryfee:(NSString *)carryfeeStr
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerSixthTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = NSLocalizedString(@"正在修改订单信息，请稍候...", nil);
    jsonPicker.showSuccessfulMessageInterval = 1.0f;
    jsonPicker.loadedSuccessfulMessage = NSLocalizedString(@"配送费修改成功", nil);
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[msgDetailInfo objectForKey:@"orderId"] forKey:@"orderId"];
    [postData setObject:carryfeeStr forKey:@"carryfee"];
    [jsonPicker postData:postData withBaseRequest:@"Order/modTakeoutCarryfee"];
}

#pragma mark Notification

//注册Notification
- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedViewWhenPush:) name:kUpdateTakeoutDetailViewWhenPush object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedViewWhenPush:) name:kUpdatePreOrderDetailViewWhenPush object:nil];
}

//撤消Notification
- (void)removeNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updatedViewWhenPush:(NSNotification *)notify
{
    int tempType = [[notify.userInfo objectForKey:@"orderType"] intValue];
    if (tempType == orderType && self.isShowingView)
    {
        isEditing = NO;
        [popoverController dismissPopoverAnimated:YES];
        [[self getDishDetailTitleView].popController dismissPopoverAnimated:YES];
        
        //刷新数据
        msgDetailInfo = [[NSDictionary alloc] initWithDictionary:notify.userInfo];
        orderDetailInfo = [[NSMutableDictionary alloc] initWithDictionary:notify.userInfo];
        orderType = [[msgDetailInfo objectForKey:@"orderType"] intValue];
        orderStatus =[[msgDetailInfo objectForKey:@"status"] intValue];
        self.orderId = [[msgDetailInfo objectForKey:@"orderId"] intValue];
        [self orderIsChecked:NO];
        [self updateViewAfterData];
        [detailTableview reloadData];
    }
}

//获取外卖的修改配送费的视图
- (DishDetailTitleView *)getDishDetailTitleView
{
    if (2 == orderType)
    {
        UITableViewCell *cell = [self.detailTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:kTableViewOnlyOneSection]];
        return ((DishDetailTitleView *)[cell.contentView viewWithTag:kDishDetailTitleViewTag]);
    }
    return nil;
}

#pragma mark UITableViewController datasource & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CellIdentifier";
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellAccessoryNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor clearColor];
    
    int row = indexPath.row;
//    int section= indexPath.section;
    
    switch (orderType)
    {
        case 1://订座
        {
            int width = 110;
            int originX = 110;
            int lineOriginY = 45;
            int lineWidth = 300;
            
            switch (row)
            {
                case 0://下单时间
                {
                    int originY = 10;
                    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, originY, width, 30)];
                    label1.backgroundColor = [UIColor clearColor];
                    label1.textAlignment = UITextAlignmentRight;
                    label1.font = [UIFont boldSystemFontOfSize:20];
                    label1.text = NSLocalizedString(@"下单时间 ：", nil);
                    [cell.contentView addSubview:label1];
                    
                    UITextField *texfield1 = [[UITextField alloc] initWithFrame:CGRectMake(originX, originY, 220, 30)];
                    texfield1.textColor = kTextDarkGradColor;
                    texfield1.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
                    texfield1.contentVerticalAlignment =UIControlContentVerticalAlignmentCenter;
                    texfield1.returnKeyType = UIReturnKeyNext;
                    texfield1.font = [UIFont systemFontOfSize:20];
                    texfield1.clearButtonMode = UITextFieldViewModeWhileEditing;
                    texfield1.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    texfield1.autocorrectionType = UITextAutocorrectionTypeNo;
                    texfield1.keyboardType = UIKeyboardTypePhonePad;
                    texfield1.borderStyle = UITextBorderStyleNone;
                    texfield1.enabled = NO;
                    
                    if (msgDetailInfo)
                    {
                        NSString *orderDate = [msgDetailInfo objectForKey:@"orderDate"];
                        NSDate *orderTime = [orderDate stringToNSDateWithFormat:@"yyyy/MM/dd HH:mm:ss"];
                        orderDate = [NSString dateToNSString:orderTime withFormat:@"yyyy-MM-dd eee HH:mm"];
                        texfield1.text = orderDate;
                    }
                    
                    [cell.contentView addSubview:texfield1];
    
                    //加上一条线
                    UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(originX, lineOriginY, lineWidth, 1)];
                    lineImageView.backgroundColor = [UIColor lightGrayColor];
                    [cell.contentView addSubview:lineImageView];
                    
                    break;
                }
                    
                case 1:
                {
                    //入座时间
                    int originY = 10;
                    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, originY, width, 30)];
                    label1.backgroundColor = [UIColor clearColor];
                    label1.textAlignment = UITextAlignmentRight;
                    label1.font = [UIFont boldSystemFontOfSize:20];
                    label1.text = NSLocalizedString(@"入座时间 ：", nil);
                    [cell.contentView addSubview:label1];
                    
                    UITextField *texfield1 = [[UITextField alloc] initWithFrame:CGRectMake(originX, originY, 220, 30)];
                    texfield1.textColor = kTextDarkGradColor;
                    texfield1.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
                    texfield1.contentVerticalAlignment =UIControlContentVerticalAlignmentCenter;
                    texfield1.returnKeyType = UIReturnKeyNext;
                    texfield1.font = [UIFont systemFontOfSize:20];
                    texfield1.clearButtonMode = UITextFieldViewModeWhileEditing;
                    texfield1.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    texfield1.autocorrectionType = UITextAutocorrectionTypeNo;
                    texfield1.keyboardType = UIKeyboardTypePhonePad;
                    texfield1.borderStyle = UITextBorderStyleNone;
                    texfield1.enabled = isEditing;
                    if (0 == orderStatus)
                    {
                        texfield1.enabled = YES;
                    }
                    
                    [cell.contentView addSubview:texfield1];
 
                    if (isEditing)
                    {
                        NSString *mealTimesStr = [orderDetailInfo objectForKey:@"mealTimes"];
                        NSDate *mealTime = [mealTimesStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
                        texfield1.text = [NSString dateToNSString:mealTime withFormat:@"yyyy-MM-dd eee HH:mm"];
                    }
                    else
                    {
                        NSString *mealTimesStr = [msgDetailInfo objectForKey:@"mealTimes"];
                        NSDate *mealTime = [mealTimesStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
                        texfield1.text = [NSString dateToNSString:mealTime withFormat:@"yyyy-MM-dd eee HH:mm"];
                    }
                    
                    //加上一条线
                    UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(originX, lineOriginY, lineWidth, 1)];
                    lineImageView.backgroundColor = [UIColor lightGrayColor];
                    [cell.contentView addSubview:lineImageView];
                    
                    //加上一个箭头
                    if (0 == orderStatus || isEditing)
                    {
                        UIImageView *arrowImageView = [[UIImageView alloc]initWithFrame:CGRectMake(395, 17, 12, 19)];
                        arrowImageView.image = [UIImage imageFromMainBundleFile:@"order_detailRightArrow.png"];
                        [cell.contentView addSubview:arrowImageView];
                        
                        UIButton *arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                        arrowBtn.frame = CGRectMake(originX, 5, lineWidth + 10, 40);
                        arrowBtn.tag = row;
                        [arrowBtn addTarget:self action:@selector(handleOrderDetailBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:arrowBtn];
                    }
                    
                    break;
                }
                case 2:
                {
                    //订座人数
                    int originY = 10;
                    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(5, originY, width, 30)];
                    label2.backgroundColor = [UIColor clearColor];
                    label2.textAlignment = UITextAlignmentRight;
                    label2.font = [UIFont boldSystemFontOfSize:20];
                    label2.text = NSLocalizedString(@"人数 ：", nil);
                    [cell.contentView addSubview:label2];
                    
                    UITextField *texfield2 = [[UITextField alloc] initWithFrame:CGRectMake(originX, originY, 220, 30)];
                    texfield2.textColor = kTextDarkGradColor;
                    texfield2.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
                    texfield2.contentVerticalAlignment =UIControlContentVerticalAlignmentCenter;
                    texfield2.returnKeyType = UIReturnKeyNext;
                    texfield2.font = [UIFont systemFontOfSize:20];
                    texfield2.clearButtonMode = UITextFieldViewModeWhileEditing;
                    texfield2.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    texfield2.autocorrectionType = UITextAutocorrectionTypeNo;
                    texfield2.keyboardType = UIKeyboardTypePhonePad;
                    texfield2.borderStyle = UITextBorderStyleNone;
                    texfield2.enabled = isEditing;
                    if (0 == orderStatus)
                    {
                        texfield2.enabled = YES;
                    }
                    
                    [cell.contentView addSubview:texfield2];

                    if (isEditing)
                    {
                        texfield2.text = [NSString stringWithFormat:@"%@%@",[orderDetailInfo objectForKey:@"peopleNum"],NSLocalizedString(@"人", nil)];
                    }
                    else
                    {
                        texfield2.text = [NSString stringWithFormat:@"%@%@",[msgDetailInfo objectForKey:@"peopleNum"],NSLocalizedString(@"人", nil)];
                    }
                    //加上一条线
                    UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(originX, lineOriginY, lineWidth, 1)];
                    lineImageView.backgroundColor = [UIColor lightGrayColor];
                    [cell.contentView addSubview:lineImageView];
                    
                    //加上一个箭头
                    if (0 == orderStatus || isEditing)
                    {
                        UIImageView *arrowImageView = [[UIImageView alloc]initWithFrame:CGRectMake(395, 17, 12, 19)];
                        arrowImageView.image = [UIImage imageFromMainBundleFile:@"order_detailRightArrow.png"];
                        [cell.contentView addSubview:arrowImageView];
                        
                        UIButton *arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                        arrowBtn.frame = CGRectMake(originX, 5, lineWidth + 10, 40);
                        arrowBtn.tag = row;
                        [arrowBtn addTarget:self action:@selector(handleOrderDetailBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:arrowBtn];
                    }
                    
                    break;
                }
                case 3:
                {
                    /*  暂时隐藏选台
                    //己选台号
                    int originY = 10;
                    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(5, originY, width, 30)];
                    label3.backgroundColor = [UIColor clearColor];
                    label3.textAlignment = UITextAlignmentRight;
                    label3.font = [UIFont boldSystemFontOfSize:25];
                    label3.text = @"选台 ：";
                    [cell.contentView addSubview:label3];
                    
                    //选台内容
                    UIView *seatsView = [self seatDetailView:row];
                    [cell.contentView addSubview:seatsView];
                     */
                    
                    break;
                }
                case 4:
                {
                    /*   暂时隐藏预点菜
                    //菜的背景
                    UIImageView *dishBgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-2, 0, 430, 42)];
                    dishBgImageView.image = [UIImage imageFromMainBundleFile:@"order_detailDishBg.png"];
                    [cell.contentView addSubview:dishBgImageView];
                    
                    UILabel *dishesTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, width, 30)];
                    dishesTitleLabel.backgroundColor = [UIColor clearColor];
                    dishesTitleLabel.textAlignment = UITextAlignmentRight;
                    dishesTitleLabel.font = [UIFont boldSystemFontOfSize:25];
                    dishesTitleLabel.adjustsFontSizeToFitWidth = YES;
                    dishesTitleLabel.text = @"预点菜 ：";
                    [cell.contentView addSubview:dishesTitleLabel];
                    
                    //总份数
                    int totalQty = 0;
                    //总金额
                    CGFloat totalSum = 0;
                    NSArray *dishes = [msgDetailInfo objectForKey:@"dishesList"];
                    int dishNum = [dishes count];
                    for (int i=0; i < dishNum; i++)
                    {
                        NSDictionary *dish = [dishes objectAtIndex:i];
                        //数量
                        int qty = [[dish objectForKey:@"quantity"] intValue];
                        totalQty += qty;
                        //价格
                        CGFloat price = [[dish objectForKey:@"currentPrice"] floatValue];
                        totalSum += price*qty;
                    }
                    if (0 != dishNum)
                    {
                        //总共份数
                        UILabel *totalQtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, 5, 100, 30)];
                        totalQtyLabel.backgroundColor = [UIColor clearColor];
                        totalQtyLabel.textColor = [UIColor lightGrayColor];
                        totalQtyLabel.font = [UIFont systemFontOfSize:20];
                        totalQtyLabel.textAlignment = UITextAlignmentLeft;
                        totalQtyLabel.adjustsFontSizeToFitWidth = YES;
                        totalQtyLabel.text = [NSString stringWithFormat:@"共%i份",totalQty];
                        [cell.contentView addSubview:totalQtyLabel];
                        
                        //总金额
                        UILabel *totalSumLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 5, 150, 30)];
                        totalSumLabel.backgroundColor = [UIColor clearColor];
                        totalSumLabel.textColor = [UIColor lightGrayColor];
                        totalSumLabel.font = [UIFont systemFontOfSize:20];
                        totalSumLabel.textAlignment = UITextAlignmentRight;
                        totalSumLabel.adjustsFontSizeToFitWidth = YES;
                        NSString *tempString = [NSString stringWithFormat:@"%.2f", totalSum];
                        totalSumLabel.text = [NSString stringWithFormat:@"预估总价:%@元",[NSString trimmingZeroInPrice:tempString]];
                        [cell.contentView addSubview:totalSumLabel];
                        
                        //加上一个箭头
                        UIImageView *arrowImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
                        NSString *arrowImageName = nil;
                        if (isOpenDetailDish)
                        {
                            arrowImageView.frame = CGRectMake(405, 15, 18, 11);
                            arrowImageName = @"order_detailDishDownArrow.png";
                        }
                        else
                        {
                            arrowImageView.frame = CGRectMake(405, 12, 12, 19);
                            arrowImageName = @"order_detailDishRightArrow.png";
                        }
                        arrowImageView.image = [UIImage imageFromMainBundleFile:arrowImageName];
                        [cell.contentView addSubview:arrowImageView];
                        
                        UIButton *arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                        arrowBtn.frame = CGRectMake(0, 0, 430, 40);
                        [arrowBtn addTarget:self action:@selector(dishDetailBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:arrowBtn];
                        
                        //菜的详细内容
                        if (isOpenDetailDish)
                        {
                            [cell.contentView addSubview:[self dishesDetailView]];
                        }
                    }
                    else
                    {
                        UILabel *dishesLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, 5, 100, 30)];
                        dishesLabel.backgroundColor = [UIColor clearColor];
                        dishesLabel.textColor = [UIColor grayColor];
                        dishesLabel.font = [UIFont systemFontOfSize:20];
                        dishesLabel.textAlignment = UITextAlignmentLeft;
                        dishesLabel.text = @"暂无";
                        [cell.contentView addSubview:dishesLabel];
                    }
                     */
                    
                    break;
                }
                case 5:
                {
                    //备注
                    NSString *remark = [[NSString stringWithFormat:@"%@", [msgDetailInfo objectForKey:@"remark"]]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if ([remark length]>0)
                    {
                        int originY = 10;
                        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, originY, width, 30)];
                        label1.backgroundColor = [UIColor clearColor];
                        label1.textAlignment = UITextAlignmentRight;
                        label1.font = [UIFont boldSystemFontOfSize:20];
                        label1.text = NSLocalizedString(@"备注 ：", nil);
                        [cell.contentView addSubview:label1];
                        
                        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, 315, 30)];
                        label2.numberOfLines = 0;
                        label2.backgroundColor = [UIColor clearColor];
                        label2.textAlignment = UITextAlignmentLeft;
                        label2.font = [UIFont systemFontOfSize:20];
                        label2.textColor = [UIColor grayColor];
                        label2.text = remark;
                        [label2 adjustLabelHeight];
                        
                        CGRect frame = label2.frame;
                        int scaleHeight = frame.size.height;
                        if (scaleHeight<30)
                        {
                            frame.size.height = 30;
                        }
                        else
                        {
                            frame.origin.y = frame.origin.y + 5;
                        }
                        label2.frame = frame;
                        [cell.contentView addSubview:label2];
                    }
                    break;
                }
                case 6:
                {
                    float originY = 40;
                    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, width, 30)];
                    label1.backgroundColor = [UIColor clearColor];
                    label1.textAlignment = UITextAlignmentRight;
                    label1.font = [UIFont boldSystemFontOfSize:20];
                    label1.textColor = [UIColor blackColor];
                    label1.text = NSLocalizedString(@"记录 ：", nil);
                    [cell.contentView addSubview:label1];
                    
                    NSArray *logList = [msgDetailInfo objectForKey:@"logList"];
                    if ([logList count]>0)
                    {
                        for (int i=0; i<[logList count]; i++)
                        {
                            //状态
                            NSDictionary *log = [logList objectAtIndex:i];
                            //签到
                            NSDictionary *finishDict = [log objectForKey:@"finish"];
                            if (0 != [finishDict count])
                            {
                                UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, originY, 350, 30)];
                                statusLabel.numberOfLines = 0;
                                statusLabel.lineBreakMode = UILineBreakModeCharacterWrap;
                                statusLabel.backgroundColor = [UIColor clearColor];
                                statusLabel.textAlignment = UITextAlignmentLeft;
                                statusLabel.font = [UIFont systemFontOfSize:20];
                                statusLabel.textColor = [UIColor grayColor];
                                statusLabel.text = [NSString stringWithFormat:@"%@ ( %d%@ )",NSLocalizedString(@"完成订座", nil),[[finishDict objectForKey:@"count"]integerValue],NSLocalizedString(@"次", nil)];
                                float statusHeight = [statusLabel adjustLabelHeight];
                                [cell.contentView addSubview:statusLabel];
                                
                                //日期
                                UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY+statusHeight, 425, 15)];
                                dateLabel.backgroundColor = [UIColor clearColor];
                                dateLabel.textAlignment = UITextAlignmentRight;
                                dateLabel.font = [UIFont systemFontOfSize:15];
                                dateLabel.textColor = [UIColor grayColor];
                                
                                NSString *dateStr = [finishDict objectForKey:@"last"];
                                NSDate *dateTime = [dateStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
                                dateLabel.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"最近一次", nil),[NSString dateToNSString:dateTime withFormat:@"yyyy-MM-dd eee HH:mm"]];
                                
                                [cell.contentView addSubview:dateLabel];
                                
                                originY = originY+statusHeight+35;
                            }
                            
                            //取消
                            NSDictionary *cancelDict = [log objectForKey:@"cancel"];
                            if (0 != [cancelDict count])
                            {
                                UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, originY, 350, 30)];
                                statusLabel.numberOfLines = 0;
                                statusLabel.lineBreakMode = UILineBreakModeCharacterWrap;
                                statusLabel.backgroundColor = [UIColor clearColor];
                                statusLabel.textAlignment = UITextAlignmentLeft;
                                statusLabel.font = [UIFont systemFontOfSize:20];
                                statusLabel.textColor = [UIColor grayColor];
                                statusLabel.text = [NSString stringWithFormat:@"%@ ( %d次 )",NSLocalizedString(@"取消订座", nil),[[cancelDict objectForKey:@"count"]integerValue]];
                                
                                float statusHeight = [statusLabel adjustLabelHeight];
                                [cell.contentView addSubview:statusLabel];
                                
                                //日期
                                UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY+statusHeight, 425, 15)];
                                dateLabel.backgroundColor = [UIColor clearColor];
                                dateLabel.textAlignment = UITextAlignmentRight;
                                dateLabel.font = [UIFont systemFontOfSize:15];
                                dateLabel.textColor = [UIColor grayColor];
                                
                                NSString *dateStr = [cancelDict objectForKey:@"last"];
                                NSDate *dateTime = [dateStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
                                dateLabel.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"最近一次", nil),[NSString dateToNSString:dateTime withFormat:@"yyyy-MM-dd eee HH:mm"]];
                                
                                [cell.contentView addSubview:dateLabel];
                                
                                originY = originY+statusHeight+35;
                            }
                            
                            //加上一条线
                            if (0 != [finishDict count] || 0 != [cancelDict count])
                            {
                                UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, originY - 15, 428, 1)];
                                lineImageView.backgroundColor = [UIColor lightGrayColor];
                                [cell.contentView addSubview:lineImageView];
                            }
                            //没有外卖记录
                            if (0 == [finishDict count] && 0 == [cancelDict count])
                            {
                                UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(15, originY, 120, 30)];
                                label2.backgroundColor = [UIColor clearColor];
                                label2.textAlignment = UITextAlignmentLeft;
                                label2.font = [UIFont systemFontOfSize:20];
                                label2.textColor = [UIColor grayColor];
                                label2.text = NSLocalizedString(@"暂无", nil);
                                [cell.contentView addSubview:label2];
                            }
                        }
                    }
                    else
                    {
                        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, originY, 120, 30)];
                        label2.backgroundColor = [UIColor clearColor];
                        label2.textAlignment = UITextAlignmentLeft;
                        label2.font = [UIFont systemFontOfSize:20];
                        label2.textColor = [UIColor grayColor];
                        label2.text = NSLocalizedString(@"暂无", nil);
                        [cell.contentView addSubview:label2];
                    }
                    
                    break;
                }
            
            }
            
            break;
        }
        case 2://外卖
        {
            int width = 110;
            int originX = 110;
            int lineOriginY = 45;
            int lineWidth = 300;
            
            switch (indexPath.row)
            {
                case 0:
                {
                    //是否需要发票
                    UILabel *invoicingLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, width, 30)];
                    invoicingLabel.backgroundColor = [UIColor clearColor];
                    invoicingLabel.textAlignment = UITextAlignmentRight;
                    invoicingLabel.font = [UIFont boldSystemFontOfSize:20];
                    invoicingLabel.text = [NSString stringWithFormat:@"%@ ：", NSLocalizedString(@"需要发票", nil)];
                    [cell.contentView addSubview:invoicingLabel];
                    
                    UILabel *invoiceValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, 10, width, 30)];
                    invoiceValueLabel.backgroundColor = [UIColor clearColor];
                    invoiceValueLabel.textAlignment = UITextAlignmentLeft;
                    invoiceValueLabel.font = [UIFont systemFontOfSize:20];
                    invoiceValueLabel.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
                    invoiceValueLabel.text = ([[msgDetailInfo objectForKey:@"invoicing"]boolValue]) ? NSLocalizedString(@"是", nil) : NSLocalizedString(@"否", nil);
                    [cell.contentView addSubview:invoiceValueLabel];
                    
                    //加上一条线
                    UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(originX, lineOriginY, lineWidth, 1)];
                    lineImageView.backgroundColor = [UIColor lightGrayColor];
                    [cell.contentView addSubview:lineImageView];
                    
                    break;
                }
                    
                case 1://下单时间
                {
                    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, width, 30)];
                    label1.backgroundColor = [UIColor clearColor];
                    label1.textAlignment = UITextAlignmentRight;
                    label1.font = [UIFont boldSystemFontOfSize:20];
                    label1.text = NSLocalizedString(@"下单时间 ：", nil);
                    [cell.contentView addSubview:label1];
                    
                    UITextField *texfield1 = [[UITextField alloc] initWithFrame:CGRectMake(originX, 10, 250, 30)];
                    texfield1.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
                    texfield1.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
                    texfield1.contentVerticalAlignment =UIControlContentVerticalAlignmentCenter;
                    texfield1.returnKeyType = UIReturnKeyNext;
                    texfield1.font = [UIFont systemFontOfSize:20];
                    texfield1.clearButtonMode = UITextFieldViewModeWhileEditing;
                    texfield1.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    texfield1.autocorrectionType = UITextAutocorrectionTypeNo;
                    texfield1.keyboardType = UIKeyboardTypePhonePad;
                    texfield1.borderStyle = UITextBorderStyleNone;
                    texfield1.enabled = NO;
                    
                    if (msgDetailInfo)
                    {
                        NSString *orderDate = [msgDetailInfo objectForKey:@"orderDate"];
                        NSDate *orderTime = [orderDate stringToNSDateWithFormat:@"yyyy/MM/dd HH:mm:ss"];
                        orderDate = [NSString dateToNSString:orderTime withFormat:@"yyyy-MM-dd eee HH:mm"];
                        texfield1.text = orderDate;
                    }
                    
                    [cell.contentView addSubview:texfield1];
                    
                    //加上一条线
                    UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(originX, lineOriginY, lineWidth, 1)];
                    lineImageView.backgroundColor = [UIColor lightGrayColor];
                    [cell.contentView addSubview:lineImageView];
                    break;
                }
                    
                case 2:
                {
                    //送达时间
                    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, width, 30)];
                    label1.backgroundColor = [UIColor clearColor];
                    label1.textAlignment = UITextAlignmentRight;
                    label1.font = [UIFont boldSystemFontOfSize:20];
                    label1.text = (1 == deliveryType)?NSLocalizedString(@"自取时间 ：", nil):NSLocalizedString(@"送达时间 ：", nil);
                    [cell.contentView addSubview:label1];
                    
                    UITextField *texfield1 = [[UITextField alloc] initWithFrame:CGRectMake(originX, 10, 250, 30)];
                    texfield1.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
                    texfield1.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
                    texfield1.contentVerticalAlignment =UIControlContentVerticalAlignmentCenter;
                    texfield1.returnKeyType = UIReturnKeyNext;
                    texfield1.font = [UIFont systemFontOfSize:20];
                    texfield1.clearButtonMode = UITextFieldViewModeWhileEditing;
                    texfield1.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    texfield1.autocorrectionType = UITextAutocorrectionTypeNo;
                    texfield1.keyboardType = UIKeyboardTypePhonePad;
                    texfield1.borderStyle = UITextBorderStyleNone;
                    texfield1.enabled = NO;
                    int mealDateType = [[msgDetailInfo objectForKey:@"takeoutTimeType"]integerValue];
                    
                    NSString *string = nil;
                    if (0 == mealDateType)
                    {
                        NSString *timeStr = [msgDetailInfo objectForKey:@"mealTimes"];
                        NSDate *mealTime = [timeStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
                        string = [NSString dateToNSString:mealTime withFormat:@"yyyy-MM-dd eee HH:mm"];
                    }
                    else
                    {
                        NSString *orderDate = [msgDetailInfo objectForKey:@"orderDate"];
                        NSDate *orderTime = [orderDate stringToNSDateWithFormat:@"yyyy/MM/dd HH:mm:ss"];
                        orderDate = [NSString dateToNSString:orderTime withFormat:@"yyyy-MM-dd eee"];
                        NSString *str = [msgDetailInfo objectForKey:@"takeoutTimeTypeDesc"];
                        string = [NSString stringWithFormat:@"%@ %@",orderDate,NSLocalizedString(str, nil)];
                    }
                    
                    texfield1.text = string;
                    [cell.contentView addSubview:texfield1];
 
                    //加上一条线
                    UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(originX, lineOriginY, lineWidth, 1)];
                    lineImageView.backgroundColor = [UIColor lightGrayColor];
                    [cell.contentView addSubview:lineImageView];

                    break;
                }
                case 3://地址
                {
                    if (0 == deliveryType)
                    {
                        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, width, 30)];
                        label2.backgroundColor = [UIColor clearColor];
                        label2.textAlignment = UITextAlignmentRight;
                        label2.font = [UIFont boldSystemFontOfSize:20];
                        label2.text = NSLocalizedString(@"地址 ：", nil);
                        [cell.contentView addSubview:label2];
                        
                        [cell.contentView addSubview:[self addAddressToViewWithCustomSpace]];
                    }

                    break;
                }
                case 4:
                {
                    NSString *carryfeeStr = [NSString stringWithFormat:@"%@",[msgDetailInfo objectForKey:@"carryfee"]];
                    DishDetailTitleView *titleView = [[DishDetailTitleView alloc]initWithCarryfee:carryfeeStr withOrderStatus:orderStatus withDeliveryType:deliveryType];
                    titleView.delegate = self;
                    titleView.tag = kDishDetailTitleViewTag;
                    [cell.contentView addSubview:titleView];
                    
                    NSArray *dishes = [msgDetailInfo objectForKey:@"dishesList"];
                    int dishNum = [dishes count];
                    if (0 != dishNum)
                    {
                        //菜的详细内容
                        [cell.contentView addSubview:[self dishesDetailView]];
                    }
                    else
                    {
                        UILabel *dishesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 42, 100, 30)];
                        dishesLabel.backgroundColor = [UIColor clearColor];
                        dishesLabel.textColor = [UIColor grayColor];
                        dishesLabel.font = [UIFont systemFontOfSize:20];
                        dishesLabel.textAlignment = UITextAlignmentLeft;
                        dishesLabel.text = NSLocalizedString(@"暂无", nil);
                        [cell.contentView addSubview:dishesLabel];
                    }
                    
                    break;
                }
                case 5:
                {
                    //备注
                    int originY = 10;
                    NSString *remark = [[NSString stringWithFormat:@"%@", [msgDetailInfo objectForKey:@"remark"]]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if ([remark length]>0)
                    {
                        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, originY, 70, 30)];
                        label1.backgroundColor = [UIColor clearColor];
                        label1.textAlignment = UITextAlignmentLeft;
                        label1.font = [UIFont boldSystemFontOfSize:20];
                        label1.text = NSLocalizedString(@"备注 ：", nil);
                        [cell.contentView addSubview:label1];
                        
                        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(70, originY, 355, 30)];
                        label2.numberOfLines = 0;
                        label2.backgroundColor = [UIColor clearColor];
                        label2.textAlignment = UITextAlignmentLeft;
                        label2.font = [UIFont systemFontOfSize:20];
                        label2.textColor = [UIColor grayColor];
                        label2.text = remark;
                        [label2 adjustLabelHeight];
                        
                        CGRect frame = label2.frame;
                        int scaleHeight = frame.size.height;
                        if (scaleHeight<30)
                        {
                            frame.size.height = 30;
                        }
                        else
                        {
                            frame.origin.y = frame.origin.y + 5;
                        }
                        label2.frame = frame;
                        [cell.contentView addSubview:label2];
                    }
                    
                    break;
                }
                case 6:
                {
                    float originY = 40;
                    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, width, 30)];
                    label1.backgroundColor = [UIColor clearColor];
                    label1.textAlignment = UITextAlignmentLeft;
                    label1.font = [UIFont boldSystemFontOfSize:20];
                    label1.textColor = [UIColor blackColor];
                    label1.text = NSLocalizedString(@"记录 ：", nil);
                    [cell.contentView addSubview:label1];
                    
                    NSArray *logList = [msgDetailInfo objectForKey:@"logList"];
                    if ([logList count]>0)
                    {
                        for (int i=0; i<[logList count]; i++)
                        {
                            //状态
                            NSDictionary *log = [logList objectAtIndex:i];
                            //确认订单
                            NSDictionary *finishDict = [log objectForKey:@"finish"];
                            if (0 != [finishDict count])
                            {
                                UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, originY, 350, 30)];
                                statusLabel.numberOfLines = 0;
                                statusLabel.lineBreakMode = UILineBreakModeCharacterWrap;
                                statusLabel.backgroundColor = [UIColor clearColor];
                                statusLabel.textAlignment = UITextAlignmentLeft;
                                statusLabel.font = [UIFont systemFontOfSize:20];
                                statusLabel.textColor = [UIColor grayColor];
                                statusLabel.text = [NSString stringWithFormat:@"%@ ( %d次 )",NSLocalizedString(@"完成外卖", nil),[[finishDict objectForKey:@"count"]integerValue]];
                                float statusHeight = [statusLabel adjustLabelHeight];
                                [cell.contentView addSubview:statusLabel];
                                
                                //日期
                                UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY+statusHeight, 425, 15)];
                                dateLabel.backgroundColor = [UIColor clearColor];
                                dateLabel.textAlignment = UITextAlignmentRight;
                                dateLabel.font = [UIFont systemFontOfSize:15];
                                dateLabel.textColor = [UIColor grayColor];
                                
                                NSString *dateStr = [finishDict objectForKey:@"last"];
                                NSDate *dateTime = [dateStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
                                dateLabel.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"最近一次", nil),[NSString dateToNSString:dateTime withFormat:@"yyyy-MM-dd eee HH:mm"]];
                                
                                [cell.contentView addSubview:dateLabel];
                                
                                originY = originY+statusHeight+35;
                            }
                            
                            //取消订单
                            NSDictionary *cancelDict = [log objectForKey:@"cancel"];
                            if (0 != [cancelDict count])
                            {
                                UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, originY, 350, 30)];
                                statusLabel.numberOfLines = 0;
                                statusLabel.lineBreakMode = UILineBreakModeCharacterWrap;
                                statusLabel.backgroundColor = [UIColor clearColor];
                                statusLabel.textAlignment = UITextAlignmentLeft;
                                statusLabel.font = [UIFont systemFontOfSize:20];
                                statusLabel.textColor = [UIColor grayColor];
                                statusLabel.text = [NSString stringWithFormat:@"%@ ( %d次 )",NSLocalizedString(@"取消外卖", nil),[[cancelDict objectForKey:@"count"]integerValue]];
                                
                                float statusHeight = [statusLabel adjustLabelHeight];
                                [cell.contentView addSubview:statusLabel];
                                
                                //日期
                                UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY+statusHeight, 425, 15)];
                                dateLabel.backgroundColor = [UIColor clearColor];
                                dateLabel.textAlignment = UITextAlignmentRight;
                                dateLabel.font = [UIFont systemFontOfSize:15];
                                dateLabel.textColor = [UIColor grayColor];
                                
                                NSString *dateStr = [cancelDict objectForKey:@"last"];
                                NSDate *dateTime = [dateStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
                                dateLabel.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"最近一次", nil),[NSString dateToNSString:dateTime withFormat:@"yyyy-MM-dd eee HH:mm"]];
                                
                                [cell.contentView addSubview:dateLabel];
                                
                                originY = originY+statusHeight+35;
                            }
                            
                            //加上一条线
                            if (0 != [finishDict count] || 0 != [cancelDict count])
                            {
                                UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, originY - 15, 428, 1)];
                                lineImageView.backgroundColor = [UIColor lightGrayColor];
                                [cell.contentView addSubview:lineImageView];
                            }
                            //没有外卖记录
                            if (0 == [finishDict count] && 0 == [cancelDict count])
                            {
                                UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(15, originY, 120, 30)];
                                label2.backgroundColor = [UIColor clearColor];
                                label2.textAlignment = UITextAlignmentLeft;
                                label2.font = [UIFont systemFontOfSize:20];
                                label2.textColor = [UIColor grayColor];
                                label2.text = NSLocalizedString(@"暂无", nil);
                                [cell.contentView addSubview:label2];
                            }
                        }
                    }
                    else
                    {
                        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(15, originY, 120, 30)];
                        label2.backgroundColor = [UIColor clearColor];
                        label2.textAlignment = UITextAlignmentLeft;
                        label2.font = [UIFont systemFontOfSize:20];
                        label2.textColor = [UIColor grayColor];
                        label2.text = NSLocalizedString(@"暂无", nil);
                        [cell.contentView addSubview:label2];
                    }
                    break;
                }
            }
            break;
        }
    }
	return cell;
}
 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    switch (orderType)
    {
        case 1:
        {
            /*实际内容 + 渐变的高*/
            rows = 6 + 1 + 1;
            break;
        }
        case 2:
        {
            /*实际内容 + 渐变的高*/
            rows = 6 + 1 + 1;
            break;
        }
        default:
            break;
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    int height = 50;
    switch (orderType)
    {
        case 1:
        {
            switch (row)
            {
                case 0:
                {
                    break;
                }
                case 1:
                {
                    break;
                }
                case 2:
                {
                    break;
                }
                case 3:
                {
                    /*
                    int space = 35;
                    UIView *tempView = [self seatDetailView:row];
                    height = tempView.frame.size.height + space;
                    if (height < 50)
                    {
                        height = 50;
                    }
                     */
                    //暂时隐藏选台
                    height = 0;
                    
                    break;
                }
                case 4:
                {
                    /*
                    UIView *aView = [self dishesDetailView];
                    height = aView.frame.size.height + 42;
                    if (!isOpenDetailDish)
                    {
                        height = 42;
                    }
                     */
                    //暂时隐藏预点菜
                    height = 0;
                    
                    break;
                }
                case 5:
                {
                    //备注
                    NSString *remark = [[NSString stringWithFormat:@"%@", [msgDetailInfo objectForKey:@"remark"]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if ([remark length]>0)
                    {
                        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 315, 30)];
                        label2.numberOfLines = 0;
                        label2.backgroundColor = [UIColor clearColor];
                        label2.textAlignment = UITextAlignmentLeft;
                        label2.font = [UIFont systemFontOfSize:20];
                        label2.textColor = [UIColor grayColor];
                        label2.text = remark;
                        height = [label2 adjustLabelHeight] + 20;
                        //确保高度
                        if (height<50)
                        {
                            height = 50;
                        }
                    }
                    else
                    {
                        //备注为空时，暂时隐藏
                        height = 0;
                    }
                    
                    break;
                }
                case 6:
                {    
                    height = 150;
                    
                    break;
                }
            }
            
            break;
        }
        case 2:
        {
            switch (row)
            {
                case 0:
                {
                    break;
                }
                case 1:
                {
                    break;
                }
                case 2:
                {
                    break;
                }
                case 3:
                {
                    int spaceY = 20;
                    if (0 == deliveryType)
                    {
                        height = [self addAddressToViewWithCustomSpace].frame.size.height + 50;
                        if (height < 50)
                        {
                            height = 50;
                        }
                    }
                    else
                    {
                        height = 0;
                    }
                    height = height + spaceY;
                    
                    break;
                }
                case 4:
                {
                    UIView *aView = [self dishesDetailView];
                    height = aView.frame.size.height + 42;
                    /* 暂时隐藏，因为菜现在一直展开
                    if (!isOpenDetailDish)
                    {
                        height = 42;
                    }
                     */
                    
                    break;
                }
                case 5:
                {
                    //备注
                    NSString *remark = [[NSString stringWithFormat:@"%@", [msgDetailInfo objectForKey:@"remark"]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if ([remark length]>0)
                    {
                        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 355, 30)];
                        label2.numberOfLines = 0;
                        label2.backgroundColor = [UIColor clearColor];
                        label2.textAlignment = UITextAlignmentLeft;
                        label2.font = [UIFont systemFontOfSize:20];
                        label2.textColor = [UIColor grayColor];
                        label2.text = remark;
                        height = [label2 adjustLabelHeight] + 20;
                        //确保高度
                        if (height<50)
                        {
                            height = 50;
                        }
                    }
                    else
                    {
                        //备注为空时，暂时隐藏
                        height = 0;
                    }
                    
                    break;
                }
                case 6:
                {
                    height = 150;
                    break;
                }
            }
            break;
        }
    }
	return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        switch (alertView.tag)
        {
            case 2:
            {
                [self finishedDinner];
                break;
            }
            case 3:
            {
                [self deliveryDinner];
                break;
            }
            case 4:
            {
                [self checkInOrder];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark NumPickerDelegate

-(void)NumPicker:(NumPicker*)picker didPickedNumber:(NSString*)number
{
    [popoverController dismissPopoverAnimated:YES];
    
    int index = picker.tag;
    NSArray *seatListArray = [orderDetailInfo objectForKey:@"seatsList"];
    if ([seatListArray count]>0)
    {
        int orderCapacity = [number intValue];
        if (orderCapacity>0)
        {
            //判断选择的台是否足够容纳订座的人数
            int totalCapacity = 0;
            for (NSDictionary *seat in seatListArray)
            {
                int capacity = [[seat objectForKey:@"maxCapacity"] intValue];
                totalCapacity+=capacity;
            }
            if (orderCapacity>totalCapacity)
            {
                [[DisplayHelper shareDisplayHelper] displayWarningAlert:NSLocalizedString(@"人数与选台：坐不下，请确认", nil) interval:kIntervalTime];
            }
        }
    }
    
    //设置订座的“人数”
    if (index == 2)
    {
        
        [orderDetailInfo setObject:number forKey:@"peopleNum"];
        [detailTableview reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
        
        isEdited = YES;
    }
}


-(void)NumPicker:(NumPicker*)picker didPickedOverflowNumber:(NSString*)number
{
    int index = picker.tag;
    //设置订座的“人数”
    if (index == 1)
    {
        [[DisplayHelper shareDisplayHelper] displayWarningAlert:NSLocalizedString(@"人数范围是1~500", nil) interval:2.5];
    }
}

#pragma mark DeskPickerDelegate
-(void)DeskPickerWithSummary:(DeskPickerWithSummary*)picker didPressedCancelButton:(BOOL)flag
{
    [popoverController dismissPopoverAnimated:YES];
}

-(void)DeskPickerWithSummary:(DeskPickerWithSummary*)picker didPickedDesks:(NSArray*)desks
{
    
}

-(void)DeskPickerWithSummary:(DeskPickerWithSummary*)picker didPickedDesksDetail:(NSArray*)desks
{
    [popoverController dismissPopoverAnimated:YES];
    
    if (desks!=nil && [desks count]>0)
    {
        int orderCapacity = [[orderDetailInfo objectForKey:@"peopleNum"] intValue];
        if (orderCapacity>0)
        {
            //判断选择的台是否足够容纳订座的人数
            int totalCapacity = 0;
            for (NSDictionary *seat in desks)
            {
                int capacity = [[seat objectForKey:@"maxCapacity"] intValue];
                totalCapacity+=capacity;
            }
            if (orderCapacity>totalCapacity)
            {
                [[DisplayHelper shareDisplayHelper] displayWarningAlert:NSLocalizedString(@"人数与选台：坐不下，请确认", nil) interval:2.5];
            }
        }
        [orderDetailInfo setObject:desks forKey:@"seatsList"];
    }
    else
    {
        [orderDetailInfo setObject:[NSArray array] forKey:@"seatsList"];
    }
    [detailTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    isEdited = YES;
}

#pragma mark DateAndTimePickerDelegate
-(void)DateAndTimePicker:(DateAndTimePicker*)picker didPickedDate:(NSDate*)date
{
    //修改订座订单的订座时间或外卖订单的外卖时间
    NSString *mealTimes = [NSString dateToNSString:date withFormat:@"yyyy-MM-dd HH:mm"];
    [orderDetailInfo setObject:mealTimes forKey:@"mealTimes"];
    [detailTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    isEdited = YES;
    [popoverController dismissPopoverAnimated:YES];
}

#pragma mark ReasonViewControllerDelegate

- (void)reasonViewController:(ReasonViewController *)ctrl didDismissView:(BOOL)flag
{
    [self dismissReasonViewController];
}

- (void)reasonViewController:(ReasonViewController *)ctrl submitReason:(NSString *)reasonStr
{
    [self dismissReasonViewController];
    
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:reasonStr,@"message", nil];
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(cancelOrder:) userInfo:info repeats:NO];
}

- (void)dismissReasonViewController
{
    [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
}

#pragma mark DishDetailTitleViewDelegate

- (void)modifyCarryfee:(NSString *)carryfeeStr
{
    [self commitCarryfee:carryfeeStr];
}

#pragma mark JsonPickerDelegate

- (void)updateViewAfterGetNetWorkData:(NSDictionary *)dict
{
    if (0 >= [dict count])
    {
        return;
    }
    msgDetailInfo = [[NSDictionary alloc] initWithDictionary:dict];
    
    if ([delegate respondsToSelector:@selector(OrderMessageDetailViewController:didUpdatedInfo:)])
    {
        [delegate OrderMessageDetailViewController:self didUpdatedInfo:msgDetailInfo];
    }
    //刷新数据
    orderStatus = [[msgDetailInfo objectForKey:@"status"] intValue];
    isEditing = NO;
    [self updateViewAfterData];
    [detailTableview reloadData];
}

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
#ifdef DEBUG
    NSLog(@"===OrderMessageDetailViewController:picker:%d,dict:%@===",picker.tag,dict);
#endif
    //取消订单,确定订单
    if (picker.tag==0 || picker.tag==1)
    {
        int responseStatus = [[dict objectForKey:@"responseStatus"] intValue];
        switch (responseStatus)
        {
                //取消成功
            case 200:
            {
                [self updateViewAfterGetNetWorkData:[dict objectForKey:@"data"]];
                
                break;
            }
            case 206:
            {
                NSString *warnString = [dict objectForKey:@"alertMsg"];
                [[DisplayHelper shareDisplayHelper] displayWarningAlert:warnString interval:kIntervalTime];
                
                [self updateViewAfterGetNetWorkData:[dict objectForKey:@"data"]];
                
                break;
            }
            default:
            {
                NSString *warnString = [dict objectForKey:@"alertMsg"];
                [[DisplayHelper shareDisplayHelper] displayWarningAlert:warnString interval:kIntervalTime];
                
                break;
            }
        }
    }
    
    //客人签到/收、出餐、送餐
    if (picker.tag==2) {
        int responseStatus = [[dict objectForKey:@"responseStatus"] intValue];
        
        switch (responseStatus)
        {
                //签到/签收成功
            case 200:
            {
                [self updateViewAfterGetNetWorkData:[dict objectForKey:@"data"]];
                
                //更新房台信息
                if (1 == orderType)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateDinningTableList object:nil userInfo:nil];
                }
                break;
            }
            case 206:
            {
                NSString *warnString = [dict objectForKey:@"alertMsg"];
                [[DisplayHelper shareDisplayHelper] displayWarningAlert:warnString interval:kIntervalTime];
                
                [self updateViewAfterGetNetWorkData:[dict objectForKey:@"data"]];
                
                //更新房台信息
                if (1 == orderType)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateDinningTableList object:nil userInfo:nil];
                }
                
                break;
            }
            default:
            {
                NSString *warnString = [dict objectForKey:@"alertMsg"];
                [[DisplayHelper shareDisplayHelper] displayWarningAlert:warnString interval:kIntervalTime];
                
                break;
            }
        }
    }
    
    //修改订单信息
    if (picker.tag==3)
    {
        int responseStatus = [[dict objectForKey:@"responseStatus"] intValue];
        switch (responseStatus)
        {
                //200:处理成功
            case 200:
            {
                [self updateViewAfterGetNetWorkData:[dict objectForKey:@"data"]];
                
                break;
            }
            case 204:
            {
                NSString *warnString = [dict objectForKey:@"alertMsg"];
                [[DisplayHelper shareDisplayHelper] displayWarningAlert:warnString interval:kIntervalTime];
                
                [self updateViewAfterGetNetWorkData:[dict objectForKey:@"data"]];
                
                break;
            }
            default:
            {
                NSString *warnString = [dict objectForKey:@"alertMsg"];
                [[DisplayHelper shareDisplayHelper] displayWarningAlert:warnString interval:kIntervalTime];
                
                break;
            }
        }
    }
    
    //修改订单为“己查看”
    if (picker.tag==4) {
        int responseStatus = [[dict objectForKey:@"responseStatus"] intValue];
        switch (responseStatus) {
                //200:处理成功
            case 200:{
                //更新数据
                NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:msgDetailInfo];
                //标记为已读
                [tmp setObject:[NSNumber numberWithInt:1] forKey:@"isChecked"];
                msgDetailInfo = [[NSDictionary alloc] initWithDictionary:tmp];
                
                //刷新数据
                if ([delegate respondsToSelector:@selector(OrderMessageDetailViewController:didChecked:newOrderStatus:)]) {
                    [delegate OrderMessageDetailViewController:self didChecked:YES newOrderStatus:orderStatus];
                }
                break;
            }
            default:
            {
                NSString *warnString = [dict objectForKey:@"data"];
                [[DisplayHelper shareDisplayHelper] displayWarningAlert:warnString interval:kIntervalTime];
                
                break;
            }
        }
    }
    
    //修改配送费信息
    if (kJsonPickerSixthTag == picker.tag)
    {
        int responseStatus = [[dict objectForKey:@"responseStatus"] intValue];
        switch (responseStatus)
        {
                //200:处理成功
            case 200:
            {
                [self updateViewAfterGetNetWorkData:[dict objectForKey:@"data"]];
                
                break;
            }
            case 401:
            {
                NSString *warnString = [dict objectForKey:@"alertMsg"];
                [[DisplayHelper shareDisplayHelper] displayWarningAlert:warnString interval:kIntervalTime];
                
                [self updateViewAfterGetNetWorkData:[dict objectForKey:@"data"]];
                
                break;
            }
            default:
            {
                [[DisplayHelper shareDisplayHelper] displayWarningAlert:[dict objectForKey:@"alertMsg"] interval:kIntervalTime];
                
                break;
            }
        }
    }
}

// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error{}
// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error{}

@end
