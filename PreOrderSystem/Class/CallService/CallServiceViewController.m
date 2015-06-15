//
//  CallServiceViewController.m
//  PreOrderSystem
//
//  Created by sWen on 12-10-29.
//
//

#import "CallServiceViewController.h"
#import "CallServiceViewControllerCell.h"
#import "UILabel+AdjustFontSize.h"
#import "Constants.h"
#import "CustomBadge.h"
#import "UIViewController+MJPopupViewController.h"
#import "PSAlertView.h"
#import "OrderListLoadMoreCell.h"
#import "NsstringAddOn.h"
#import "UILabel+AdjustFontSize.h"
#import "CallServiceHandleView.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "MainViewController.h"
#import "SuperDataClass.h"
#import "CallServiceSuperDataClass.h"
#import "OfflineManager.h"
#import "StaffManagementSuperDataClass.h"

#define kMoreActionSheetTag 1000
#define kServiceStateActionSheetTag 1100

@interface CallServiceViewController ()
{
    NSArray *handleBtnArray;
}


- (void)addNotification;
- (void)addPullDownReFresh;
- (void)getCallServiceData:(int)page withAnimated:(BOOL)animated;
- (void)SaveCallServiceData:(NSMutableDictionary *)dict;
- (void)createChatView;

@end

@implementation CallServiceViewController

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

    dataArray = [[NSMutableArray alloc]initWithCapacity:3];
    charViewArray = [[NSMutableArray alloc]initWithCapacity:3];
    currentPageIndex = 1;
    totalPage = 0;
    
    [self addPictureToView];
    [self updateCallServiceAuthority];
    if (!self.callServiceTableView.hidden)
    {
        [self addNotification];
        [self addPullDownReFresh];
        [self getCallServiceData:currentPageIndex withAnimated:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self removeNotification];
    dataArray = nil;
    charViewArray = nil;
    _refreshHeaderView = nil;
    loadMoreOrdersCell = nil;
    jsonPicker = nil;
    
#ifdef DEBUG
    NSLog(@"===CallServiceViewController,viewDidUnload===");
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"service") forKey:@"title"];
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
    [self removeNotification];
}

//初始化“下拉刷新”控件
- (void)addPullDownReFresh
{
    _reloading = NO;
    if (_refreshHeaderView == nil) {
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.callServiceTableView.bounds.size.height, self.callServiceTableView.bounds.size.width, self.callServiceTableView.bounds.size.height)];
		_refreshHeaderView.delegate = self;
        _refreshHeaderView.backgroundColor = [UIColor clearColor];
		[self.callServiceTableView addSubview:_refreshHeaderView];
	}
	[_refreshHeaderView refreshLastUpdatedDate];
}

- (void)addPictureToView
{
    self.bgImageView.image = [UIImage imageFromMainBundleFile:@"callService_frameBg.png"];
}

- (void)updateCallServiceAuthority
{
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSArray *authorityArray = [offlineMgr getAccountAuthority];
    for (NSDictionary *authDict in authorityArray)
    {
        StaffManagementAuthDataClass *authClass = [[StaffManagementAuthDataClass alloc] initWithStaffManagementAuthData:authDict];
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfCallServiceIndexStr])
        {
            for (StaffManagementSubAuthDataClass *subAuth in authClass.childrenArray)
            {
                if ([subAuth.indexStr isEqualToString:@"qrcodeSetting"])
                {
                    self.editButton.enabled = subAuth.open;
                }
                else if ([subAuth.indexStr isEqualToString:@"main"])
                {
                    self.callServiceTableView.hidden = !subAuth.open;
                    if (self.callServiceTableView.hidden)
                    {
                        self.bgImageView.hidden = NO;
                    }
                }
            }
            break;
        }
    }
}

//创建聊天视图
- (void)createChatView
{
    CallServiceViewControllerCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CallServiceViewControllerCell" owner:self options:nil] lastObject];
    [charViewArray removeAllObjects];
    for (int i = 0; i < [dataArray count]; i++)
    {
        UIView *charView = [cell updateWithData:[dataArray objectAtIndex:i]];
        [charViewArray addObject:charView];
    }
}

#pragma mark - Notification

- (void)addNotification
{
    //监听Notification(收到推送，刷新呼叫服务列表)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCallServiceList) name:kShouldUpdateCallServiceList object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWhenEnterForeground) name:kUpdatedCallServiceListWhenEnterForeground object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)refreshCallServiceList
{
    [self getCallServiceData:currentPageIndex withAnimated:NO];
}

- (void)refreshWhenEnterForeground
{
    [self getCallServiceData:currentPageIndex withAnimated:NO];
}

// 更新badge（包括程序的badge、房台的badge、订座列表的badge、外卖列表的badge、服务列表的badge）
- (void)updateBadge
{
    NSDictionary *userInfo0 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:duc], @"num", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateDinnerTableBadge
                                                        object:nil
                                                      userInfo:userInfo0];
    
    NSDictionary *userInfo1 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:puc], @"num", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdatePreorderOrderNotifNum
                                                        object:nil
                                                      userInfo:userInfo1];
    
    NSDictionary *userInfo2 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:tuc], @"num", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateTakeoutOrderNotifNum
                                                        object:nil
                                                      userInfo:userInfo2];
    
    NSDictionary *userInfo3 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:muc], @"num", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateCallServiceNotifNum
                                                        object:nil
                                                      userInfo:userInfo3];
    
    NSDictionary *userInfo4 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:ruc], @"num", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateTakeoutRemindersNotifNum
                                                        object:nil
                                                      userInfo:userInfo4];
    
    int badge = duc + puc + tuc + muc + ruc;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
}

#pragma mark - UIButton Clicked

-(IBAction)editButtonPressed:(UIButton*)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:kLoc(@"customize_qrcode"), nil];
    actionSheet.tag = kMoreActionSheetTag;
    
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:sender.frame inView:self.view animated:YES];
    }
  
}

#pragma mark - network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

//读取
- (void)getCallServiceData:(int)page withAnimated:(BOOL)animated
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = YES;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [jsonPicker postData:postData withBaseRequest:@"callservice/getlist"];
}

//更改状态
- (void)SaveCallServiceData:(NSMutableDictionary *)dict
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 1;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowUpdateAlert = NO;
    jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = kLoc(@"submit_succeed");
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] initWithDictionary:dict];
    [jsonPicker postData:postData withBaseRequest:@"callservice/updateStatus"];
    
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
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
}

#pragma mark UITableView delegate 

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if (0 == [dataArray count])
    {
        return 100;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (0 == [dataArray count])
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float space = 20;
    float height = 75;
    if (indexPath.row < [dataArray count] && indexPath.row < [charViewArray count])
    {
        UILabel *seatsNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 124, 28)];
        seatsNameLabel.font = [UIFont boldSystemFontOfSize:20];
        seatsNameLabel.numberOfLines = 0;
        seatsNameLabel.text = [[dataArray objectAtIndex:indexPath.row]objectForKey:@"sortName"];
        float seatsNameHeight = [seatsNameLabel adjustLabelHeight] + 30;
        
        UIView *charView = [charViewArray objectAtIndex:indexPath.row];
        float contentHeight = charView.frame.size.height + height;
        
        //标题与内容谁的高度高些
        if (seatsNameHeight > contentHeight)
        {
            return seatsNameHeight + space;
        }
        else
        {
            return contentHeight + space;
        }
    }
    //加载更多标签
    if (indexPath.row == [dataArray count] )
    {
        height = 80;
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.callServiceTableView.hidden)
    {
        self.bgImageView.hidden = ([dataArray count])? YES:NO;
    }
    if (currentPageIndex < totalPage)
    {
        return [dataArray count]+1;
    }
    else
    {
        return [dataArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
	CallServiceViewControllerCell *cell = (CallServiceViewControllerCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil)
    {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"CallServiceViewControllerCell" owner:self options:nil] lastObject];
	}
    
    if (indexPath.row < [dataArray count])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell updateWithData:[dataArray objectAtIndex:indexPath.row]];
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if (loadMoreOrdersCell==nil)
        {
            loadMoreOrdersCell = [[[NSBundle mainBundle] loadNibNamed:@"OrderListLoadMoreCell" owner:self options:nil] lastObject];
            loadMoreOrdersCell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        [loadMoreOrdersCell loadText:kLoc(@"load_more_call_service_message")];
        return loadMoreOrdersCell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [dataArray count])
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        int page = currentPageIndex+1;
        if (page<=totalPage)
        {
            [loadMoreOrdersCell startLoading:kLoc(@"load_more_call_service_message_wait")];
            [self getCallServiceData:page withAnimated:NO];
        }
        
        if (currentPageIndex == totalPage && indexPath.row == [dataArray count])
        {
            [loadMoreOrdersCell loadTextWithOutData:kLoc(@"no_more_call_service_message")];
        }
    }
    else
    {
        //状态
        int state = [[[dataArray objectAtIndex:indexPath.row] objectForKey:@"status"]integerValue];
        if (0 == state || 1== state)
        {
            CallServiceViewControllerCell *cell = (CallServiceViewControllerCell *)[self.callServiceTableView cellForRowAtIndexPath:indexPath];
            cell.bgImageView.image = [UIImage imageFromMainBundleFile:@"callService_cellSelectedBg.png"];
            
            NSInteger btnCount = [handleBtnArray count];
            if (btnCount)
            {
                CallServiceHandleView *stateActionSheet = [[CallServiceHandleView alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                for (NSInteger i = 0; i < btnCount; i++)
                {
                    CallServiceButtonDataClass *btnClass = [handleBtnArray objectAtIndex:i];
                    [stateActionSheet addButtonWithTitle:btnClass.btnName];
                }
                [stateActionSheet addButtonWithTitle:kLoc(@"cancel")];
                stateActionSheet.tag = kServiceStateActionSheetTag;
                stateActionSheet.contentId = [[[dataArray objectAtIndex:indexPath.row]objectForKey:@"id"]integerValue];
                [stateActionSheet showInView:self.view.window];
                selectedIndex = indexPath;
            }
            else
            {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
        else
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

#pragma mark QRCodeViewController delegate

-(void)QRCodeViewController:(QRCodeViewController*)ctrl didDismissView:(BOOL)flag
{
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (kMoreActionSheetTag == actionSheet.tag)
    {
        if (buttonIndex == 0)
        {
            QRCodeViewController *codeViewController = [[QRCodeViewController alloc]initWithNibName:@"QRCodeViewController" bundle:nil];
            codeViewController.delegate = self;
            [[MainViewController getMianViewShareInstance] presentPopupViewController:codeViewController animationType:MJPopupViewAnimationSlideBottomBottom];
            // 缩放视图
            scaleView(codeViewController.view);
        }
    }
    else if (kServiceStateActionSheetTag == actionSheet.tag)
    {
        if (kZeroNumber <= buttonIndex)
        {
            CallServiceHandleView *handleView = (CallServiceHandleView *)actionSheet;
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithCapacity:3];
            NSString *contenIdString = [NSString stringWithFormat:@"%d",handleView.contentId];
            [tempDict setObject:contenIdString forKey:@"id"];
            
            NSInteger btnCount = [handleBtnArray count];
            if (buttonIndex < btnCount)
            {
                CallServiceButtonDataClass *btnClass = [handleBtnArray objectAtIndex:buttonIndex];
                [tempDict setObject:btnClass.btnValue forKey:@"status"];
            }
            else
            {
                [self.callServiceTableView reloadData];
                return;
            }
            [self SaveCallServiceData:tempDict];
        }
        [self.callServiceTableView reloadData];
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.callServiceTableView];
}

//结束加载数据,无论是否成功加载数据
- (void)finishLoading
{
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doneLoadingTableViewData) userInfo:nil repeats:NO];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self getCallServiceData:currentPageIndex withAnimated:NO];
}


-(void)egoRefreshTableHeaderDidTriggerLoadMore
{
    if (currentPageIndex>0 && currentPageIndex<totalPage)
    {
        int page = currentPageIndex+1;
        if (page<=totalPage)
        {
            [loadMoreOrdersCell startLoading:kLoc(@"load_more_call_service_message_wait")];
            [self getCallServiceData:page withAnimated:NO];
            
        }
    }
    if (currentPageIndex == totalPage)
    {
        [loadMoreOrdersCell loadTextWithOutData:kLoc(@"no_more_call_service_message")];
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
    SuperDataClass *superDataClass = [[SuperDataClass alloc] initWithData:dict];
    NSInteger responseStatus = superDataClass.responseStatus;
    if (picker.tag==0)
    {
        switch (responseStatus)
        {
            case 200:
            {
                handleBtnArray = [[CallServiceSuperDataClass alloc] initWithCallServiceSuperData:dict].buttonsArray;
                
                currentPageIndex = [[superDataClass.dataDict objectForKey:@"currentPage"] intValue];
                totalPage = [[superDataClass.dataDict objectForKey:@"totalPage"] intValue];
                [dataArray removeAllObjects];
                [dataArray addObjectsFromArray:[superDataClass.dataDict objectForKey:@"list"]];
                [self createChatView];
                
                NSDictionary *unreadInfo = [superDataClass.dataDict objectForKey:@"data"];
                duc = [[unreadInfo objectForKey:@"duc"] intValue];
                puc = [[unreadInfo objectForKey:@"puc"] intValue];
                tuc = [[unreadInfo objectForKey:@"tuc"] intValue];
                muc = [[unreadInfo objectForKey:@"muc"] intValue];
                ruc = [[unreadInfo objectForKey:@"ruc"] intValue];
                [self updateBadge];
                
                [self.callServiceTableView reloadData];
                [loadMoreOrdersCell stopLoading:kLoc(@"load_more_call_service_message")];
                
                break;
            }
            case 201:
            {
                [dataArray removeAllObjects];
                currentPageIndex = 1;
                totalPage = 0;
                
                NSDictionary *unreadInfo = [superDataClass.dataDict objectForKey:@"data"];
                duc = [[unreadInfo objectForKey:@"duc"] intValue];
                puc = [[unreadInfo objectForKey:@"puc"] intValue];
                tuc = [[unreadInfo objectForKey:@"tuc"] intValue];
                muc = [[unreadInfo objectForKey:@"muc"] intValue];
                ruc = [[unreadInfo objectForKey:@"ruc"] intValue];
                [self updateBadge];
                
                [self.callServiceTableView reloadData];
                [loadMoreOrdersCell stopLoading:kLoc(@"load_more_call_service_message")];
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:superDataClass.alertMsg];
                break;
            }
        }
    }
    
    if (picker.tag==1)
    {
        switch (responseStatus)
        {
            case 200:
            {
                currentPageIndex = 1;
                [dataArray removeAllObjects];
                [dataArray addObjectsFromArray:[superDataClass.dataDict objectForKey:@"list"]];
                [charViewArray removeAllObjects];
                [self createChatView];
                
                NSDictionary *unreadInfo = [superDataClass.dataDict objectForKey:@"data"];
                duc = [[unreadInfo objectForKey:@"duc"] intValue];
                puc = [[unreadInfo objectForKey:@"puc"] intValue];
                tuc = [[unreadInfo objectForKey:@"tuc"] intValue];
                muc = [[unreadInfo objectForKey:@"muc"] intValue];
                ruc = [[unreadInfo objectForKey:@"ruc"] intValue];
                [self updateBadge];
                
                [self.callServiceTableView reloadData];
                break;
            }
            case 203:
            {
                currentPageIndex = 1;
                [self getCallServiceData:currentPageIndex withAnimated:NO];
                [PSAlertView showWithMessage:superDataClass.alertMsg];
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:superDataClass.alertMsg];
                break;
            }
        }
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
