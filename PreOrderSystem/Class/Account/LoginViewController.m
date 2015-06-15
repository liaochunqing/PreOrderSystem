//
//  LoginViewController.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "ApplyAccountViewController.h"
#import "MainViewController.h"
#import "JsonPicker.h"
#import "PSAlertView.h"
#import "OfflineManager.h"
#import "DataDownloader.h"
#include "Constants.h"
#import "UIImage+imageWithContentsOfFile.h"

@interface LoginViewController (Private)
- (void)registerForNotifications;
- (void)unregisterFromNotifications;
-(IBAction)applyForBusinessAccountButtonPressed:(id)sender;
-(IBAction)loginAccountButtonPressed:(id)sender;
//登录帐号(通过oAuthToken)
-(void)loginAccountWithOauth;
-(IBAction)nextByTextField:(UITextField*)textField;
- (void)whenShowApplyBtn;

@end

@implementation LoginViewController
@synthesize clearButton;
@synthesize accountTextfield;
@synthesize passwordTextfield;
@synthesize loginScrollview;
@synthesize backGroundImageView;
@synthesize contextImageView;
@synthesize logoImageView;
@synthesize accountImageView;
@synthesize passwordImageView;
@synthesize accountLineImageView;
@synthesize passwordLineImageView;
@synthesize applyBtn;


#pragma mark -
#pragma mark LIFE CYCLE
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
    [self addPictureToView];
    [self registerForNotifications];
    [self whetherWarnBeforeLogin];
    [self clearBadge];
    [self whenShowApplyBtn];
    
    /* 模拟看内存警告时是否有问题
     [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(didReceiveMemoryWarning) userInfo:nil repeats:YES];
    */
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self unregisterFromNotifications];
    jsonPicker = nil;
    offlineMgr = nil;
    HUD = nil;
    downloadingPicsArray = nil;
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

-(void)dealloc
{
    [self unregisterFromNotifications];
}

#pragma mark PRIVATE METHODS
- (void)registerForNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)unregisterFromNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

//存储空间不足时提醒，没有则执行登录操作
- (void)whetherWarnBeforeLogin
{
    if (!offlineMgr)
    {
        offlineMgr = [OfflineManager sharedOfflineManager];
    }
    float freeSpace = [offlineMgr getFreeDiskspace];
    //判断是否清除过缓存
    NSString *lastTimeString = [[NSUserDefaults standardUserDefaults]objectForKey:kOnedayclearData];//@"2012-11-15 12:10:50";
    int oneDay = 0;
    if ([lastTimeString length] != 0)
    {
        oneDay = [self getIntervalDayByDate:lastTimeString];
    }
    else
    {
        oneDay = 1;
    }
    if (freeSpace < 200 && oneDay >= 1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:kLoc(@"the_remaining_storage_space_is_less_than_200m") delegate:self cancelButtonTitle:kLoc(@"next_time") otherButtonTitles:kLoc(@"clear_image_cache"),nil];
        alert.tag = 1;
        [alert show];
    }
    else
    {
        [self isLoginedOfAccount];
    }
}

- (void)addPictureToView
{
    backGroundImageView.image = [UIImage imageFromMainBundleFile:@"login_background.png"];
    logoImageView.image = [UIImage imageFromMainBundleFile:@"Account_logo.png"];
    contextImageView.image = [UIImage imageFromMainBundleFile:@"Accont_loginBg.png"];
    
    //繁体
//    if (![kCurrentLanguageOfDevice isEqualToString:kChineseFamiliarStyle])
//    {
//        self.accountImageView.image = [UIImage imageFromMainBundleFile:@"Account_loginAccount_Traditional.png"];
//        self.passwordImageView.image = [UIImage imageFromMainBundleFile:@"Accont_loginPassword_Traditional.png"];
//        [self.applyBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"account_applyBtnBg_Traditional.png"] forState:UIControlStateNormal];
//        [self.loginButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"Account_loginBtnBg_Traditional.png"] forState:UIControlStateNormal];
//        logoImageView.image = [UIImage imageFromMainBundleFile:@"Account_logo_Traditional.png"];
//    }
    
    self.accountImageView.image = kLocImage(@"Account_loginAccount.png");
    self.passwordImageView.image = kLocImage(@"Accont_loginPassword.png");
    [self.applyBtn setBackgroundImage:kLocImage(@"account_applyBtnBg.png") forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:kLocImage(@"Account_loginBtnBg.png") forState:UIControlStateNormal];
    logoImageView.image = kLocImage(@"Account_logo.png");
}

-(IBAction)applyForBusinessAccountButtonPressed:(id)sender
{
    ApplyAccountViewController *applyAccountCtrl = [[ApplyAccountViewController alloc] initWithNibName:@"ApplyAccountViewController" bundle:nil];
    [self.navigationController pushViewController:applyAccountCtrl animated:YES];
}

//清空图片
- (IBAction)clearBtnClick:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:kLoc(@"are_you_sure_to_clear_cached_images") delegate:self cancelButtonTitle:kLoc(@"cancel") otherButtonTitles:kLoc(@"confirm"),nil];
    alert.tag = 0;
    [alert show];
}

//登录成功后跳转至房台页面
-(void)goToMainView
{
    MainViewController *mainViewController = [[MainViewController alloc] init];
    [self.navigationController pushViewController:mainViewController animated:YES];
}

-(IBAction)nextByTextField:(UITextField*)textField
{
    if (textField==accountTextfield)
    {
        [passwordTextfield becomeFirstResponder];
        return;
    }
    
    if (textField==passwordTextfield)
    {
        [passwordTextfield resignFirstResponder];
        return;
    }
}

//badge归零
-(void)clearBadge
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)whenShowApplyBtn
{
    //发布时间
    NSString *lastTimeString = @"2014-06-16 18:00:00";
    int oneDay = 0;
    oneDay = [self getIntervalDayByDate:lastTimeString];
    if (10 <= oneDay)
    {
        applyBtn.hidden = NO;
    }
    else
    {
        applyBtn.hidden = YES;
    }
}

-(void)downloadNextPhoto
{
    //图片下载采用单线程
    for (int i=0; i<[downloadingPicsArray count];i++)
    {
        NSString *dishPic = [downloadingPicsArray objectAtIndex:i];
        if (![offlineMgr isOfflinePhotoExistWithFileName:[dishPic lastPathComponent]])
        {
            DataDownloader *downloader = [[DataDownloader alloc] init];
            downloader.delegate = self;
            [downloader parseWithURL:dishPic type:DataDownloaderTypePic];
            break;
        }
        else
        {
            [downloadingPicsArray removeObjectAtIndex:i];
        }
    }
    
    
    //下载完成
    if ([downloadingPicsArray count]==0)
    {
        [HUD hide:YES];
        [self goToMainView];
        totalDownloaded = 0;
    }
    else
    {
        //更新提示内容
        int remaingDownload = totalDownloaded-[downloadingPicsArray count];
        float progress = (float)remaingDownload/totalDownloaded*100;
        NSString *tempStr1 = kLoc(@"has_done");
        NSString *tempStr2 = kLoc(@"loading_menus_pictures");
        HUD.labelText = [NSString stringWithFormat:@"[%@%2.0f％]%@",tempStr1,progress,tempStr2];
    }
}

//下载菜式图片
-(void)downloadDishPhotos:(NSArray*)photos
{
    if (downloadingPicsArray==nil)
    {
        downloadingPicsArray = [[NSMutableArray alloc] init];
    }
    [downloadingPicsArray removeAllObjects];
    
    for (NSDictionary *cookbook in photos)
    {
        NSArray *cbList = [cookbook objectForKey:@"cookbookList"];
        for (NSDictionary *cb in cbList)
        {
            NSString *dishPic = [cb objectForKey:@"dishesPicture"];
            NSString *dishThumb = [cb objectForKey:@"dishesPicture"];
            //NSString *dishThumb = [cb objectForKey:@"dishesPictureThumb"];
            
            // NSLog(@"===dishPic:%@\n%@,%d,%d===",dishPic,dishThumb,[offlineMgr isOfflinePhotoExistWithFileName:[dishThumb lastPathComponent]],[offlineMgr isOfflinePhotoExistWithFileName:[dishThumb lastPathComponent]]);
            
            //下载菜单大图
            if ([dishPic length]>0)
            {
                if (![offlineMgr isOfflinePhotoExistWithFileName:[dishPic lastPathComponent]])
                {
                    [downloadingPicsArray addObject:dishPic];
                }
            }
            //下载菜单缩略图
            if ([dishThumb length]>0)
            {
                if (![offlineMgr isOfflinePhotoExistWithFileName:[dishPic lastPathComponent]])
                {
                    [downloadingPicsArray addObject:dishThumb];
                }
            }
        }
    }
    totalDownloaded = [downloadingPicsArray count];
    if (0 != [downloadingPicsArray count])
    {
        if (HUD==nil)
        {
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            HUD.delegate = self;
            HUD.mode = MBProgressHUDModeIndeterminate;
            HUD.labelText = kLoc(@"ready_for_downloading_menus_data_please_wait");
            [self.view addSubview:HUD];
        }
        [HUD show:YES];
        [self downloadNextPhoto];
    }
    else
    {
        [HUD hide:YES];
        [self goToMainView];
    }
}

#pragma mark - network

//是否登录了帐号
- (void)isLoginedOfAccount
{
    AccountManager *accountMgr = [AccountManager sharedAccountManager];
    if ([accountMgr isLogin])
    {
        accountTextfield.text = [accountMgr userName];
        passwordTextfield.text = [accountMgr userPassword];
    }
    else
    {
        return;
    }
    
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 2;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowLoginAlertView = NO;
    jsonPicker.loadingMessage = kLoc(@"verifying_account_information_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withBaseRequest:@"status/isLogined"];
}

//登录帐号(通过帐号、密码)
-(void)loginAccountWithPassword
{
    //判断用户的帐号(必须为6位或以上)
    NSString *account = [accountTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (0 == [account length])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kLoc(@"please_enter_your_account_number") delegate:nil cancelButtonTitle:kLoc(@"i_know") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //判断用户的密码(必须为6位或以上)
    NSString *password = [passwordTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (0 == [password length])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kLoc(@"please_enter_your_password") delegate:nil cancelButtonTitle:kLoc(@"i_know") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //登录帐号
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowLoginAlertView = NO;
    jsonPicker.loadingMessage = kLoc(@"verifying_account_information_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:account forKey:@"code"];
    [postData setObject:password forKey:@"password"];
    
    
    if (!offlineMgr) {
        offlineMgr = [OfflineManager sharedOfflineManager];
    }
    NSString *lastUpdatedDate = [offlineMgr data_LastUpdatedDate];
    if (lastUpdatedDate!=nil)
    {
        [postData setObject:lastUpdatedDate forKey:@"lastUpdatedDate"];
    }
    [jsonPicker postData:postData withBaseRequest:@"auth/login"];
}


//登录帐号(通过oAuthToken登录, JsonPicker己带有oAuthToken，所以不需要提交帐号和密码)
-(void)loginAccountWithOauth{
    AccountManager *accountMgr = [AccountManager sharedAccountManager];
    if ([accountMgr isLogin])
    {
        accountTextfield.text = [accountMgr userName];
        passwordTextfield.text = [accountMgr userPassword];
        
        //登录帐号
        if (nil == jsonPicker)
        {
            jsonPicker = [[JsonPicker alloc] init];
        }
        jsonPicker.delegate = self;
        jsonPicker.tag = 1;
        jsonPicker.showActivityIndicator = YES;
        jsonPicker.isShowLoginAlertView = NO;
        jsonPicker.loadingMessage = kLoc(@"verifying_account_information_please_wait");
        jsonPicker.loadedSuccessfulMessage = nil;
        
        NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
        
        NSString *lastUpdatedDate = [offlineMgr data_LastUpdatedDate];
        if (lastUpdatedDate)
        {
            [postData setObject:lastUpdatedDate forKey:@"lastUpdatedDate"];
        }
        [jsonPicker postData:postData withBaseRequest:@"auth/login"];
    }
}


-(IBAction)loginAccountButtonPressed:(id)sender
{
    [accountTextfield resignFirstResponder];
    [passwordTextfield resignFirstResponder];
    [loginScrollview setContentOffset:CGPointZero animated:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loginAccountWithPassword) userInfo:nil repeats:NO];
}

#pragma mark - MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[HUD removeFromSuperview];
	HUD = nil;
}

#pragma mark UIKeyboardNotification

- (void)keyboardWillShow:(NSNotification*)sender
{
    [loginScrollview setContentOffset:CGPointMake(0, 150) animated:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    [loginScrollview setContentOffset:CGPointZero animated:YES];
}

#pragma mark clear picture  清除图片

-(void)clearImageData
{
    if (!offlineMgr)
    {
        offlineMgr = [OfflineManager sharedOfflineManager];
    }
    [offlineMgr eraseOfflinePhotos];
}

-(NSString *)timeTranferToNSString:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *lastTimeString =  [dateFormatter stringFromDate:date];
    return lastTimeString;
}

//时间比较
-(int)getIntervalDayByDate:(NSString *)dateStr
{
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fromdate=[format dateFromString:dateStr];
    CGFloat interval =[[NSDate date] timeIntervalSinceDate:fromdate];
    int day = interval/kOnedayTranferToSecond;
    
#ifdef DEBUG
    NSLog(@"===%s,%d,%f===", __FUNCTION__, day,[[NSDate date] timeIntervalSinceDate:[format dateFromString:dateStr]]);
#endif
    
    return day;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

#pragma mark JsonPickerDelegate

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    int responseStatus = [[dict objectForKey:@"status"] intValue];
    //通过账户、密码登录
    if (picker.tag==0)
    {
        switch (responseStatus)
        {
            case 200:{
                
                //登录成功，保存OAuthToken
                AccountManager *accountMgr = [AccountManager sharedAccountManager];
                NSString *oAuthToken = [[dict objectForKey:@"data"] objectForKey:@"oauthToken"];
                [accountMgr loginAccountWithUserName:accountTextfield.text withPassword:passwordTextfield.text andToken:oAuthToken];
                //餐厅名称
                [accountMgr saveRestaurantName:[[dict objectForKey:@"data"]objectForKey:@"corpName"]];
                
                if (!offlineMgr)
                {
                    offlineMgr = [OfflineManager sharedOfflineManager];
                }
                //保存数据
                
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
                
                
                //保存备注数据
                NSArray *memoOptions = [[dict objectForKey:@"data"] objectForKey:@"memoOptions"];
                //NSArray *memoList = [memoOptions objectForKey:@"dataList"];
                //NSString *memoUpdatedDate = [dtOptions objectForKey:@"lastUpdate"];
                [offlineMgr saveOfflineMemos:memoOptions withUpdatedDate:dtUpdatedDate];
                
                //保存规则设置的开放期限列表
                NSArray *timeLimitOptions = [[dict objectForKey:@"data"] objectForKey:@"timeLimitOptions"];
                [offlineMgr saveRuleLimitTitles:timeLimitOptions];
                
                //用户开通了哪些权限，保存，以便控制主页中菜单按钮的显示
                NSArray *authorityArray = [[dict objectForKey:@"data"] objectForKey:@"menu"];
                [offlineMgr saveAccountAuthority:authorityArray];
                
                //保存货币符号
                [offlineMgr saveCurrencySymbol:[[dict objectForKey:@"data"]objectForKey:@"currency"]];
                
                //连锁店信息
                [offlineMgr saveBranchShopData:[[dict objectForKey:@"data"]objectForKey:@"branch"]];
                
                // 保存订座，外卖默认查询时间
                [offlineMgr saveDefaultOrderFilterDateData:[[dict objectForKey:@"data"]objectForKey:@"defaultOrderFilterDate"]];
                
                //下载图片
                [self downloadDishPhotos:cookbookList];
                
                break;
            }
            default:
            {
                NSString *warnString = [dict objectForKey:@"desc"];
                [PSAlertView showWithMessage:warnString];
                
                [self clearBadge];
                break;
            }
        }
    }
    
    //通过oAuthToken登录
    if (picker.tag==1)
    {
        switch (responseStatus)
        {
            case 200:{
                
                //登录成功，保存OAuthToken
                AccountManager *accountMgr = [AccountManager sharedAccountManager];
                NSString *oAuthToken = [[dict objectForKey:@"data"] objectForKey:@"oauthToken"];
                [accountMgr loginAccountWithToken:oAuthToken];
                
                //保存数据
                if (!offlineMgr) {
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
                
                //保存货币符号
                [offlineMgr saveCurrencySymbol:[[dict objectForKey:@"data"]objectForKey:@"currency"]];
                
                //连锁店信息
                [offlineMgr saveBranchShopData:[[dict objectForKey:@"data"]objectForKey:@"branch"]];
                
                // 保存订座，外卖默认查询时间
                [offlineMgr saveDefaultOrderFilterDateData:[[dict objectForKey:@"data"]objectForKey:@"defaultOrderFilterDate"]];
                
                [self downloadDishPhotos:cookbookList];
                
                break;
            }
            //登录失败，注销该帐号
            default:
            {
                AccountManager *accountMgr = [AccountManager sharedAccountManager];
                [accountMgr logoutAccount];
                passwordTextfield.text = @"";
                [self clearBadge];
                
                NSString *warnString = [dict objectForKey:@"desc"];
                [PSAlertView showWithMessage:warnString];
                
                break;
            }
        }
    }
    if (2 == picker.tag)
    {
        switch (responseStatus)
        {
            //已经登录
            case 200:
            {
                //用户开通了哪些权限，保存，以便控制主页中菜单按钮的显示
                NSArray *authorityArray = [[dict objectForKey:@"data"] objectForKey:@"menu"];
                [offlineMgr saveAccountAuthority:authorityArray];
                
                //保存货币符号
                [offlineMgr saveCurrencySymbol:[[dict objectForKey:@"data"]objectForKey:@"currency"]];
                
                //连锁店信息
                [offlineMgr saveBranchShopData:[[dict objectForKey:@"data"]objectForKey:@"branch"]];
                
                // 保存订座，外卖默认查询时间
                [offlineMgr saveDefaultOrderFilterDateData:[[dict objectForKey:@"data"]objectForKey:@"defaultOrderFilterDate"]];
                [self goToMainView];
                break;
            }
            //没有登录
            case 101:
            {
                sleep(1);
                [self clearBadge];
                AccountManager *accountMgr = [AccountManager sharedAccountManager];
                [accountMgr logoutAccount];
                self.passwordTextfield.text = @"";
                [PSAlertView showWithMessage:NSLocalizedString(@"登录失败", nil)];
                
                break;
            }
            default:
            {
                sleep(1);
                passwordTextfield.text = @"";
                [self clearBadge];
                NSString *warnString = [dict objectForKey:@"desc"];
                [PSAlertView showWithMessage:warnString];
                
                break;
            }
        }
    }
}


// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error
{
    
}


// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error
{
    //通过oAuthToken登录
    if (picker.tag==1)
    {
        passwordTextfield.text = @"";
    }
    [self clearBadge];
}

#pragma mark DataDownloaderDelegate
//
-(void)DataDownloader:(DataDownloader *)loader didLoadPhoto:(UIImage *)image{
    if (!offlineMgr) {
        offlineMgr = [OfflineManager sharedOfflineManager];
    }
    [offlineMgr saveOfflinePhoto:image andPhotoFileName:[loader url]];
    
    if ([downloadingPicsArray count]>0) {
        NSString *currentDownloadingUrl = [downloadingPicsArray objectAtIndex:0];
        if ([[currentDownloadingUrl lastPathComponent] isEqualToString:[loader url]]) {
            [downloadingPicsArray removeObjectAtIndex:0];
        }
    }
    [self downloadNextPhoto];
}


//加载失败，返回默认图像
-(void)DataDownloader:(DataDownloader *)loader didFailedLoadPhoto:(UIImage *)image{
    if ([downloadingPicsArray count]>0) {
        NSString *currentDownloadingUrl = [downloadingPicsArray objectAtIndex:0];
        if ([[currentDownloadingUrl lastPathComponent] isEqualToString:[loader url]]) {
            [downloadingPicsArray removeObjectAtIndex:0];
        }
    }
    [self downloadNextPhoto];
}

-(void)DataDownloader:(DataDownloader *)loader didFailWithNetwork:(NSError *)error
{
    [HUD hide:YES];
}

#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0)
    {
        if (buttonIndex == 1)
        {
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(clearImageData) userInfo:nil repeats:NO];
            
        }
    }
    
    if (alertView.tag == 1)
    {
        if (buttonIndex == 1)
        {
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(clearImageData) userInfo:nil repeats:NO];
            //记录清除过缓存
            NSString *lastTimeString = [self timeTranferToNSString:[NSDate date]];
            [[NSUserDefaults standardUserDefaults]setObject:lastTimeString forKey:kOnedayclearData];
        }
        else
        {
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(loginAccountWithOauth) userInfo:nil repeats:NO];
            //[self loginAccountWithOauth];/*UIAlertView与MBProgressHUD会有冲突 */
        }
    }
}

@end
