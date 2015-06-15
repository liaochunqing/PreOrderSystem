//
//  MoreViewController.m
//  PreOrderSystem
//
//  Created by sWen on 12-10-18.
//
//

#import "MoreViewController.h"
#import "InfoViewController.h"
#import "AccountManagementViewController.h"
#import "PrintManagementViewController.h"
#import "Constants.h"
#import "PSAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+ShowInView.h"
#import "StaffManagementViewController.h"
#import "OfflineManager.h"
#import "StaffManagementSuperDataClass.h"

#define kQuitAlertViewTag 1000
#define kTopBtnDefaultTag 1100

typedef enum {
    kMoreTopStaffBtnTag = kTopBtnDefaultTag,
    kMoreTopAccountBtnTag,
    kMoreTopPrinterBtnTag,
    kMoreTopAboutBtnTag
}kMoreTopBtnTag;

static MoreViewController *shareInstance = nil;

@interface MoreViewController ()<JsonPickerDelegate>
{
    InfoViewController *infoviewController;
    AccountManagementViewController *accountManagementViewController;
    PrintManagementViewController *printViewController;
    StaffManagementViewController *staffVC;
    
    JsonPicker *jsonPicker;
    NSInteger selectedTopBtnIndex;
    BOOL accountEditFlag;
}

@property (nonatomic, weak) IBOutlet UIImageView *backGroundImageView;
@property (nonatomic, weak) IBOutlet UIScrollView *topSrollView;
@property (nonatomic, weak) IBOutlet UIButton *quitButton;

- (IBAction)quitButtonClicked:(id)sender;

@end

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        shareInstance = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addPictureToView];
    [self addBtnToTopScrollView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    accountManagementViewController = nil;
    infoviewController = nil;
    printViewController = nil;
    staffVC = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"more") forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationMaskLandscape;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
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

-(void)dealloc
{
    shareInstance = nil;
}

- (void)addPictureToView
{
    self.backGroundImageView.image = LoadImageWithPNGType(@"more_bg");
    //繁体/简体
//    NSString *quitBtnImg = (![kCurrentLanguageOfDevice isEqualToString:kChineseFamiliarStyle]) ? @"more_quitLogin_traditinal": @"more_quitLogin";
    [self.quitButton setBackgroundImage:kLocImage(@"more_quitLogin.png") forState:UIControlStateNormal];
}

- (void)addBtnToTopScrollView
{
    NSArray *subViewsArray = self.topSrollView.subviews;
    NSInteger btnCount = [subViewsArray count];
    for (int i = 0; i < btnCount; i++)
    {
        id tempClass = [subViewsArray objectAtIndex:i];
        if ([tempClass isKindOfClass:NSClassFromString(@"UIButton")])
        {
            UIButton *tempBtn = (UIButton *)tempClass;
            [tempBtn removeFromSuperview];
        }
    }
    
    NSArray *pageArray = nil;
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSArray *authorityArray = [offlineMgr getAccountAuthority];
    for (NSDictionary *authDict in authorityArray)
    {
        StaffManagementAuthDataClass *authClass = [[StaffManagementAuthDataClass alloc] initWithStaffManagementAuthData:authDict];
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfMoreIndexStr])
        {
            for (StaffManagementSubAuthDataClass *subAuth in authClass.childrenArray)
            {
                if (([subAuth.indexStr isEqualToString:@"profileModifying"]))
                {
                    accountEditFlag = subAuth.open;
                    break;
                }
            }
            pageArray = authClass.pageArray;
            break;
        }
    }
    
    NSInteger btnTag = kTopBtnDefaultTag;
    UIImage *btnNormalImg = LoadImageWithPNGType(@"more_topSideBarButton");
    UIImage *btnSelectedImg = LoadImageWithPNGType(@"more_topSideBarSelectedButton");
    NSString *btnTitle = nil;
    UIFont *titleFont = [UIFont boldSystemFontOfSize:25];
    const float btnWidth = btnNormalImg.size.width;
    const float btnHeight = btnNormalImg.size.height;
    float contentSizeWidth = 5;
    const float btnSpace = -20;
    NSInteger btnIndex = kZeroNumber;
    for (NSString *indexName in pageArray)
    {
        if ([indexName isEqualToString:@"user"])
        {
            btnTag = kMoreTopStaffBtnTag;
            btnTitle = kLoc(@"staff_management");
        }
        else if ([indexName isEqualToString:@"account"])
        {
            btnTag = kMoreTopAccountBtnTag;
            btnTitle = kLoc(@"manage_account");
        }
        else if ([indexName isEqualToString:@"about"])
        {
            btnTag = kMoreTopAboutBtnTag;
            btnTitle = kLoc(@"about");
        }
        else if ([indexName isEqualToString:@"print"])
        {
            btnTag = kMoreTopPrinterBtnTag;
            btnTitle = kLoc(@"manage_printer");
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = btnTag;
        btn.frame = CGRectMake(contentSizeWidth, 0, btnWidth, btnHeight);
        [btn setTitle:btnTitle forState:UIControlStateNormal];
        btn.titleLabel.font = titleFont;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundImage:btnNormalImg forState:UIControlStateNormal];
        [btn setBackgroundImage:btnSelectedImg forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(topButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.topSrollView addSubview:btn];
        contentSizeWidth = contentSizeWidth + btnWidth + btnSpace;
        
        if (btnIndex == kZeroNumber)
        {
            btn.selected = YES;
            selectedTopBtnIndex = btn.tag;
            switch (btn.tag)
            {
                case kMoreTopStaffBtnTag:
                {
                    [self gotoStaffVC];
                    
                    break;
                }
                case kMoreTopAccountBtnTag:
                {
                    [self gotoAccountVC];
                    
                    break;
                }
                case kMoreTopAboutBtnTag:
                {
                    [self gotoInfoVC];
                    
                    break;
                }
                case kMoreTopPrinterBtnTag:
                {
                    [self gotoPrintVC];
                    
                    break;
                }
            }
        }
        btnIndex ++;
    }
}

+ (MoreViewController *)getMoreVCShareInstance
{
    return shareInstance;
}


#pragma mark - goto view

- (void)gotoStaffVC
{
    [self resetBgViewFrame:YES];
    [self whetherDismissView:staffVC];
    
    if (nil == staffVC)
    {
        staffVC = [[StaffManagementViewController alloc] init];
    }
    staffVC.fatherVC = self;
    staffVC.view.hidden = NO;
    [staffVC showInView:self withOriginPoint:kStaffManagementViewControllerOrigin withAnimated:NO];
}

- (void)gotoAccountVC
{
    [self resetBgViewFrame:NO];
    [self whetherDismissView:accountManagementViewController];
    
    if (accountManagementViewController == nil)
    {
        accountManagementViewController = [[AccountManagementViewController alloc] init];
    }
    accountManagementViewController.editAuthorityFlag = accountEditFlag;
    accountManagementViewController.view.hidden = NO;
    accountManagementViewController.fatherVC = self;
    [accountManagementViewController showInView:self withOriginPoint:kAccountManagementViewControllerOrigin withAnimated:NO];
}

- (void)gotoInfoVC
{
    [self resetBgViewFrame:NO];
    [self whetherDismissView:infoviewController];
    
    if (infoviewController==nil)
    {
        infoviewController = [[InfoViewController alloc] init];
    }
    [infoviewController showInView:self withOriginPoint:kInfoViewControllerOrigin withAnimated:NO];
}

- (void)gotoPrintVC
{
    [self resetBgViewFrame:YES];
    [self whetherDismissView:printViewController];
    
    if (nil == printViewController)
    {
        printViewController = [[PrintManagementViewController alloc] init];
    }
    [printViewController showInView:self withOriginPoint:kPrintManagementViewControllerOrigin withAnimated:NO];
}

#pragma mark - UIButton Clicked

- (void)topButtonClicked:(UIButton *)sender
{
    NSInteger index = sender.tag;
    if (index != selectedTopBtnIndex)
    {
        UIButton *oldSelectedBtn = (UIButton*)[self.topSrollView viewWithTag:selectedTopBtnIndex];
        UIButton *newSelectedBtn = (UIButton*)[self.topSrollView viewWithTag:index];
        oldSelectedBtn.selected = NO;
        newSelectedBtn.selected = YES;
        [self.topSrollView sendSubviewToBack:oldSelectedBtn];
        [self.topSrollView bringSubviewToFront:newSelectedBtn];
        selectedTopBtnIndex = index;
        
        switch (index)
        {
            case kMoreTopStaffBtnTag:
            {
                [self gotoStaffVC];
                
                break;
            }
            case kMoreTopAccountBtnTag:
            {
                [self gotoAccountVC];
                
                break;
            }
            case kMoreTopAboutBtnTag:
            {
                [self gotoInfoVC];
                
                break;
            }
            case kMoreTopPrinterBtnTag:
            {
                [self gotoPrintVC];
                
                break;
            }
        }
    }
}

- (IBAction)quitButtonClicked:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLoc(@"are_you_sure_to_logout") message:@"" delegate:self cancelButtonTitle:kLoc(@"cancel") otherButtonTitles:kLoc(@"confirm"), nil];
    alert.tag = kQuitAlertViewTag;
    [alert show];
}

- (void)resetBgViewFrame:(BOOL)bigFlag
{
    CGFloat tempHeight = 0;
    if (bigFlag)
    {
        tempHeight = 614.0;
    }
    else
    {
        tempHeight = 387.0;
    }
    CGRect bgViewFrame = self.backGroundImageView.frame;
    bgViewFrame.size.height = tempHeight;
    self.backGroundImageView.frame = bgViewFrame;
    
    UIImage *tempImage = LoadImageWithPNGType(@"more_bg");
    self.backGroundImageView.image = [tempImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
}

- (void)whetherDismissView:(UIViewController *)aVC
{
    NSArray *subViewArray = self.childViewControllers;
    for (id object in subViewArray)
    {
        if ([object isKindOfClass:[UIViewController class]])
        {
            UIViewController *tempVC = (UIViewController *)object;
            if (tempVC != aVC)
            {
                [tempVC dismissViewControllerWithAnimated:NO];
            }
        }
    }
}

#pragma mark - network

//登出帐号
-(void)logoutAccount
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = @"正在登出帐号，请稍候...";
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withBaseRequest:@"auth/logout"];
}

#pragma mark PUBLIC METHODS

-(void)showInView:(UIView*)aView
{
    self.view.alpha = 0.0f;
    CGRect frame = self.view.frame;
    frame.origin.x = 170;
    self.view.frame = frame;
    [aView addSubview:self.view];
    [UIView beginAnimations:@"animationID" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationRepeatAutoreverses:NO];
    self.view.alpha = 1.0f;
    CGRect aFrame = self.view.frame;
    aFrame.origin.y = 0;
    self.view.frame = aFrame;
	[UIView commitAnimations];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	[self.view removeFromSuperview];
}

-(void)dismissView
{
    //self.view.alpha = 1.0f;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    [UIView setAnimationDuration:1.0f];
    CGRect aFrame = self.view.frame;
    //aFrame.origin.y = 500;
    self.view.frame = aFrame;
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //self.view.alpha = 0.0f;
    [UIView commitAnimations];
    
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (kQuitAlertViewTag == alertView.tag)
    {
        if (buttonIndex==1)
        {
            [self logoutAccount];
        }
    }
}

#pragma mark JsonPickerDelegate

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    if (kJsonPickerFirstTag == picker.tag)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            case 200:
            {
                //登出订餐成功
                [[NSNotificationCenter defaultCenter]postNotificationName:kLogoutAccount object:nil];
                
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
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error{
    
}

// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error{
    
}

@end
