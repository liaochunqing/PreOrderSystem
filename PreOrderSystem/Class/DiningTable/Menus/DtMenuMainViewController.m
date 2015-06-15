//
//  DtMenuMainViewController.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-27.
//
//

#import "DtMenuMainViewController.h"
#import "DiningTableImageName.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "PSAlertView.h"
#import "NsstringAddOn.h"
#import "DiningTableDataClass.h"
#import "DtMenuDataClass.h"
#import "Constants.h"
#import "UIViewController+ShowInView.h"
#import "UIViewController+MJPopupViewController.h"
#import "DtPreOrderDishViewController.h"
#import "MainViewController.h"
#import "CustomPopoverTouchView.h"
#import "DishSelectView.h"
#import "TakeoutCookbookPackageViewController.h"

#define kReturnAlertViewTag 10771
#define kDtMenuCuisineBtnTag 1000
#define kHeightForRowAtIndexPath 70
#define kDtMenuCuisineCount [dtMenuListDataClass.dtMenuListArray count]
#define kUIButtonClassStr @"UIButton"
#define kDtMenuCuisineBtnTitleNormalColor [UIColor colorWithRed:254.0/255.0 green:254.0/255.0 blue:254.0/255.0 alpha:1.0]
#define kDtMenuCuisineBtnTitleSelectedColor [UIColor colorWithRed:91.0/255.0 green:68.0/255.0 blue:34.0/255.0 alpha:1.0]

#define kDtMenuCookbookViewStartOrigin CGPointMake(1024.0, 50.0)
#define kDtMenuCookbookViewEndOrigin CGPointMake(563.0, 50.0)


@interface DtMenuMainViewController ()<DtPreOrderDishViewControllerDelegate, CustomPopoverTouchViewDelegate>
{
    JsonPicker *jsonPicker;
    DtMenuListDataClass *dtMenuListDataClass;
    int currentCuisineIndex;
    BOOL reloading;//下拉刷新
    EGORefreshTableHeaderView *refreshHeaderView;//下拉刷新
    DtMenuCookbookViewController *dtMenuCookbookVc;
    DtMenuCookbookPackageViewController *dtMenuCookbookPackageVc;
    DtMenuShoppingCarViewController *dtMenuShoppingCarVc;
    CustomPopoverTouchView *customTouchView;
    UIViewController *currentVCFromRight;
    
    ///左边选菜View,
    DishSelectView *dishSelectView_;
    
    /// 套餐点菜视图控制器
    TakeoutCookbookPackageViewController *takeoutCookbookPackageVc;
}

- (IBAction)shoppingCarBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;

@end

@implementation DtMenuMainViewController

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
    
    currentCuisineIndex = kDtMenuCuisineBtnTag;
    [self addPictureToView];
    [self addLocalizedString];
    [self addPullDownReFresh];
    [self getDtMenuData:YES];
    [self loadDishView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTopTitle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (void)loadDishView
{
    dishSelectView_ = [[DishSelectView alloc]initWithFrame:CGRectMake(8, 162, 420, 549)];
    dishSelectView_.delegate = self;
    dishSelectView_.isAddDishOnly = YES;
    [dishSelectView_ addDishByID];
    [dishSelectView_ setEGORefreshView];
    [self.view addSubview:dishSelectView_];
}


- (void)updateTopTitle
{
    NSMutableString *topTitleStr = nil;
    NSString *currentHousingStr = [NSString getStrWithoutWhitespace:self.housingDataClass.housingName];
    if (![NSString strIsEmpty:currentHousingStr])
    {
        topTitleStr = [[NSMutableString alloc]initWithFormat:@"%@>%@",currentHousingStr, kLoc(@"menu")];
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        [info setObject:topTitleStr forKey:@"title"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
    }
}

- (void)addPictureToView
{
    UIImage *btnImg = [UIImage imageFromMainBundleFile:kDtBtnSecondBgImageName];
    [self.shoppingCarButton setBackgroundImage:btnImg forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:btnImg forState:UIControlStateNormal];
    self.bgImageView.image = [UIImage imageFromMainBundleFile:kDtAddAreadBgImageName];
}

/**
 *  刷新该版面顶部的台号/会员等信息
 */
- (void)updateTableInfo
{
    NSDictionary *orderInfoDic = dtMenuListDataClass.orderInfoDic;
    self.seatTimeTextField.delegate = self;
    self.userNumberTextField.delegate = self;
    self.peopleNumTextField.delegate  = self;
    if (orderInfoDic.count)
    {
        self.tableNameTextField.text = [orderInfoDic objectForKey:@"tableName"];
        self.peopleNumTextField.text = [orderInfoDic objectForKey:@"numberOfPeople"];
        self.userNumberTextField.text = [orderInfoDic objectForKey:@"userNumber"];
        self.userNameTextField.text = [orderInfoDic objectForKey:@"userName"];
        self.roomAreaTextField.text = [orderInfoDic objectForKey:@"typeName"];
        self.membershipPointTextField.text = [orderInfoDic objectForKey:@"integral"];
        
        
        NSString *errStr = @"0000";
        NSString *timeStr = [orderInfoDic objectForKey:@"seatingTime"];
        NSRange rang = [timeStr rangeOfString:errStr];
        if (rang.location == NSNotFound)
        {
            self.seatTimeTextField.text = timeStr;
        }
    }
    else
    {
        self.tableNameTextField.text = self.housingDataClass.housingName;
    }
}

- (void)addLocalizedString
{
    [self.shoppingCarButton setTitle:kLoc(@"shopping_car") forState:UIControlStateNormal];
    [self.backButton setTitle:kLoc(@"back") forState:UIControlStateNormal];
}

//初始化“下拉刷新”控件
- (void)addPullDownReFresh
{
    reloading = NO;
    if (refreshHeaderView == nil)
    {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.menuTableView.bounds.size.height, self.menuTableView.bounds.size.width, self.menuTableView.bounds.size.height)];
		refreshHeaderView.delegate = self;
        refreshHeaderView.backgroundColor = [UIColor clearColor];
		[self.menuTableView addSubview:refreshHeaderView];
	}
	[refreshHeaderView refreshLastUpdatedDate];
}

- (void)dismissAllViewController
{
    self.shoppingCarButton.enabled = YES;
    self.backButton.enabled = YES;
    
    [dtMenuCookbookVc dismissViewToRight:kDtMenuCookbookViewStartOrigin];
    [dtMenuCookbookPackageVc dismissViewToRight:kDtMenuCookbookViewStartOrigin];
    [dtMenuShoppingCarVc dismissViewToRight:kDtMenuCookbookViewStartOrigin];
    [customTouchView removeFromSuperview];
}

- (DtMenuCookbookDataClass *)getDtMenuCookbookDataClass:(NSDictionary *)dict
{
    DtMenuCookbookDataClass *tempClass = [[DtMenuCookbookDataClass alloc] initWithDtMenuCookbookData:dict];
    return tempClass;
}
#pragma mark -private method
// 日期选择器
- (void)datePickerCreate
{

    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n", @""]
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:kLoc(@"confirm")
                                  otherButtonTitles:nil, nil];
    actionSheet.tag = 1;
    if (self.datetimePicker == nil)
    {
        self.datetimePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0.0, 270.0, 300.0)];
        if (kIsiPhone)
        {
            self.datetimePicker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
        }
        self.datetimePicker.backgroundColor = [UIColor clearColor];
    }
    
    if ([self.seatTimeTextField.text length] > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *date = [dateFormatter dateFromString:self.seatTimeTextField.text];
        
        if (date == nil)
        {
            date = [NSDate date];
        }
        self.datetimePicker.date = date;
    }
    
    [actionSheet addSubview:self.datetimePicker];
    CGRect textFrame = self.seatTimeTextField.frame;
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:textFrame inView:self.view animated:YES];
    }
}

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

#pragma mark - goto VC

/*购物车*/
- (void)gotoDtMenuShoppingCarVC:(DtMenuShoppingCarListDataClass *)dataClass
{
    self.shoppingCarButton.enabled = NO;
    //self.backButton.enabled = NO;
    
    if (!dtMenuShoppingCarVc) {
        dtMenuShoppingCarVc = [[DtMenuShoppingCarViewController alloc] initWithNibName:@"DtMenuShoppingCarViewController" bundle:nil];
    }
    dtMenuShoppingCarVc.delegate = self;
    dtMenuShoppingCarVc.housingDataClass = self.housingDataClass;
    dtMenuShoppingCarVc.shoppingCarListDataClass = [dataClass copy];
    dtMenuShoppingCarVc.areaName = self.areaName;
    dtMenuShoppingCarVc.housingStateType = self.housingStateType;
    currentVCFromRight = dtMenuShoppingCarVc;
    //[self showViewInMianView:dtMenuShoppingCarVc];
    
    dtMenuShoppingCarVc.seatingTime = self.seatTimeTextField.text?:@"";
    dtMenuShoppingCarVc.userNumber = self.userNumberTextField.text?:@"";
    dtMenuShoppingCarVc.numberOfPeople = self.peopleNumTextField.text?:@"";
    
    [self.view addSubview:dtMenuShoppingCarVc.view];
    dtMenuShoppingCarVc.view.frame = CGRectMake(395, 140, dtMenuShoppingCarVc.view.frame.size.width, dtMenuShoppingCarVc.view.frame.size.height);
}

/*预点菜入台*/
- (void)gotoPreOrderDishVC
{
    DtPreOrderDishViewController *preOrderDishVC = [[DtPreOrderDishViewController alloc]initWithNibName:@"DtPreOrderDishViewController" bundle:nil];
    preOrderDishVC.delegate = self;
    preOrderDishVC.queueListArray = dtMenuListDataClass.queueListArray;
    preOrderDishVC.housingId = self.housingDataClass.housingId;
    
    MainViewController *mainVC = [MainViewController getMianViewShareInstance];
    [mainVC presentPopupViewController:preOrderDishVC
                         animationType:MJPopupViewAnimationSlideBottomBottom];
    // 缩放视图
    scaleView(mainVC.view);
}

#pragma mark - add Cuisine to scrollowView

- (void)addCuisineToScrollowView
{
    NSArray *btnArray = self.cuisineScrollView.subviews;
    int btnCount = [btnArray count];
    for (int i = 0; i < btnCount; i++)
    {
        id tempClass = [btnArray objectAtIndex:i];
        if ([tempClass isKindOfClass:NSClassFromString(kUIButtonClassStr)])
        {
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
    for (int i = 0; i < cuisineCount; i++)
    {
        DtMenuDataClass *tempClass = [self getDtMenuCuisineData:i];
        
        UIFont *titleFont = [UIFont boldSystemFontOfSize:20];
        CGSize titleSize = [tempClass.cuisineName sizeWithFont:titleFont];
        btnWidth = titleSize.width + btnSpace;
        if (btnWidth < normalImg.size.width)
        {
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
    if (index < kDtMenuCuisineCount)
    {
        DtMenuDataClass *tempClass = [[DtMenuDataClass alloc] initWithDtMenuData:[dtMenuListDataClass.dtMenuListArray objectAtIndex:index]];
        return tempClass;
    }
    return nil;
}

#pragma mark - Button Clicked

- (IBAction)shoppingCarBtnClicked:(id)sender
{
    [self getShoppingCarData:NO];
}

- (IBAction)backBtnClicked:(id)sender
{
    self.housingStateType = dtMenuShoppingCarVc.housingStateType;
    if (dtMenuShoppingCarVc.isModified_ || dtMenuShoppingCarVc.isAddNewDish_)
    {
        NSString *alertMessage = kLoc(@"data_is_not_saved_confirm_to_leave");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertMessage
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:kLoc(@"cancel")
                                                  otherButtonTitles:kLoc(@"confirm"), nil];
        alertView.tag = kReturnAlertViewTag;
        [alertView show];
    }
    else
    {
        [self getShoppingCarDataForBackButton:YES];
    }
    
}

- (void)cuisineBtnClicked:(UIButton *)sender
{
    int index = sender.tag;
    if (index != currentCuisineIndex)
    {
        UIButton *oldSelectedBtn = (UIButton*)[self.cuisineScrollView viewWithTag:currentCuisineIndex];
        UIButton *newSelectedBtn = (UIButton*)[self.cuisineScrollView viewWithTag:index];
        oldSelectedBtn.selected = NO;
        newSelectedBtn.selected = YES;
        currentCuisineIndex = index;
        [self.menuTableView reloadData];
        [self dismissAllViewController];
    }
}

#pragma mark - network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

- (void)getDtMenuData:(BOOL)animated
{
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    NSString *networkPathStr = @"diningtable/open";
    [postData setObject:[NSNumber numberWithInt:self.housingDataClass.housingId] forKey:@"tableId"];
    
    if (!jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = YES;
    if (!animated)
    {
        jsonPicker.loadingMessage = nil;
    }
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:networkPathStr];
}

- (void)getShoppingCarData:(BOOL)animated
{
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    [postData setObject:[NSNumber numberWithInt:self.housingDataClass.housingId] forKey:@"tableId"];
    
    if (!jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerSecondTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = NO;
    if (!animated)
    {
        jsonPicker.loadingMessage = nil;
    }
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:@"diningtable/getCart"];
}

- (void)getShoppingCarDataForBackButton:(BOOL)animated
{
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    [postData setObject:[NSNumber numberWithInt:self.housingDataClass.housingId] forKey:@"tableId"];
    
    if (!jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerThirdTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = YES;
    if (!animated)
    {
        jsonPicker.loadingMessage = nil;
    }
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:@"diningtable/getCart"];
}

/**
 *  根据用户输入的会员号获取会员名
 *
 *  @param userNumber 会员号
 */
- (void)getUserNameByUserNumber:(NSString *)userNumber showActivityIndicator:(BOOL)animated
{
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    [postData setObject:userNumber forKey:@"userNumber"];
    
    if (!jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFourthTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = NO;
    if (!animated)
    {
        jsonPicker.loadingMessage = nil;
    }
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:@"diningtable/getUserName"];
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = kDtMenuListTableViewCellReuseIdentifier;
	DtMenuListTableViewCell *cell = (DtMenuListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell)
    {
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
    if (indexForCell < cookbookCount)
    {
        if (thirdIndex < cookbookCount)
        {
            firstClass =  [self getDtMenuCookbookDataClass:[cookbookArray objectAtIndex:firstIndex]];
            secondClass = [self getDtMenuCookbookDataClass:[cookbookArray objectAtIndex:secondIndex]];
            thirdClass =  [self getDtMenuCookbookDataClass:[cookbookArray objectAtIndex:thirdIndex]];
        }
        else if (secondIndex < cookbookCount)
        {
            firstClass = [self getDtMenuCookbookDataClass:[cookbookArray objectAtIndex:firstIndex]];
            secondClass = [self getDtMenuCookbookDataClass:[cookbookArray objectAtIndex:secondIndex]];
        }
        else
        {
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
    if ( 0 == tempCount % kDtMenuSmallCellNumForPerListCell)
    {
        number = tempCount / kDtMenuSmallCellNumForPerListCell;
    }
    else
    {
        number = tempCount / kDtMenuSmallCellNumForPerListCell + 1;
    }
    return number;
}

#pragma mark - DtMenuListTableViewCellDelegate

- (void)dishCellSelectedAtIndex:(DtMenuCookbookDataClass *)dishDataClass
{
    self.shoppingCarButton.enabled = NO;
    self.backButton.enabled = NO;
    
    UIViewController *tempVC = nil;
    DtMenuDataClass *tempDataClass = [self getDtMenuCuisineData:(currentCuisineIndex - kDtMenuCuisineBtnTag)];
    if (kZeroNumber != [dishDataClass.packageArray count])
    {
        // 套餐点菜
        if (!dtMenuCookbookPackageVc)
        {
            dtMenuCookbookPackageVc = [[DtMenuCookbookPackageViewController alloc] initWithNibName:@"DtMenuCookbookPackageViewController" bundle:nil];
        }
        dtMenuCookbookPackageVc.cuisineRemarkArray = tempDataClass.remarkArray;
        dtMenuCookbookPackageVc.delegate = self;
        dtMenuCookbookPackageVc.cookbookDataClass = dishDataClass;
        dtMenuCookbookPackageVc.housingId = self.housingDataClass.housingId;
        tempVC = currentVCFromRight = dtMenuCookbookPackageVc;
    }
    else
    {
        // 普通点菜
        if (!dtMenuCookbookVc) {
            dtMenuCookbookVc = [[DtMenuCookbookViewController alloc] initWithNibName:@"DtMenuCookbookViewController" bundle:nil];
        }
        dtMenuCookbookVc.cuisineRemarkArray = tempDataClass.remarkArray;
        dtMenuCookbookVc.delegate = self;
        dtMenuCookbookVc.cookbookDataClass = dishDataClass;
        dtMenuCookbookVc.housingId = self.housingDataClass.housingId;
        tempVC = currentVCFromRight = dtMenuCookbookVc;
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


#pragma mark - DtMenuCookbookViewControllerDelegate

- (void)DtMenuCookbookViewHavedDismiss
{
    [self dismissAllViewController];
}

#pragma mark - TakeoutCookbookPackageViewControllerDelegate methods

- (void)takeoutCookbookPackageViewHavedDismiss
{
    //[self dismissAllViewController];//旧版
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

- (void)takeoutCookbookPackageViewController:(TakeoutCookbookPackageViewController *)ctl didSavePackageDish:(NSDictionary *)packageDishData
{
    [dtMenuShoppingCarVc addNewDish:packageDishData dishIsPackage:YES];
}
#pragma mark - DtMenuCookbookViewPackageControllerDelegate

- (void)DtMenuCookbookPackageViewHavedDismiss
{
    [self dismissAllViewController];
}

#pragma mark - DtMenuShoppingCarViewControllerDelegate

- (void)dtMenuShoppingCarViewHavedDismiss
{
    self.housingStateType = dtMenuShoppingCarVc.housingStateType;
    [self dismissAllViewController];
}

- (void)submitFailWithNewDishData:(NSDictionary *)dic
{
    dtMenuListDataClass = [[DtMenuListDataClass alloc] initWithDtMenuListData:dic];
//    [self.menuTableView reloadData];
//    [self addCuisineToScrollowView];
    
    //给左边的通用选菜view添加数据源.
    [dishSelectView_ setSelectDataModel:dtMenuListDataClass.dtMenuListArray];
    [dishSelectView_ reloadData];
}

#pragma mark - DtPreOrderDishViewControllerDelegate

-(void)dismissDtPreOrderDishViewController
{
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

#pragma mark - CustomPopoverTouchViewDelegate

- (void)customPopoverTouchView:(UIView*)view touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    // 点击不做操作
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

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kReturnAlertViewTag)
    {
        if (buttonIndex == alertView.cancelButtonIndex)
        {
            return;
        }
        else if (1 == buttonIndex)
        {
            [self getShoppingCarDataForBackButton:YES];
        }
    }
    else
    {
        switch (buttonIndex)
        {
            case 0://取消
            {
                if ([self.delegate respondsToSelector:@selector(dtMenuMainViewHavedDismiss: withHousingData: flag:)])
                {
                    [self.delegate dtMenuMainViewHavedDismiss:self.housingButtonCell withHousingData:self.housingDataClass flag: NO];
                }
                break;
            }
            case 1://确定
            {
                if ([self.delegate respondsToSelector:@selector(dtMenuMainViewHavedDismiss: withHousingData: flag:)])
                {
                    [self.delegate dtMenuMainViewHavedDismiss:self.housingButtonCell withHousingData:self.housingDataClass flag: YES];
                }
                break;
            }
                
            default:
                break;
        }
    }

}

#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (actionSheet.tag)
    {
        case 1:
        {
            if (buttonIndex == actionSheet.destructiveButtonIndex)
            {
                // 时间选择完成
                self.seatTimeTextField.text = [NSString dateToNSString:self.datetimePicker.date
                                                        withFormat:@"yyyy-MM-dd HH:mm"];
                dtMenuShoppingCarVc.seatingTime = self.seatTimeTextField.text;
                
            } else {
                // 尽快送达
                //self.seatTimeTextField.text = kLoc(@"as_soon_as_possible");
            }
            break;
        }
            
        default: {
            break;
        }
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
    if ([textField isEqual:self.seatTimeTextField])
    {
        // 时间选择
        [self.view endEditing:YES];
        [self performSelector:@selector(datePickerCreate)
                   withObject:nil
                   afterDelay:0.3];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.peopleNumTextField])
    {
        dtMenuShoppingCarVc.numberOfPeople = textField.text;
    }
    else if ([textField isEqual:self.userNumberTextField])
    {
        dtMenuShoppingCarVc.userNumber = textField.text;
        if (textField.text.length)
        {
            [self getUserNameByUserNumber:textField.text showActivityIndicator:NO];
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // 限制只能输入数字
    if (textField == self.peopleNumTextField)
    {
        return [self validateNumber:string];
    }
    return YES;
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
        NSMutableDictionary *originDishDataDic = [NSMutableDictionary dictionaryWithDictionary:[tempDataClass.cookbookArray objectAtIndex:cpath.cookbookIndex]];
        DtMenuCookbookDataClass *selectedCookBook = [self getDtMenuCookbookDataClass:originDishDataDic];
        [originDishDataDic setObject:tempDataClass.remarkArray forKey:@"remark"];
        
       // self.cuisineRemarkArray = tempDataClass.remarkArray;
        if (selectedCookBook.packageArray.count)//若是套餐,则弹出套餐设置界面
        {
            takeoutCookbookPackageVc = [[TakeoutCookbookPackageViewController alloc] initWithNibName:@"TakeoutCookbookPackageViewController" bundle:nil];
            takeoutCookbookPackageVc.cuisineRemarkArray = tempDataClass.remarkArray;
            //房台内点菜忽略打包费:
            selectedCookBook.packfee = @"";
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
        else//普通菜则直接传进购物车
        {
            [dtMenuShoppingCarVc addNewDish:originDishDataDic dishIsPackage:NO];
        }
        
    }
}


#pragma mark - JsonPickerDelegate

//@"diningtable/open"
- (void)handleFirstJsonPicker:(NSDictionary *)dict
{
    NSLog(@"***%@",dict);
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    dtMenuListDataClass = [[DtMenuListDataClass alloc] initWithDtMenuListData:dataClass.dataDict];
    
    //给左边的通用选菜view添加数据源.
    [dishSelectView_ setSelectDataModel:dtMenuListDataClass.dtMenuListArray];
    [dishSelectView_ reloadData];
    [self updateTableInfo];
    //获取购物车数据并显示:
    if (!dtMenuShoppingCarVc)
    {
        [self shoppingCarBtnClicked:nil];
    }
    
    
    //[self.menuTableView reloadData];
    //[self addCuisineToScrollowView];
    
    NSString *alertMsgStr = [NSString getStrWithoutWhitespace:dataClass.alertMsg];
    switch (dataClass.responseStatus)
    {
        case kFirstResponseStatus:
        {
            if (self.housingStateType != kHousingHavedDish)
            {
                self.housingStateType = kHousingHavedOpen;
            }
            if (![NSString strIsEmpty:alertMsgStr])
            {
                [PSAlertView showWithMessage:alertMsgStr];
            }
            
            // 不显示预点菜入座
//            if (kHousingNotOpen == self.housingDataClass.housingStatus && [dtMenuListDataClass.queueListArray count])
//            {
//                
//                [self gotoPreOrderDishVC];
//            }
            break;
        }
        case kSecondResponseStatus:
        {
            if (![NSString strIsEmpty:alertMsgStr])
            {
                [PSAlertView showWithMessage:alertMsgStr];
            }
            
            break;
        }
        default:
        {
            if (![NSString strIsEmpty:alertMsgStr])
            {
                [PSAlertView showWithMessage:alertMsgStr];
            }
            break;
        }
    }
}

- (void)handleSecondJsonPicker:(NSDictionary *)dict
{
#ifdef DEBUG
    NSLog(@"****%@",dict);
#endif
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    DtMenuShoppingCarListDataClass *shoppingCarListDataClass = [[DtMenuShoppingCarListDataClass alloc] initWithDtMenuShoppingCarListData:dataClass.dataDict];
    switch (dataClass.responseStatus)
    {
        case kFirstResponseStatus:
        {

            /*
            if ([shoppingCarListDataClass.dishesArray count])
            {
                [self gotoDtMenuShoppingCarVC:shoppingCarListDataClass];
            }
            else
            {
                [PSAlertView showWithMessage:dataClass.alertMsg];
            }
             */
            [self gotoDtMenuShoppingCarVC:shoppingCarListDataClass];
            break;
        }
        default:
        {
            //[PSAlertView showWithMessage:dataClass.alertMsg];
            [self gotoDtMenuShoppingCarVC:shoppingCarListDataClass];
            break;
        }
    }
}

- (void)handleThirdJsonPicker:(NSDictionary *)dict
{
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    switch (dataClass.responseStatus)
    {
        case kSecondResponseStatus://201 无数据
        {
            
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil
                                                               message:kLoc(@"clear_the_tables")
                                                              delegate:self
                                                     cancelButtonTitle:kLoc(@"no")
                                                     otherButtonTitles:kLoc(@"yes"), nil];
            [alerView show];
            break;
        }
            
        default:
        {
            if ([self.delegate respondsToSelector:@selector(dtMenuMainViewHavedDismiss:withHousingData:flag:)])
            {
                [self.delegate dtMenuMainViewHavedDismiss:self.housingButtonCell withHousingData:self.housingDataClass flag:NO];
            }
            break;
        }
    }
}

- (void)handleFourthJsonPicker:(NSDictionary *)dict
{
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    switch (dataClass.responseStatus)
    {
        case kFirstResponseStatus:
        {
            NSString *userNameStr = [[dict objectForKey:@"data"]objectForKey:@"userName"];
            if (userNameStr)
            {
                self.userNameTextField.text = userNameStr;
            }
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
#ifdef DEBUG
    NSLog(@"===%@,dict:%@===",self.class,dict);
#endif
    
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
            
        case kJsonPickerThirdTag:
        {
            [self handleThirdJsonPicker:dict];
            break;
        }
        case kJsonPickerFourthTag:
        {
            [self handleFourthJsonPicker:dict];
        }
            
        default:
        {
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
