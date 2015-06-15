//
//  StaffManagementViewController.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-6.
//
//

#import "StaffManagementViewController.h"
#import "StaffManagementTableViewCell.h"
#import "JsonPicker.h"
#import "PSAlertView.h"
#import "SuperDataClass.h"
#import "StaffManagementSuperDataClass.h"
#import "Constants.h"
#import "StaffInfoViewController.h"
#import "UIViewController+ShowInView.h"
#import "MoreViewController.h"
#import "PostManagementViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "MainViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "NsstringAddOn.h"
#import "StaffSortStyleView.h"
#import "CustomPopoverTouchView.h"
#import "StaffManagementAlertView.h"

#define kDeleteAlertViewTag 1000

@interface StaffManagementViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, StaffManagementTableViewCellDelegate, JsonPickerDelegate, StaffInfoViewControllerDelegate, PostManagementViewControllerDelegate, EGORefreshTableHeaderDelegate, StaffSortStyleViewDelegate, CustomPopoverTouchViewDelegate, UIAlertViewDelegate>
{
    JsonPicker *jsonPicker;
    StaffManagementSuperDataClass *staffDataClass;
    StaffInfoViewController *addNewStaffInfoVC;
    StaffInfoViewController *editStaffInfoVC;
    BOOL _reloading;//下拉刷新
    EGORefreshTableHeaderView *pullDownRefreshView;
    NSInteger sortIndex;
    StaffSortStyleView *stylePickerView;
    CustomPopoverTouchView *customTouchView;
    /// 搜索字符串
    NSString *searchString_;
}

@property (nonatomic, weak) IBOutlet UIImageView *searchBgImageView;
@property (nonatomic, weak) IBOutlet UITextField *searchTextField;
@property (nonatomic, weak) IBOutlet UITextField *sortTextField;
@property (nonatomic, weak) IBOutlet UIButton *sortButton;
@property (nonatomic, weak) IBOutlet UITableView *staffTableView;
@property (nonatomic, weak) IBOutlet UIButton *addStaffButton;
@property (nonatomic, weak) IBOutlet UIButton *postManagementButton;

- (IBAction)sortBtnClicked:(UIButton*)sender;
- (IBAction)addStaffBtnClicked:(UIButton*)sender;
- (IBAction)postManagementBtnClicked:(UIButton *)sender;

@end

@implementation StaffManagementViewController

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
    
    sortIndex = -1;
    [self addPictureToView];
    [self addLocalizedString];
    [self addPullDownReFresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"more_staff_management") forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
    
    // 更新数据
    searchString_ = @"";
    self.sortTextField.text = @"";
    sortIndex = -1;
    self.sortTextField.placeholder = kLoc(@"filter");
    [self getStaffManagementInfoData:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (addNewStaffInfoVC && (!addNewStaffInfoVC.isTakePhoto))
    {
        [self staffInfoViewController:addNewStaffInfoVC didDismissView:nil];
    }
    if (editStaffInfoVC && (!editStaffInfoVC.isTakePhoto))
    {
        [self staffInfoViewController:editStaffInfoVC didDismissView:nil];
    }
}

- (void)addPictureToView
{
    self.searchBgImageView.image = LoadImageWithPNGType(@"more_staffSearchBg");
    [self.sortButton setBackgroundImage:LoadImageWithPNGType(@"more_staffSortBtnBg") forState:UIControlStateNormal];
    [self.postManagementButton setBackgroundImage:LoadImageWithPNGType(@"more_shortButton") forState:UIControlStateNormal];
    [self.addStaffButton setBackgroundImage:LoadImageWithPNGType(@"more_staffAdd") forState:UIControlStateNormal];
}

- (void)addLocalizedString
{
    [self.addStaffButton setTitle:kLoc(@"adds") forState:UIControlStateNormal];
    [self.postManagementButton setTitle:kLoc(@"position_management") forState:UIControlStateNormal];
    self.searchTextField.placeholder = kLoc(@"the_name");
    self.sortTextField.placeholder = kLoc(@"filter");
}

//下拉刷新
- (void)addPullDownReFresh
{
    _reloading = NO;
    if (!pullDownRefreshView)
    {
        pullDownRefreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.staffTableView.bounds.size.height, self.staffTableView.bounds.size.width, self.staffTableView.bounds.size.height)];
        pullDownRefreshView.delegate = self;
        pullDownRefreshView.backgroundColor = [UIColor clearColor];
        [self.staffTableView addSubview:pullDownRefreshView];
    }
    [pullDownRefreshView refreshLastUpdatedDate];
}

#pragma mark - UIButton Clicked

- (IBAction)sortBtnClicked:(UIButton*)sender
{
    [self.searchTextField resignFirstResponder];
    
    MainViewController *mainVC = [MainViewController getMianViewShareInstance];
    if (!customTouchView)
    {
        customTouchView = [[CustomPopoverTouchView alloc] initWithFrame:mainVC.view.frame];
    }
    customTouchView.delegate = self;
    [mainVC.view addSubview:customTouchView];
    
    if (!stylePickerView)
    {
        stylePickerView = [[StaffSortStyleView alloc] initWithFrame:CGRectZero];
    }
    stylePickerView.delegate = self;
    [stylePickerView showInView:mainVC.view withOriginPoint:kStaffSortStyleViewOrigin withAnimated:YES];
    [stylePickerView updateStaffSortStyleView:staffDataClass.sortArray];
}

- (IBAction)addStaffBtnClicked:(UIButton*)sender
{
    [self.searchTextField resignFirstResponder];
    
    self.view.hidden = YES;
    if (!addNewStaffInfoVC)
    {
        addNewStaffInfoVC = [[StaffInfoViewController alloc]init];
    }
    addNewStaffInfoVC.delegate = self;
    addNewStaffInfoVC.isAddNewStaff = YES;
    addNewStaffInfoVC.staffInfo = nil;
    addNewStaffInfoVC.postListArray = [NSMutableArray array];
    [addNewStaffInfoVC showInView:self.fatherVC withOriginPoint:kStaffInfoViewControllerOrigin withAnimated:NO];
}

- (IBAction)postManagementBtnClicked:(UIButton *)sender
{
    [self.searchTextField resignFirstResponder];
    
    PostManagementViewController *postVC = [[PostManagementViewController alloc] initWithNibName:@"PostManagementViewController" bundle:nil];
    postVC.delegate = self;
    [[MainViewController getMianViewShareInstance] presentPopupViewController:postVC animationType:MJPopupViewAnimationSlideBottomBottom];
    // 缩放视图
    scaleView(postVC.view);
}

#pragma mark - network

-(void)getStaffManagementInfoData:(BOOL)animated
{
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    
    if (searchString_.length > 0)
    {
        [postData setObject:searchString_ forKey:@"keyword"];
    }
    self.searchTextField.text = searchString_;
    
    if ((kZeroNumber < sortIndex) && (sortIndex < [staffDataClass.sortArray count]))
    {
        StaffManagementSortDataClass *sortClass = [staffDataClass.sortArray objectAtIndex:sortIndex];
        [postData setObject:sortClass.valueStr forKey:@"orderby"];
    }
    
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:@"user/getlist"];
}

-(void)deleteStaffData:(BOOL)animated withStaffId:(NSString *)staffIdStr
{
    if (nil == jsonPicker) {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerSecondTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:staffIdStr forKey:@"id"];
    [jsonPicker postData:postData withBaseRequest:@"user/del"];
}

#pragma mark - UITableViewController datasource & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"staffManagementCell";
    StaffManagementTableViewCell *cell = (StaffManagementTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil)
    {
        cell = [[StaffManagementTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    int indexRow = indexPath.row;
    cell.delegate = self;
    cell.tag = indexRow;
    
    NSArray *staffArray = staffDataClass.staffListArray;
    NSInteger staffCount = [staffArray count];
    StaffManagementStaffInfoDataClass *firstInfo = nil;
    StaffManagementStaffInfoDataClass *secondInfo = nil;
    const NSInteger firstIndex = indexRow * kStaffManagementCellHaveTwoSubCell;
    const NSInteger secondIndex = firstIndex + kStaffManagementCellSecondSubCellIndex;
    if (firstIndex < staffCount)
    {
        firstInfo = [staffArray objectAtIndex:firstIndex];
        if(secondIndex < staffCount)
        {
            secondInfo = [staffArray objectAtIndex:secondIndex];
        }
    }
    [cell updateStaffManagementCell:firstInfo withSecondStaffData:secondInfo];
    
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger staffCount = [staffDataClass.staffListArray count];
    NSInteger cellRow = 0;
    if (staffCount%kStaffManagementCellHaveTwoSubCell)
    {
        cellRow = staffCount/kStaffManagementCellHaveTwoSubCell + 1;
    }
    else
    {
        cellRow = staffCount/kStaffManagementCellHaveTwoSubCell;
    }
    return cellRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kStaffManagementCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (0 == [staffDataClass.staffListArray count])
    {
        const NSInteger viewHeight = 100;
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.staffTableView.frame.size.width, viewHeight)];
        aView.backgroundColor = [UIColor clearColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, self.staffTableView.frame.size.width, viewHeight - 40)];
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
    if ([staffDataClass.staffListArray count]==0)
    {
        return 100;
    }
    else
    {
        return 0;
    }
}

#pragma mark - StaffManagementTableViewCellDelegate

- (void)staffManagementTableViewCell:(StaffManagementTableViewCell *)cell withEidtData:(NSInteger)index
{
    [self.searchTextField resignFirstResponder];
    
    StaffManagementStaffInfoDataClass *staffClass = [[StaffManagementStaffInfoDataClass alloc] initWithStaffInfoClass:[staffDataClass.staffListArray objectAtIndex:index]];
    NSMutableArray *postArray = [[NSMutableArray alloc] initWithArray:staffDataClass.postArray];
    self.view.hidden = YES;
    if (!editStaffInfoVC)
    {
        editStaffInfoVC = [[StaffInfoViewController alloc]init];
    }
    editStaffInfoVC.delegate = self;
    editStaffInfoVC.isAddNewStaff = NO;
    editStaffInfoVC.staffInfo = staffClass;
    editStaffInfoVC.postListArray = postArray;
    [editStaffInfoVC showInView:self.fatherVC withOriginPoint:kStaffInfoViewControllerOrigin withAnimated:NO];
}

- (void)staffManagementTableViewCell:(StaffManagementTableViewCell *)cell withDeleteStaff:(NSString *)staffIdStr
{
    [self.searchTextField resignFirstResponder];
    
    StaffManagementAlertView *alertView = [[StaffManagementAlertView alloc]initWithTitle:kLoc(@"are_you_sure_to_delete") message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:kLoc(@"confirm"), kLoc(@"cancel"), nil];
    alertView.tag = kDeleteAlertViewTag;
    alertView.staffIdStr = staffIdStr;
    alertView.delegate = self;
    [alertView show];
}

#pragma mark - StaffInfoViewControllerDelegate

- (void)staffInfoViewController:(StaffInfoViewController*)ctrl didDismissView:(NSDictionary *)lastestStaffListData
{
    self.view.hidden = NO;
    
    if (self.view.superview != nil) {
        // 返回操作，更新标题
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        [info setObject:kLoc(@"more_staff_management") forKey:@"title"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
    }
    
    if (lastestStaffListData)
    {
        [self updateStaffManagementView:lastestStaffListData];
    }
    [ctrl dismissViewControllerWithAnimated:NO];
}

#pragma mark - PostManagementViewControllerDelegate

- (void)dismissPostManagementViewController:(PostManagementViewController *)ctrl withUpdateStaffListFlag:(BOOL)Flag
{
    if (Flag)
    {
        [self getStaffManagementInfoData:NO];
    }
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

#pragma mark - StaffSortStyleViewDelegate

- (void)sortStyleHavedSelected:(StaffSortStyleView *)styleView withSelectStyle:(NSString *)styleStr
{
    // 带上搜索框的条件
    searchString_ = self.searchTextField.text;
    
    self.sortTextField.text = styleStr;
    sortIndex = styleView.styleIndex;
    [self getStaffManagementInfoData:YES];
    [self customPopoverTouchView:nil touchesBegan:nil withEvent:nil];
}

#pragma mark - CustomPopoverTouchViewDelegate

- (void)customPopoverTouchView:(UIView *)view touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:customTouchView];
    CGRect touchRect = CGRectMake(kStaffSortStyleViewOrigin.x, kStaffSortStyleViewOrigin.y, stylePickerView.frame.size.width, stylePickerView.frame.size.height);
    if (!CGRectContainsPoint(touchRect, touchPoint))
    {
        [stylePickerView dismissViewWithAnimated:YES];
        [customTouchView removeFromSuperview];
    }
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (kZeroNumber == buttonIndex)
    {
        if (kDeleteAlertViewTag == alertView.tag)
        {
            NSString *staffIdStr = ((StaffManagementAlertView *)alertView).staffIdStr;
            [self deleteStaffData:YES withStaffId:staffIdStr];
        }
    }
}

#pragma mark - UITextFidld delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.sortTextField == textField) {
        [self sortBtnClicked:nil];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (self.searchTextField == textField) {
        searchString_ = [NSString getStrWithoutWhitespace:textField.text];
        [self getStaffManagementInfoData:YES];
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
	[pullDownRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.staffTableView];
}

//结束加载数据,无论是否成功加载数据
- (void)finishLoading
{
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doneLoadingTableViewData) userInfo:nil repeats:NO];
}

#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self getStaffManagementInfoData:NO];
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

- (void)updateStaffManagementView:(NSDictionary *)dict
{
    staffDataClass = [[StaffManagementSuperDataClass alloc] initWithStaffManagementSuperData:dict];
    [self.staffTableView reloadData];
}

- (void)handleFirstJsonPicker:(NSDictionary *)dict
{
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    switch (dataClass.responseStatus)
    {
        case kFirstResponseStatus:
        {
            [self updateStaffManagementView:dataClass.dataDict];
            
            break;
        }
        default:
        {
            [PSAlertView showWithMessage:dataClass.alertMsg];
            break;
        }
    }
}

- (void)handleSecondJsonPicker:(NSDictionary *)dict
{
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    switch (dataClass.responseStatus)
    {
        case kFirstResponseStatus:
        {
            [self updateStaffManagementView:dataClass.dataDict];
            [PSAlertView showWithMessage:dataClass.alertMsg];
            
            break;
        }
        default:
        {
            [PSAlertView showWithMessage:dataClass.alertMsg];
            break;
        }
    }
}

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    switch (picker.tag)
    {
        case kJsonPickerFirstTag:
        {
            [self handleFirstJsonPicker:dict];
            
            break;
        }
        case kJsonPickerSecondTag:
        {
            [self handleSecondJsonPicker:dict];
            
            break;
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

@end
