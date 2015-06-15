//
//  promotionMainViewController.m
//  PreOrderSystem
//
//  Created by SWen on 14-6-30.
//
//
#import "UIImage+imageWithContentsOfFile.h"
#import "promotionMainViewController.h"
#import "PromotionMainViewTableViewCell.h"
#import "PromotionSettingViewController.h"
#import "MainViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "JsonPicker.h"
#import "PSAlertView.h"
#import "NsstringAddOn.h"
#import "EGORefreshTableHeaderView.h"
#import "Constants.h"

#define kDateFirstFormat @"yyyy-MM-dd"
#define kStateActionSheetTag 1000

@interface promotionMainViewController () <PromotionMainViewTableViewCellDelegate,EGORefreshTableHeaderDelegate, UIActionSheetDelegate>
{
    NSMutableArray *_originPromoteActivityArray;
    NSMutableArray *_promoteActivityArray;
    NSMutableArray *_promoteCookbookGroupArray;
    JsonPicker *_jsonPicker;
    UIDatePicker *_datePicker;
    NSMutableArray *_activeStatusArray;// 存放（全部，有效，无效）
    NSMutableArray *_activeDataArray;//存放数据
    //下拉刷新
    BOOL _reloading;
    EGORefreshTableHeaderView *pullDownRefreshView;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *keyWordTextfield;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIImageView *searchBG;
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDateTextField;
@property (weak, nonatomic) IBOutlet UIButton *activeButton;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *promotionActivityLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (IBAction)activeBtnClick:(UIButton *)sender;
- (IBAction)sureBtnClick:(UIButton *)sender;
- (IBAction)addBtnClick:(UIButton *)sender;

@end

@implementation promotionMainViewController

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
    // Do any additional setup after loading the view from its nib.
    
    [self addLocalizedString];
    [self addPictureToView];
    [self addPullDownReFresh];
    [self getPromoteActivity:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:[NSString stringWithFormat:@"%@>%@",kLoc(@"menus"),kLoc(@"privilege_activity")] forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - PRIVATE METHODS

- (void)addLocalizedString
{
    self.keyWordTextfield.placeholder = kLoc(@"privilege_activity_name");
    self.startDateTextField.placeholder = kLoc(@"start_date");
    self.endDateTextField.placeholder = kLoc(@"end_date");
    self.numberLabel.text = kLoc(@"serial_number");
    self.promotionActivityLabel.text = kLoc(@"privilege_activity");
    self.timeLabel.text = kLoc(@"time_frame");
    self.stateLabel.text = kLoc(@"all");
    [self.sureButton setTitle:kLoc(@"back") forState:UIControlStateNormal];
}

- (void)addPictureToView
{
    self.stateImageView.image = [UIImage imageNamed:@"order_shopDownArrow"];
}
//下拉刷新
- (void)addPullDownReFresh
{
    _reloading = NO;
    
    if (!pullDownRefreshView)
    {
        pullDownRefreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        pullDownRefreshView.delegate = self;
        pullDownRefreshView.backgroundColor = [UIColor clearColor];
        [self.tableView addSubview:pullDownRefreshView];
    }
    
    [pullDownRefreshView refreshLastUpdatedDate];
}
-(void)showInView:(UIView*)aView
{
    self.view.alpha = 0.0f;
    [aView addSubview:self.view];
    [UIView beginAnimations:@"animationID" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationRepeatAutoreverses:NO];
    self.view.alpha = 1.0f;
    [UIView commitAnimations];
}

- (void)entryPromotionsettingViewWithRow:(NSInteger)row
{
    PromotionSettingViewController *vc = [[PromotionSettingViewController alloc] initWithNibName:@"PromotionSettingViewController" bundle:nil];
    vc.allCuisineDataArr = self.allCuisineDataArr;
    vc.promoteCookbookGroupArray = _promoteCookbookGroupArray;
    
    if (row >= 0)
    {
        vc.promoteActivity = _promoteActivityArray[row];
    }

    vc.sureBlock = ^(NSMutableDictionary *dict){
        [self getPromoteActivity:NO];
        [self.tableView reloadData];
    };
    
    [[MainViewController getMianViewShareInstance] presentPopupViewController:vc animationType:MJPopupViewAnimationSlideBottomBottom];
    // 缩放视图
    scaleView(vc.view);
}
- (void)hideKeyboard
{
    [self.keyWordTextfield resignFirstResponder];
}
// 日期选择器
- (void)datePickerCreate:(UITextField *)textField
{
    /*键盘在时，收起键盘*/
    [self hideKeyboard];
    
    NSString *title = @"";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
    
    if (textField == self.startDateTextField)
    {
        actionSheet.tag = 1;
    }
    else if(textField == self.endDateTextField)
    {
        actionSheet.tag = 2;
    }
    
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-15.0, 0.0, 320.0, 216.0)];
    if (kIsiPhone) {
        _datePicker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
    }
    _datePicker.backgroundColor = [UIColor clearColor];
    _datePicker.tag = 1;
    _datePicker.datePickerMode = UIDatePickerModeDate;
    //    picker.date = pickerDate;
    [actionSheet addSubview:_datePicker];
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:textField.frame inView:self.view animated:YES];
    }
}

#pragma mark --button click
- (IBAction)activeBtnClick:(UIButton *)sender
{
    [self hideKeyboard];
    
    sender.selected = !sender.selected;
    if (_activeStatusArray.count == 0) return;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (int i = 0; i < _activeStatusArray.count; i++)
    {
        NSString *string = [NSString stringWithFormat:@"%@" ,kLoc([_activeStatusArray[i] objectForKey:@"name"])];
        [actionSheet addButtonWithTitle:string];
    }
    
    actionSheet.tag = kStateActionSheetTag;
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:self.activeButton.frame inView:self.view animated:YES];
    }
}

- (IBAction)sureBtnClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(promotionMainViewController:didDismissView:)])
    {
        [self.delegate promotionMainViewController:self didDismissView:YES];
    }
    
    [self.view removeFromSuperview];
}


- (IBAction)addBtnClick:(UIButton *)sender
{
    [self entryPromotionsettingViewWithRow:-1];
}

#pragma mark - UITableViewController datasource & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"PromotionMainViewTableViewCell";
    PromotionMainViewTableViewCell *cell = (PromotionMainViewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PromotionMainViewTableViewCell" owner:self options:nil] lastObject];
	}
    
    cell.delegate = self;
    
    NSDictionary *dict = _promoteActivityArray[indexPath.row];
    [cell updateData:dict status:NO];
    
	return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _promoteActivityArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kPromotionMainViewTableViewCellHight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self entryPromotionsettingViewWithRow:indexPath.row];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case 1://startdate
        {
            //确定
            if (0 == buttonIndex)
            {
                NSString *dateStr = [NSString dateToNSString:_datePicker.date withFormat:kDateFirstFormat];
                self.startDateTextField.text = dateStr;
                if (self.startDateTextField.text.length && self.endDateTextField.text.length)
                {
                    [self getPromoteActivity:YES];
                }
            }
            
            break;
        }
            
        case 2://enddate
        {
            //确定
            if (0 == buttonIndex)
            {
                NSString *dateStr = [NSString dateToNSString:_datePicker.date withFormat:kDateFirstFormat];
                self.endDateTextField.text = dateStr;
                if (self.startDateTextField.text.length && self.endDateTextField.text.length)
                {
                    [self getPromoteActivity:YES];
                }
            }
            
            break;
        }
        case kStateActionSheetTag:
        {
            if (buttonIndex == 0)//全部
            {
                _promoteActivityArray = [[NSMutableArray alloc] initWithArray:_originPromoteActivityArray];
                self.stateLabel.text = [actionSheet buttonTitleAtIndex:buttonIndex];
                [_tableView reloadData];
            }
            else if (buttonIndex == 1)//有效
            {
                _promoteActivityArray = [[NSMutableArray alloc] init];
                for (NSDictionary *dict in _originPromoteActivityArray)
                {
                    int isActive = [[dict objectForKey:@"isActive"] intValue];
                    if (isActive)
                    {
                        [_promoteActivityArray addObject:dict];
                    }
                }
                self.stateLabel.text = [actionSheet buttonTitleAtIndex:buttonIndex];
                [_tableView reloadData];
                
            }
            else if (buttonIndex == 2)//无效
            {
                _promoteActivityArray = [[NSMutableArray alloc] init];
                for (NSDictionary *dict in _originPromoteActivityArray)
                {
                    int isActive = [[dict objectForKey:@"isActive"] intValue];
                    if (isActive == 0)
                    {
                        [_promoteActivityArray addObject:dict];
                    }
                }
                self.stateLabel.text = [actionSheet buttonTitleAtIndex:buttonIndex];
                [_tableView reloadData];
            }
            
            
        }
            
        default:
            break;
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
    if (actionSheet.tag == kStateActionSheetTag)
    {
        self.stateImageView.image = [UIImage imageNamed:@"order_shopUpArrow"];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kStateActionSheetTag)
    {
        self.stateImageView.image = [UIImage imageNamed:@"order_shopDownArrow"];
    }
}
#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.startDateTextField || textField == self.endDateTextField)
    {
        [self datePickerCreate: textField];
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self getPromoteActivity:YES];
    return YES;
}

#pragma mark -PromotionMainViewTableViewCellDelegate
- (void)PromotionMainViewTableViewCell:(PromotionMainViewTableViewCell *)cell didDeletedAtIndex:(NSInteger)index
{
    [_promoteActivityArray removeObjectAtIndex:index];
    [self.tableView reloadData];
}
#pragma mark Data Source Loading / Reloading Methods

- (void)doneLoadingTableViewData
{
	_reloading = NO;
	[pullDownRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

//结束加载数据,无论是否成功加载数据
- (void)finishLoading
{
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doneLoadingTableViewData) userInfo:nil repeats:NO];
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

#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self getPromoteActivity:NO];
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
#pragma mark - network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */
- (void)getPromoteActivity:(BOOL)animated
{
    if (!_jsonPicker)
    {
        _jsonPicker = [[JsonPicker alloc] init];
    }
    
    _jsonPicker.delegate = self;
    _jsonPicker.tag = 1;
    _jsonPicker.showActivityIndicator = animated;
    _jsonPicker.isShowUpdateAlert = YES;
    
    if (animated)
    {
        _jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    }
    else
    {
        _jsonPicker.loadingMessage = nil;
    }
    
    _jsonPicker.loadedSuccessfulMessage = nil;
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];

    NSString *startDateStr = self.startDateTextField.text;
    NSString *endDateStr = self.endDateTextField.text;
    NSString *keyWordStr = self.keyWordTextfield.text;
    if (!startDateStr) startDateStr = @"";
    if (!endDateStr) endDateStr = @"";
    if (!keyWordStr) keyWordStr = @"";
    [postData setObject:startDateStr forKey:@"fromDate"];
    [postData setObject:endDateStr forKey:@"toDate"];
    [postData setObject:keyWordStr forKey:@"name"];
    [_jsonPicker postData:postData withBaseRequest:@"CookbookPromote/getPromoteActivity"];
}

// 选择时间，网路请求
- (void)getPromoteActivityWhenSelectedDate:(BOOL)animated
{
    if (!_jsonPicker)
    {
        _jsonPicker = [[JsonPicker alloc] init];
    }
    
    _jsonPicker.delegate = self;
    _jsonPicker.tag = 2;
    _jsonPicker.showActivityIndicator = animated;
    _jsonPicker.isShowUpdateAlert = YES;
    
    if (animated)
    {
        _jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    }
    else
    {
        _jsonPicker.loadingMessage = nil;
    }
    
    _jsonPicker.loadedSuccessfulMessage = nil;
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:self.startDateTextField.text forKey:@"fromDate"];
    [postData setObject:self.endDateTextField.text forKey:@"toDate"];
    [postData setObject:self.keyWordTextfield.text forKey:@"name"];
    [_jsonPicker postData:postData withBaseRequest:@"CookbookPromote/getPromoteActivity"];
}
#pragma mark - JsonPickerDelegate
-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    if (picker.tag==1)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        NSDictionary *dataDict = [dict objectForKey:@"data"];
        
        switch (responseStatus)
        {
            case 200:
            {
                NSArray *tempArray = [dataDict objectForKey:@"promoteActivity"];
                _originPromoteActivityArray = [[NSMutableArray alloc] initWithArray:tempArray];
                _promoteActivityArray = [[NSMutableArray alloc] initWithArray:tempArray];
                
                tempArray = [dataDict objectForKey:@"promoteCookbookGroup"];
                _promoteCookbookGroupArray = [[NSMutableArray alloc] initWithArray:tempArray];
                
                //有效，无效，全部
                _activeStatusArray = [[NSMutableArray alloc] initWithArray:[dataDict objectForKey:@"filtrate"]];
                //刷新
                [_tableView reloadData];
                break;
            }
                
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                break;
            }
        }
    }
    else if (picker.tag == 2)//时间选择
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        NSDictionary *dataDict = [dict objectForKey:@"data"];
        
        switch (responseStatus)
        {
            case 200:
            {
                NSArray *tempArray = [dataDict objectForKey:@"promoteActivity"];
                _originPromoteActivityArray = [[NSMutableArray alloc] initWithArray:tempArray];
                _promoteActivityArray = [[NSMutableArray alloc] initWithArray:tempArray];
                
                tempArray = [dataDict objectForKey:@"promoteCookbookGroup"];
                _promoteCookbookGroupArray = [[NSMutableArray alloc] initWithArray:tempArray];
                
                //有效，无效，全部
                _activeStatusArray = [[NSMutableArray alloc] initWithArray:[dataDict objectForKey:@"filtrate"]];
                //刷新
                [_tableView reloadData];
                break;
            }
                
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
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

@end
