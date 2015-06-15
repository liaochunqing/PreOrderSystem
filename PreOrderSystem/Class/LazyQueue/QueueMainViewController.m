//
//  QueueMainViewController.m
//  PreOrderSystem
//
//  Created by sWen on 13-3-7.
//
//

#import <QuartzCore/QuartzCore.h>
#import "QueueMainViewController.h"
#import "PSAlertView.h"
#import "Constants.h"
#import "UIViewController+MJPopupViewController.h"
#import "ArrangHandleView.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "QueueCommon.h"
#import "SocketPrinterFunctions.h"
#import "MainViewController.h"
#import "NsstringAddOn.h"
#import "SuperDataClass.h"
#import "QueueSuperDataClass.h"
#import "QueueAddArrangDataClass.h"
#import "OfflineManager.h"
#import "StaffManagementSuperDataClass.h"
#import "QueueLookDishViewController.h"
#import "QueueArrangDataClass.h"
#import "UITextFieldAddition.h"

#define kIsShowAllArrangKey @"isShowAllArrang"
/*QueueMainViewControllerCell中，ArrangTableViewCell背景图片起点以上cell的高度*/
#define kTopHeightForCell 200
/*QueueMainViewControllerCell中，ArrangTableViewCell背景图片尾巴以下cell的高度*/
#define kBottomHeightForCell 20
#define kTakeNumberLength 2
#define kPhoneNumberLength 11
#define kHongkongPhoneNumberLength 8
#define kArrangHandleActionSheetTag 1000
#define kMoreBtnActionSheetTag 1100
#define kChooseTableActionSheetTag 1200
#define kClearAlertViewTag 1300
#define kTakeNumAlertViewTag 1400

@interface QueueMainViewController ()<UITextFieldDelegate, QueueLookDishViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    //存储排号数据
    NSMutableArray *queueListArray;
    JsonPicker *jsonPicker;
    //下拉刷新
    BOOL _reloading;
    EGORefreshTableHeaderView *pullDownRefreshView;
    NSMutableArray *socketObjectArray;
    
    BOOL editCategoryFlag;
    BOOL clearArrangFlag;
    
    /// 可用的房台数据源
    NSMutableArray *dinnerTableSource_;
    
    /// 要入座的排号标号
    NSString *takeSeatArrangId_;
}

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UITableView *queueTableView;
@property (nonatomic, weak) IBOutlet UIButton *moreButton;
@property (nonatomic, weak) IBOutlet UIImageView *addArrangBgImageView;
@property (nonatomic, weak) IBOutlet UIButton *addArrangButton;
@property (nonatomic, weak) IBOutlet UITextField *addArrangTextField;
@property (nonatomic, weak) IBOutlet UITextField *phoneTextField;

- (IBAction)addArrangButtonPressed:(id)sender;
- (IBAction)moreButtonPressed:(UIButton *)sender;
- (void)addPullDownReFresh;
- (void)getArrangListDataWithAnimated:(BOOL)animated;
- (void)clearArrangListData;
- (void)updateArrangStatus:(NSDictionary *)dict;

@end

@implementation QueueMainViewController

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
    
    // 添加关闭按钮
    [self.searchPhoneNumberTextfield bindCloseButton];
    [self.phoneTextField bindCloseButton];
    [self.addArrangTextField bindCloseButton];
    
    self.searchPhoneNumberTextfield.delegate = self;
    self.searchPhoneNumberTextfield.placeholder = kLoc(@"phone_number");
    queueListArray = [[NSMutableArray alloc]initWithCapacity:1];
    [self addPullDownReFresh];
    [self addPictureToView];
    [self addLocalizedString];
    [self updateQueueAuthority];
    [self getArrangListDataWithAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    queueListArray = nil;
    jsonPicker = nil;
    pullDownRefreshView = nil;
    
#ifdef DEBUG
    NSLog(@"===QueueMainViewController,viewDidUnload===");
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"queue") forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
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
    
}

- (void)addPictureToView
{
    self.bgImageView.image = [UIImage imageFromMainBundleFile:@"queue_frameBg.png"];
    self.addArrangBgImageView.image = kLocImage(@"queue_addArrangBg.png");
}

- (void)addLocalizedString
{
    self.phoneTextField.placeholder = kLoc(@"phone_number_require");
    self.addArrangTextField.placeholder = kLoc(@"person_number_require");
}

// 限制只能输入0到9的数字
- (BOOL)validateNumber:(NSString*)number
{
    int i = 0;
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    while (i < number.length)
    {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        
        if (range.length == 0)
        {
            res = NO;
            break;
        }
        
        i++;
    }
    
    return res;
}


//下拉刷新
- (void)addPullDownReFresh
{
    _reloading = NO;
    if (!pullDownRefreshView)
    {
        pullDownRefreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.queueTableView.bounds.size.height, self.queueTableView.bounds.size.width, self.queueTableView.bounds.size.height)];
        pullDownRefreshView.delegate = self;
        pullDownRefreshView.backgroundColor = [UIColor clearColor];
        [self.queueTableView addSubview:pullDownRefreshView];
    }
    [pullDownRefreshView refreshLastUpdatedDate];
}

//打印
- (void)printArrangInfo:(NSDictionary *)dataDict
{
    if (!socketObjectArray)
    {
        socketObjectArray = [[NSMutableArray alloc] init];
    }
    [socketObjectArray removeAllObjects];
    [SocketPrinterFunctions getSocketPrinterObject:socketObjectArray mode:kPrinterModeQueue];
    
    QueueAddArrangDataClass *addArrangDataClass = [[QueueAddArrangDataClass alloc] initWithQueueAddArrangArrangData:dataDict];
    int printerCount = [socketObjectArray count];
    for (int i = 0; i < printerCount; i++)
    {
        [[socketObjectArray objectAtIndex:i] printQueueReceiptWithName:addArrangDataClass];
    }
}

- (void)hideKeyBoard
{
    [self.phoneTextField resignFirstResponder];
    [self.addArrangTextField resignFirstResponder];
    [self.searchPhoneNumberTextfield resignFirstResponder];
}

/**
 * 排队权限
 */
- (void)updateQueueAuthority
{
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSArray *authorityArray = [offlineMgr getAccountAuthority];

    for (NSDictionary *authDict in authorityArray)
    {
        StaffManagementAuthDataClass *authClass = [[StaffManagementAuthDataClass alloc] initWithStaffManagementAuthData:authDict];
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfQueueIndexStr])
        {
            for (StaffManagementSubAuthDataClass *subAuth in authClass.childrenArray)
            {
                if ([subAuth.indexStr isEqualToString:@"editing"])
                {
                    editCategoryFlag = subAuth.open;
                }
                else if ([subAuth.indexStr isEqualToString:@"clearing"])
                {
                    clearArrangFlag = subAuth.open;
                }
            }
            break;
        }
    }
    if (!editCategoryFlag && !clearArrangFlag)
    {
        self.moreButton.enabled = NO;
    }
    else
    {
        self.moreButton.enabled = YES;
    }
}

#pragma mark - UIButton pressed

- (IBAction)moreButtonPressed:(UIButton *)sender
{
    [self hideKeyBoard];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = kMoreBtnActionSheetTag;
    if (editCategoryFlag)
    {
        [actionSheet addButtonWithTitle:kLoc(@"edit_arranging_category")];
    }
    if (clearArrangFlag)
    {
        [actionSheet addButtonWithTitle:kLoc(@"clear_arranging")];
    }
    
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:sender.frame inView:self.view animated:YES];
    }
}

//取号按钮
- (IBAction)addArrangButtonPressed:(id)sender
{
    [self hideKeyBoard];

    NSString *phoneStr = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger phoneLength = [phoneStr length];
    if (phoneLength)
    {
        if (kPhoneNumberLength != phoneLength && kHongkongPhoneNumberLength != phoneLength)
        {
            [PSAlertView showWithMessage:kLoc(@"please_enter_a_valid_mobile_number")];
            return;
        }
    }
    else
    {
        [PSAlertView showWithMessage:kLoc(@"mobile_number_can_not_be_empty")];
        return;
    }
    
    NSString *numberStr = [self.addArrangTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (0 == [numberStr length])
    {
        [PSAlertView showWithMessage:kLoc(@"please_enter_arranging_number")];
        return;
    }
    if (1 == [numberStr length] && 0 == [numberStr integerValue])
    {
        [PSAlertView showWithMessage:kLoc(@"please_enter_the_correct_arranging_number")];
        return;
    }
    else
    {
        if (0 == [[numberStr substringWithRange:NSMakeRange(0, 1)]integerValue] && 0 == [[numberStr substringWithRange:NSMakeRange(1, 1)]integerValue])
        {
            [PSAlertView showWithMessage:kLoc(@"please_enter_the_correct_arranging_number")];
            return;
        }
    }
    
    BOOL isFind = NO;
    for (NSDictionary *queueDict in queueListArray)
    {
        NSArray *arrangListArray = [queueDict objectForKey:@"arrangList"];
        for (NSDictionary *arrangDict in arrangListArray)
        {
            if ([phoneStr isEqualToString:[arrangDict objectForKey:@"mobileNumber"]])
            {
                isFind = YES;
                break;
            }
        }
        if (isFind)
        {
            break;
        }
    }
    if (isFind)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:kLoc(@"you_have_been_took_continue_to_take_ticket") message:nil delegate:self cancelButtonTitle:kLoc(@"yes") otherButtonTitles:kLoc(@"no"), nil];
        alertView.tag = kTakeNumAlertViewTag;
        [alertView show];
        
        return;
    }
    self.addArrangTextField.text = numberStr;
    self.phoneTextField.text = phoneStr;
    [self addArrangData];
}

#pragma mark - showInView/dismissView

- (void)showInView:(UIView*)aView
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


- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	[self.view removeFromSuperview];
}

- (void)dismissView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
}

#pragma mark network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

- (void)getArrangListDataWithAnimated:(BOOL)animated
{
    if (nil == jsonPicker) {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = YES;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    if (self.mobileSearchNumber.length > 0) {
        [postData setObject:self.mobileSearchNumber forKey:@"mobile"];
    }
    
    // 还原搜索条件
    self.searchPhoneNumberTextfield.text = self.mobileSearchNumber;
    [jsonPicker postData:postData withBaseRequest:@"Queue/getList"];
}

- (void)clearArrangListData
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerSecondTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowUpdateAlert = NO;
    jsonPicker.loadingMessage =  kLoc(@"clearing_arranging_please_wait");
    jsonPicker.loadedSuccessfulMessage =  kLoc(@"operate_succeed");
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withBaseRequest:@"Queue/clear"];
}

//更改排号状态
- (void)updateArrangStatus:(NSDictionary *)dict
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerThirdTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowUpdateAlert = NO;
    jsonPicker.loadingMessage =  kLoc(@"modifing_arranging_please_wait");
    jsonPicker.loadedSuccessfulMessage =  kLoc(@"operate_succeed");
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] initWithDictionary:dict];
    [jsonPicker postData:postData withBaseRequest:@"Queue/updateStatus"];
#ifdef DEBUG
    NSLog(@"===QueueMainViewController,postData:%@===",postData);
#endif
}

- (void)addArrangData
{
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:self.addArrangTextField.text forKey:@"number"];
    [postData setObject:self.phoneTextField.text forKey:@"mobileNumber"];
    
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFourthTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowUpdateAlert = NO;
    jsonPicker.loadingMessage =  kLoc(@"saving_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:@"Queue/add"];
    
#ifdef DEBUG
    NSLog(@"===addArrangViewController,postData:%@===",postData);
#endif
}

/**
 * @brief   入座获取可用房台。
 *
 */
- (void)takeSeatOperation
{
    if (nil == jsonPicker) {
        jsonPicker = [[JsonPicker alloc] init];
    }
    
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerSixthTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowUpdateAlert = NO;
    jsonPicker.loadingMessage =  kLoc(@"fetching_available_tables_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:[NSDictionary dictionary] withBaseRequest:@"queue/getUsableTable"];
}

#pragma mark UITableViewDataSource && UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    QueueMainViewControllerCell *cell = (QueueMainViewControllerCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"QueueMainViewControllerCell" owner:self options:nil]lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    cell.tag = indexPath.row;
    //是否显示所有排号
    BOOL isShowAllArrang = [[[queueListArray objectAtIndex:indexPath.row] objectForKey:kIsShowAllArrangKey]boolValue];
    [cell updateViewAfterGetData:[queueListArray objectAtIndex:indexPath.row] withShowAllArrangFlag:isShowAllArrang];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [queueListArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return 315 * 2;
    
    NSArray *arrangListArray = [[queueListArray objectAtIndex:indexPath.row] objectForKey:@"arrangList"];
    int arrangCount = [arrangListArray count];
    int totalRow = 0;
    if (0 == arrangCount)
    {
        totalRow = 1;
    }
    else
    {
        BOOL flag = [[[queueListArray objectAtIndex:indexPath.row] objectForKey:kIsShowAllArrangKey]boolValue];
        if (flag)
        {
            totalRow = (0 == arrangCount % kArrangNumberForPerCell)?(arrangCount/kArrangNumberForPerCell):(arrangCount/kArrangNumberForPerCell + 1);
        }
        else
        {
            totalRow = 1;
        }
    }
    return kTopHeightForCell + kHeightForArrangCell *  totalRow + kBottomHeightForCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if (0 == [queueListArray count])
    {
        return 100;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (0 == [queueListArray count])
    {
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 748, 100)];
        aView.backgroundColor = [UIColor clearColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 748, 100)];
        label1.numberOfLines = 2;
        label1.backgroundColor = [UIColor clearColor];
        label1.textAlignment = UITextAlignmentCenter;
        label1.font = [UIFont boldSystemFontOfSize:20];
        label1.textColor = [UIColor blackColor];
        label1.text = kLoc(@"no_records");
        [aView addSubview:label1];
        
        return aView;
    }
    return nil;
}

#pragma mark QueueMainViewControllerCell delegate

- (void)queueMainViewControllerCellTopHavedTap:(QueueMainViewControllerCell *)cell
{
    [self hideKeyBoard];
}

- (void)handleArrang:(QueueMainViewControllerCell *)cell wihtIndex:(int)index withCategoryName:(NSString *)categoryName
{
    [self hideKeyBoard];
    
    NSArray *arrangListArray = [[queueListArray objectAtIndex:cell.tag] objectForKey:@"arrangList"];
    NSDictionary *arrangDict = [arrangListArray objectAtIndex:index];
    NSString *serialNumStr = [NSString stringWithFormat:@"%@%@",[arrangDict objectForKey:@"serialNumber"], kLoc(@"number")];
    NSString *peopleNumStr = [NSString stringWithFormat:@"%@%@",[arrangDict objectForKey:@"peopleNumber"], kLoc(@"person")];
    NSString *titleString = [NSString stringWithFormat:@"%@\n%@/%@", categoryName, serialNumStr, peopleNumStr];
    NSArray *dishArray = [arrangDict objectForKey:@"dishes"];
    
    // 检测是否为第一个未处理的排号
    BOOL noProcessed = NO;
    for (int i = 0; i < arrangListArray.count && i <= index; i++) {
        NSDictionary *item = [arrangListArray objectAtIndex:i];
        if ([[item objectForKey:@"statusValue"] intValue] == 0) {
            if (i == index) {
                noProcessed = YES;
            }
            break;
        }
    }
    
    // 弹出操作菜单
    ArrangHandleView *actionSheet = [[ArrangHandleView alloc] initWithTitle:titleString delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (noProcessed) {
        [actionSheet addButtonWithTitle:kLoc(@"call_number")];
    }
    [actionSheet addButtonWithTitle:kLoc(@"take_seat")];
    [actionSheet addButtonWithTitle:kLoc(@"invalid")];
    if ([dishArray count])
    {
        [actionSheet addButtonWithTitle:kLoc(@"view_list")];
    }
    actionSheet.tag = kArrangHandleActionSheetTag;
    actionSheet.cellTag = cell.tag;
    actionSheet.arrangIndex = index;
    [actionSheet showInView:self.view.window];
}

- (void)whetherShowAllArrang:(int)index
{
    if (index < [queueListArray count])
    {
        //添加一个字段(kIsShowAllArrangKey)，用来控制是否要显示全部排号
        NSMutableDictionary *arrangDict = [[NSMutableDictionary alloc]initWithDictionary:[queueListArray objectAtIndex:index]];
        BOOL flag = ![[arrangDict objectForKey:kIsShowAllArrangKey]boolValue];
        [arrangDict setObject:[NSNumber numberWithBool:flag] forKey:kIsShowAllArrangKey];
        [queueListArray replaceObjectAtIndex:index withObject:arrangDict];
        
        [self.queueTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:kTableViewOnlyOneSection]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.queueTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:kTableViewOnlyOneSection] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark EditArrangCategoryViewControllerDelegate

- (void)EditArrangCategoryViewController:(EditArrangCategoryViewController*)ctrl didDismissView:(BOOL)flag
{
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
    
    if (YES ==  ctrl.isEditAndSave)
    {
        //最新排队数据
        if (ctrl.latestQueueListArray)
        {
            [queueListArray removeAllObjects];
            [queueListArray addObjectsFromArray:ctrl.latestQueueListArray];
            [self.queueTableView reloadData];
        }
        
        
        //有排队的类别不能删除，做出提醒
        NSString *tempString = [ctrl.alertMsg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (0 != [tempString length])
        {
            if ([tempString compare:kLoc(@"submit_succeed")] == NSOrderedSame)// 成功时不需要提示框
            {
                return;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:tempString message:nil delegate:nil cancelButtonTitle:kLoc(@"confirm") otherButtonTitles: nil];
            [alertView show];
        }
    }
}

#pragma mark - QueueLookDishViewControllerDelegate

-(void)dismissQueueLookDishViewController
{
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (kMoreBtnActionSheetTag == actionSheet.tag)
    {
        if (kZeroNumber <= buttonIndex)
        {
            if (editCategoryFlag)
            {
                switch (buttonIndex)
                {
                    case 0:
                    {
                        [self gotoEditArrangCategoryVC];
                        
                        break;
                    }
                    case 1:
                    {
                        
                        //手机号码清空
                        [self showClearAllAlertView];
                        
                        break;
                    }
                }
            }
            else
            {
                [self showClearAllAlertView];
            }
        }
    }
    else if (kArrangHandleActionSheetTag == actionSheet.tag)
    {
        ArrangHandleView *tempView = (ArrangHandleView *)actionSheet;
        NSDictionary *listDict = [queueListArray objectAtIndex:tempView.cellTag];
        NSString *categoryIdString = [NSString stringWithFormat:@"%@",[listDict objectForKey:@"categoryId"]];
        NSString *categoryName = [listDict objectForKey:@"categoryName"];
        NSArray *arrangArray = [listDict objectForKey:@"arrangList"];
        NSDictionary *arrangDict = [arrangArray objectAtIndex:tempView.arrangIndex];
        NSString *arrangIdString = [NSString stringWithFormat:@"%@",[arrangDict objectForKey:@"arrangId"]];
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithCapacity:3];
        [tempDict setObject:categoryIdString forKey:@"categoryId"];
        [tempDict setObject:arrangIdString forKey:@"arrangId"];
        
        // 检测是否为第一个未处理的排号
        BOOL noProcessed = NO;
        for (int i = 0; i < arrangArray.count && i <= tempView.arrangIndex; i++) {
            NSDictionary *item = [arrangArray objectAtIndex:i];
            if ([[item objectForKey:@"statusValue"] intValue] == 0) {
                if (i == tempView.arrangIndex) {
                    noProcessed = YES;
                }
                break;
            }
        }
        
        if (noProcessed) {
            if (0 == buttonIndex) {
                // 叫号
                [tempDict setObject:@"3" forKey:@"statusValue"];
            } else if (1 == buttonIndex) {
                // 入座
                takeSeatArrangId_ = arrangIdString;
                [self takeSeatOperation];
                return;
            } else if(2 == buttonIndex) {
                // 作废
                [tempDict setObject:@"2" forKey:@"statusValue"];
            } else if(3 == buttonIndex) {
                // 查看清单
                [self gotoQueueLookDishVC:arrangDict withCategoryName:categoryName];
                return;
            } else {
                return;
            }
        } else {
            if (0 == buttonIndex) {
                // 入座
                takeSeatArrangId_ = arrangIdString;
                [self takeSeatOperation];
                return;
            } else if (1 == buttonIndex) {
                // 作废
                [tempDict setObject:@"2" forKey:@"statusValue"];
            } else if(2 == buttonIndex) {
                // 查看清单
                [self gotoQueueLookDishVC:arrangDict withCategoryName:categoryName];
                return;
            } else {
                return;
            }
        }
        [self updateArrangStatus:tempDict];
    } else if (actionSheet.tag == kChooseTableActionSheetTag) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            UIPickerView *picker = nil;
            for (UIView *subView in actionSheet.subviews) {
                if ([subView isKindOfClass:[UIPickerView class]]) {
                    picker = (UIPickerView *)subView;
                    break;
                }
            }
            
            if (picker != nil) {
                NSInteger firstRow = [picker selectedRowInComponent:0];
                NSInteger secondRow = [picker selectedRowInComponent:1];
                // 提交数据
                NSDictionary *areaDict = [dinnerTableSource_ objectAtIndex:firstRow];
                NSArray *housingList = [areaDict objectForKey:@"table"];
                NSDictionary *housingDict = [housingList objectAtIndex:secondRow];
                NSInteger housingId = [[housingDict objectForKey:@"id"] integerValue];
                if (jsonPicker == nil) {
                    jsonPicker = [[JsonPicker alloc] init];
                }
                jsonPicker.delegate = self;
                jsonPicker.tag = kJsonPickerEighthTag;
                jsonPicker.showActivityIndicator = YES;
                jsonPicker.isShowUpdateAlert = NO;
                jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
                jsonPicker.loadedSuccessfulMessage = kLoc(@"take_seat_succeed");
                NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
                [postData setValue:takeSeatArrangId_ forKey:@"queueId"];
                [postData setValue:[NSNumber numberWithInteger:housingId] forKey:@"tableId"];
                [jsonPicker postData:postData withBaseRequest:@"queue/seat"];
                takeSeatArrangId_ = nil;
            }
        }
    }
}

- (void)gotoEditArrangCategoryVC
{
    EditArrangCategoryViewController *categoryViewController = [[EditArrangCategoryViewController alloc]initWithNibName:@"EditArrangCategoryViewController" bundle:nil];
    categoryViewController.delegate = self;
    
    [[MainViewController getMianViewShareInstance] presentPopupViewController:categoryViewController animationType:MJPopupViewAnimationSlideBottomBottom];
    // 缩放视图
    scaleView(categoryViewController.view);
}

- (void)gotoQueueLookDishVC:(NSDictionary *)arrangDict withCategoryName:(NSString *)name
{
    QueueArrangDataClass *arrangClass = [[QueueArrangDataClass alloc] initWithArrangData:arrangDict];
    QueueLookDishViewController *lookDishVC = [[QueueLookDishViewController alloc]initWithNibName:@"QueueLookDishViewController" bundle:nil];
    lookDishVC.delegate = self;
    lookDishVC.arrangClass = arrangClass;
    lookDishVC.categoryName = name;
    
    [[MainViewController getMianViewShareInstance] presentPopupViewController:lookDishVC animationType:MJPopupViewAnimationSlideBottomBottom];
    // 缩放视图
    scaleView(lookDishVC.view);
}

- (void)showClearAllAlertView
{
    if (0 == [queueListArray count])
    {
        return;
    }
    BOOL isAllHandle = YES;
    for (int i = 0; i < [queueListArray count]; i++)
    {
        NSMutableArray *arrangListArray = [[NSMutableArray alloc]initWithArray:[[queueListArray objectAtIndex:i] objectForKey:@"arrangList"]];
        if (0 != [arrangListArray count])
        {
            isAllHandle = NO;
            break;
        }
    }
    NSString *titleString = @"";
    if (isAllHandle)
    {
        titleString = kLoc(@"are_you_sure_to_clear_all");
    }
    else
    {
        titleString = kLoc(@"some_arrang_has_not_been_processed_confirm_to_clear");
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titleString
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:kLoc(@"cancel")
                                              otherButtonTitles:kLoc(@"confirm"), nil];
    alertView.tag = kClearAlertViewTag;
    [alertView show];
}

#pragma mark - UIPickerViewDataSource & UIPickerViewDelegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return dinnerTableSource_.count;
    } else if (component == 1) {
        NSInteger firstRow = [pickerView selectedRowInComponent:0];
        NSDictionary *areaDict = [dinnerTableSource_ objectAtIndex:firstRow];
        NSArray *housingList = [areaDict objectForKey:@"table"];
        return housingList.count;
    } else {
        return 0;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString *rowText = @"";
    UIColor *textColor = [UIColor blackColor];
    NSInteger firstRow = [pickerView selectedRowInComponent:0];
    if (0 == component) {
        NSDictionary *areaDict = [dinnerTableSource_ objectAtIndex:row];
        rowText = [areaDict objectForKey:@"typeName"];
        if (row == firstRow) {
            textColor = [UIColor colorWithRed:0.0 green:87.0/255.0 blue:240.0/255.0 alpha:1.0];
        }
    } else {
        NSInteger secondRow = [pickerView selectedRowInComponent:1];
        NSDictionary *areaDict = [dinnerTableSource_ objectAtIndex:firstRow];
        NSArray *housingList = [areaDict objectForKey:@"table"];
        NSDictionary *housingDict = [housingList objectAtIndex:row];
        rowText = [housingDict objectForKey:@"name"];
        if (row == secondRow) {
            textColor = [UIColor colorWithRed:0 green:87.0/255.0 blue:240.0/255.0 alpha:1.0];
        }
    }
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 40.0)];
    contentLabel.textAlignment = UITextAlignmentCenter;
    contentLabel.textColor = textColor;
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.font = [UIFont boldSystemFontOfSize:18];
    contentLabel.text = rowText;
    return contentLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [pickerView reloadAllComponents];
}

#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case kClearAlertViewTag:
        {
            if (1 == buttonIndex)
            {
                [self clearArrangListData];
            }
            break;
        }
        case kTakeNumAlertViewTag:
        {
            if (0 == buttonIndex)
            {
                [self addArrangData];
            }
            else if (1 == buttonIndex)
            {
                self.addArrangTextField.text = @"";
                self.phoneTextField.text = @"";
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
    self.queueTableView.scrollEnabled = NO;
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.queueTableView.scrollEnabled = YES;
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.addArrangTextField == textField)
    {
        if ((![NSString isValidateNumber:string]) || range.location >= kTakeNumberLength)
        {
            return NO;
        }
    }
    else if (self.phoneTextField == textField)
    {
        if ((![NSString isValidateNumber:string]) || range.location >= kPhoneNumberLength)
        {
            return NO;
        }
    }
    else if (self.searchPhoneNumberTextfield == textField)
    {
        if ((![NSString isValidateNumber:string]) || range.location >= kPhoneNumberLength)
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyBoard];
    
    if (self.searchPhoneNumberTextfield == textField) {
        
        self.mobileSearchNumber = textField.text;
        [self getArrangListDataWithAnimated:YES];
    }
    
    return YES;
}


#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pullDownRefreshView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullDownRefreshView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark Data Source Loading / Reloading Methods

- (void)doneLoadingTableViewData
{
	_reloading = NO;
	[pullDownRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.queueTableView];
}

//结束加载数据,无论是否成功加载数据
- (void)finishLoading
{
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doneLoadingTableViewData) userInfo:nil repeats:NO];
}

#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self getArrangListDataWithAnimated:NO];
}


-(void)egoRefreshTableHeaderDidTriggerLoadMore
{
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date];
}

#pragma mark - JsonPickerDelegate

- (void)updateQueueTableView:(SuperDataClass *)dataClass withIsAddFlag:(BOOL)isAddFlag
{
    [queueListArray removeAllObjects];
    if (isAddFlag)
    {
        QueueSuperDataClass *queueDataClass = [[QueueSuperDataClass alloc] initWithQueueSuperData:dataClass.dataDict];
        [queueListArray addObjectsFromArray:queueDataClass.queueListArray];
    }
    [self.queueTableView reloadData];
}

- (void)showWarningAlert:(SuperDataClass *)dataClass
{
    if (dataClass.alertMsg.length > 0) {
        [PSAlertView showWithMessage:dataClass.alertMsg];
    }
}

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
#ifdef DEBUG
    NSLog(@"===QueueMainViewController,dict:%@====",dict);
#endif
    
    SuperDataClass *superDataClass = [[SuperDataClass alloc] initWithData:dict];
    NSLog(@"****%@",dict);
    int responseStatus = superDataClass.responseStatus;
    
    switch (picker.tag)
    {
        case kJsonPickerFirstTag:
        {
            switch (responseStatus)
            {
                case 200:
                {
                    [self updateQueueTableView:superDataClass withIsAddFlag:YES];
                    
                    break;
                }
                case 201:
                {
                    [self updateQueueTableView:superDataClass withIsAddFlag:NO];
                    
                    break;
                }
                default:
                {
                    [self showWarningAlert:superDataClass];
                    
                    break;
                }
            }
            
            break;
        }
        case kJsonPickerSecondTag:
        {
            switch (responseStatus)
            {
                case 200:
                {
                    
                    self.searchPhoneNumberTextfield.text = @"";
                    self.mobileSearchNumber = @"";
                    
                    [self updateQueueTableView:superDataClass withIsAddFlag:YES];
                    
                    break;
                }
                default:
                {
                    [self showWarningAlert:superDataClass];
                    
                    break;
                }
            }
            
            break;
        }
        case kJsonPickerThirdTag:
        {
            switch (responseStatus)
            {
                case 200:
                {
                    self.searchPhoneNumberTextfield.text = @"";
                    self.mobileSearchNumber = @"";
                    
                    [self updateQueueTableView:superDataClass withIsAddFlag:YES];
                    
                    break;
                }
                case 203:
                {
                    
                    self.searchPhoneNumberTextfield.text = @"";
                    self.mobileSearchNumber = @"";
                    
                    [self updateQueueTableView:superDataClass withIsAddFlag:YES];
                    
                    break;
                }
                default:
                {
                    [self showWarningAlert:superDataClass];
                    
                    break;
                }
            }
            
            break;
        }
        case kJsonPickerFourthTag:
        {
            switch (responseStatus)
            {
                    //保存成功
                case 200:
                {
                    self.addArrangTextField.text = @"";
                    self.phoneTextField.text = @"";
                    
                    self.mobileSearchNumber = @"";
                    self.searchPhoneNumberTextfield.text = @"";
                    
                    [self printArrangInfo:superDataClass.dataDict];
                    [self updateQueueTableView:superDataClass withIsAddFlag:YES];
                    
                    break;
                }
                    //保存失败
                default:
                {
                    [self showWarningAlert:superDataClass];
                    
                    break;
                }
            }
            
            break;
        }
            
        case kJsonPickerSixthTag:// 获取可用房台
        {
            switch (responseStatus)
            {
                // 获取成功
                case 200:
                {
                    NSArray *dinnerTables = [superDataClass.dataDict objectForKey:@"diningTable"];
                    if ([dinnerTables isKindOfClass:[NSArray class]] == NO || dinnerTables.count == 0) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                            message:kLoc(@"has_not_available_table")
                                                                           delegate:nil
                                                                  cancelButtonTitle:kLoc(@"confirm")
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    } else {
                        if (dinnerTableSource_ == nil) {
                            dinnerTableSource_ = [[NSMutableArray alloc] init];
                        }
                        [dinnerTableSource_ removeAllObjects];
                        [dinnerTableSource_ addObjectsFromArray:dinnerTables];
                        
                        NSString *title = [NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n",
                                           kLoc(@"select_table")];
                        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                                 delegate:self
                                                                        cancelButtonTitle:kLoc(@"cancel")
                                                                   destructiveButtonTitle:nil
                                                                        otherButtonTitles:kLoc(@"confirm"), nil];
                        actionSheet.tag = kChooseTableActionSheetTag;
                        
                        UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 0.0, 270.0, 300.0)];
                        if (kIsiPhone) {
                            picker.frame = CGRectMake(0.0, 0.0, actionSheet.bounds.size.width, 300.0);
                        }
                        
                        picker.dataSource = self;
                        picker.delegate = self;
                        picker.showsSelectionIndicator = YES;
                        [actionSheet addSubview:picker];
                        
                        [actionSheet showInView:self.view.window];
                    }
                    break;
                }
                // 获取失败
                default:
                {
                    [self showWarningAlert:superDataClass];
                    
                    break;
                }
            }
            
            break;
        }
            
        case kJsonPickerSevenTag:// 按手机号码搜索
        {
            switch (responseStatus)
            {
                    //保存成功
                case 200:
                {
                    [self updateQueueTableView:superDataClass withIsAddFlag:YES];
                    break;
                }
                    //保存失败
                default:
                {
                    [self showWarningAlert:superDataClass];
                    
                    break;
                }
            }
            
            break;
        }
            
        case kJsonPickerEighthTag: {
            // 房台入座
            switch (responseStatus)
            {
                case 200: {
                    // 入座成功
                    [self updateQueueTableView:superDataClass withIsAddFlag:YES];
                    
                    self.searchPhoneNumberTextfield.text = @"";
                    
                    // 通知房台页面更新UI
                    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateDinningTableList
                                                                        object:nil
                                                                      userInfo:nil];
                    
                    if (superDataClass.alertMsg.length > 0) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                            message:superDataClass.alertMsg
                                                                           delegate:nil
                                                                  cancelButtonTitle:kLoc(@"confirm")
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    }
                    
                    break;
                }
                case 201: {
                    // 入座失败
                    if (superDataClass.alertMsg.length > 0) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                            message:superDataClass.alertMsg
                                                                           delegate:nil
                                                                  cancelButtonTitle:kLoc(@"confirm")
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    }
                    break;
                }
                case 202: {
                    // 入座失败，排号已处理过，需要刷新排号数据
                    [self updateQueueTableView:superDataClass withIsAddFlag:NO];
                    
                    if (superDataClass.alertMsg.length > 0) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                            message:superDataClass.alertMsg
                                                                           delegate:nil
                                                                  cancelButtonTitle:kLoc(@"confirm")
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    }
                    break;
                }
                case 203: {
                    // 入座失败，房台不可用，需要刷新房台数据
                    NSArray *dinnerTables = [superDataClass.dataDict objectForKey:@"diningTable"];
                    if ([dinnerTables isKindOfClass:[NSArray class]] == NO || dinnerTables.count == 0) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                            message:kLoc(@"has_not_available_table")
                                                                           delegate:nil
                                                                  cancelButtonTitle:kLoc(@"confirm")
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    } else {
                        if (dinnerTableSource_ == nil) {
                            dinnerTableSource_ = [[NSMutableArray alloc] init];
                        }
                        [dinnerTableSource_ removeAllObjects];
                        [dinnerTableSource_ addObjectsFromArray:dinnerTables];
                        
                        NSString *title = [NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n",
                                           kLoc(@"select_table")];
                        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                                 delegate:self
                                                                        cancelButtonTitle:kLoc(@"cancel")
                                                                   destructiveButtonTitle:nil
                                                                        otherButtonTitles:kLoc(@"confirm"), nil];
                        actionSheet.tag = kChooseTableActionSheetTag;
                        
                        UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 0.0, 270.0, 300.0)];
                        if (kIsiPhone) {
                            picker.frame = CGRectMake(0.0, 0.0, actionSheet.bounds.size.width, 300.0);
                        }
                        picker.dataSource = self;
                        picker.delegate = self;
                        picker.showsSelectionIndicator = YES;
                        [actionSheet addSubview:picker];
                        
                        [actionSheet showInView:self.view.window];
                    }
                    break;
                }
                default: {
                    [self showWarningAlert:superDataClass];
                    
                    break;
                }
                    
                    break;
            }
        }

        default:
            break;
    }
    [self finishLoading];
}


// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error
{
    [self finishLoading];
}


// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error
{
    [self finishLoading];
}



@end
