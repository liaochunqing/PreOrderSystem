//
//  DishCardMainViewController.m
//  PreOrderSystem
//
//  Created by sWen on 13-4-9.
//
//  jhh_菜牌

#import "DishCardMainViewController.h"
#import "Constants.h"
#import "DishCardListTableviewCell.h"
#import "DishCardItemDetailPicker.h"
#import "UIViewController+MJPopupViewController.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "UIDevice+platform.h"
#import "PSAlertView.h"
#import "MainViewController.h"
#import "OfflineManager.h"
#import "StaffManagementSuperDataClass.h"
#import "promotionMainViewController.h"
#import "DishCardNewViewController.h"

@interface DishCardMainViewController () {
    promotionMainViewController *_promotionController;
    DishCardNewViewController *_dishCardNewVc;
}

- (void)updateBottomViewAfterGetData;
- (void)getDishCardDataAnimated:(BOOL)animated;
- (void)deleteDishItems:(NSString *)idStr;
- (void)addTapGesture;

@end

@implementation DishCardMainViewController

@synthesize bgImageView;
@synthesize cuisineScrollview;
@synthesize dishCardTableview;
@synthesize searchbarTextfield;
@synthesize moreBtn;
@synthesize imgBaseURL;

#pragma mark - LIFE CYLCE
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
    
    isSearching = NO;
    [self addPullDownReFresh];
    [self addPictureToView];
    [self addLocalizedString];
    [self updateDishCardAuthority];
    if (![[UIDevice platformString]isEqualToString:@"iPad 1"])
    {
        [self addTapGesture];
#ifdef DEBUG
        NSLog(@"===%@,%@===",[self class],[UIDevice platformString]);
#endif
    }
    [self getDishCardDataAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _refreshHeaderView = nil;
    jsonPicker = nil;
    allDishCardListArray = nil;
    filterDishCardListArray = nil;
    imgBaseURL = nil;
    
#ifdef DEBUG
    NSLog(@"===DishCardMainViewController,viewDidUnload===");
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"menus") forKey:@"title"];
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
    
#ifdef DEBUG
    NSLog(@"===DishCardMainViewController,dealloc===");
#endif
}

-(void)showInView:(UIView*)aView{
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
    
    CGRect aFrame = self.view.frame;
    self.view.frame = aFrame;
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];

    if (_dishCardNewVc)
    {
        [_dishCardNewVc.view removeFromSuperview];
    }
    if (_promotionController)
    {
        [_promotionController.view removeFromSuperview];
    }
    if (discountViewController_)
    {
        [discountViewController_.view removeFromSuperview];
    }
    [self displayAll];
}


#pragma mark - PRIVATE METHODS

- (void)addLocalizedString
{
    self.searchbarTextfield.placeholder = kLoc(@"dish_name");
    [self.promotionButton setTitle:kLoc(@"privilege_activity") forState:UIControlStateNormal];
    [self.promotiomGroupButton setTitle:kLoc(@"privilege_group") forState:UIControlStateNormal];
}

- (void)addPictureToView
{
    bgImageView.image = [UIImage imageFromMainBundleFile:@"dishCard_frameBg.png"];
    self.searchBgImageView.image = [UIImage imageFromMainBundleFile:@"dishCard_searchBar.png"];
}

//初始化“下拉刷新”控件
- (void)addPullDownReFresh{
    _reloading = NO;
    if (!_refreshHeaderView)
    {
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - dishCardTableview.bounds.size.height, dishCardTableview.bounds.size.width, dishCardTableview.bounds.size.height)];
	}
    _refreshHeaderView.delegate = self;
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    [dishCardTableview addSubview:_refreshHeaderView];
	[_refreshHeaderView refreshLastUpdatedDate];
}


-(void)removePullDownReFresh
{
    [_refreshHeaderView removeFromSuperview];
}

//底部分栏
- (void)updateBottomViewAfterGetData
{
    int newListCount = [allDishCardListArray count];
    int oldListCount = [cuisineScrollview.subviews count];
    cuisineScrollview.contentSize = CGSizeMake(newListCount*145, 35);
    
    for (int i = 0; i < oldListCount; i++)
    {
        UIButton *lastSelectedBtn = (UIButton*)[cuisineScrollview viewWithTag:i + 1000];
        [lastSelectedBtn removeFromSuperview];
    }
    
    for (int i=newListCount-1; i>=0; i--)
    {
        NSString *cuisineName = [[allDishCardListArray objectAtIndex:i] objectForKey:@"name"];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i+1000;
        btn.frame = CGRectMake(i*135, 0, 145, 35);
        [btn setTitle:cuisineName forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.titleLabel.minimumFontSize = 12;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageFromMainBundleFile: @"dishCard_tabButtonNormal.png"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCard_tabButtonSelected.png"] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(cuisineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cuisineScrollview addSubview:btn];
    }
    UIButton *currentSelectedBtn = (UIButton*)[cuisineScrollview viewWithTag:selectedCuisineIndex + 1000];
    [cuisineScrollview bringSubviewToFront:currentSelectedBtn];
    currentSelectedBtn.selected = YES;
    
#ifdef DEBUG
    NSLog(@"===cuisineSrollView,subView:%d===",[cuisineScrollview.subviews count]);
#endif
}

-(void)searchDishCardWithKeyword:(NSString*)keyword{
    if (!filterDishCardListArray) {
        filterDishCardListArray = [[NSMutableArray alloc] init];
    }
    [filterDishCardListArray removeAllObjects];
    
    //开始搜索
    for (NSDictionary *cuisine in allDishCardListArray) {
        for (int i = 0; i < [[cuisine objectForKey:@"cookbook"] count]; i++) {
            NSDictionary *dish = [[cuisine objectForKey:@"cookbook"] objectAtIndex:i];
            NSString *dishName = [dish objectForKey:@"name"];
            //搜索成员名包含某字符的成员
            NSRange resultFromAccount = [dishName rangeOfString:keyword options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
            if (resultFromAccount.location != NSNotFound) {
                [filterDishCardListArray addObject:dish];
            }
        }
    }
    [dishCardTableview reloadData];
}

- (void)updateDishCardAuthority
{
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSArray *authorityArray = [offlineMgr getAccountAuthority];
    for (NSDictionary *authDict in authorityArray)
    {
        StaffManagementAuthDataClass *authClass = [[StaffManagementAuthDataClass alloc] initWithStaffManagementAuthData:authDict];
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfCookbookIndexStr])
        {
            for (StaffManagementSubAuthDataClass *subAuth in authClass.childrenArray)
            {
                if ([subAuth.indexStr isEqualToString:@"editing"])
                {
                    self.addDishBtn.enabled = self.moreBtn.enabled = subAuth.open;
                }
            }
            break;
        }
    }
}
- (void)hideAll
{
    self.searchBgImageView.hidden = bgImageView.hidden = dishCardTableview.hidden = searchbarTextfield.hidden = cuisineScrollview.hidden = moreBtn.hidden = self.promotionButton.hidden = self.addDishBtn.hidden = self.promotiomGroupButton.hidden = YES;
}

- (void)displayAll
{
    self.searchBgImageView.hidden = bgImageView.hidden = dishCardTableview.hidden = searchbarTextfield.hidden = cuisineScrollview.hidden = moreBtn.hidden = self.promotionButton.hidden = self.addDishBtn.hidden = self.promotiomGroupButton.hidden= NO;
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:NSLocalizedString(@"菜牌", nil) forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
}

#pragma mark - UIGestureRecognizer

- (void)addTapGesture
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer addTarget:self action:@selector(handleTapGestureRecognizer:)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)handleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    //退出删除状态
    if (isDeletingFlag)
    {
        [dishCardTableview reloadData];
        isDeletingFlag = NO;
    }
}


#pragma mark - network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

- (void)getDishCardDataAnimated:(BOOL)animated
{
    if (!jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 1;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = YES;
    if (animated)
    {
        jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    }
    else
    {
        jsonPicker.loadingMessage = nil;
    }
    jsonPicker.loadedSuccessfulMessage = nil;
    
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    
    ///jhh_changed_菜牌_获取菜品列表
    [jsonPicker postData:postData withBaseRequest:@"cookbook/getlist"];
}

//删除菜品
- (void)deleteDishItems:(NSString *)idStr
{
    if (!jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 2;
    jsonPicker.showActivityIndicator = NO;
    jsonPicker.isShowUpdateAlert = NO;
    jsonPicker.loadingMessage = nil;
    jsonPicker.loadedSuccessfulMessage = nil;
    
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    [postData setObject:idStr forKey:@"id"];
    ///jhh_changed_菜牌_删除菜品
    [jsonPicker postData:postData withBaseRequest:@"cookbook/delete"];
//    [jsonPicker postData:postData withBaseRequest:@"DishCard/deleteItem"];
}

#pragma mark - UIButton

-(void)cuisineButtonPressed:(UIButton*)sender
{
    int index = sender.tag-1000;
    if (index!=selectedCuisineIndex)
    {
        int subViewCount = [allDishCardListArray count];
        for (int i = 0; i < subViewCount; i++)
        {
            UIButton *lastSelectedBtn = (UIButton*)[cuisineScrollview viewWithTag:i + 1000];
            lastSelectedBtn.selected = NO;
            [cuisineScrollview sendSubviewToBack:lastSelectedBtn];
        }
        
        UIButton *currentSelBtn = (UIButton*)[cuisineScrollview viewWithTag:index+1000];
        currentSelBtn.selected = YES;
        [cuisineScrollview bringSubviewToFront:currentSelBtn];
        
        selectedCuisineIndex = index;
        [dishCardTableview reloadData];
    }
}

//添加菜牌
- (IBAction)addDishCardItemButtonPressed:(UIButton*)sender
{
    [searchbarTextfield resignFirstResponder];
    if (0 == [allDishCardListArray count])
    {
        [PSAlertView showWithMessage:kLoc(@"please_add_cuisineInfo")];
        return;
    }
    //jhh_note
    int cuisineId = [[[allDishCardListArray objectAtIndex:selectedCuisineIndex] objectForKey:@"id"] intValue];
    
#if 0
    DishCardItemDetailPicker *dishCardNewPicker = [[DishCardItemDetailPicker alloc] initWithNibName:@"DishCardItemDetailPicker" bundle:nil];
    dishCardNewPicker.delegate = self;
    dishCardNewPicker.isEditEnable = self.moreBtn.enabled;
    
    [[MainViewController getMianViewShareInstance] presentPopupViewController:dishCardNewPicker animationType:MJPopupViewAnimationSlideBottomBottom];
    // 缩放视图
    scaleView(DishCardNewViewController.view);
    //刷新数据
    [dishCardNewPicker updateViewWithCuisineID:cuisineId withImgBaseURL:self.imgBaseURL];
#else
    [self hideAll];
    
    //通知刷新主标题
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    NSString *str = [NSString stringWithFormat:@"%@>新增", [[allDishCardListArray objectAtIndex:selectedCuisineIndex] objectForKey:@"name"] ];
    [info setObject:str forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
    
//    if (_dishCardNewVc == nil)
    {
        _dishCardNewVc = [[DishCardNewViewController alloc] init];
        _dishCardNewVc.allDishCardListArray = [NSMutableArray arrayWithArray:allDishCardListArray];;
        _dishCardNewVc.delegate = self;
    }
    [_dishCardNewVc showInView:self.view];
    
    //刷新数据
    [_dishCardNewVc updateViewWithCuisineID:cuisineId withImgBaseURL:self.imgBaseURL];
#endif
}

- (IBAction)moreButtonPressed:(UIButton*)sender
{
    [searchbarTextfield resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:kLoc(@"editing_cuisine"),kLoc(@"editing_remark"), nil];
    actionSheet.tag = 0;
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:sender.frame inView:self.view animated:YES];
    }
}

//优惠活动列表
- (IBAction)promotionBtnClick:(UIButton *)sender
{
    [self hideAll];
    
    _promotionController = [[promotionMainViewController alloc] initWithNibName:@"promotionMainViewController" bundle:nil];
    _promotionController.delegate = self;
    
    _promotionController.allCuisineDataArr = allDishCardListArray;
    
    [_promotionController showInView:self.view];
}

/**
 *  点击优惠组合按钮
 *
 *  @param sender btn
 */
- (IBAction)promotiongBtnClick:(UIButton *)sender
{
    if (discountViewController_)
    {
        [discountViewController_ dismissView];
    }
    discountViewController_ = [[DiscountViewController alloc]init];
    discountViewController_.allCuisineDataArr = allDishCardListArray;
    discountViewController_.delegate = self;
    self.moreBtn.hidden = YES;
    self.dishCardTableview.hidden = YES;
    self.cuisineScrollview.hidden = YES;
    self.promotiomGroupButton.hidden = YES;
    self.promotionButton.hidden = YES;
    [discountViewController_ showInView:self.view];
}

#pragma mark - promotionDelegate
- (void)promotionMainViewController:(promotionMainViewController *)ctrl didDismissView:(BOOL)flag
{
    [self displayAll];
}

#pragma mark - promotionsettingDelegate
- (void)DishCardNewViewController:(DishCardNewViewController*)ctrl didDismissView:(BOOL)flag
{
    [ctrl.view removeFromSuperview];
    
    if (flag)//是否有改动， 有则网络请求数据
    {
        [self performSelector:@selector(getDishCardDataAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:1];
    }
    
    [self displayAll];
}

- (void)DishCardNewViewControllerDidAddedNewItem:(NSDictionary *)item
{
    [self getDishCardDataAnimated:NO];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!isSearching) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    [searchbarTextfield resignFirstResponder];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!isSearching) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    else {
        [searchbarTextfield resignFirstResponder];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //退出删除状态
    if (isDeletingFlag)
    {
        [dishCardTableview reloadData];
        isDeletingFlag = NO;
    }
}

#pragma mark - Data Source Loading Methods

- (void)doneLoadingTableViewData{
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:dishCardTableview];
}

//结束加载数据,无论是否成功加载数据
- (void)finishLoading
{
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doneLoadingTableViewData) userInfo:nil repeats:NO];
}

#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    if (!isSearching) {
        [self getDishCardDataAnimated:NO];
    }
    else {
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doneLoadingTableViewData) userInfo:nil repeats:NO];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date];
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = kDishCardListTableviewCellReuseIdentifier;
	DishCardListTableviewCell *cell = (DishCardListTableviewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell)
    {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"DishCardListTableviewCell" owner:self options:nil] lastObject];
	}
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    int row = indexPath.row;
    cell.tag = row;
    
    if (!isSearching) {
        NSArray *cookbook = [[allDishCardListArray objectAtIndex:selectedCuisineIndex] objectForKey:@"cookbook"];
        int total = [cookbook count];
        NSDictionary *col1 = nil;
        NSDictionary *col2 = nil;
        if (row*2<total) {
            col1 = [cookbook objectAtIndex:row*2];
        }
        if (row*2+1<total) {
            col2 = [cookbook objectAtIndex:row*2+1];
        }
        [cell updateCellInfoAtColumn1:col1 column2:col2];
    }
    else {
        int total = [filterDishCardListArray count];
        NSDictionary *col1 = nil;
        NSDictionary *col2 = nil;
        if (row*2<total) {
            col1 = [filterDishCardListArray objectAtIndex:row*2];
        }
        if (row*2+1<total) {
            col2 = [filterDishCardListArray objectAtIndex:row*2+1];
        }
        [cell updateCellInfoAtColumn1:col1 column2:col2];
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    float height = 0;
    if (!isSearching) {
        NSArray *cookbook = [[allDishCardListArray objectAtIndex:selectedCuisineIndex] objectForKey:@"cookbook"];
        if ([cookbook count]==0 && !_reloading){
            height = 60;
        }
    }
    else {
        if ([filterDishCardListArray count]==0){
            height = 60;
        }
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!isSearching)
    {
        NSArray *cookbook = [[allDishCardListArray objectAtIndex:selectedCuisineIndex] objectForKey:@"cookbook"];
        if ([cookbook count]==0 && !_reloading)
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
        if ([filterDishCardListArray count]==0){
            UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 748, 60)];
            aView.backgroundColor = [UIColor clearColor];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 748, 60)];
            label1.numberOfLines = 2;
            label1.backgroundColor = [UIColor clearColor];
            label1.textAlignment = UITextAlignmentCenter;
            label1.font = [UIFont boldSystemFontOfSize:20];
            label1.textColor = [UIColor blackColor];
            label1.text = [NSString stringWithFormat:@"%@“%@”%@",kLoc(@"can_not_search_anything_which_contain_the_keyword"), searchbarTextfield.text,kLoc(@"the_dishes")];
            [aView addSubview:label1];
            
            return aView;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 72;
    
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int rows = 0;
    if (!isSearching) {
        if (selectedCuisineIndex < [allDishCardListArray count]) {
            NSArray *cookbook = [[allDishCardListArray objectAtIndex:selectedCuisineIndex] objectForKey:@"cookbook"];
            rows = [cookbook count]/2;
            if ([cookbook count]%2>0) {
                rows++;
            }
        }
    }
    else {
        rows = [filterDishCardListArray count]/2;
        if ([filterDishCardListArray count]%2>0) {
            rows++;
        }
    }
    return rows;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    isSearching = YES;
    [self removePullDownReFresh];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([searchbarTextfield.text isEqualToString:@""])
    {
        isSearching = NO;
        [self addPullDownReFresh];
        self.addDishBtn.hidden = NO;
        cuisineScrollview.hidden = NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int loc = range.location;
    int len = range.length;
#ifdef DEBGU
    NSLog(@"==shouldChangeCharactersInRange:%i,%i===", range.location, range.length);
#endif
    if (loc==0 && len==1)
    {
        isSearching = NO;
        [self addPullDownReFresh];
        [dishCardTableview reloadData];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    isSearching = YES;
    [self removePullDownReFresh];
    NSString *keywordWithoutSpace = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [searchbarTextfield resignFirstResponder];
    
    [self searchDishCardWithKeyword:keywordWithoutSpace];
    cuisineScrollview.hidden = YES;
    self.addDishBtn.hidden = YES;

     
    return YES;
}

#pragma mark UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (0 == actionSheet.tag)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                EditCuisineViewController *cuisineViewController = [[EditCuisineViewController alloc] initWithNibName:@"EditCuisineViewController" bundle:nil];
                cuisineViewController.delegate = self;
                
                [[MainViewController getMianViewShareInstance] presentPopupViewController:cuisineViewController animationType:MJPopupViewAnimationSlideBottomBottom];
                // 缩放视图
                scaleView(cuisineViewController.view);
                
                break;
            }
            case 1:
            {
                DishCardRemarkViewController *remarkViewController = [[DishCardRemarkViewController alloc] initWithNibName:@"DishCardRemarkViewController" bundle:nil];
                remarkViewController.delegate = self;
                
                [[MainViewController getMianViewShareInstance] presentPopupViewController:remarkViewController animationType:MJPopupViewAnimationSlideBottomBottom];
                // 缩放视图
                scaleView(remarkViewController.view);
                break;
            }
            case 2://优惠套餐临时入口
            {
                if (discountViewController_)
                {
                    [discountViewController_ dismissView];
                }
                discountViewController_ = [[DiscountViewController alloc]init];
                discountViewController_.delegate = self;
                self.moreBtn.hidden = YES;
                self.dishCardTableview.hidden = YES;
                self.cuisineScrollview.hidden = YES;
                [discountViewController_ showInView:self.view];
                break;
            }
                
            default:
            {
                break;
            }
        }
    }
}

#pragma mark - DishCardItemDetailPickerDelegate

- (void)DishCardItemDetailPickerDidAddedNewItem:(NSDictionary*)item
{
    [allDishCardListArray removeAllObjects];
    [allDishCardListArray addObjectsFromArray:[[item objectForKey:@"data"] objectForKey:@"list"]];
    //刷新
    [self updateBottomViewAfterGetData];
    [dishCardTableview reloadData];
}

- (void)dismissDishCardItemDetailPicker:(DishCardItemDetailPicker*)ctrl
{
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}
#pragma mark - DiscountViewControllerDelegate
- (void)DiscountViewController:(DiscountViewController *)ctrl didDismissView:(BOOL)flag
{
    self.moreBtn.hidden = NO;
    self.dishCardTableview.hidden = NO;
    self.cuisineScrollview.hidden = NO;
    self.promotionButton.hidden = NO;
    self.promotiomGroupButton.hidden = NO;
}
#pragma mark - EditCuisineViewControllerDelegate

-(void)dismissViewOfEditCuisineViewController:(EditCuisineViewController *)ctrl withLastestDishCardData:(NSDictionary *)dict
{
    if (dict)
    {
        if (!allDishCardListArray)
        {
            allDishCardListArray = [[NSMutableArray alloc] init];
        }
        [allDishCardListArray removeAllObjects];
        [allDishCardListArray addObjectsFromArray:[[dict objectForKey:@"data"] objectForKey:@"list"]];
        self.imgBaseURL = [[dict objectForKey:@"data"] objectForKey:@"imgBaseURL"];
        int listCount = [allDishCardListArray count];
        //确保selectedCuisineIndex小于listCount，避免去[allDishCardListArray objectAtIndex:selectedCuisineIndex]出问题
        if (selectedCuisineIndex >= listCount)
        {
            selectedCuisineIndex = listCount - 1;
            if (selectedCuisineIndex < 0)
            {
                selectedCuisineIndex = 0;
            }
        }
        //刷新
        [self updateBottomViewAfterGetData];
        [dishCardTableview reloadData];
    }
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
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
}

#pragma mark - DishCardRemarkViewControllerDelegate

- (void)dismissViewOfRemarkViewController:(DishCardRemarkViewController *)ctrl
{
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

#pragma mark - DishCardListTableviewCellDelegate

-(void)dishCardCellSelectedAtIndex:(int)index
{
    [searchbarTextfield resignFirstResponder];
    if (isDeletingFlag)
    {
        //退出删除状态
        [dishCardTableview reloadData];
        isDeletingFlag = NO;
        return;
    }
    NSDictionary *dishCardInfo = nil;
    if (!isSearching)
    {
        dishCardInfo = [[allDishCardListArray[selectedCuisineIndex] objectForKey:@"cookbook"] objectAtIndex:index];
    }
    else
    {
        dishCardInfo = filterDishCardListArray[index];
    }
    
#if 0
    DishCardItemDetailPicker *dishCardDetailPicker = [[DishCardItemDetailPicker alloc] initWithNibName:@"DishCardItemDetailPicker" bundle:nil];
    dishCardDetailPicker.delegate = self;
    dishCardDetailPicker.isEditEnable = self.moreBtn.enabled;
    
    [[MainViewController getMianViewShareInstance] presentPopupViewController:dishCardDetailPicker animationType:MJPopupViewAnimationSlideBottomBottom];
    // 缩放视图
    scaleView(dishCardDetailPicker.view);
    //刷新数据
    [dishCardDetailPicker updateViewWithDishInfo:dishCardInfo withImgBaseURL:self.imgBaseURL];
#else
    [self hideAll];
    
//    if (_dishCardNewVc == nil)
    {
        _dishCardNewVc = [[DishCardNewViewController alloc] init];
        _dishCardNewVc.allDishCardListArray = [NSMutableArray arrayWithArray:allDishCardListArray];
        _dishCardNewVc.delegate = self;
    }
    
    [_dishCardNewVc showInView:self.view];
    
    //刷新数据
    [_dishCardNewVc updateViewWithDishInfo:dishCardInfo withImgBaseURL:self.imgBaseURL];
    
    //通知刷新主标题
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *str = [NSString stringWithFormat:@"%@>%@", [[allDishCardListArray objectAtIndex:selectedCuisineIndex] objectForKey:@"name"] ,[dishCardInfo objectForKey:@"name"]];
    [dict setObject:NSLocalizedString(str, nil)  forKey:@"title"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:dict];
#endif
}

- (void)deleteDishCardState:(BOOL)flag
{
    isDeletingFlag = flag;
}

- (void)deleteDishCard:(DishCardListTableviewCell*)cell withItemId:(NSString *)itemId
{
    if (0 != [itemId length])
    {
        [self deleteDishItems:itemId];
        isDeletingFlag = NO;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

#pragma mark - JsonPickerDelegate
-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    if (picker.tag==1 || picker.tag == 2)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            case 200:
            {
                if (!allDishCardListArray)
                {
                    allDishCardListArray = [[NSMutableArray alloc] init];
                    selectedCuisineIndex = 0;
                }
                [allDishCardListArray removeAllObjects];
                if (0 != [[[dict objectForKey:@"data"] objectForKey:@"list"] count])
                {
                    [allDishCardListArray addObjectsFromArray:[[dict objectForKey:@"data"] objectForKey:@"list"]];
                }
                self.imgBaseURL = [[dict objectForKey:@"data"] objectForKey:@"imgBaseURL"];
                
                //刷新
                [self updateBottomViewAfterGetData];
                [dishCardTableview reloadData];

                break;
            }
            case 201:
            {
                [allDishCardListArray removeAllObjects];
                [dishCardTableview reloadData];
                
                break;
            }
            case 250:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                
                if (!allDishCardListArray)
                {
                    allDishCardListArray = [[NSMutableArray alloc] init];
                    selectedCuisineIndex = 0;
                }
                [allDishCardListArray removeAllObjects];
                if (0 != [[[dict objectForKey:@"data"] objectForKey:@"list"] count])
                {
                    [allDishCardListArray addObjectsFromArray:[[dict objectForKey:@"data"] objectForKey:@"list"]];
                }
                self.imgBaseURL = [[dict objectForKey:@"data"] objectForKey:@"imgBaseURL"];
                
                //刷新
                [self updateBottomViewAfterGetData];
                [dishCardTableview reloadData];
            }
            default:
            {
                sleep(1.5);
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
