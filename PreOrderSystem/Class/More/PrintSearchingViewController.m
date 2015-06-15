//
//  PrintSearchingViewController.m
//  PreOrderSystem
//
//  Created by SWen on 14-4-24.
//
//

#import "PrintSearchingViewController.h"
#import "MainViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "MBProgressHUD.h"
#import "StarIO/SMPort.h"
#import "PrintSearchingTableViewCell.h"
#import "PSAlertView.h"
#import "EGORefreshTableHeaderView.h"
#import "Constants.h"

#define kCellIdentifier @"CellIdentifier"


@interface PrintSearchingViewController () <MBProgressHUDDelegate, UITableViewDataSource, UITableViewDelegate,EGORefreshTableHeaderDelegate>
{
    NSMutableArray *_printersListArray;
    BOOL isLoaded ;
    BOOL isConnectedPrinter ;
    
    BOOL _reloading; //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshReloadTableView;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)cancelBtnClick:(UIButton *)sender;
@end

@implementation PrintSearchingViewController


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
    self.titleLabel.text = kLoc(@"search_printer");
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self addPullDownReFresh];// 添加下拉刷新
    [self searchAvaliablePrinters];
}

#pragma mark -- private
// 搜索打印机
-(void)searchAvaliablePrinters
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
    HUD.delegate = self;
    [window addSubview:HUD];
    
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = kLoc(@"searching_printers") ;
    [HUD showWhileExecuting:@selector(loadAvailablePrinters) onTarget:self withObject:nil animated:YES];
}

-(void)loadAvailablePrinters
{
    isLoaded = YES;
    isConnectedPrinter = NO;
    
    if (!_printersListArray)
    {
        _printersListArray = [[NSMutableArray alloc] init];
    }
    
    [_printersListArray removeAllObjects];
    [_printersListArray addObjectsFromArray:[SMPort searchPrinter]];
    

//    [_printersListArray addObject:_printersListArray[0]];
    _reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [self.tableView reloadData];
}

//下拉刷新
- (void)addPullDownReFresh
{
    //初始化“下拉刷新”控件
    _reloading = NO;
    
    if (_refreshHeaderView == nil)
    {
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        _refreshHeaderView.backgroundColor = [UIColor clearColor];
		_refreshHeaderView.delegate = self;
		[self.tableView addSubview:_refreshHeaderView];
	}
    
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
}

#pragma mark --button press
- (IBAction)cancelBtnClick:(UIButton *)sender
{
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

- (IBAction)doneBtnClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(PrintSearchingViewController: withConnectedCell:)])
    {
        NSMutableArray *cellArray  = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < _printersListArray.count; i++)
        {
            PrintSearchingTableViewCell *cell = (PrintSearchingTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            if (cell.connectedStatus)
            {
                [cellArray addObject:cell];
            }
        }

        [self.delegate PrintSearchingViewController:self withConnectedCell:cellArray];
    }
    
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

#pragma mark tableViewDelegate && datesource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _printersListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
	PrintSearchingTableViewCell *cell = (PrintSearchingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if (cell == nil)
    {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"PrintSearchingTableViewCell" owner:self options:nil] lastObject];
	}
    
    if (_printersListArray.count && _printersListArray.count > indexPath.row)
    {
        PortInfo *info = _printersListArray[indexPath.row];
        cell.connectBtn.tag = indexPath.row;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [cell updatePrinterInfo:info defaultSearchingPrinterArray:self.defaultSearchingPrinterArray];
        [cell defaultConnected:info defaultSearchingPrinterArray:self.defaultSearchingPrinterArray];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    _isRefreshReloadTableView = YES;
    [self searchAvaliablePrinters];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}
@end
