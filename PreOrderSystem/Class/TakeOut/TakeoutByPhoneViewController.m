//
//  TakeoutByPhoneViewController.m
//  PreOrderSystem
//
//  Created by YorkIT on 14-6-17.
//  jhh_外卖_电话外卖
//

#import "TakeoutByPhoneViewController.h"
#import "DiningTableImageName.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "PSAlertView.h"
#import "NsstringAddOn.h"
#import "DiningTableDataClass.h"
#import "DtMenuDataClass.h"
#import "Constants.h"
#import "UIViewController+ShowInView.h"
#import "UIViewController+MJPopupViewController.h"
#import "MainViewController.h"
#import "CustomPopoverTouchView.h"
#import "TakeoutUserInfoViewController.h"
#import "CookbookPath.h"
#import "CuisineDataModel.h"
#import "CustomBadge.h"
#import "CookbookDataClass.h"

#define kDtMenuCuisineBtnTag 1000
#define kHeightForRowAtIndexPath 70
#define kDtMenuCuisineCount [dtMenuListDataClass.dtMenuListArray count]
#define kUIButtonClassStr @"UIButton"
#define kDtMenuCuisineBtnTitleNormalColor [UIColor colorWithRed:254.0/255.0 green:254.0/255.0 blue:254.0/255.0 alpha:1.0]
#define kDtMenuCuisineBtnTitleSelectedColor [UIColor colorWithRed:91.0/255.0 green:68.0/255.0 blue:34.0/255.0 alpha:1.0]

#define kDtMenuCookbookViewStartOrigin CGPointMake(1024.0, 50.0)
#define kDtMenuCookbookViewEndOrigin CGPointMake(563.0, 50.0)

#define kCancelAlertViewTag 89

@interface TakeoutByPhoneViewController() <CustomPopoverTouchViewDelegate,
TakeoutUserInfoViewControllerDelegate, UIAlertViewDelegate> {
    
    /// 网络请求对象
    JsonPicker *jsonPicker;
    /// 数据源
    DtMenuListDataClass *dtMenuListDataClass;
    /// 当前选中的菜系索引
    int currentCuisineIndex;
    /// 正在刷新
    BOOL reloading;
    /// 下拉刷新视图
    EGORefreshTableHeaderView *refreshHeaderView;
    /// 普通点菜视图控制器
    TakeoutCookbookViewController *takeoutCookbookVc;
    /// 套餐点菜视图控制器
    TakeoutCookbookPackageViewController *takeoutCookbookPackageVc;
    /// 购物车视图控制器
    TakeoutShoppingCarViewController *takeoutShoppingCarVc;
    /// 点击事件视图
    CustomPopoverTouchView *customTouchView;
    /// 要显示的视图控制器
    UIViewController *currentVCFromRight;
    
    ///临时测试选菜View,
    DishSelectView *dishSelectView_;
    
    //购物车物品数量
    CustomBadge *sideBadge;
}

- (IBAction)shoppingCarBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;

@end

@implementation TakeoutByPhoneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentCuisineIndex = kDtMenuCuisineBtnTag;
    [self addPictureToView];
    [self addLocalizedString];
    //[self addPullDownReFresh];
    [self getDtMenuData:YES];
    if (self.phoneOrderInputTypeDefault)
    {
        [self userInfoButtonAction:nil];
    }
    [self justTest];
}

- (void)justTest
{
    dishSelectView_ = [[DishSelectView alloc]initWithFrame:CGRectMake(0, 70, 420, 640)];
    dishSelectView_.delegate = self;
    dishSelectView_.isAddDishOnly = YES;
    [dishSelectView_ addDishByID];
    [dishSelectView_ setEGORefreshView];
    [self.view addSubview:dishSelectView_];
    
//    [self shoppingCarBtnClicked:nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //测试用,启动时删除上次数据
    [userDefaults setObject:nil forKey:kTakeoutByPhoneDishesListKey];
    [userDefaults synchronize];
    [self gotoDtMenuShoppingCarVC];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTopTitle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

/**
 * @brief   更新标题。
 *
 */
- (void)updateTopTitle
{
    NSString *topTitleStr = [NSString stringWithFormat:@"%@>%@",kLoc(@"takeout"), kLoc(@"phone_order")];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:topTitleStr forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
}

- (void)addPictureToView
{
    UIImage *btnImg = [UIImage imageFromMainBundleFile:kDtBtnSecondBgImageName];
    [self.userInfoButton setBackgroundImage:btnImg forState:UIControlStateNormal];
    [self.shoppingCarButton setBackgroundImage:btnImg forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:btnImg forState:UIControlStateNormal];
    self.bgImageView.image = [UIImage imageFromMainBundleFile:kDtAddAreadBgImageName];
}

- (void)addLocalizedString
{
//    [self.shoppingCarButton setTitle:kLoc(@"data_input") forState:UIControlStateNormal];
    [self.shoppingCarButton setTitle:kLoc(@"shopping_car") forState:UIControlStateNormal];
    [self.backButton setTitle:kLoc(@"back") forState:UIControlStateNormal];
    [self.userInfoButton setTitle:kLoc(@"data_input") forState:UIControlStateNormal];
}

//初始化“下拉刷新”控件
- (void)addPullDownReFresh
{
    reloading = NO;
    if (refreshHeaderView == nil)
    {
        CGRect refreshRect = CGRectMake(0.0,
                                        0.0f - dishSelectView_.originalMenuTableView.bounds.size.height,
                                        dishSelectView_.originalMenuTableView.bounds.size.width,
                                        dishSelectView_.originalMenuTableView.bounds.size.height);
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:refreshRect];
		refreshHeaderView.delegate = self;
        refreshHeaderView.backgroundColor = [UIColor blackColor];
		[dishSelectView_.originalMenuTableView addSubview:refreshHeaderView];
	}
	[refreshHeaderView refreshLastUpdatedDate];
}

- (void)dismissAllViewController
{
    self.userInfoButton.enabled = YES;
    self.shoppingCarButton.enabled = YES;
    self.backButton.enabled = YES;
    
    [takeoutCookbookVc dismissViewToRight:kDtMenuCookbookViewStartOrigin];
    [takeoutCookbookPackageVc dismissViewToRight:kDtMenuCookbookViewStartOrigin];
    [takeoutShoppingCarVc dismissViewToRight:kDtMenuCookbookViewStartOrigin];
    [customTouchView removeFromSuperview];
}

- (DtMenuCookbookDataClass *)getDtMenuCookbookDataClass:(NSDictionary *)dict
{
    DtMenuCookbookDataClass *tempClass = [[DtMenuCookbookDataClass alloc] initWithDtMenuCookbookData:dict];
    return tempClass;
}

#pragma mark - goto VC

/**
 * @brief   进入购物车。
 *
 *
 */
- (void)gotoDtMenuShoppingCarVC
{
    /*
     测试新购物车,临时屏蔽:
    self.userInfoButton.enabled = NO;
    self.shoppingCarButton.enabled = NO;
    self.backButton.enabled = NO;
    */
    if (!takeoutShoppingCarVc)
    {
        takeoutShoppingCarVc = [[TakeoutShoppingCarViewController alloc] initWithNibName:@"TakeoutShoppingCarViewController"
                     bundle:nil];
    }
    takeoutShoppingCarVc.delegate = self;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *tempDishList = [userDefaults objectForKey:kTakeoutByPhoneDishesListKey];
    NSDictionary *userInfo = [userDefaults objectForKey:kTakeoutByPhoneUserInfoKey];
    NSMutableDictionary *carData = [NSMutableDictionary dictionary];
    if (userInfo != nil)
    {
        [carData setObject:userInfo forKey:@"corpInfo"];
    }
    if (tempDishList.count)
    {
        [carData setObject:tempDishList forKey:@"dishes"];
    }
    
    // 复制对象，否则无法编辑（重要）
    carData = [DtMenuShoppingCarListDataClass duplicateObject:carData];
    DtMenuShoppingCarListDataClass *carListData = nil;
    carListData = [[DtMenuShoppingCarListDataClass alloc] initWithDtMenuShoppingCarListData:carData];
    takeoutShoppingCarVc.shoppingCarListDataClass = carListData;
    currentVCFromRight = takeoutShoppingCarVc;
    /*
    原版:
    [self showViewInMianView:takeoutShoppingCarVc];
     */
    [self.view addSubview:takeoutShoppingCarVc.view];

    takeoutShoppingCarVc.view.frame = CGRectMake(390, 50, takeoutShoppingCarVc.view.frame.size.width, takeoutShoppingCarVc.view.frame.size.height);
}

#pragma mark - add Cuisine to scrollowView

- (void)addCuisineToScrollowView
{
    NSArray *btnArray = self.cuisineScrollView.subviews;
    int btnCount = [btnArray count];
    for (int i = 0; i < btnCount; i++) {
        id tempClass = [btnArray objectAtIndex:i];
        if ([tempClass isKindOfClass:NSClassFromString(kUIButtonClassStr)]) {
            UIButton *tempView = (UIButton *)tempClass;
            [tempView removeFromSuperview];
        }
    }
    
    int cuisineCount = kDtMenuCuisineCount;
    float btnWidth = 0.0;
    UIImage *normalImg = [UIImage imageFromMainBundleFile:kDtMenuCuisineNormalBtnBgImageName];
    UIImage *selectImg = [UIImage imageFromMainBundleFile:kDtMenuCuisineSelectedBtnBgImageName];
    float btnHeight = normalImg.size.height;
    float contentSizeWidth = 0.0;
    float btnSpace = 60;
    for (int i = 0; i < cuisineCount; i++) {
        DtMenuDataClass *tempClass = [self getDtMenuCuisineData:i];
        
        UIFont *titleFont = [UIFont boldSystemFontOfSize:20];
        CGSize titleSize = [tempClass.cuisineName sizeWithFont:titleFont];
        btnWidth = titleSize.width + btnSpace;
        if (btnWidth < normalImg.size.width) {
            btnWidth = normalImg.size.width;
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i + kDtMenuCuisineBtnTag;
        btn.frame = CGRectMake(contentSizeWidth, 0, btnWidth, btnHeight);
        [btn setTitle:tempClass.cuisineName forState:UIControlStateNormal];
        btn.titleLabel.font = titleFont;
        [btn setTitleColor:kDtMenuCuisineBtnTitleNormalColor forState:UIControlStateNormal];
        [btn setTitleColor:kDtMenuCuisineBtnTitleSelectedColor forState:UIControlStateSelected];
        [btn setBackgroundImage:normalImg forState:UIControlStateNormal];
        [btn setBackgroundImage:selectImg forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(cuisineBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.cuisineScrollView addSubview:btn];
        
#ifdef DEBUG
        NSLog(@"===%s,%f,%f===",__FUNCTION__, contentSizeWidth, btnWidth);
#endif
        
        contentSizeWidth = contentSizeWidth + btnWidth - 3;
    }
    self.cuisineScrollView.contentSize = CGSizeMake(contentSizeWidth, btnHeight);
    UIButton *currentSelectedBtn = (UIButton*)[self.cuisineScrollView viewWithTag:currentCuisineIndex];
    currentSelectedBtn.selected = YES;
}

- (DtMenuDataClass *)getDtMenuCuisineData:(int)index
{
    if (index < kDtMenuCuisineCount) {
        DtMenuDataClass *tempClass = [[DtMenuDataClass alloc] initWithDtMenuData:[dtMenuListDataClass.dtMenuListArray objectAtIndex:index]];
        return tempClass;
    }
    return nil;
}

#pragma mark - Button Clicked

- (IBAction)userInfoButtonAction:(id)sender
{
    TakeoutUserInfoViewController *userInfoController = nil;
    userInfoController = [[TakeoutUserInfoViewController alloc] init];
    userInfoController.delegate = self;
    userInfoController.phoneOrderTypeDefault = self.phoneOrderTypeDefault;
    [[MainViewController getMianViewShareInstance] presentPopupViewController:userInfoController
                                                                animationType:MJPopupViewAnimationSlideBottomBottom];
    // 缩放视图
    scaleView(userInfoController.view);
}

- (IBAction)shoppingCarBtnClicked:(id)sender
{
}

- (IBAction)backBtnClicked:(id)sender
{
    // 尝试关闭
    [self tryDismissView];
}

/**
 * @brief   点击菜系按钮事件。
 *
 */
- (void)cuisineBtnClicked:(UIButton *)sender
{
    int index = sender.tag;
    if (index != currentCuisineIndex) {
        UIButton *oldSelectedBtn = (UIButton *)[self.cuisineScrollView viewWithTag:currentCuisineIndex];
        UIButton *newSelectedBtn = (UIButton *)[self.cuisineScrollView viewWithTag:index];
        oldSelectedBtn.selected = NO;
        newSelectedBtn.selected = YES;
        currentCuisineIndex = index;
        [self.menuTableView reloadData];
        [self dismissAllViewController];
    }
}

- (void)tryDismissView
{
    // 获取数据
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id dishesData = [userDefaults objectForKey:kTakeoutByPhoneDishesListKey];
    id userInfo = [userDefaults objectForKey:kTakeoutByPhoneUserInfoKey];
    BOOL willShowAlert = NO;
    if (dishesData != nil || userInfo != nil) {
        willShowAlert = YES;
    } else if (takeoutCookbookVc != nil && takeoutCookbookVc.view.superview != nil) {
        willShowAlert = YES;
    } else if (takeoutCookbookPackageVc != nil && takeoutCookbookPackageVc.view.superview != nil) {
        willShowAlert = YES;
    }
    
    if (willShowAlert) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kLoc(@"data_is_not_saved_confirm_to_leave")
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:kLoc(@"cancel")
                                                  otherButtonTitles:kLoc(@"confirm"), nil];
        alertView.tag = kCancelAlertViewTag;
        [alertView show];
    } else {
        // 执行离开
        [dishSelectView_ removeNotification];
        if ([self.delegate respondsToSelector:@selector(takeoutByPhoneViewController:dismissWithDataChanged:)]) {
            [self.delegate takeoutByPhoneViewController:self dismissWithDataChanged:NO];
        }
    }

}

#pragma mark - network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

- (void)getDtMenuData:(BOOL)animated
{
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    NSString *networkPathStr = @"diningtable/cookbook";
    
    if (!jsonPicker) {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = YES;
    if (!animated) {
        jsonPicker.loadingMessage = nil;
    }
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:networkPathStr];
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = kDtMenuListTableViewCellReuseIdentifier;
	DtMenuListTableViewCell *cell = (DtMenuListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"DtMenuListTableViewCell" owner:self options:nil] lastObject];
	}
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    int indexRow = indexPath.row;
    cell.tag = indexRow;
    DtMenuDataClass *tempDataClass = [self getDtMenuCuisineData:(currentCuisineIndex - kDtMenuCuisineBtnTag)];
    NSArray *cookbookArray = tempDataClass.cookbookArray;
    int cookbookCount = [cookbookArray count];
    
    DtMenuCookbookDataClass *firstClass = nil;
    DtMenuCookbookDataClass *secondClass = nil;
    DtMenuCookbookDataClass *thirdClass = nil;
    int indexForCell = indexRow * kDtMenuSmallCellNumForPerListCell;
    const int firstIndex = indexForCell;
    const int secondIndex = firstIndex + 1;
    const int thirdIndex = secondIndex + 1;
    if (indexForCell < cookbookCount) {
        if (thirdIndex < cookbookCount) {
            firstClass = [self getDtMenuCookbookDataClass:[cookbookArray objectAtIndex:firstIndex]];
            secondClass = [self getDtMenuCookbookDataClass:[cookbookArray objectAtIndex:secondIndex]];
            thirdClass = [self getDtMenuCookbookDataClass:[cookbookArray objectAtIndex:thirdIndex]];
        } else if (secondIndex < cookbookCount) {
            firstClass = [self getDtMenuCookbookDataClass:[cookbookArray objectAtIndex:firstIndex]];
            secondClass = [self getDtMenuCookbookDataClass:[cookbookArray objectAtIndex:secondIndex]];
        } else {
            firstClass = [self getDtMenuCookbookDataClass:[cookbookArray objectAtIndex:firstIndex]];
        }
    }
    [cell updateCellInfo:firstClass withColumnSecond:secondClass withColumnThird:thirdClass];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeightForRowAtIndexPath;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int index = currentCuisineIndex - kDtMenuCuisineBtnTag;
    DtMenuDataClass *tempDataClass = [self getDtMenuCuisineData:index];
    NSArray *tempArray = tempDataClass.cookbookArray;
    int tempCount = [tempArray count];
    int number = 0;
    if ( 0 == tempCount % kDtMenuSmallCellNumForPerListCell) {
        number = tempCount / kDtMenuSmallCellNumForPerListCell;
    } else {
        number = tempCount / kDtMenuSmallCellNumForPerListCell + 1;
    }
    return number;
}

#pragma mark - DtMenuListTableViewCellDelegate

- (void)dishCellSelectedAtIndex:(DtMenuCookbookDataClass *)dishDataClass
{
    self.userInfoButton.enabled = NO;
    self.shoppingCarButton.enabled = NO;
    self.backButton.enabled = NO;
    
    UIViewController *tempVC = nil;
    DtMenuDataClass *tempDataClass = [self getDtMenuCuisineData:(currentCuisineIndex - kDtMenuCuisineBtnTag)];
    if (kZeroNumber != [dishDataClass.packageArray count]) {
        // 套餐点菜
        if (!takeoutCookbookPackageVc) {
            takeoutCookbookPackageVc = [[TakeoutCookbookPackageViewController alloc] initWithNibName:@"TakeoutCookbookPackageViewController" bundle:nil];
        }
        takeoutCookbookPackageVc.cuisineRemarkArray = tempDataClass.remarkArray;
        takeoutCookbookPackageVc.delegate = self;
        takeoutCookbookPackageVc.cookbookDataClass = dishDataClass;
        tempVC = currentVCFromRight = takeoutCookbookPackageVc;
        
    } else {
        // 普通点菜
        if (!takeoutCookbookVc)
        {
            takeoutCookbookVc = [[TakeoutCookbookViewController alloc] initWithNibName:@"TakeoutCookbookViewController" bundle:nil];
        }
        takeoutCookbookVc.cuisineRemarkArray = tempDataClass.remarkArray;
        takeoutCookbookVc.delegate = self;
        takeoutCookbookVc.cookbookDataClass = dishDataClass;
        tempVC = currentVCFromRight = takeoutCookbookVc;
    }
    [self showViewInMianView:tempVC];
}

- (void)showViewInMianView:(UIViewController *)showVC
{
    MainViewController *mainVC = [MainViewController getMianViewShareInstance];
    if (!customTouchView) {
        CGRect viewFrame = mainVC.view.bounds;
        viewFrame.origin.x = 160.0;
        viewFrame.size.width -= 160.0;
        customTouchView = [[CustomPopoverTouchView alloc] initWithFrame:viewFrame];
    }
    customTouchView.delegate = self;
    [mainVC.view addSubview:customTouchView];
    [showVC showInViewFromRightSide:mainVC
               withStartOriginPoint:kDtMenuCookbookViewStartOrigin
                 withEndOriginPoint:kDtMenuCookbookViewEndOrigin];
}


#pragma mark - TakeoutCookbookViewControllerDelegate methods

- (void)takeoutCookbookViewHavedDismiss
{
    [self dismissAllViewController];
}

#pragma mark - TakeoutCookbookPackageViewControllerDelegate methods

- (void)takeoutCookbookPackageViewHavedDismiss
{
    //[self dismissAllViewController];//旧版
    [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
}

- (void)takeoutCookbookPackageViewController:(TakeoutCookbookPackageViewController *)ctl didSavePackageDish:(NSDictionary *)packageDishData
{
    [self reloadCar];
}

#pragma mark - TakeoutShoppingCarViewControllerDelegate methods


- (void)takeoutShoppingCarViewHadDismiss:(TakeoutShoppingCarViewController *)viewController
{
    [self dismissAllViewController];
}


- (void)takeoutShoppingCarViewSubmitted:(TakeoutShoppingCarViewController *)viewController
{
    [self dismissAllViewController];
    
    // 关闭电话外卖视图
    if ([self.delegate respondsToSelector:@selector(takeoutByPhoneViewController:dismissWithDataChanged:)]) {
        [self.delegate takeoutByPhoneViewController:self dismissWithDataChanged:YES];
    }
}

- (void)takeoutShoppingCarViewMustInputUserInfo:(TakeoutShoppingCarViewController *)viewController
{
    // 弹出资料输入页面
    [self userInfoButtonAction:self.userInfoButton];
}

//购物车提交失败,返回新的菜品数据.
- (void)takeoutShoppingCarViewSubmittedFailWithNewCookBookData:(SuperDataClass *)superDataClass
{
    
    //给左边的通用选菜view添加数据源.
    NSLog(@">>>>%@",[superDataClass.dataDict objectForKey:@"cookbook"]);
    NSMutableDictionary *temDic = [[NSMutableDictionary alloc]init];
    [temDic setObject:[superDataClass.dataDict objectForKey:@"cookbook"] forKey:@"list"];
    dtMenuListDataClass = [[DtMenuListDataClass alloc] initWithDtMenuListData:temDic];
    [dishSelectView_ setSelectDataModel:[superDataClass.dataDict objectForKey:@"cookbook"]];
    [dishSelectView_ reloadData];
    [self refreshCarDish:temDic];
}

#pragma mark - CustomPopoverTouchViewDelegate

- (void)customPopoverTouchView:(UIView *)view touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    // 点击不做操作
}

#pragma mark - TakeoutUserInfoViewControllerDelegate methods

- (void)takeoutUserInfoViewControllerDidDismiss:(TakeoutUserInfoViewController *)viewController
{
    // 检测资料输入情况
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [userDefault objectForKey:kTakeoutByPhoneUserInfoKey];
    if (userInfo == nil) {
        // 用户没有输入，取消购物车检测
        takeoutShoppingCarVc.isWaitingForContinue = NO;
    }
    
    [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark Data Source Loading / Reloading Methods

- (void)doneLoadingTableViewData
{
	reloading = NO;
	[refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.menuTableView];
}

//结束加载数据,无论是否成功加载数据
- (void)finishLoading
{
    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self getDtMenuData:NO];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kCancelAlertViewTag) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // 通知sliderBar停止继续
            [MainViewController getMianViewShareInstance].breakPressAction = YES;
        } else {
            // 关闭子页面
            [self dismissAllViewController];
            
            // 确定离开
            if ([self.delegate respondsToSelector:@selector(takeoutByPhoneViewController:dismissWithDataChanged:)]) {
                [self.delegate takeoutByPhoneViewController:self dismissWithDataChanged:NO];
            }
        }
    }
}
#pragma mark - DishSelectViewDelegate
- (void)DishSelectView:(DishSelectView *)disSelectView DidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self getDtMenuData:NO];
}

- (void)DishSelectVieW:(DishSelectView *)disSelectView didSelectedCookbookPathArr:(NSMutableArray *)indexArr
{
    for (CookbookPath *cpath in indexArr)
    {
        DtMenuDataClass *tempDataClass = (DtMenuDataClass *) [self getDtMenuCuisineData:cpath.cuisineIndex];
        DtMenuCookbookDataClass *selectedCookBook = [self getDtMenuCookbookDataClass:[tempDataClass.cookbookArray objectAtIndex:cpath.cookbookIndex]];
        self.cuisineRemarkArray = tempDataClass.remarkArray;
        if (selectedCookBook.packageArray.count)
        {
            takeoutCookbookPackageVc = [[TakeoutCookbookPackageViewController alloc] initWithNibName:@"TakeoutCookbookPackageViewController" bundle:nil];
            takeoutCookbookPackageVc.cuisineRemarkArray = tempDataClass.remarkArray;
            takeoutCookbookPackageVc.delegate = self;
            takeoutCookbookPackageVc.cookbookDataClass = selectedCookBook;
            if (tempDataClass.remarkArray.count)
            {
                takeoutCookbookPackageVc.isNoRemark = NO;
            }
            else
            {
                takeoutCookbookPackageVc.isNoRemark = YES;
            }
            [[MainViewController getMianViewShareInstance] presentPopupViewController:takeoutCookbookPackageVc animationType:MJPopupViewAnimationSlideBottomBottom];
            // 缩放视图
            scaleView(takeoutCookbookPackageVc.view);
        }
        else
        {
            [self addCookbookToCar:selectedCookBook];
        }
        
    }
    [self reloadCar];
}


- (void)DishSelectVieW:(DishSelectView *)disSelectView didRemovedCookbookPathArr:(NSMutableArray *)indexArr
{
    for (CookbookPath *cpath in indexArr)
    {
        DtMenuDataClass *tempDataClass = (DtMenuDataClass *) [self getDtMenuCuisineData:cpath.cuisineIndex];
        DtMenuCookbookDataClass *selectedCookBook = [self getDtMenuCookbookDataClass:[tempDataClass.cookbookArray objectAtIndex:cpath.cookbookIndex]];
        self.cuisineRemarkArray = tempDataClass.remarkArray;
        [self removeCookbookFromCar:selectedCookBook];
    }
    [self reloadCar];
}


/**
 *  刷新购物车
 */
- (void)reloadCar
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *tempDishList = [userDefaults objectForKey:kTakeoutByPhoneDishesListKey];
    if (tempDishList == nil) {
        tempDishList = [NSArray array];
    }
    NSMutableArray *dishesList = [NSMutableArray arrayWithArray:tempDishList];
    NSDictionary *userInfo = [userDefaults objectForKey:kTakeoutByPhoneUserInfoKey];
    NSMutableDictionary *carData = [NSMutableDictionary dictionary];
    if (userInfo != nil)
    {
        [carData setObject:userInfo forKey:@"corpInfo"];
    }
    if (dishesList.count)
    {
        [carData setObject:dishesList forKey:@"dishes"];
    }
    
    // 复制对象，否则无法编辑（重要）
    carData = [DtMenuShoppingCarListDataClass duplicateObject:carData];
    DtMenuShoppingCarListDataClass *carListData = nil;
    carListData = [[DtMenuShoppingCarListDataClass alloc] initWithDtMenuShoppingCarListData:carData];
    takeoutShoppingCarVc.shoppingCarListDataClass = carListData;
    [takeoutShoppingCarVc reload];
}

/**
 *  删除一个菜品(从左边选择框)
 *  照搬旧代码,待优化.
 *  @param cookbookData 待删菜品
 */
- (void)removeCookbookFromCar:(DtMenuCookbookDataClass *)cookbookData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *tempDishList = [userDefaults objectForKey:kTakeoutByPhoneDishesListKey];
    if (tempDishList == nil) {
        tempDishList = [NSArray array];
    }
    NSMutableArray *dishesList = [NSMutableArray arrayWithArray:tempDishList];
    for (NSDictionary *dishInfo in dishesList)
    {
        if ([[dishInfo objectForKey:@"name"] isEqualToString:cookbookData.name])
        {
            [dishesList removeObject:dishInfo];
            break;
        }
    }
    [userDefaults setObject:dishesList forKey:kTakeoutByPhoneDishesListKey];
    [userDefaults synchronize];
}


//jhh_newCar
/**
 *  添加一个菜品
 *  照搬旧代码,待优化.
 *  @param cookbookData 待添加菜品
 */
- (void)addCookbookToCar:(DtMenuCookbookDataClass *)cookbookData
{

    NSArray *priceArray = cookbookData.priceArray;
    
    NSDictionary *priceDic = (NSDictionary *)[priceArray objectAtIndex:0];
    NSString *styleStr = [priceDic objectForKey:@"style"];
    NSString *currentPromotePriceStr = [NSString stringWithFormat:@"%@",[priceDic objectForKey:@"promotePrice"]];
    NSString *currentPriceStr = [NSString stringWithFormat:@"%@",[priceDic objectForKey:@"promotePrice"]];
    if (!currentPriceStr.length)
    {
        currentPriceStr = [NSString stringWithFormat:@"%@",[priceDic objectForKey:@"price"]];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *tempDishList = [userDefaults objectForKey:kTakeoutByPhoneDishesListKey];
    if (tempDishList == nil)
    {
        tempDishList = [NSArray array];
    }
    NSMutableArray *dishesList = [NSMutableArray arrayWithArray:tempDishList];
    NSMutableDictionary *dishInfo = [NSMutableDictionary dictionary];
    [dishInfo setObject:cookbookData.name forKey:@"name"];
    [dishInfo setObject:@"1"forKey:@"quantity"];
    
    //备注,空的
    NSMutableArray *currentRemarks = [[NSMutableArray alloc]init];
    [dishInfo setObject:currentRemarks forKey:@"currentRemark"];
    [dishInfo setObject:self.cuisineRemarkArray forKey:@"remark"];
    NSArray *testArr = cookbookData.packageArray;

    [dishInfo setObject:testArr forKey:@"package"];
    [dishInfo setObject:styleStr forKey:@"currentStyle"];
    [dishInfo setObject:currentPromotePriceStr forKey:@"currentPromotePrice"];
    [dishInfo setObject:currentPriceStr forKey:@"currentPrice"];
    [dishInfo setObject:[priceDic objectForKey:@"price"] forKey:@"originalPrice"];
    [dishInfo setObject:cookbookData.priceArray forKey:@"price"];
    [dishInfo setObject:cookbookData.isMultiStyle forKey:@"isMultiStyle"];
    [dishInfo setObject:[NSNumber numberWithInt:1] forKey:@"modifiable"];
    [dishInfo setObject:cookbookData.packageArray forKey:@"package"];
    [dishInfo setObject:cookbookData.cookID forKey:@"cbID"];
    [dishInfo setObject:cookbookData.packfee forKey:@"packfee"];
    [dishInfo setObject:[NSNumber numberWithInt:0] forKey:@"currentStyleIndex"];
    [dishesList addObject:dishInfo];
    
    // 本地保存
    [userDefaults setObject:dishesList forKey:kTakeoutByPhoneDishesListKey];
    [userDefaults synchronize];
}

//刷新购物车中的价格数据.
- (void)refreshCarDish:(NSDictionary *)temDic
{
    NSArray *temArr = dishSelectView_.allCuisineArr;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *tempDishList = [userDefaults objectForKey:kTakeoutByPhoneDishesListKey];
    if (tempDishList == nil)
    {
        tempDishList = [NSArray array];
    }
    NSMutableArray *dishesList = [NSMutableArray arrayWithArray:tempDishList];
    for (int x = 0;x < dishesList.count;x++)
    {
        NSDictionary *oldDishInfo = [dishesList objectAtIndex:x];
        NSMutableDictionary *dishInfo = [NSMutableDictionary dictionaryWithDictionary:oldDishInfo];
        NSString *cbID = [dishInfo objectForKey:@"cbID"];
        NSInteger styleIndex = [[dishInfo objectForKey:@"currentStyleIndex"]integerValue];
        for (int i = 0;i < temArr.count;i++)
        {
            BOOL isFound = NO;
            for (int i = 0; i<[dtMenuListDataClass.dtMenuListArray count]; i++)
            {
                BOOL isFound = NO;
                DtMenuDataClass *tempDataClass = (DtMenuDataClass *) [self getDtMenuCuisineData:i];
                for (int j = 0; j < tempDataClass.cookbookArray.count; j++)
                {
                    DtMenuCookbookDataClass *selectedCookBook = [self getDtMenuCookbookDataClass:[tempDataClass.cookbookArray objectAtIndex:j]];
                    if ([cbID isEqualToString:selectedCookBook.cookID])
                    {
                         NSArray *priceArray = selectedCookBook.priceArray;
                        if (priceArray.count > styleIndex)
                        {
                            NSDictionary *priceDic = (NSDictionary *)[priceArray objectAtIndex:styleIndex];
                            [dishInfo setObject:[priceDic objectForKey:@"style"] forKey:@"currentStyle"];
                            [dishInfo setObject:[NSString stringWithFormat:@"%@",[priceDic objectForKey:@"promotePrice"]] forKey:@"currentPromotePrice"];
                            [dishInfo setObject:[priceDic objectForKey:@"price"] forKey:@"currentPrice"];
                        }
                        [dishInfo setObject:priceArray forKey:@"price"];
                        [dishesList replaceObjectAtIndex:x withObject:dishInfo];
                        isFound = YES;
                        break;
                    }
                }
            }
            if (isFound)
            {
                break;
            }
        }
    }
    
    // 本地保存
    [userDefaults setObject:dishesList forKey:kTakeoutByPhoneDishesListKey];
    [userDefaults synchronize];
    [self reloadCar];
    
}

#pragma mark - JsonPickerDelegate methods

- (void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
#ifdef DEBUG
    NSLog(@"===%@, dict:%@===", self.class, dict);
#endif
    
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    
    switch (picker.tag) {
        case kJsonPickerFirstTag: {
            // 获取菜系和菜式列表
            dtMenuListDataClass = [[DtMenuListDataClass alloc] initWithDtMenuListData:dataClass.dataDict];
            
            //给左边的通用选菜view添加数据源.
            [dishSelectView_ setSelectDataModel:dtMenuListDataClass.dtMenuListArray];
            [dishSelectView_ reloadData];
            
            // 更新UI
            [self.menuTableView reloadData];
            
            // 将菜系添加到滚动容器视图
            [self addCuisineToScrollowView];
            
            [PSAlertView showWithMessage:dataClass.alertMsg];
            
            break;
        }
            
        default: {
#ifdef DEBUG
            NSLog(@"===%s,error===",__FUNCTION__);
#endif
            break;
        }
    }
    [self finishLoading];
}

// JSON解释错误时返回
- (void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error
{
    [self finishLoading];
}

// 网络连接失败时返回（无网络的情况）
- (void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error
{
    [self finishLoading];
}

@end
