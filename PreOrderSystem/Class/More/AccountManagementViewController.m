//
//  AccountManagementViewController.m
//  PreOrderSystem
//
//  Created by sWen on 12-10-24.
//
//

#import "AccountManagementViewController.h"
#import "EditPasswordViewController.h"
#import "EditAccountViewController.h"
#import "OfflineManager.h"
#import "Constants.h"
#import "PSAlertView.h"
#import "UIViewController+ShowInView.h"
#import "MoreViewController.h"

@interface AccountManagementViewController ()<UITextFieldDelegate, JsonPickerDelegate, EditAccountViewControllerDelegate, EditPasswordViewControllerDelegate>
{
    JsonPicker *jsonPicker;
    EditPasswordViewController *passwordViewController;
    EditAccountViewController *editAccountViewController;
}

@property (nonatomic, weak)IBOutlet UILabel *nameLabel;
@property (nonatomic, weak)IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak)IBOutlet UILabel *contactsLabel;
@property (nonatomic, weak)IBOutlet UILabel *addressLabel;
@property (nonatomic, weak)IBOutlet UILabel *emailLabel;
@property (nonatomic, weak)IBOutlet UILabel *nameDetailLabel;
@property (nonatomic, weak)IBOutlet UILabel *phoneDetailLabel;
@property (nonatomic, weak)IBOutlet UILabel *contactsDetailLabel;
@property (nonatomic, weak)IBOutlet UITextView *addressDetailTextView;
@property (nonatomic, weak)IBOutlet UILabel *emailDetailLabel;
@property (nonatomic, weak) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UIButton *passwordButton;

- (IBAction)passwordButtonClicked:(UIButton *)sender;
- (IBAction)editButtonClicked:(id)sender;
- (void)refreshView:(NSDictionary *)accountDictionary;
- (void)getAccountInfomation:(BOOL)animated;

@end

@implementation AccountManagementViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.editButton.hidden = self.passwordButton.hidden = !self.editAuthorityFlag;
    [self addLocalizedString];
    [self addPictureToView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    jsonPicker = nil;
    editAccountViewController = nil;
    passwordViewController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"more_account_management") forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
    
    static BOOL isShowAnimated = YES;
    //缓存数据
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    [self refreshView:[offlineMgr getOfflineAccountInfo]];
    //最新数据
    [self getAccountInfomation:isShowAnimated];
    isShowAnimated = NO;
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
    
#ifdef DEBUG
    NSLog(@"===AccountManagementViewController,dealloc===");
#endif
}

- (void)addLocalizedString
{
//    self.nameLabel.text = kLoc(@"餐厅名称 ：", nil);
//    self.phoneLabel.text = kLoc(@"电话 ：", nil);
//    self.contactsLabel.text = kLoc(@"联络人 ：", nil);
//    self.emailLabel.text = kLoc(@"电子邮箱 ：", nil);
//    self.addressLabel.text = kLoc(@"餐厅地址 ：", nil);
//    [self.editButton setTitle:kLoc(@"编辑", nil) forState:UIControlStateNormal];
//    [self.passwordButton setTitle:kLoc(@"修改密码", nil) forState:UIControlStateNormal];
    NSString *ll =kLoc(@"restaurant_name");
    self.nameLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"restaurant_name")];
    self.phoneLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"telephone")];
    self.contactsLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"contact")];
    self.emailLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"email")];
    self.addressLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"restaurant_address")];
    [self.editButton setTitle:kLoc(@"edit") forState:UIControlStateNormal];
    [self.passwordButton setTitle:kLoc(@"modify_password") forState:UIControlStateNormal];
}

- (void)addPictureToView
{
    [self.editButton setBackgroundImage:LoadImageWithPNGType(@"more_shortButton") forState:UIControlStateNormal];
    [self.passwordButton setBackgroundImage:LoadImageWithPNGType(@"more_shortButton") forState:UIControlStateNormal];
}

- (void)refreshView:(NSDictionary *)accountDictionary
{
    self.nameDetailLabel.text = [[accountDictionary objectForKey:@"data"]objectForKey:@"name"];
    self.phoneDetailLabel.text = [[accountDictionary objectForKey:@"data"]objectForKey:@"phone"];
    self.contactsDetailLabel.text = [[accountDictionary objectForKey:@"data"]objectForKey:@"linkMan"];
    self.addressDetailTextView.text = [[accountDictionary objectForKey:@"data"]objectForKey:@"address"];
    self.emailDetailLabel.text = [[accountDictionary objectForKey:@"data"]objectForKey:@"email"];
}

#pragma mark - network

-(void)getAccountInfomation:(BOOL)animated
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withBaseRequest:@"CorpInfo"];
}

#pragma mark - UIButton Clicked

- (IBAction)passwordButtonClicked:(UIButton *)sender
{
    self.view.hidden = YES;
    
    if (passwordViewController == nil)
    {
        passwordViewController = [[EditPasswordViewController alloc]init];
    }
    passwordViewController.delegate = self;
    [passwordViewController showInView:self.fatherVC withOriginPoint:kEditAccountViewControllerOrigin withAnimated:NO];
}

- (IBAction)editButtonClicked:(id)sender
{
    self.view.hidden = YES;
    if (editAccountViewController == nil)
    {
        editAccountViewController = [[EditAccountViewController alloc]init];
    }
    editAccountViewController.delegate = self;
    [editAccountViewController showInView:self.fatherVC withOriginPoint:kEditPasswordViewControllerOrigin withAnimated:NO];
}

#pragma mark EditPasswordViewControllerDelegate

-(void)EditPasswordViewController:(EditPasswordViewController*)ctrl didDismissView:(BOOL)flag
{
    self.view.hidden = NO;
    [ctrl dismissViewControllerWithAnimated:NO];
}

#pragma mark EditAccountViewControllerDelegate

-(void)EditAccountViewController:(EditAccountViewController*)ctrl didDismissView:(BOOL)flag
{
    self.view.hidden = NO;
    //缓存数据
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    [self refreshView:[offlineMgr getOfflineAccountInfo]];
    
    [ctrl dismissViewControllerWithAnimated:NO];
}

#pragma mark - JsonPickerDelegate

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    if (kJsonPickerFirstTag == picker.tag)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            case 200:
            {
                [self refreshView:dict];
                
                OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
                [offlineMgr saveOfflineAccountInfo:dict];
                
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
