//
//  ApplyAccountViewController.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ApplyAccountViewController.h"
#import "NoticeViewController.h"
#import "Constants.h"
#import "OfflineManager.h"
#import "MainViewController.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "NsstringAddOn.h"
#import "UITextFieldAddition.h"

#define kQuitAlertViewTag 1100

@interface ApplyAccountViewController ()
{
    int isOpenBooking;//是否开通在线订座，0表示没有开通，1表示开通
    int isOpenTakeaway;
    int isOpenTakeoutBySelfhelp;
    int isOpenMenu;
    int isOpenQueue;
    int isOpenCallService;
    int isOpenDiningtable;
    JsonPicker *jsonPicker;
    MBProgressHUD *promptHUD;
    OfflineManager *offlineMgr;
}

- (void)registerForNotifications;
- (void)unregisterFromNotifications;
- (IBAction)cancelApplyButtonPressed:(id)sender;
- (IBAction)submitButtonPressed:(id)sender;
- (IBAction)nextByTextField:(UITextField*)textField;
- (IBAction)infoButtonPressed:(UIButton *)sender;
- (void)addGestureRecognizer;
- (void)registerAccount:(NSDictionary *)dict;
- (BOOL)isValidateEmail:(NSString *)email;
- (void)goToMainView;

@end

@implementation ApplyAccountViewController

@synthesize restNameTextfield;
@synthesize restPhoneNumTextfield;
@synthesize restPhoneNumTextfield2;
@synthesize restContactTextfield;
@synthesize restAddressTextfield;
@synthesize restEmailTextfield;
@synthesize restScrollview;
@synthesize applyBgImageView;
@synthesize contextBgImageView;
@synthesize logoImageView;
@synthesize nameImageView;
@synthesize phoneNumImageView;
@synthesize contactImageView;
@synthesize addressImageView;
@synthesize submitButton;
@synthesize cancelButton;
@synthesize infoButton;
@synthesize nameLineImageView;
@synthesize phoneNumLineImageView;
@synthesize contactLineImageView;
@synthesize addressLineImageView;
@synthesize emailImageView;
@synthesize emailLineImageView;
@synthesize bookingImageView;
@synthesize takeawayImageView;
@synthesize queueImageView;
@synthesize callServiceImageView;
@synthesize openFunctionImageView;
@synthesize menuImageView;
@synthesize bookingLabel;
@synthesize takeawayLabel;
@synthesize queueLabel;
@synthesize menuLabel;
@synthesize callServiceLabel;
@synthesize popoverController;

#pragma mark -
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
    
    // 添加关闭按钮
    [self.restPhoneNumTextfield bindCloseButton];
    [self.restPhoneNumTextfield2 bindCloseButton];
    
    [self registerForNotifications];
    [self addGestureRecognizer];
    [self addPictureToView];
    [self addLocalizedString];
    
    isOpenDiningtable = 0;
    isOpenBooking = 0;
    isOpenTakeaway = 0;
    isOpenTakeoutBySelfhelp = 0;
    isOpenMenu = 0;
    isOpenQueue = 0;
    isOpenCallService = 0;
    
    offlineMgr = [OfflineManager sharedOfflineManager];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    [self unregisterFromNotifications];
    
#ifdef DEBUG
    NSLog(@"===ApplyAccountViewController,dealloc===");
#endif
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark -
#pragma mark PRIVATE METHODS

- (void)addLocalizedString
{
    self.diningTableLabel.text = kLoc(@"take_seat_and_order_dishes");
    self.takeawayLabel.text = kLoc(@"deliver_meal_and_takeout");
    self.takeaway2Label.text = kLoc(@"take_meal_and_takeout");
    self.bookingLabel.text = kLoc(@"online_takeout");
    self.menuLabel.text = kLoc(@"show_menus");
    self.queueLabel.text = kLoc(@"queue_with_phone");
    self.callServiceLabel.text = kLoc(@"call_serivce");
}

- (void)addPictureToView
{
    applyBgImageView.image = [UIImage imageFromMainBundleFile:@"login_background.png"];
    contextBgImageView.image = [UIImage imageFromMainBundleFile:@"Accont_applyBg.png"];
    logoImageView.image = [UIImage imageFromMainBundleFile:@"Account_logo.png"];
    //繁体
//    if (![kCurrentLanguageOfDevice isEqualToString:kChineseFamiliarStyle])
//    {
//        self.nameImageView.image = [UIImage imageFromMainBundleFile:@"Account_Name_Traditional.png"];
//        self.phoneNumImageView.image = [UIImage imageFromMainBundleFile:@"Account_PhoneNum_Traditional.png"];
//        self.contactImageView.image = [UIImage imageFromMainBundleFile:@"Acount_Contact_Traditional.png"];
//        self.addressImageView.image = [UIImage imageFromMainBundleFile:@"Account_Address_Traditional.png"];
//        self.emailImageView.image = [UIImage imageFromMainBundleFile:@"Account_email_Traditional.png"];
//        self.openFunctionImageView.image = [UIImage imageFromMainBundleFile:@"Account_OpenFunction_Traditional.png"];
//        logoImageView.image = [UIImage imageFromMainBundleFile:@"Account_logo_Traditional.png"];
//    }
    
    self.nameImageView.image = kLocImage(@"Account_Name.png");
    self.phoneNumImageView.image = kLocImage(@"Account_PhoneNum.png");
    self.contactImageView.image = kLocImage(@"Acount_Contact.png");
    self.addressImageView.image = kLocImage(@"Account_Address.png");
    self.emailImageView.image = kLocImage(@"Account_email.png");
    self.openFunctionImageView.image = kLocImage(@"Account_OpenFunction.png");
    logoImageView.image = kLocImage(@"Account_logo.png");
    [self.cancelButton setBackgroundImage:kLocImage(@"cancelBtn_Normal.png") forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:kLocImage(@"cancelBtn_Selected.png") forState:UIControlStateSelected];
    [self.submitButton setBackgroundImage:kLocImage(@"submitBtn_Normal.png") forState:UIControlStateNormal];
    [self.submitButton setBackgroundImage:kLocImage(@"submitBtn_Selected.png") forState:UIControlStateSelected];
}

//登录成功后跳转至主页面
-(void)goToMainView
{
    MainViewController *mainViewController = [[MainViewController alloc] init];
    [self.navigationController pushViewController:mainViewController animated:YES];
}

//利用正则表达式验证格式是否正确
-(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//“取消申请”按钮
-(IBAction)cancelApplyButtonPressed:(id)sender
{
    if (![NSString strIsEmpty:[NSString getStrWithoutWhitespace:restNameTextfield.text]] || ![NSString strIsEmpty:[NSString getStrWithoutWhitespace:restPhoneNumTextfield.text]] || ![NSString strIsEmpty:[NSString getStrWithoutWhitespace:restPhoneNumTextfield2.text]] || ![NSString strIsEmpty:[NSString getStrWithoutWhitespace:restContactTextfield.text]] || ![NSString strIsEmpty:[NSString getStrWithoutWhitespace:restAddressTextfield.text]]>0 || ![NSString strIsEmpty:[NSString getStrWithoutWhitespace:restEmailTextfield.text]] || (1 == isOpenDiningtable) || (1 == isOpenBooking) || (1 == isOpenTakeaway) || (1 == isOpenMenu) || (1 == isOpenQueue) || (1 == isOpenCallService) || (1 == isOpenTakeoutBySelfhelp))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kLoc(@"cancel_will_clear_current_contents_confirmed_to_leave") delegate:self cancelButtonTitle:kLoc(@"cancel") otherButtonTitles:kLoc(@"confirm"), nil];
        alert.tag = kQuitAlertViewTag;
        [alert show];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(IBAction)submitButtonPressed:(id)sender{
    
    //收起键盘
    [restNameTextfield resignFirstResponder];
    [restPhoneNumTextfield resignFirstResponder];
    [restPhoneNumTextfield2 resignFirstResponder];
    [restContactTextfield resignFirstResponder];
    [restAddressTextfield resignFirstResponder];
    [restEmailTextfield resignFirstResponder];
    
    //判断餐厅名称(必须为6位或以上)
    NSString *restName = [restNameTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([restName length]==0) {
        [PSAlertView showWithMessage:kLoc(@"please_enter_the_full_name_of_the_restaurant")];
        return;
    }
    
    //判断餐厅的电话(必须为6位或以上)
    NSString *restPhoneNum = [restPhoneNumTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *restPhoneNum2 = [restPhoneNumTextfield2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    int phoneNumLength = [restPhoneNum length] + [restPhoneNum2 length];
    if (0 == [restPhoneNum length])
    {
        restPhoneNum = @"";
    }
    if (0 == [restPhoneNum2 length])
    {
        restPhoneNum2 = @"";
    }
    if (0 == phoneNumLength) {
        [PSAlertView showWithMessage:kLoc(@"please_enter_a_full_restaurant_phone_number")];
        return;
    }
    
    //判断餐厅的联系人(必须为6位或以上)
    NSString *restContact = [restContactTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([restContact length]==0) {
        [PSAlertView showWithMessage:kLoc(@"please_enter_a_full_restaurant_contact")];
        return;
    }
    
    //判断餐厅的地址(必须为6位或以上)
    NSString *restAddress = [restAddressTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([restAddress length]==0) {
        [PSAlertView showWithMessage:kLoc(@"please_enter_the_complete_address_of_the_restaurant")];
        return;
    }
    //判断邮箱
    NSString *restEmail = [restEmailTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([restEmail length]==0) {
        [PSAlertView showWithMessage:kLoc(@"please_enter_your_full_email_address")];
        return;
    }
    if (NO == [self isValidateEmail:restEmail]) {
        [PSAlertView showWithMessage:kLoc(@"please_enter_a_valid_email_address")];
        return;
    }
    
    //判断是否至少开通了一个权限
    if (0 == isOpenDiningtable && 0 == isOpenBooking && 0 == isOpenTakeaway  && 0 == isOpenTakeoutBySelfhelp && 0 == isOpenCallService && 0 == isOpenQueue && 0 == isOpenMenu) {
        [PSAlertView showWithMessage:kLoc(@"you_must_open_one_function_at_least")];
        return;
    }
    
    NSMutableDictionary *postDataDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    [postDataDict setObject:restName forKey:@"corpName"];
    [postDataDict setObject:[NSString stringWithFormat:@"%@%@",restPhoneNum,restPhoneNum2] forKey:@"phone"];
    [postDataDict setObject:restContact forKey:@"linkMan"];
    [postDataDict setObject:restAddress forKey:@"address"];
    [postDataDict setObject:restEmail forKey:@"email"];
    [postDataDict setObject:[NSNumber numberWithInt:isOpenDiningtable] forKey:@"isOpenDiningtable"];
    [postDataDict setObject:[NSNumber numberWithInt:isOpenBooking] forKey:@"isOpenBooking"];
    [postDataDict setObject:[NSNumber numberWithInt:isOpenTakeaway]  forKey:@"isOpenTakeaway"];
    [postDataDict setObject:[NSNumber numberWithInt:isOpenTakeoutBySelfhelp]  forKey:@"isOpenTakeoutBySelfhelp"];
    [postDataDict setObject:[NSNumber numberWithInt:isOpenQueue]  forKey:@"isOpenQueue"];
    [postDataDict setObject:[NSNumber numberWithInt:isOpenMenu]  forKey:@"isOpenCookbook"];
    [postDataDict setObject:[NSNumber numberWithInt:isOpenCallService]  forKey:@"isOpenCallService"];
    
    //提交注册信息
    [self registerAccount:postDataDict];
}

-(IBAction)nextByTextField:(UITextField*)textField
{
    if (textField==restNameTextfield) {
        [restPhoneNumTextfield becomeFirstResponder];
        return;
    }
    
    if (textField==restPhoneNumTextfield) {
        [restPhoneNumTextfield2 becomeFirstResponder];
        return;
    }
    
    if (textField==restPhoneNumTextfield2) {
        [restContactTextfield becomeFirstResponder];
        return;
    }
    
    if (textField==restContactTextfield) {
        [restAddressTextfield becomeFirstResponder];
        return;
    }
    
    if (textField==restAddressTextfield) {
        [restEmailTextfield becomeFirstResponder];
        return;
    }
    if (textField==restEmailTextfield) {
        [restScrollview setContentOffset:CGPointZero animated:YES];
        [restEmailTextfield resignFirstResponder];
        return;
    }
}

- (IBAction)infoButtonPressed:(UIButton *)sender
{
    if (nil == self.popoverController)
    {
        NoticeViewController *contentViewController = [[NoticeViewController alloc] initWithNibName:@"NoticeViewController" bundle:nil];
        
        self.popoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
        
        if ([self.popoverController respondsToSelector:@selector(setContainerViewProperties:)])
        {
            [self.popoverController setContainerViewProperties:[self improvedContainerViewProperties]];
        }
        
        self.popoverController.delegate = self;
        self.popoverController.passthroughViews = [NSArray arrayWithObject:sender];
    }
    CGRect rect = CGRectMake(sender.frame.origin.x + 10, sender.frame.origin.y + (kSystemVersionIsIOS7?195:180), sender.frame.size.width, sender.frame.size.height);
    // 设置父视图，防止变形，更可以缩放视图
    self.popoverController.parentView = self.view;
    [self.popoverController dismissPopoverAnimated:YES];
    [self.popoverController presentPopoverFromRect:rect
                                            inView:self.view
                          permittedArrowDirections:UIPopoverArrowDirectionRight
                                          animated:YES];
}

#pragma mark GestureRecognizer

- (void)addGestureRecognizer
{
    UITapGestureRecognizer *diningTableGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    diningTableGesture.numberOfTouchesRequired = 1; //手指数
    diningTableGesture.numberOfTapsRequired = 1; //tap次数
    
    UITapGestureRecognizer *takeawayImageViewOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    takeawayImageViewOne.numberOfTouchesRequired = 1; //手指数
    takeawayImageViewOne.numberOfTapsRequired = 1; //tap次数
    
    UITapGestureRecognizer *takeaway2ImageViewOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    takeaway2ImageViewOne.numberOfTouchesRequired = 1; //手指数
    takeaway2ImageViewOne.numberOfTapsRequired = 1; //tap次数
    
    UITapGestureRecognizer *bookingImageViewOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    bookingImageViewOne.numberOfTouchesRequired = 1; //手指数
    bookingImageViewOne.numberOfTapsRequired = 1; //tap次数
    
    UITapGestureRecognizer *menuImageViewOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    menuImageViewOne.numberOfTouchesRequired = 1; //手指数
    menuImageViewOne.numberOfTapsRequired = 1; //tap次数
    
    UITapGestureRecognizer *queueImageViewOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    queueImageViewOne.numberOfTouchesRequired = 1; //手指数
    queueImageViewOne.numberOfTapsRequired = 1; //tap次数
    
    UITapGestureRecognizer *callServiceImageViewOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    callServiceImageViewOne.numberOfTouchesRequired = 1; //手指数
    callServiceImageViewOne.numberOfTapsRequired = 1; //tap次数
    
    [self.diningTableImageView addGestureRecognizer:diningTableGesture];
    [takeawayImageView addGestureRecognizer:takeawayImageViewOne];
    [self.takeaway2ImageView addGestureRecognizer:takeaway2ImageViewOne];
    [bookingImageView addGestureRecognizer:bookingImageViewOne];
    [menuImageView addGestureRecognizer:menuImageViewOne];
    [queueImageView addGestureRecognizer:queueImageViewOne];
    [callServiceImageView addGestureRecognizer:callServiceImageViewOne];
}

//处理单指事件
- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender
{
    if (sender.numberOfTapsRequired == 1)
    {
        NSString *path1 = @"";//[[NSBundle mainBundle]pathForResource:@"unOpenFunctionBg" ofType:@"png"];
        NSString *path2 = [[NSBundle mainBundle]pathForResource:@"openFunctionBg" ofType:@"png"];
        UIColor *color1 = [UIColor colorWithRed:245.0/255.0 green:143.0/255.0 blue:63.0/255.0 alpha:1.0];
        UIColor *color2 = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:254.0/255.0 alpha:1.0];
        
        switch (sender.view.tag)
        {
            //开台点菜
            case 1:
            {
                if (1 == isOpenDiningtable)
                {
                    isOpenDiningtable = 0;
                    self.diningTableImageView.image = [UIImage imageWithContentsOfFile:path1];
                    self.diningTableLabel.textColor = color1;
                }
                else
                {
                    isOpenDiningtable = 1;
                    self.diningTableImageView.image = [UIImage imageWithContentsOfFile:path2];
                    self.diningTableLabel.textColor = color2;
                    /*开台点菜不可以单独存在，一定要和菜牌在一起，但是菜牌可以单独存在*/
                    if (0 == isOpenMenu)
                    {
                        isOpenMenu = 1;
                        menuImageView.image = [UIImage imageWithContentsOfFile:path2];
                        menuLabel.textColor = color2;
                    }
                }
                break;
            }
                
                //送餐外卖
            case 2:
            {
                if (1 == isOpenTakeaway)
                {
                    isOpenTakeaway = 0;
                    takeawayImageView.image = [UIImage imageWithContentsOfFile:path1];
                    takeawayLabel.textColor = color1;
                }
                else
                {
                    isOpenTakeaway = 1;
                    takeawayImageView.image = [UIImage imageWithContentsOfFile:path2];
                    takeawayLabel.textColor = color2;
                    /*外卖不可以单独存在，一定要和菜牌在一起，但是菜牌可以单独存在*/
                    if (0 == isOpenMenu)
                    {
                        isOpenMenu = 1;
                        menuImageView.image = [UIImage imageWithContentsOfFile:path2];
                        menuLabel.textColor = color2;
                    }
                }
                break;
            }
                //自取外卖
            case 3:
            {
                if (1 == isOpenTakeoutBySelfhelp)
                {
                    isOpenTakeoutBySelfhelp = 0;
                    self.takeaway2ImageView.image = [UIImage imageWithContentsOfFile:path1];
                    self.takeaway2Label.textColor = color1;
                }
                else
                {
                    isOpenTakeoutBySelfhelp = 1;
                    self.takeaway2ImageView.image = [UIImage imageWithContentsOfFile:path2];
                    self.takeaway2Label.textColor = color2;
                    /*外卖不可以单独存在，一定要和菜牌在一起，但是菜牌可以单独存在*/
                    if (0 == isOpenMenu)
                    {
                        isOpenMenu = 1;
                        menuImageView.image = [UIImage imageWithContentsOfFile:path2];
                        menuLabel.textColor = color2;
                    }
                }
                break;
            }
                //在线订座
            case 4:
            {
                if (1 == isOpenBooking)
                {
                    isOpenBooking = 0;
                    bookingImageView.image = [UIImage imageWithContentsOfFile:path1];
                    bookingLabel.textColor = color1;
                }
                else
                {
                    isOpenBooking = 1;
                    bookingImageView.image = [UIImage imageWithContentsOfFile:path2];
                    bookingLabel.textColor = color2;
                }
                break;
            }
                //菜牌展示
            case 5:
            {
                if (1 == isOpenMenu)
                {
                    isOpenMenu = 0;
                    menuImageView.image = [UIImage imageWithContentsOfFile:path1];
                    menuLabel.textColor = color1;
                    /*外卖不可以单独存在，一定要和菜牌在一起，但是菜牌可以单独存在*/
                    if (1 == isOpenDiningtable)
                    {
                        isOpenDiningtable = 0;
                        self.diningTableImageView.image = [UIImage imageWithContentsOfFile:path1];
                        self.diningTableLabel.textColor = color1;
                    }
                    if (1 == isOpenTakeaway)
                    {
                        isOpenTakeaway = 0;
                        takeawayImageView.image = [UIImage imageWithContentsOfFile:path1];
                        takeawayLabel.textColor = color1;
                    }
                    if (1 == isOpenTakeoutBySelfhelp)
                    {
                        isOpenTakeoutBySelfhelp = 0;
                        self.takeaway2ImageView.image = [UIImage imageWithContentsOfFile:path1];
                        self.takeaway2Label.textColor = color1;
                    }
                }
                else
                {
                    isOpenMenu = 1;
                    menuImageView.image = [UIImage imageWithContentsOfFile:path2];
                    menuLabel.textColor = color2;
                }
                break;
            }
                //手机排队
            case 6:
            {
                if (1 == isOpenQueue)
                {
                    isOpenQueue = 0;
                    queueImageView.image = [UIImage imageWithContentsOfFile:path1];
                    queueLabel.textColor = color1;
                }
                else
                {
                    isOpenQueue = 1;
                    queueImageView.image = [UIImage imageWithContentsOfFile:path2];
                    queueLabel.textColor = color2;
                }
                break;
            }
                //呼叫服务
            case 7:
            {
                if (1 == isOpenCallService)
                {
                    isOpenCallService = 0;
                    callServiceImageView.image = [UIImage imageWithContentsOfFile:path1];
                    callServiceLabel.textColor = color1;
                }
                else
                {
                    isOpenCallService = 1;
                    callServiceImageView.image = [UIImage imageWithContentsOfFile:path2];
                    callServiceLabel.textColor = color2;
                    
                    // 开台点菜要关联
                    isOpenDiningtable = 1;
                    self.diningTableImageView.image = [UIImage imageWithContentsOfFile:path2];
                    self.diningTableLabel.textColor = color2;
                    /*开台点菜不可以单独存在，一定要和菜牌在一起，但是菜牌可以单独存在*/
                    if (0 == isOpenMenu)
                    {
                        isOpenMenu = 1;
                        menuImageView.image = [UIImage imageWithContentsOfFile:path2];
                        menuLabel.textColor = color2;
                    }
                }
                break;
            }
        }
    }
}

#pragma mark Notifications

- (void)registerForNotifications {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)unregisterFromNotifications {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification*)sender{
    //CGSize kbSize = [[sender.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到键盘的高度
    
    //float keyboardHeight = kbSize.height;
    
    //[restTableview setContentOffset:CGPointMake(0, keyboardHeight-250) animated:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification{
    [restScrollview setContentOffset:CGPointZero animated:YES];
}

- (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
	
	WEPopoverContainerViewProperties *props = [WEPopoverContainerViewProperties alloc];
	NSString *bgImageName = nil;
	CGFloat bgMargin = 0.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
	
	//bgImageName = @"popoverBg.png";
	
	// These constants are determined by the popoverBg.png image file and are image dependent
	bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13
	bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
	
	props.leftBgMargin = bgMargin;
	props.rightBgMargin = bgMargin;
	props.topBgMargin = bgMargin;
	props.bottomBgMargin = bgMargin;
	props.leftBgCapSize = bgCapSize;
	props.topBgCapSize = bgCapSize;
	props.bgImageName = bgImageName;
	props.leftContentMargin = contentMargin;
	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
	props.topContentMargin = contentMargin;
	props.bottomContentMargin = contentMargin;
	
	props.arrowMargin = 4.0;
	/*
	props.upArrowImageName = @"popoverArrowUp.png";
	props.downArrowImageName = @"popoverArrowDown.png";
	props.leftArrowImageName = @"popoverArrowLeft.png";
	props.rightArrowImageName = @"popoverArrowRight.png";
    */
	return props;
}

#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController
{
	//Safe to release the popover here
	//self.popoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController
{
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}

#pragma mark network

//注册帐号
- (void)registerAccount:(NSDictionary *)dict
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"submitting_register_info_please_wait");
    jsonPicker.loadedSuccessfulMessage = kLoc(@"register_succeed");
    [jsonPicker postData:dict withBaseRequest:@"auth/register"];
}

#pragma mark UIAlertviewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        //“取消申请”按钮
        case kQuitAlertViewTag:
        {
            if (buttonIndex==1)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        }
        //注册成功
        case 1:
        {
            if (buttonIndex==0)
            {
                [self goToMainView];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        }
        //注册成功，但是待审核
        case 2:
        {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        //注册失败
        case 3:
        {
            if (buttonIndex==0)
            {
                [self submitButtonPressed:nil];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark UITextviewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView{
    
}


#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    infoButton.userInteractionEnabled = NO;
    
    if (textField==restNameTextfield) {
        [restScrollview setContentOffset:CGPointMake(0, 220) animated:YES];
        return;
    }
    
    if (textField==restPhoneNumTextfield) {
        [restScrollview setContentOffset:CGPointMake(0, 220) animated:YES];
        return;
    }
    if (textField==restPhoneNumTextfield2) {
        [restScrollview setContentOffset:CGPointMake(0, 220) animated:YES];
        return;
    }
    
    if (textField==restContactTextfield) {
        [restScrollview setContentOffset:CGPointMake(0, 220) animated:YES];
        return;
    }
    
    if (textField==restAddressTextfield) {
        [restScrollview setContentOffset:CGPointMake(0, 220) animated:YES];
        return;
    }
    
    if (textField==restEmailTextfield) {
        [restScrollview setContentOffset:CGPointMake(0, 220) animated:YES];
        return;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    infoButton.userInteractionEnabled = YES;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    //[restTableview setContentOffset:CGPointZero animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField==restPhoneNumTextfield)
    {
        if (range.location >= 4)
        {
            [restPhoneNumTextfield2 becomeFirstResponder];
            return NO;
        }
        else
        {
            return YES;
        }
    }
    
    if (textField==restPhoneNumTextfield2)
    {
        if (range.location >= 11)
        {
            [restContactTextfield becomeFirstResponder];
            return NO;
        }
        else
        {
            return YES;
        }
        /*
        if (0 == [restPhoneNumTextfield.text length])
        {
            if (range.location >= 11)
            {
                return NO;
            }
            else
            {
                return YES;
            }
        }
        else
        {
            
            if (range.location >= 11 - [restPhoneNumTextfield.text length])
            {
                return NO;
            }
            else
            {
                return YES;
            }
        }
         */
    }
     
    return YES;
}

#pragma mark JsonPickerDelegate
-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    int responseStatus = [[dict objectForKey:@"status"] intValue];
    if (picker.tag==0)
    {
        switch (responseStatus)
        {
            //提交申请成功
            case 200:
            {
                //登录成功，保存OAuthToken
                AccountManager *accountMgr = [AccountManager sharedAccountManager];
                NSString *oAuthToken = [[dict objectForKey:@"data"] objectForKey:@"oauthToken"];
                [accountMgr loginAccountWithToken:oAuthToken];
                
                //保存数据
                if (!offlineMgr)
                {
                    offlineMgr = [OfflineManager sharedOfflineManager];
                }
                //保存营业时间
                [offlineMgr saveOfflineBusinessHours:[[dict objectForKey:@"data"]objectForKey:@"businessHours"]];
                
                //保存菜单数据
                NSDictionary *cookbookOptions = [[dict objectForKey:@"data"] objectForKey:@"cookbookOptions"];
                NSArray *cookbookList = [cookbookOptions objectForKey:@"dataList"];
                NSString *cookbookUpdatedDate = [cookbookOptions objectForKey:@"lastUpdate"];
                [offlineMgr saveOfflineDishes:cookbookList withUpdatedDate:cookbookUpdatedDate];
                
                //保存房台数据
                NSDictionary *dtOptions = [[dict objectForKey:@"data"] objectForKey:@"dtOptions"];
                NSArray *dtList = [dtOptions objectForKey:@"dataList"];
                NSString *dtUpdatedDate = [dtOptions objectForKey:@"lastUpdate"];
                [offlineMgr saveOfflineDinningTable:dtList withUpdatedDate:dtUpdatedDate];
                
                
                //保存规则设置的开放期限列表
                NSArray *timeLimitOptions = [[dict objectForKey:@"data"] objectForKey:@"timeLimitOptions"];
                [offlineMgr saveRuleLimitTitles:timeLimitOptions];
                
                //用户开通了哪些权限，保存，以便控制主页中菜单按钮的显示
                NSArray *authorityArray = [[dict objectForKey:@"data"] objectForKey:@"menu"];
                [offlineMgr saveAccountAuthority:authorityArray];
                
                //这里可以不下载图片，因为刚注册的时候是没有房台数据的
                //[self downloadDishPhotos:cookbookList];
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[dict objectForKey:@"desc"] message:nil delegate:self cancelButtonTitle:kLoc(@"login_now") otherButtonTitles:kLoc(@"back"),nil];
                alertView.tag = 1;
                [alertView show];
                
                break;
            }
            case 220:
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[dict objectForKey:@"desc"]
                                                                   message:nil
                                                                  delegate:self
                                                         cancelButtonTitle:kLoc(@"confirm")
                                                         otherButtonTitles:nil];
                alertView.tag = 2;
                [alertView show];
                break;
            }
            case 250:
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[dict objectForKey:@"desc"]
                                                                   message:nil
                                                                  delegate:self
                                                         cancelButtonTitle:kLoc(@"retry")
                                                         otherButtonTitles:kLoc(@"cancel"), nil];
                alertView.tag = 3;
                [alertView show];
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
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
