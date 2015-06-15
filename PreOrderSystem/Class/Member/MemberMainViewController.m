//
//  MemberMainViewController.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-24.
//
//

#import "MemberMainViewController.h"
#import "Constants.h"
#import "CouponHeadTableViewCell.h"
#import "CouponTableViewCell.h"
#import "CouponUseHeadTableViewCell.h"
#import "CouponUseTableViewCell.h"
#import "EGORefreshTableHeaderView.h"
//#import "EGORefreshTableFootView.h"
#import "JsonPicker.h"
#import "SuperDataClass.h"
#import "MemberSuperDataClass.h"
#import "PSAlertView.h"
#import "NsstringAddOn.h"
#import "MainViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "MemberLookDishViewController.h"
#import "Reachability.h"
#import "AdvancedSearchViewController.h"
#import "MBProgressHUD.h"
#import "OrderListLoadMoreCell.h"
#import "UITextFieldAddition.h"

#define kDefaultTimeTypeIndex (-1)
#define kCouponTypeBtnTag 1000
#define kTimeTypeBtnTag 2000
#define kStartTimeActionSheetTag 3000
#define kEndTimeActionSheetTag 3100
#define kStartTimeDatePickerTag 4000
#define kEndTimeDatePickerTag 4100
#define kExportActionSheetTag 4200
#define kSendEmailAlertViewTag 4300
#define kPhoneNumberLength 11


@interface MemberMainViewController ()<UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, /*EGORefreshTableFootDelegate, */JsonPickerDelegate, UITextFieldDelegate, UIActionSheetDelegate, CouponUseHeadTableViewCellDelegate, CouponUseTableViewCellDelegate, MemberLookDishViewControllerDelegate, MBProgressHUDDelegate,AdvancedSearchViewControllerDelegate>
{
    BOOL _reloading;//下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGORefreshTableFootView *_refreshFootView;//加载更多
    JsonPicker *jsonPicker;
    MemberSuperDataClass *memberDataClass;
    NSInteger currentCouponTypeIndex;
    NSInteger currentTimeTypeIndex;
    MBProgressHUD *saveZipFileHUD;
    NSMutableArray *useCouponArray;
    NSDictionary *exportDict;//保存导出的数据
    NSMutableDictionary *_loadDict;//保存下载到的数据
    OrderListLoadMoreCell *loadMoreOrdersCell;
}

@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *advancedSearch;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (nonatomic, weak) IBOutlet UIButton *couponButton;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIButton *exportButton;
@property (nonatomic, weak) IBOutlet UITableView *memberTableView;

@end

@implementation MemberMainViewController

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
    [self.mobileTextField bindCloseButton];
    
    self.mobileTextField.delegate = self;
    
    [self.dateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    currentCouponTypeIndex = kCouponTypeBtnTag;
    currentTimeTypeIndex = kDefaultTimeTypeIndex;
    self.bgImageView.frame = CGRectMake(self.bgImageView.frame.origin.x, self.bgImageView.frame.origin.y, 820.5, self.bgImageView.frame.size.height);
    [self addPictureToView];
    [self addLocalizedString];
    [self addPullDownReFresh];
    [self getFirstPageData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"member_coupons_usage") forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dateButtonClick:(id)sender
{
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    [self.mobileTextField resignFirstResponder];
    // 并联手机号码搜索
    self.mobileSearchNumber = self.mobileTextField.text;
    
    // 清空高级搜索的条件
    for (int i = 0; i < memberDataClass.couponTypeArray.count; i++) {
        MemberCouponTypeDataClass *typeClass = [memberDataClass.couponTypeArray objectAtIndex:i];
        typeClass.isChecked = (i == 0);
    }
    memberDataClass.startDate = @"";
    memberDataClass.endDate = @"";
    memberDataClass.dateStrIndex = -1;

    // 获取数据
    [self getMemberInfoData:memberDataClass.useCurrentPage withAnimated:YES];
}

- (IBAction)advancedSearchButtonClick:(id)sender
{
    [self.mobileTextField resignFirstResponder];
    //高级搜索
    AdvancedSearchViewController *vc = [[AdvancedSearchViewController alloc] initWithNibName:@"AdvancedSearchViewController" bundle:nil];
    vc.delegate = self;
    vc.memberDataClass = memberDataClass;
    [[MainViewController getMianViewShareInstance] presentPopupViewController:vc animationType:MJPopupViewAnimationSlideBottomBottom];
    // 缩放视图
    scaleView(vc.view);
}

- (void)addPictureToView
{
    self.bgImageView.image = LoadImageWithPNGType(@"member_frameBg");
    [self.couponButton setBackgroundImage:LoadImageWithPNGType(@"member_couponBtn") forState:UIControlStateNormal];
    [self.exportButton setBackgroundImage:LoadImageWithPNGType(@"more_shortButton") forState:UIControlStateNormal];
    [self.advancedSearch setBackgroundImage:LoadImageWithPNGType(@"more_shortButton") forState:UIControlStateNormal];
    [self.dateButton setBackgroundImage:LoadImageWithPNGType(@"more_shortButton") forState:UIControlStateSelected];
}

- (void)addLocalizedString
{
    [self.couponButton setTitle:kLoc(@"coupons_usage") forState:UIControlStateNormal];
    [self.exportButton setTitle:kLoc(@"export") forState:UIControlStateNormal];
    [self.advancedSearch setTitle:kLoc(@"advanced_search") forState:UIControlStateNormal];
    self.mobileTextField.placeholder = kLoc(@"phone_number");
}

//利用正则表达式验证格式是否是数字
+ (BOOL)isValidateNumber:(NSString *)numString
{
    NSString *emailRegex = @"[0-9]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:numString];
}

//下拉刷新
- (void)addPullDownReFresh
{
    _reloading = NO;
    if (!_refreshHeaderView)
    {
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.memberTableView.bounds.size.height, self.memberTableView.frame.size.width, self.memberTableView.bounds.size.height)];
		_refreshHeaderView.delegate = self;
        _refreshHeaderView.backgroundColor = [UIColor clearColor];
		[self.memberTableView addSubview:_refreshHeaderView];
	}
	[_refreshHeaderView refreshLastUpdatedDate];
}
/*
//上拉加载更多
- (void)addPullUpLoadMore
{
    _reloading = NO;
    if (_refreshFootView == nil)
    {
		_refreshFootView = [[EGORefreshTableFootView alloc] initWithFrame: CGRectMake(0.0f, self.memberTableView.bounds.size.height, self.memberTableView.frame.size.width, self.memberTableView.bounds.size.height)];
		_refreshFootView.delegate = self;
        _refreshFootView.backgroundColor = [UIColor clearColor];
		[self.memberTableView addSubview:_refreshFootView];
	}
}
*/
- (void)updateMemberView
{
    if (!useCouponArray) {
        useCouponArray = [[NSMutableArray alloc] init];
    }
    if (1 >= memberDataClass.useCurrentPage) {
        [useCouponArray removeAllObjects];
    }
    for (MemberUseCountDataClass *useCountClass in memberDataClass.useCountArray) {
        [useCouponArray addObject:useCountClass];
    }
    [self.memberTableView reloadData];
}

- (void)updateDate:(NSDictionary *)dataDict
{
    NSDictionary *dict = nil;
    if (dataDict) {
        if ([dataDict objectForKey:@"data"]) {
            dict = [[dataDict objectForKey:@"data"] objectForKey:@"dateButton"];
        }
    }
    
    if (dict) {
        NSString *string = [dict objectForKey:@"name"];
        [self.dateButton setTitle:kLoc(string) forState:UIControlStateNormal];
//        [self.dateButton setTitle:[dict objectForKey:@"name"] forState:UIControlStateSelected];
    }
}

//显示时间ActionSheet
- (void)showStartTimeActionSheet:(NSInteger)actionSheetTag withDatePickerDate:(NSDate *)pickerDate withDatePickerTag:(NSInteger)datePickerTag withRect:(CGRect)showRect
{
    NSString *title = @"";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
    actionSheet.tag = actionSheetTag;
    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-15.0, 0.0, 320.0, 216.0)];
    if (kIsiPhone) {
        picker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
    }
    picker.backgroundColor = [UIColor clearColor];
    picker.tag = datePickerTag;
    picker.datePickerMode = UIDatePickerModeDate;
    picker.date = pickerDate;
    [actionSheet addSubview:picker];
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:showRect inView:self.view animated:YES];
    }
}

//联网获取第一页数据
- (void)getFirstPageData
{
    memberDataClass.useCurrentPage = 1;
    [self getMemberInfoData:memberDataClass.useCurrentPage withAnimated:YES];
}

- (void)showExportActionSheet
{
    UIActionSheet *exportActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:kLoc(@"save_to_local"),kLoc(@"send_to_email"), nil];
    exportActionSheet.tag = kExportActionSheetTag;
    
    [exportActionSheet showInView:self.view.window];
}

#pragma mark - UIButton Clicked

- (IBAction)exportBtnClicked:(id)sender
{
    [self.mobileTextField resignFirstResponder];
    [self exportMemberInfoData:YES];
}

#pragma mark - Network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

//获取订座订单列表
-(void)getMemberInfoData:(NSInteger)page withAnimated:(BOOL)animated
{
    // 优惠券类型
    NSNumber *couponType = nil;
    for (MemberCouponTypeDataClass *typeClass in memberDataClass.couponTypeArray) {
        if (typeClass.isChecked) {
            couponType = [NSNumber numberWithInt:[typeClass.value intValue]];
            break;
        }
    }
    
    NSString *startDate = (memberDataClass.startDate ? memberDataClass.startDate : @"");
    NSString *endDate =  (memberDataClass.endDate ? memberDataClass.endDate : @"");
    
    if (self.dateButton.selected) {
        // 日期数据
        NSDictionary *dict = nil;
        if (_loadDict) {
            if ([_loadDict objectForKey:@"data"]) {
                dict = [[_loadDict objectForKey:@"data"] objectForKey:@"dateButton"];
            }
        }
        
        if (dict) {
            startDate = [dict objectForKey:@"start"];
            endDate = [dict objectForKey:@"end"];
        }
    }
    
    // 排序字段
    NSMutableDictionary *sortDict = nil;
    if (memberDataClass.currentSortClass) {
        sortDict = [[NSMutableDictionary alloc] init];
        [sortDict setObject:memberDataClass.currentSortClass.fieldStr forKey:@"field"];
        [sortDict setObject:[NSNumber numberWithBool:memberDataClass.currentSortClass.orderFlag]
                     forKey:@"order"];
    }
    
    // 开始时间和结束时间
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[NSNumber numberWithInt:(int)page] forKey:@"page"];
    [postData setObject:startDate forKey:@"startDate"];
    [postData setObject:endDate forKey:@"endDate"];
    
    if (sortDict) {
        [postData setObject:sortDict forKey:@"sort"];
    }
    
    if (couponType != nil) {
        [postData setObject:couponType forKey:@"type"];
    }
    
    // 更新搜索内容
    self.mobileTextField.text = self.mobileSearchNumber;
    if ([self.mobileSearchNumber length] > 0) {
        [postData setObject:self.mobileSearchNumber forKey:@"mobile"];
    }
    
    if (nil == jsonPicker) {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = YES;
    jsonPicker.loadingMessage = kLoc(@"updating_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:@"member/getCouponCount"];
}

// 导出优惠
-(void)exportMemberInfoData:(BOOL)animated
{
    NSString *startDate = (memberDataClass.startDate ? memberDataClass.startDate : @"");
    NSString *endDate =  (memberDataClass.endDate ? memberDataClass.endDate : @"");
    
    NSMutableDictionary *sortDict = nil;
    if (memberDataClass.currentSortClass) {
        sortDict = [[NSMutableDictionary alloc] init];
        [sortDict setObject:memberDataClass.currentSortClass.fieldStr forKey:@"field"];
        [sortDict setObject:[NSNumber numberWithBool:memberDataClass.currentSortClass.orderFlag] forKey:@"order"];
    }
   
    // 优惠券类型
    NSNumber *couponType = nil;
    for (MemberCouponTypeDataClass *typeClass in memberDataClass.couponTypeArray) {
        if (typeClass.isChecked) {
            couponType = [NSNumber numberWithInt:[typeClass.value intValue]];
            break;
        }
    }
    
    // 排序字段
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:startDate forKey:@"startDate"];
    [postData setObject:endDate forKey:@"endDate"];
    if (sortDict) {
        [postData setObject:sortDict forKey:@"sort"];
    }
    
    if (couponType != nil) {
        [postData setObject:couponType forKey:@"type"];
    }
    
    // 更新搜索内容
    self.mobileTextField.text = self.mobileSearchNumber;
    if ([self.mobileSearchNumber length] > 0) {
        [postData setObject:self.mobileSearchNumber forKey:@"mobile"];
    }
    
    if (nil == jsonPicker) {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerSecondTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.loadingMessage = kLoc(@"updating_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:@"member/exportCouponCount"];
}

//通过邮件接收导出的数据
- (void)submitExportToEmail:(NSString *)emailURLStr
{
    if ([NSString strIsEmpty:emailURLStr]) {
        emailURLStr = [exportDict objectForKey:@"email"];
        return;
    }
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[exportDict objectForKey:@"path"] forKey:@"path"];
    [postData setObject:emailURLStr forKey:@"email"];
    
    if (nil == jsonPicker) {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerThirdTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"updating_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = kLoc(@"submit_succeed");
    [jsonPicker postData:postData withBaseRequest:@"file/email"];
}

#pragma mark - 下载zip文件

- (void)downLoadZipFile
{
    if (![exportDict count]) {
        return;
    }
    
    // 判断网络，异步加载
    if ([[Reachability shareReachability] checkNetworking]) {
        if (!saveZipFileHUD) {
            saveZipFileHUD = [[MBProgressHUD alloc] initWithView:self.view];
            saveZipFileHUD.delegate = self;
            saveZipFileHUD.mode = MBProgressHUDModeIndeterminate;
            saveZipFileHUD.labelText = kLoc(@"saving_data_please_wait");
            [[MainViewController getMianViewShareInstance].view addSubview:saveZipFileHUD];
        }
        [saveZipFileHUD show:YES];
        
        NSString *fileName = [exportDict objectForKey:@"name"];
        NSURL *url = [NSURL URLWithString:[exportDict objectForKey:@"url"]];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
             if ([data length] > 0  &&  error == nil) {
                 NSString *filePath = [self zipFilePath:fileName];
                 BOOL isTrue = [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
                 [saveZipFileHUD hide:YES];
                 if (isTrue) {
                     NSString *titleStr = [NSString stringWithFormat:@"%@:%@", kLoc(@"file_path"), filePath];
                     UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:titleStr message:nil delegate:nil cancelButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
                     [alertView show];
                 } else {
                     [saveZipFileHUD hide:YES];
                     [PSAlertView showWithMessage:kLoc(@"save_failed")];
                 }
             } else {
                 [saveZipFileHUD hide:YES];
                 [PSAlertView showWithMessage:kLoc(@"save_failed")];
             }
         }];
    }
}

- (NSString *)zipFilePath:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentPath, fileName];
    return filePath;
}

#pragma mark - MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[saveZipFileHUD removeFromSuperview];
	saveZipFileHUD = nil;
}

#pragma mark - UITableViewController datasource & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger indexSection = indexPath.section;
    NSInteger indexRow = indexPath.row;
    if (kTableViewFirstSection == indexSection) {
        if (kTableViewFirstRow == indexRow) {
            static NSString *cellIdentifier = kCouponHeadTableViewCellReuseIdentifier;
            CouponHeadTableViewCell *cell = (CouponHeadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"CouponHeadTableViewCell" owner:self options:nil] lastObject];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell updateCouponHeadCell];
            
            return cell;
        } else {
            static NSString *cellIdentifier = kCouponTableViewCellReuseIdentifier;
            CouponTableViewCell *cell = (CouponTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"CouponTableViewCell" owner:self options:nil] lastObject];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            NSInteger typeCountIndex = indexRow - 1;//减去head
            [cell updateCouponCell:[memberDataClass.typeCountArray objectAtIndex:typeCountIndex]];
            
            return cell;
        }
    } else {
        if (kTableViewFirstRow == indexRow) {
            static NSString *cellIdentifier = kCouponUseHeadTableViewCellReuseIdentifier;
            CouponUseHeadTableViewCell *cell = (CouponUseHeadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"CouponUseHeadTableViewCell" owner:self options:nil] lastObject];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.delegate = self;
            [cell updateCouponUserHeadCell:memberDataClass.currentSortClass];
            
            return cell;
        } else {
            if (indexPath.row == 1 + [useCouponArray count]) {
                if (loadMoreOrdersCell == nil) {
                    loadMoreOrdersCell = [[[NSBundle mainBundle] loadNibNamed:@"OrderListLoadMoreCell" owner:self options:nil] lastObject];
                    loadMoreOrdersCell.selectionStyle = UITableViewCellSelectionStyleGray;
                    [loadMoreOrdersCell loadText:kLoc(@"member_more_message_wait")];
                }

                return loadMoreOrdersCell;
            }
            
            static NSString *cellIdentifier = kCouponUseTableViewCellReuseIdentifier;
            CouponUseTableViewCell *cell = (CouponUseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"CouponUseTableViewCell" owner:self options:nil] lastObject];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            NSInteger useCountIndex = indexRow - 1;//减去head
            cell.tag = useCountIndex;
            cell.delegate = self;
            [cell updateCouponUseCell:[useCouponArray objectAtIndex:useCountIndex]];
            
            return cell;
        }
        
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger cellRow = 0;
    if (kTableViewFirstSection == section && [memberDataClass.typeCountArray count]) {
        /*head + cell*/
        cellRow = 1 + [memberDataClass.typeCountArray count];
    } else if (kTableViewSecondSection == section && [memberDataClass.typeCountArray count]) {
        /*head + cell + 加载更多*/
//        int i =memberDataClass.useCurrentPage;
//        int k = memberDataClass.useTotalPage;
        if (memberDataClass.useCurrentPage < memberDataClass.useTotalPage) {
            cellRow = 2 + [useCouponArray count];
        } else {
            /*head + cell*/
            cellRow = 1 + [useCouponArray count];
        }
    }
    return cellRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kTableViewFirstRow == indexPath.row) {
        if (kTableViewSecondSection == indexPath.section) {
            return 40;
        } else {
            return 30;
        }
    } else if (kTableViewSecondSection == indexPath.section &&
               indexPath.row == 1 + [useCouponArray count]) {
        return 80.0;
    }
    return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (kTableViewFirstSection == section && kZeroNumber == [memberDataClass.typeCountArray count] && kZeroNumber == [useCouponArray count])
    {
        int viewHeight = 100;
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.memberTableView.frame.size.width, viewHeight)];
        aView.backgroundColor = [UIColor clearColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, self.memberTableView.frame.size.width, viewHeight - 40)];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (kTableViewFirstSection == section && kZeroNumber == [memberDataClass.typeCountArray count] && kZeroNumber == [useCouponArray count])
    {
        return 100;
    }
    else
    {
        return 0;
    }
}

#pragma mark - CouponUseTableViewCellDelegate

- (void)couponUseHeadTableViewCell:(CouponUseHeadTableViewCell *)cell withSortHavedChanged:(BOOL)openFlag
{
    [self.mobileTextField resignFirstResponder];
    [self.memberTableView reloadData];
    [self getFirstPageData];
}

#pragma mark - CouponUseTableViewCellDelegate

- (void)couponUseTableViewCell:(CouponUseTableViewCell *)cell withDetailBtnClicked:(NSInteger)cellIndex
{
    MemberLookDishViewController *lookDishVC = [[MemberLookDishViewController alloc]initWithNibName:@"MemberLookDishViewController" bundle:nil];
    lookDishVC.delegate = self;
    lookDishVC.useCountDataClass = [useCouponArray objectAtIndex:cellIndex];
    [[MainViewController getMianViewShareInstance] presentPopupViewController:lookDishVC animationType:MJPopupViewAnimationSlideBottomBottom];
    // 缩放视图
    scaleView(lookDishVC.view);
}

#pragma mark - MemberLookDishViewControllerDelegate

-(void)dismissMemberLookDishViewController
{
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

#pragma mark Data Source Loading Methods

- (void)doneLoadingTableViewData
{
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.memberTableView];
}

//结束加载数据,无论是否成功加载数据
- (void)finishLoading
{
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doneLoadingTableViewData) userInfo:nil repeats:NO];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self.mobileTextField resignFirstResponder];
    [self getFirstPageData];
}

-(void)egoRefreshTableHeaderDidTriggerLoadMore
{
    NSInteger currentPage = memberDataClass.useCurrentPage;
    currentPage++;
    if (currentPage <= memberDataClass.useTotalPage)
    {
        memberDataClass.useCurrentPage = currentPage;
        if (loadMoreOrdersCell == nil)
        {
            [loadMoreOrdersCell startLoading:kLoc(@"member_more_message_wait")];
        }

        [self getMemberInfoData:currentPage withAnimated:YES];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

/*
#pragma mark EGORefreshTableFootViewDelegate Methods

- (void)egoRefreshTableFootDidTriggerRefresh:(EGORefreshTableFootView*)view
{
	memberDataClass.useCurrentPage++;
    [self getMemberInfoData:memberDataClass.useCurrentPage withAnimated:YES];
}

- (BOOL)egoRefreshTableFootDataSourceIsLoading:(EGORefreshTableFootView*)view
{
	return _reloading;
}
 */

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.mobileTextField isEqual:textField]) {
        [textField resignFirstResponder];
        
        // 清空高级搜索的条件
        for (int i = 0; i < memberDataClass.couponTypeArray.count; i++) {
            MemberCouponTypeDataClass *typeClass = [memberDataClass.couponTypeArray objectAtIndex:i];
            typeClass.isChecked = (i == 0);
        }
        memberDataClass.startDate = @"";
        memberDataClass.endDate = @"";
        memberDataClass.dateStrIndex = -1;
        
        // 保存搜索条件
        self.mobileSearchNumber = self.mobileTextField.text;
        
        [self getMemberInfoData:memberDataClass.useCurrentPage withAnimated:YES];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.mobileTextField == textField) {
        if ((![NSString isValidateNumber:string]) || range.location >= kPhoneNumberLength) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case kExportActionSheetTag: {
            //保存到本地
            if (0 == buttonIndex) {
                [self downLoadZipFile];
            } else if(1 == buttonIndex) {
                // 发送到邮箱
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:nil
                                                                  delegate:self
                                                         cancelButtonTitle:kLoc(@"cancel")
                                                         otherButtonTitles:kLoc(@"confirm"), nil];
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *addTextField = [alertView textFieldAtIndex:0];
                addTextField.text = [exportDict objectForKey:@"email"];
                addTextField.clearButtonMode = UITextFieldViewModeAlways;
                alertView.tag = kSendEmailAlertViewTag;
                [alertView show];
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kSendEmailAlertViewTag: {
            if (0 == buttonIndex) {
                //[self showExportActionSheet];
            } else {
                NSString *newAddress = [[alertView textFieldAtIndex:0].text
                                        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [self submitExportToEmail:newAddress];
            }
            break;
        }
    }
}

#pragma mark - JsonPickerDelegate

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    if (_loadDict == nil)
    {
        _loadDict = [[NSMutableDictionary alloc] init];
    }
    [_loadDict removeAllObjects];
    [_loadDict setDictionary:dict];
    SuperDataClass *superClass = [[SuperDataClass alloc] initWithData:dict];
    NSInteger responseStatus = superClass.responseStatus;
    if (kJsonPickerFirstTag == picker.tag)
    {
        switch (responseStatus)
        {
            case 200:
            {
                // 不需要替换开始时间、结束时间和时间字符串的索引
                NSString *tempStartDateStr = memberDataClass.startDate;
                NSString *tempEndDateStr = memberDataClass.endDate;
                NSInteger tempDateStrIndex = memberDataClass.dateStrIndex;
                if (memberDataClass == nil) {
                    tempDateStrIndex = -1;
                }
                memberDataClass = [[MemberSuperDataClass alloc] initWithMemberSuperData:superClass.dataDict];
                memberDataClass.startDate = tempStartDateStr;
                memberDataClass.endDate = tempEndDateStr;
                memberDataClass.dateStrIndex = tempDateStrIndex;
                [loadMoreOrdersCell stopLoading:kLoc(@"member_more_message_wait")];
                [self updateDate:_loadDict];
                [self updateMemberView];
                
                break;
            }
            default:
            {
                sleep(1.5);
                [PSAlertView showWithMessage:superClass.alertMsg];
                
                break;
            }
        }
    }
    else if (kJsonPickerSecondTag == picker.tag)
    {
        switch (responseStatus)
        {
            case 200:
            {
                exportDict = superClass.dataDict;
                [self performSelector:@selector(showExportActionSheet) withObject:nil afterDelay:0.5];
                
                break;
            }
            default:
            {
                sleep(1.5);
                [PSAlertView showWithMessage:superClass.alertMsg];
                
                break;
            }
        }
    }
    else if (kJsonPickerThirdTag == picker.tag)
    {
        switch (responseStatus)
        {
                //成功
            case 200:
            {
                
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:superClass.alertMsg];
                
                break;
            }
        }
    }
    [self finishLoading];
}

// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error{
    [self finishLoading];
}

// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error{
    [self finishLoading];
}


#pragma mark AdvancedSearchViewControllerDelegate

- (void)advancedSearchViewController:(AdvancedSearchViewController *)ctrl
{
    memberDataClass.useCurrentPage = 1;
    int page = (int)memberDataClass.useCurrentPage;
    
    // 优惠券类型
    NSNumber *couponType = nil;
    for (MemberCouponTypeDataClass *typeClass in memberDataClass.couponTypeArray) {
        if (typeClass.isChecked) {
            couponType = [NSNumber numberWithInt:[typeClass.value intValue]];
            break;
        }
    }
    
    // 排序信息
    NSMutableDictionary *sortDict = nil;
    if (memberDataClass.currentSortClass) {
        sortDict = [[NSMutableDictionary alloc] init];
        [sortDict setObject:memberDataClass.currentSortClass.fieldStr forKey:@"field"];
        [sortDict setObject:[NSNumber numberWithBool:memberDataClass.currentSortClass.orderFlag] forKey:@"order"];
    }
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [postData setObject:memberDataClass.startDate?memberDataClass.startDate:@"" forKey:@"startDate"];
    [postData setObject:memberDataClass.endDate?memberDataClass.endDate:@"" forKey:@"endDate"];
    
    // 清空手机号码和按钮状态
    self.mobileSearchNumber = @"";
    self.mobileTextField.text = @"";
    
    self.dateButton.selected = NO;
    
    if (sortDict) {
        [postData setObject:sortDict forKey:@"sort"];
    }
    
    if (couponType != nil) {
        [postData setObject:couponType forKey:@"type"];
    }
    
    if (nil == jsonPicker) {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowUpdateAlert = YES;
    jsonPicker.loadingMessage = kLoc(@"updating_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:@"member/getCouponCount"];
}

@end
