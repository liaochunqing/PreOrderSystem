//
//  DiscountViewController.m
//  PreOrderSystem
//
//  Created by mac on 14-7-1.
//
//

#import "DiscountViewController.h"
#import "Constants.h"
#import "DiscountViewControllerTableViewCell.h"
#import "PromoteCookBookDataModel.h"
#import "PSAlertView.h"
#import "PromoteCookBookGroupDataModel.h"
#import "CuisineDataModel.h"
typedef enum
{
    kAlertFirstTag = 100580,
    kAlertSecondTag,
    kAlertThirdTag,
}kAlertTag;

@interface DiscountViewController ()
{
    JsonPicker *jsonPicker;
    
    //优惠套餐数据,数组存放的是DiscountDataModel.h数据模型.
    NSMutableArray *discountDataArr_;
    
    //点击某项优惠菜单进行编辑时,保存该项在数组的位置,
    NSInteger discontIndex_;
    
    //所有菜式优惠组合数据.
    PromoteCookBookDataModel *promoteCookBookData_;
    
    //准备提交服务器的待删除数据.
    NSMutableArray *deleteArr_;
    
    //存放搜索结果
    NSMutableArray *filterDishCardListArray;
    
    //点击了switch控件的PromoteCookBookGroupDataModel,作用类似指针
    PromoteCookBookGroupDataModel *switchPromteCookbookData;
    
    //待提交的开关变化数据
    NSDictionary *submitDic_;
    
    
}
@end

@implementation DiscountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        discountDataArr_ = [[NSMutableArray alloc]init];
    }
    return self;
}
- (void)dealloc
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.reloading = YES;
    self.discountListTableView.delegate = self;
    self.discountListTableView.dataSource = self;
    self.searchTextfield.delegate = self;
    [self.view bringSubviewToFront:self.discountListTableView];
    [self performSelector:@selector(getDiscountData) withObject:nil afterDelay:0.1];
    [self setEGORefreshView];//添加下拉刷新
    [self addLocalizedString];//给xib的一些label添加本地化
    [self NavTitleChangeNotification];//通知mainView更改navTitle
}

/**
 *  给xib的一些label添加本地化
 */
- (void)addLocalizedString
{
    self.searchTextfield.placeholder = kLoc(@"privilege_group_name");
    
    self.discountNumLabel.text = kLoc(@"serial_number");
    self.discountNameLabel.text = kLoc(@"privilege_group_name");
    self.quantityLabel.text = kLoc(@"numbers");
    self.switchLabel.text = kLoc(@"on_off");
    self.deleteLabel.text = kLoc(@"delete");
    [self.cancelBtn setTitle:kLoc(@"back") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    
    CGRect aFrame = self.view.frame;
    aFrame.origin.x = 0;
    aFrame.origin.y = kSystemVersionIsIOS7 ? 15:0;
    self.view.frame = aFrame;
	[UIView commitAnimations];

}
#pragma mark - private method
/**
 *  通知mainView更改navTitle
 */
- (void)NavTitleChangeNotification
{
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:[NSString stringWithFormat:@"%@>%@",kLoc(@"menus"),kLoc(@"privilege_group")] forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
}

/**
 *  初始化“下拉刷新”控件
 */
- (void)setEGORefreshView
{
    _reloading = NO;
    
    if (_RefreshHeaderView == nil)
    {
        CGRect refreshRect = CGRectMake(0.0f,
                                        0.0f - self.discountListTableView.bounds.size.height,
                                        self.discountListTableView.bounds.size.width,
                                        self.discountListTableView.bounds.size.height);
		_RefreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:refreshRect];
		_RefreshHeaderView.delegate = self;
        _RefreshHeaderView.backgroundColor = [UIColor clearColor];
		[self.discountListTableView addSubview:_RefreshHeaderView];
	}
}

/**
 *  删除下拉刷新
 */
- (void)removeEGORefreshView
{
    [_RefreshHeaderView removeFromSuperview];
}


/**
 *  优惠组合开关事件
 *
 *  @param sw 开关控件
 */
- (void)discountSwitchChange:(UISwitch *)sw
{
    UITableViewCell * cell = nil;
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        cell = (UITableViewCell *)sw.superview.superview;
    }
    else
    {
        cell = (UITableViewCell *)sw.superview.superview.superview;
    }
    NSIndexPath * indexPath = [self.discountListTableView indexPathForCell:cell];
    NSArray *temArr = nil;
    if (_isSearching)
    {
        temArr = filterDishCardListArray;
    }
    else
    {
        temArr = promoteCookBookData_.promoteCookbookGroupArr;
    }
    if (promoteCookBookData_.promoteCookbookGroupArr.count > indexPath.row)
    {
        PromoteCookBookGroupDataModel *promoteData = [temArr objectAtIndex:indexPath.row];
        switchPromteCookbookData = promoteData;
        submitDic_ = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:sw.on],@"switch",promoteData.promoteKey,@"key",nil];
        
        NSString *alertInfo = nil;
        
        if (sw.isOn)
        {
            alertInfo = kLoc(@"are_you_sure_to_start");
        }
        else
        {
            alertInfo = kLoc(@"are_you_sure_to_stop");
        }
        
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:kLoc(@"是否进行当前操作") delegate:self cancelButtonTitle:kLoc(@"cancel") otherButtonTitles:kLoc(@"confirm"), nil];
        alert.tag = kAlertSecondTag;
        [alert show];
    }
}



#pragma mark network

//读取组合数据
- (void)getDiscountData
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withBaseRequest:@"CookbookPromote/getPromoteCookbookGroup"];
}

- (void)submitDeleteData
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 1;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:deleteArr_ forKey:@"key"];
    [jsonPicker postData:postData withBaseRequest:@"CookbookPromote/delPromoteCookbookGroup"];
}

/**
 *  优惠组合开启/关闭
 *
 *  @param dic 待提交数据
 */
- (void)submitSwitch:(NSDictionary *)dic
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 2;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSArray *itemArr = [NSArray arrayWithObject:dic];
    NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
    [postData setObject:itemArr forKey:@"item"];
    [jsonPicker postData:postData withBaseRequest:@"CookbookPromote/switchPromoteGroupItem"];
}

#pragma mark -ButtonPress

- (IBAction)cancelBtnPress:(id)sender
{
    [self dismissView];
}

- (IBAction)searchBtnPress:(id)sender
{
    if (_isSearching)
    {
        _isSearching = NO;
        
    }
}

- (IBAction)sureBtnPress:(id)sender
{
    if (deleteArr_.count)
    {
        [self submitDeleteData];
    }
}

- (IBAction)addDiscountBtnPress:(id)sender
{
    EditDiscountViewController *discountView = [[EditDiscountViewController alloc]initWithNibName:@"EditDiscountViewController" bundle:nil];
    discountView.delegate = self;
    discountView.promoteCookbookGroupArr = promoteCookBookData_.promoteCookbookGroupArr;
    
    for (NSDictionary *dic in self.allCuisineDataArr)
    {
        CuisineDataModel *cuiData = [[CuisineDataModel alloc]initAllDetailWithData:dic];
        [discountView.cuisineDataArr addObject:cuiData];
    }

    [[MainViewController getMianViewShareInstance] presentPopupViewController:discountView animationType:MJPopupViewAnimationSlideBottomBottom];
    // 缩放视图
    scaleView(discountView.view);
}



//跳出本页面
-(void)dismissView
{
    [self.view removeFromSuperview];
    if (_delegate && [_delegate respondsToSelector:@selector(DiscountViewController:didDismissView:)])
    {
        [_delegate DiscountViewController:self didDismissView:YES];
    }
}

/**
 *  从tableView中删除某项
 *
 *  @param sender btn
 */
- (void)deleteDiscountList:(UIButton *)sender
{
    UIAlertView *deleteAlert = [[UIAlertView alloc]initWithTitle:nil
                                                         message:kLoc(@"are_you_sure_to_delete")
                                                        delegate:self
                                               cancelButtonTitle:kLoc(@"no")
                                               otherButtonTitles:kLoc(@"yes"), nil];
    deleteAlert.tag = kAlertFirstTag;
    [deleteAlert show];
    DiscountViewControllerTableViewCell * cell = nil;
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        cell = (DiscountViewControllerTableViewCell *)sender.superview.superview;
    }
    else
    {
        cell = (DiscountViewControllerTableViewCell *)sender.superview.superview.superview;
    }
    
    NSIndexPath * path = [self.discountListTableView indexPathForCell:cell];
    NSArray *temArr = nil;
    if (self.isSearching)
    {
        temArr = filterDishCardListArray;
    }
    else
    {
        temArr = promoteCookBookData_.promoteCookbookGroupArr;
    }
    if (temArr.count > path.row)
    {
        if (!deleteArr_)
        {
            deleteArr_ = [[NSMutableArray alloc]init];
        }
        PromoteCookBookGroupDataModel *temGroupData = [temArr objectAtIndex:path.row];
        [deleteArr_ addObject:temGroupData.promoteKey];        
    }
    
}

#pragma mark -UIAlertViewDelegate
//确认是否删除该组合item
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertFirstTag)
    {
        if (buttonIndex == 0)
        {
            [deleteArr_ removeAllObjects];
        }
        else
        {
            [self submitDeleteData];
        }
    }
    else if (alertView.tag == kAlertSecondTag)
    {
        if (buttonIndex == 1)
        {
            [self submitSwitch:submitDic_];
        }
        else
        {
            [self.discountListTableView reloadData];
        }
        
    }

}


#pragma mark EditDiscountViewControllerDelegate
- (void)dismissEditDiscountViewController:(EditDiscountViewController *)ctl
{
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
    //[self resetDataModel];
}

//重置优惠组合数据源中的allCuisineDataArr数据.
//- (void)resetDataModel
//{
//    dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(global, ^{
//        for (CuisineDataModel *cuisineData in promoteCookBookData_.allCuisineDataArr)
//        {
//            for (CookbookDataClass *temCookData in cuisineData.cookbookDataArr)
//            {
//                temCookData.isSelected = NO;
//            }
//        }
//    });
//}

- (void)didFinishEditWithNewDiscountModel:(PromoteCookBookGroupDataModel *)newPromoteCookBookData isEditExistItem:(BOOL)flag
{
    if (!flag)
    {
        [promoteCookBookData_.promoteCookbookGroupArr addObject:newPromoteCookBookData];
    }
    else
    {
        for (int i = 0 ; i < promoteCookBookData_.promoteCookbookGroupArr.count; i++)
        {
            PromoteCookBookGroupDataModel *originData = (PromoteCookBookGroupDataModel *)[promoteCookBookData_.promoteCookbookGroupArr objectAtIndex:i];
            if ([originData.promoteKey isEqualToString:newPromoteCookBookData.promoteKey]) {
                [promoteCookBookData_.promoteCookbookGroupArr replaceObjectAtIndex:i withObject:newPromoteCookBookData];
            }
        }
    }
    [self.discountListTableView reloadData];
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
    //[self resetDataModel];

}


#pragma mark UITableView delegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_isSearching)
    {
        return promoteCookBookData_.promoteCookbookGroupArr.count;
    }
    else
    {
        return filterDishCardListArray.count;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    DiscountViewControllerTableViewCell *cell = (DiscountViewControllerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"DiscountViewControllerTableViewCell"
                                             owner:self
                                           options:nil]lastObject];
        [cell.deleteItemBtn addTarget:self action:@selector(deleteDiscountList:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (promoteCookBookData_.promoteCookbookGroupArr.count > indexPath.row)
    {
        NSArray *temArr = nil;
        if (_isSearching)
        {
            temArr = filterDishCardListArray;
        }
        else
        {
            temArr = promoteCookBookData_.promoteCookbookGroupArr;
        }
        PromoteCookBookGroupDataModel *promoteData = [temArr objectAtIndex:indexPath.row];
        cell.discountID.text = promoteData.promoteNumber;
        cell.discountName.text = promoteData.promoteName;
        cell.discountSwitch.on = promoteData.isActive;
        cell.dishNumLabel.text = [NSString stringWithFormat:@"%d",promoteData.groupCookbookArr.count];
        [cell.discountSwitch addTarget:self
                                action:@selector(discountSwitchChange:)
                      forControlEvents:UIControlEventValueChanged];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    discontIndex_ = indexPath.row;
    if (promoteCookBookData_.promoteCookbookGroupArr.count > discontIndex_)
    {
        PromoteCookBookGroupDataModel *promoteCookData = [promoteCookBookData_.promoteCookbookGroupArr objectAtIndex:indexPath.row];
        EditDiscountViewController *editCtl = [[EditDiscountViewController alloc]initWithNibName:@"EditDiscountViewController" bundle:nil];
        editCtl.promoteCookbookGroupData = promoteCookData;
        editCtl.promoteCookbookGroupArr = promoteCookBookData_.promoteCookbookGroupArr;
        editCtl.isEditExistItem = YES;
        for (NSDictionary *dic in self.allCuisineDataArr)
        {
            CuisineDataModel *cuiData = [[CuisineDataModel alloc]initAllDetailWithData:dic];
            [editCtl.cuisineDataArr addObject:cuiData];
        }
        editCtl.delegate = self;
        [[MainViewController getMianViewShareInstance] presentPopupViewController:editCtl animationType:MJPopupViewAnimationSlideBottomBottom];
        // 缩放视图
        scaleView(editCtl.view);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!self.isSearching)
    {
        if ([promoteCookBookData_.promoteCookbookGroupArr count] == 0 && !_reloading)
        {
            UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 748, 60)];
            aView.backgroundColor = [UIColor clearColor];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 748, 60)];
            label1.numberOfLines = 2;
            label1.backgroundColor = [UIColor clearColor];
            label1.textAlignment = UITextAlignmentCenter;
            label1.font = [UIFont boldSystemFontOfSize:20];
            label1.textColor = [UIColor blackColor];
            label1.text = kLoc(@"no_records");
            [aView addSubview:label1];
            
            return aView;
        }
        else
            return nil;
    }
    else {
        if ([filterDishCardListArray count]==0)
        {
            UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 748, 60)];
            aView.backgroundColor = [UIColor clearColor];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 748, 60)];
            label1.numberOfLines = 2;
            label1.backgroundColor = [UIColor clearColor];
            label1.textAlignment = UITextAlignmentCenter;
            label1.font = [UIFont boldSystemFontOfSize:20];
            label1.textColor = [UIColor blackColor];
            label1.text = [NSString stringWithFormat:@"%@“%@”%@",kLoc(@"can_not_search_anything_which_contain_the_keyword"), self.searchTextfield.text,kLoc(@"the_ground")];
            [aView addSubview:label1];
            
            return aView;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    float height = 0;
    if (!self.isSearching)
    {
        if ([promoteCookBookData_.promoteCookbookGroupArr count]==0 && !_reloading)
        {
            height = 60;
        }
    }
    else
    {
        if ([filterDishCardListArray count]==0)
        {
            height = 60;
        }
    }
    return height;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_RefreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_RefreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark Data Source Loading / Reloading Methods

- (void)doneLoadingTableViewData
{
	_reloading = NO;
    [_RefreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.discountListTableView];
}

//结束加载数据,无论是否成功加载数据
- (void)finishLoading
{
    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.isSearching = YES;
    [self.searchBtn setTitle:kLoc(@"done") forState:UIControlStateNormal];
    [self removeEGORefreshView];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.searchTextfield.text isEqualToString:@""])
    {
        self.isSearching = NO;
        self.addDiscountBtn.hidden = NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger loc = range.location;
    NSInteger len = range.length;
    if (loc==0 && len==1)
    {
        self.isSearching = NO;
        [self.discountListTableView reloadData];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.isSearching = YES;
    //[self removeEGORefreshView];
    NSString *keywordWithoutSpace = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self.searchTextfield resignFirstResponder];
    if (!keywordWithoutSpace.length)
    {
        self.addDiscountBtn.hidden = NO;
        self.isSearching = NO;
        [self.discountListTableView reloadData];
    }
    else
    {
        [self searchDishCardWithKeyword:keywordWithoutSpace];
        self.addDiscountBtn.hidden = YES;
    }
    return YES;
}

/**
 *  搜索方法
 *
 *  @param keyword 搜索关键字
 */
-(void)searchDishCardWithKeyword:(NSString*)keyword
{
    if (!filterDishCardListArray)
    {
        filterDishCardListArray = [[NSMutableArray alloc] init];
    }
    [filterDishCardListArray removeAllObjects];
    
    //开始搜索
    for (PromoteCookBookGroupDataModel *promoteData in promoteCookBookData_.promoteCookbookGroupArr)
    {
        //搜索成员名包含某字符的成员
        NSRange resultFromAccount = [promoteData.promoteName rangeOfString:keyword options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
        if (resultFromAccount.location != NSNotFound)
        {
            [filterDishCardListArray addObject:promoteData];
        }
    }
    [self.discountListTableView reloadData];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    if (!self.isSearching)
    {
        [self getDiscountData];
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doneLoadingTableViewData) userInfo:nil repeats:NO];
    }
}



- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date];
}

#pragma mark JsonPickerDelegate
-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    int responseStatus = [[dict objectForKey:@"status"] intValue];
    self.reloading = NO;
    if (picker.tag == 0)//获取列表.
    {
        switch (responseStatus)
        {
            case 200:
            {
                if (promoteCookBookData_)
                {
                    promoteCookBookData_ = nil;
                }
                NSDictionary *allDataDic = [dict objectForKey:@"data"];
                promoteCookBookData_ = [[PromoteCookBookDataModel alloc]initWithData:allDataDic andAllCuisineDataArr:self.allCuisineDataArr];
                [self.discountListTableView reloadData];
                break;
            }
            default:
            {
                NSString *str = [dict objectForKey:@"desc"];
                [PSAlertView showWithMessage:str];
                break;
            }
        }
    }
    else if (picker.tag == 1)//删除item
    {
        switch (responseStatus)
        {
            case 200:
            {
                NSArray *delKeyArr = [[dict objectForKey:@"data"]objectForKey:@"delKey"];
                if (delKeyArr.count)
                {
                    NSString *deleKeyStr = (NSString *) [delKeyArr lastObject];
                    for (int i = 0; i < promoteCookBookData_.promoteCookbookGroupArr.count; i++)
                    {
                        PromoteCookBookGroupDataModel *temGroupData = (PromoteCookBookGroupDataModel *)[promoteCookBookData_.promoteCookbookGroupArr objectAtIndex:i];
                        if ([temGroupData.promoteKey isEqualToString:deleKeyStr])
                        {
                            [promoteCookBookData_.promoteCookbookGroupArr removeObjectAtIndex:i];
                            break;
                        }
                    }
                    if (self.isSearching)
                    {
                        for (int i = 0; i < filterDishCardListArray.count; i++)
                        {
                            PromoteCookBookGroupDataModel *temGroupData = (PromoteCookBookGroupDataModel *)[filterDishCardListArray objectAtIndex:i];
                            if ([temGroupData.promoteKey isEqualToString:deleKeyStr])
                            {
                                [filterDishCardListArray removeObjectAtIndex:i];
                                break;
                            }
                        }
                    }
                    [self.discountListTableView reloadData];
                }
                else
                {
                    NSString *errStr = [dict objectForKey:@"desc"];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:errStr
                                                                  delegate:nil
                                                         cancelButtonTitle:kLoc(@"good")
                                                         otherButtonTitles:nil, nil];
                    [alert show];
                }
                [deleteArr_ removeAllObjects];
                break;
            }
            default:
            {
                NSString *str = [dict objectForKey:@"desc"];
                [PSAlertView showWithMessage:str];
                break;
            }
        }
    }
    else if (picker.tag == 2)//item开启/关闭
    {
        switch (responseStatus)
        {
            case 200:
            {
                switchPromteCookbookData.isActive = !switchPromteCookbookData.isActive;
                break;
            }
            default:
            {
                NSString *str = [dict objectForKey:@"desc"];
                [PSAlertView showWithMessage:str];
                break;
            }
        }
        [self.discountListTableView reloadData];
    }
}


// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error
{
    
}

// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error
{
    if (picker.tag == 2)//item开关
    {
        [self.discountListTableView reloadData];
    }
}

@end
