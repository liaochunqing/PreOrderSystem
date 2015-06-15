//
//  DiningTableMainViewController.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-27.
//
//

#import "DiningTableMainViewController.h"
#import "DiningTableGuideView.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "PSAlertView.h"
#import "DiningTableDataClass.h"
#import "Constants.h"
#import "NsstringAddOn.h"
#import "DiningTableImageName.h"
#import "UIViewController+ShowInView.h"
#import "MainViewController.h"
#import "OfflineManager.h"
#import "StaffManagementSuperDataClass.h"


#define kMoreUIActionSheetTag 1000
#define kClearUIAlertViewTag 1100
#define kAreaBtnTag 1200
#define kIsShowHeadView ((0 == [dtDataArray count])?YES:NO)
#define kDiningTableAreaCount [diningTableDataClass.diningTableDataArray count]
#define kHousingPageControltintColor ([UIColor colorWithRed:189.0/255.0 green:189.0/255.0 blue:189.0/255.0 alpha:1.0])
#define kHousingPageControlCurrentPageIndicatorTintColor ([UIColor colorWithRed:241.0/255.0 green:108.0/255.0 blue:16.0/255.0 alpha:1.0])
#define kHousingScrollViewWidth self.housingScrollView.frame.size.width
#define kHousingScrollViewHeight self.housingScrollView.frame.size.height
#define kHousingBtnCellSpaceX 190
#define kHousingBtnCellSpaceY 120
#define kHousingMaxCountPerPage 16
#define kHousingCountPerRow 4
#define kHousingCountPerColumn 4
#define kGetDiningTableDataNetworkPath @"diningtable/getlist"
#define kUpdateHousingStatusNetworkPath @"diningtable/updateStatus"
#define kUpdateHousingStatusNetworkTableInfoParameter @"tableInfo"
#define kUpdateHousingStatusNetworkOperationTypeParameter @"operationType"
#define kDtSubAuthBookingIndexStr @"booking"            /*订座*/
#define kDtSubAuthDisablingIndexStr @"disabling"       /*停用*/
#define kDtSubAuthClearingIndexStr @"clearing"        /*清空*/
#define kDtSubAuthSettingIndexStr @"setting"         /*设置*/
#define kISHavedShowAddGuideView @"iSHavedShowAddGuideView"


typedef enum {
    kButtonFirstIndex = 0,
    kButtonSecondIndex,
    kButtonThirdIndex,
    kButtonFourthIndex
}kButtonIndex;

@interface DiningTableMainViewController ()
{
    DiningTableGuideView *guideView;
    DiningTableAreaListView *areaListView;
    DtMenuMainViewController *dtMenuMainVC;
    JsonPicker *jsonPicker;
    DiningTableDataClass *diningTableDataClass;
    int selectedAreaIndex;
    NSMutableArray *housingInfoArray;/*切换房台状态时用到*/
    NSString *operationTypeStr;/*切换房台状态时用到*/
    NSMutableArray *actionSheetSubAuthArray;
    
    /// 标记房台列表的“未读”的数目
    int duc;
    /// 标记订座列表的“未读”的数目
    int puc;
    /// 标记外卖列表的“未读”的数目
    int tuc;
    /// 标记服务列表的“未读”的数目
    int muc;
    /// 标记外卖列表的“催单”的数目
    int ruc;
    
    /// 要选中的房台编号
    NSString *currentTableId_;
}

@property(nonatomic, weak) IBOutlet UIButton *refrashButton;
@property(nonatomic, weak) IBOutlet UIButton *moreButton;
@property(nonatomic, weak) IBOutlet UIButton *cancelButton;
@property(nonatomic, weak) IBOutlet UIButton *trueButton;
@property(nonatomic, weak) IBOutlet UIImageView *topBgImageView;
@property(nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property(nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property(nonatomic, weak) IBOutlet UIImageView *guideImageView;
@property(nonatomic, weak) IBOutlet UIImageView *leftShortGradualChangeImageView;
@property(nonatomic, weak) IBOutlet UIImageView *rightShortGradualChangeImageView;
@property(nonatomic, weak) IBOutlet UIImageView *leftGradualChangeImageView;
@property(nonatomic, weak) IBOutlet UIImageView *rightGradualChangeImageView;
@property(nonatomic, weak) IBOutlet UIScrollView *areaScrollView;
@property(nonatomic, weak) IBOutlet UIScrollView *housingScrollView;
@property(nonatomic, weak) IBOutlet UIPageControl *housingPageControl;
@property(nonatomic, weak) IBOutlet UILabel *noDataLabel;


- (IBAction)refrashBtnClicked:(UIButton*)sender;
- (IBAction)moreBtnClicked:(UIButton*)sender;
- (IBAction)cancelBtnClicked:(UIButton*)sender;
- (IBAction)trueBtnClicked:(UIButton*)sender;

@end

@implementation DiningTableMainViewController

- (void)dealloc
{
    [self removeNotifications];
}

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
    
    selectedAreaIndex = -1;
    operationTypeStr = nil;
    housingInfoArray = [[NSMutableArray alloc]init];
    [self addPictureToView];
    [self addLocalizedString];
    [self updateDiningTableAuthority];
    [self getDiningTableData:YES];
    [self addNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTopTitle];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [areaListView dismissAreaListView:nil];
    [dtMenuMainVC dismissViewControllerWithAnimated:NO];
    dtMenuMainVC = nil;
    self.view.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ((kSystemVersionOfCurrentDevice >= 6.0) && [self isViewLoaded] && ![self.view window])
    {
        [self viewDidUnload];
        [self setView:nil];
        areaListView = nil;
    }
}

- (void)addPictureToView
{
    UIImage *btnImage = [UIImage imageFromMainBundleFile:kDtBtnSecondBgImageName];
    self.topBgImageView.image = [UIImage imageFromMainBundleFile:kDtFrameTopBgImageName];
    self.bgImageView.image = [UIImage imageFromMainBundleFile:kDtFrameWhiteBgImageName];
    self.leftGradualChangeImageView.image = [UIImage imageFromMainBundleFile:kDtLeftShortGradualChangeImageName];
    self.rightGradualChangeImageView.image = [UIImage imageFromMainBundleFile:kDtRightShortGradualChangeImageName];
    self.leftGradualChangeImageView.image = [UIImage imageFromMainBundleFile:kDtLeftGradualChangeImageName];
    self.rightGradualChangeImageView.image = [UIImage imageFromMainBundleFile:kDtRightGradualChangeImageName];
    [self.moreButton setImage:[UIImage imageFromMainBundleFile:kDtMoreBtnImageName] forState:UIControlStateNormal];
    [self.refrashButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.trueButton setBackgroundImage:btnImage forState:UIControlStateNormal];
}

- (void)addLocalizedString
{
    [self.refrashButton setTitle:kLoc(@"refresh") forState:UIControlStateNormal];
    [self.cancelButton setTitle:kLoc(@"cancel") forState:UIControlStateNormal];
    [self.trueButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
}

// 注册Notification
- (void)addNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(updatedDinnerTableData:)
               name:kShouldUpdateDinningTableList
             object:nil];
}

// 撤消Notification
- (void)removeNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)whetherShowPicture
{
    if (0 == kDiningTableAreaCount) {
        self.lineImageView.image = nil;
        /*是否显示暂无数据*/
        self.noDataLabel.hidden = YES;
        self.guideImageView.image = [UIImage imageFromMainBundleFile:@"dt_guideSecondBg.png"];
    } else {
        self.lineImageView.image = [UIImage imageFromMainBundleFile:@"dt_frameLine.png"];
        self.guideImageView.image = nil;
    }
}

- (void)whetherShowMoreBtn:(BOOL)flag
{
    self.refrashButton.hidden = self.moreButton.hidden = !flag;
    self.cancelButton.hidden = self.trueButton.hidden = flag;
    self.leftGradualChangeImageView.hidden = self.rightGradualChangeImageView.hidden = !flag;
    NSString *bgImgStr = (flag)?kDtFrameWhiteBgImageName:kDtFrameGrayBgImageName;
    self.bgImageView.image = [UIImage imageFromMainBundleFile:bgImgStr];
}

- (AreaDataClass *)getAreaData:(int)index
{
    if (index < kDiningTableAreaCount) {
        AreaDataClass *tempClass = [[AreaDataClass alloc] initWithAreaData:[diningTableDataClass.diningTableDataArray objectAtIndex:index]];
        return tempClass;
    }
    return nil;
}

- (void)updateTopTitle
{
    int index = selectedAreaIndex - kAreaBtnTag;
    AreaDataClass *tempClass = [self getAreaData:index];
    NSMutableString *topTitleStr = [[NSMutableString alloc]initWithFormat:@"%@",kLoc(@"table")];
    NSString *currentAreaStr = [NSString getStrWithoutWhitespace:tempClass.typeName];
    if (![NSString strIsEmpty:currentAreaStr]) {
        [topTitleStr appendString:[NSString stringWithFormat:@">%@", currentAreaStr]];
    }
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:topTitleStr forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle
                                                        object:nil
                                                      userInfo:info];
}

- (void)updateDiningTableAuthority
{
    if (!actionSheetSubAuthArray) {
        actionSheetSubAuthArray = [[NSMutableArray alloc] init];
    }
    [actionSheetSubAuthArray removeAllObjects];
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSArray *authorityArray = [offlineMgr getAccountAuthority];
    for (NSDictionary *authDict in authorityArray) {
        StaffManagementAuthDataClass *authClass = [[StaffManagementAuthDataClass alloc] initWithStaffManagementAuthData:authDict];
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfDiningTableIndexStr]) {
            for (StaffManagementSubAuthDataClass *subAuth in authClass.childrenArray) {
                if (subAuth.open && ([subAuth.indexStr isEqualToString:kDtSubAuthBookingIndexStr]||[subAuth.indexStr isEqualToString:kDtSubAuthDisablingIndexStr]||[subAuth.indexStr isEqualToString:kDtSubAuthClearingIndexStr]||[subAuth.indexStr isEqualToString:kDtSubAuthSettingIndexStr])) {
                    [actionSheetSubAuthArray addObject:subAuth];
                }
            }
            break;
        }
    }
    self.moreButton.enabled = ([actionSheetSubAuthArray count])?YES:NO;
    // 追加取消功能键
    [actionSheetSubAuthArray addObject:kLoc(@"cancel")];
}

#pragma mark - show/dismiss view

- (void)showDiningTableMainViewInView:(UIView *)aView
{
    CGRect frame = self.view.frame;
    frame.origin.x = 170;
    self.view.frame = frame;
    [aView addSubview:self.view];
}

- (void)dismissDiningTableMainView
{
    [self.view removeFromSuperview];
}

#pragma mark - add View

- (void)addGuideView
{
    self.guideImageView.hidden = YES;
    
    NSUserDefaults *temp = [NSUserDefaults standardUserDefaults];
    [temp setObject:[NSNumber numberWithBool:YES] forKey:kISHavedShowAddGuideView];
    [temp synchronize];
    
    if (!guideView)
    {
        guideView = [[DiningTableGuideView alloc] initWithFrame:CGRectZero];
    }
    guideView.delegate = self;
    [guideView showInView:self.view.superview withOriginPoint:CGPointZero withAnimated:YES];
}

- (void)addAreaView
{
    self.view.hidden = YES;
    if (!areaListView)
    {
        areaListView = [[DiningTableAreaListView alloc] initWithFrame:CGRectZero];
    }
    areaListView.delegate = self;
    areaListView.diningTableListArray = [[NSMutableArray alloc] initWithArray:diningTableDataClass.diningTableDataArray];
    [areaListView showInView:self.view.superview withOriginPoint:kPointForShowView withAnimated:YES];
    [areaListView updateAreaListView];
}

- (void)addAreaToScrollowView
{
    NSArray *btnArray = self.areaScrollView.subviews;
    int btnCount = [btnArray count];
    for (int i = 0; i < btnCount; i++)
    {
        id tempClass = [btnArray objectAtIndex:i];
        if ([tempClass isKindOfClass:NSClassFromString(@"UIButton")] || [tempClass isKindOfClass:NSClassFromString(@"UIImageView")])
        {
            UIView *tempView = (UIView *)tempClass;
            [tempView removeFromSuperview];
        }
    }
    
    if (currentTableId_ != nil) {
        selectedAreaIndex = -1;
    }
    
    UIImage *btnBgImg = [UIImage imageFromMainBundleFile:@"dt_srollowBg.png"];
    UIFont *titleFont = [UIFont systemFontOfSize:20];
    int totalPages = kDiningTableAreaCount;
    float btnWidth = 0.0;
    float btnHeight = self.areaScrollView.frame.size.height;
    float contentSizeWidth = 0.0;
    float btnSpace = 10;
    CGSize titleSize = CGSizeZero;
    
    if (selectedAreaIndex >= kAreaBtnTag + totalPages) {
        selectedAreaIndex = MAX(kAreaBtnTag + totalPages - 1, kAreaBtnTag);
    }
    
    for (int i = 0; i < totalPages; i++)
    {
        AreaDataClass *tempClass = [self getAreaData:i];
        
        titleSize = [tempClass.typeName sizeWithFont:titleFont];
        btnWidth = titleSize.width;
        if (btnWidth < btnBgImg.size.width)
        {
            btnWidth = btnBgImg.size.width;
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i + kAreaBtnTag;
        btn.frame = CGRectMake(contentSizeWidth, 0, btnWidth, btnHeight);
        
        if (currentTableId_ != nil) {
            for (NSDictionary *tempHousingDict in tempClass.housingDataArray) {
                int tempHousingId = [[tempHousingDict objectForKey:kHousingId] intValue];
                NSString *tempHousingIdStr = [NSString stringWithFormat:@"%d", tempHousingId];
                if ([tempHousingIdStr isEqualToString:currentTableId_]) {
                    btn.selected = YES;
                    selectedAreaIndex = (int)btn.tag;
                    if (CGRectGetMaxX(btn.frame) > self.areaScrollView.bounds.size.width) {
                        CGFloat xPos = CGRectGetMinX(btn.frame) - self.areaScrollView.bounds.size.width;
                        xPos += btn.frame.size.width;
                        self.areaScrollView.contentOffset = CGPointMake(xPos, 0.0);
                    }
                    
                    break;
                }
            }
        } else {
            if (selectedAreaIndex == (int)btn.tag) {
                btn.selected = YES;
            }
        }
        
        [btn setTitle:tempClass.typeName forState:UIControlStateNormal];
        btn.titleLabel.font = titleFont;
        float colorValue = 14.0/255.0;
        [btn setTitleColor:[UIColor colorWithRed:colorValue green:colorValue blue:colorValue alpha:1.0] forState:UIControlStateNormal];
        [btn setBackgroundImage:nil forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:103.0/255.0 green:149.0/255.0 blue:23.0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [btn setBackgroundImage:btnBgImg forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(areaBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.areaScrollView addSubview:btn];
        contentSizeWidth = contentSizeWidth + btnWidth + btnSpace;
        
        // 分割竖线
        if(totalPages != i)
        {
            UIImage *lineImage = [UIImage imageFromMainBundleFile:@"dt_areaLine.png"];
            UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(contentSizeWidth - 2 * btnSpace/3, btn.frame.origin.y, lineImage.size.width - 8, btnHeight - 3)];
            float bgcolorValue = 200.0/255.0;
            lineImageView.backgroundColor = [UIColor colorWithRed:bgcolorValue green:bgcolorValue blue:bgcolorValue alpha:1.0];
            [self.areaScrollView addSubview:lineImageView];
        }
    }
    self.areaScrollView.contentSize = CGSizeMake(contentSizeWidth, btnHeight);
    if (selectedAreaIndex == -1) {
        selectedAreaIndex = kAreaBtnTag;
        UIButton *currentSelectedBtn = (UIButton *)[self.areaScrollView viewWithTag:selectedAreaIndex];
        currentSelectedBtn.selected = YES;
        
        [self updateTopTitle];
    }
    
#ifdef DEBUG
    NSLog(@"===cuisineSrollView,subView:%d===",[self.areaScrollView.subviews count]);
#endif
}

- (void)addHousingToScrollowView
{
    NSArray *btnCellArray = self.housingScrollView.subviews;
    int btnCellCount = [btnCellArray count];
    for (int i = 0; i < btnCellCount; i++)
    {
        id tempClass = [btnCellArray objectAtIndex:i];
        if ([tempClass isKindOfClass:NSClassFromString(kHousingBtnClassName)])
        {
            HousingButtonCell *tempBtnCell = (HousingButtonCell *)tempClass;
            [tempBtnCell dismissViewWithAnimated:NO];
        }
    }
    
    int index = selectedAreaIndex - kAreaBtnTag;
    AreaDataClass *tempClass = [self getAreaData:index];
    NSMutableArray *tempArray = tempClass.housingDataArray;
    int housingCount = [tempArray count];
    if (0 < housingCount)
    {
        int pageIndex = 0;
        for (int k = 0; k < housingCount; k++)
        {
            pageIndex = k/kHousingMaxCountPerPage;
            int originX = k%kHousingCountPerRow;
            int originY = k/kHousingCountPerColumn%kHousingCountPerRow;
            
            NSDictionary *housingDict = [tempArray objectAtIndex:k];
            HousingButtonCell *housingBtn = [[HousingButtonCell alloc] initWithHousingData:housingDict];
            housingBtn.tag = k;
            housingBtn.delegate = self;
            CGPoint btnPoint = CGPointMake(pageIndex * kHousingScrollViewWidth + originX * kHousingBtnCellSpaceX + 30, originY * kHousingBtnCellSpaceY);
            
            [housingBtn showInView:self.housingScrollView withOriginPoint:btnPoint withAnimated:NO];
        }
        //总页数
        int totalPages = 0;
        totalPages = housingCount/kHousingMaxCountPerPage;
        if (housingCount%kHousingMaxCountPerPage>0)
        {
            totalPages++;
        }
        self.housingScrollView.contentSize = CGSizeMake(kHousingScrollViewWidth * totalPages, kHousingScrollViewHeight);
        //点
        self.housingPageControl.hidden = NO;
        self.housingPageControl.numberOfPages = totalPages;
        self.housingPageControl.hidesForSinglePage = YES;
        if (kSystemVersionLaterIOS5 && 1 < totalPages)
        {
            self.housingPageControl.pageIndicatorTintColor = kHousingPageControltintColor;
            self.housingPageControl.currentPageIndicatorTintColor = kHousingPageControlCurrentPageIndicatorTintColor;
        }
        /*是否显示暂无数据*/
        self.noDataLabel.hidden = YES;
    }
    else
    {
        self.housingPageControl.hidden = YES;
        self.noDataLabel.hidden = NO;
    }
}

- (void)addUIActionSheet:(NSArray *)subAuthArray withTag:(int)tag withShowFromRect:(CGRect)rect
{
    int btnCount = [subAuthArray count];
    if (0 < btnCount)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        actionSheet.tag = tag;
        NSInteger cancelButtonIndex = -1;
        for (int k = 0; k < btnCount; k++) {
            StaffManagementSubAuthDataClass *subAuth = [subAuthArray objectAtIndex:k];
            if ([subAuth isKindOfClass:[NSString class]]) {
                cancelButtonIndex = k;
                [actionSheet addButtonWithTitle:(NSString *)subAuth];
            } else {
                [actionSheet addButtonWithTitle:subAuth.name];
            }
        }
        
        if (cancelButtonIndex != -1) {
            actionSheet.cancelButtonIndex = cancelButtonIndex;
        }
        
        if (CGRectEqualToRect(rect, CGRectZero) || kIsiPhone)
        {
            [actionSheet showInView:self.view.window];
        }
        else
        {
            [actionSheet showFromRect:rect inView:self.view animated:YES];
        }
    }
}

#pragma mark - UIButton Clicked

- (IBAction)refrashBtnClicked:(UIButton*)sender
{
    [self getDiningTableData:YES];
}

- (IBAction)moreBtnClicked:(UIButton*)sender
{
    [self addUIActionSheet:actionSheetSubAuthArray withTag:kMoreUIActionSheetTag withShowFromRect:sender.frame];
}

- (IBAction)cancelBtnClicked:(UIButton*)sender
{
    [housingInfoArray removeAllObjects];
    [self whetherShowMoreBtn:YES];
    [self updateHousingCellUI:kHousingUnKnownSwitchState withStatusSettingData:nil];
}

- (IBAction)trueBtnClicked:(UIButton*)sender
{
    [self updateHousingStatus:YES];
}

- (void)areaBtnClicked:(UIButton *)sender
{
    int index = sender.tag;
    if (index != selectedAreaIndex)
    {
        UIButton *oldSelectedBtn = (UIButton*)[self.areaScrollView viewWithTag:selectedAreaIndex];
        UIButton *newSelectedBtn = (UIButton*)[self.areaScrollView viewWithTag:index];
        oldSelectedBtn.selected = NO;
        newSelectedBtn.selected = YES;
        selectedAreaIndex = index;
        [self whetherShowMoreBtn:YES];
        [self addHousingToScrollowView];
        [self updateTopTitle];
    }
}

#pragma mark - network

- (void)updatedDinnerTableData:(NSNotification *)notification
{
    if (notification.object != nil) {
        // 房台编号
        int tableId = [notification.object intValue];
        currentTableId_ = [NSString stringWithFormat:@"%d", tableId];
        
        int totalPages = (int)kDiningTableAreaCount;
        int willSelectedItemIndex = -1;
        for (int i = 0; i < totalPages; i++) {
            AreaDataClass *tempClass = [self getAreaData:i];
            for (int j = 0; j < tempClass.housingDataArray.count; j++) {
                NSDictionary *housingDict = [tempClass.housingDataArray objectAtIndex:j];
                HousingDataClass *housingData = [[HousingDataClass alloc] initWithHousingData:housingDict];
                if (housingData.housingId == tableId) {
                    willSelectedItemIndex = i;
                    break;
                }
            }
            
            if (willSelectedItemIndex != -1) {
                break;
            }
            
        }
        
        int tag = willSelectedItemIndex + kAreaBtnTag;
        UIButton *areaButton = (UIButton *)[self.areaScrollView viewWithTag:tag];
        if (areaButton != nil) {
            [self areaBtnClicked:areaButton];
        }
    }
    [self getDiningTableData:NO];
}

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

- (void)getDiningTableData:(BOOL)animated
{
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
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
    [jsonPicker postData:postData withBaseRequest:kGetDiningTableDataNetworkPath];
}

- (void)updateHousingStatus:(BOOL)animated
{
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    [postData setObject:housingInfoArray forKey:kUpdateHousingStatusNetworkTableInfoParameter];
    [postData setObject:operationTypeStr forKey:kUpdateHousingStatusNetworkOperationTypeParameter];
    
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
    [jsonPicker postData:postData withBaseRequest:kUpdateHousingStatusNetworkPath];
}

#pragma mark - DiningTableGuideViewDelegate

- (void)guideViewHavedDismiss:(DiningTableGuideView *)viewClass
{
    guideView = nil;
    self.guideImageView.hidden = NO;
}

#pragma mark - DiningTableAreaViewDelegate

- (void)dismissAreaViewWithNewData:(NSMutableArray *)dtArray
{
    if (dtArray ) {
        diningTableDataClass.diningTableDataArray = dtArray;
        
        // 更新未读数量
        int unreadCount = 0;
        for (NSDictionary *areaDic in dtArray) {
            NSArray *tableList = [areaDic objectForKey:@"table"];
            for (NSDictionary *tableDic in tableList) {
                int unconfirmed = [[tableDic objectForKey:@"unconfirmed"] intValue];
                unreadCount += unconfirmed;
            }
        }
        duc = unreadCount;
        
        [self updateBadge];
        [self addAreaToScrollowView];
        [self addHousingToScrollowView];
        [self whetherShowPicture];
    }
    [self updateTopTitle];
    
    self.view.hidden = NO;
}

#pragma mark - HousingButtonCellDelegate

- (void)housingBtnCellSelected:(HousingButtonCell *)cell withHousingData:(HousingDataClass *)dataClass withStatusSetting:(BOOL)flag
{
    if (flag)
    {
        [self getHousingInfoWhenModifyHousingState:dataClass withAddFlag:cell.bigButton.selected];
    }
    else
    {
        if (kHousingHavedStop != dataClass.housingStatus)
        {
            self.view.hidden = YES;
            int index = selectedAreaIndex - kAreaBtnTag;
            AreaDataClass *tempClass = [self getAreaData:index];
            NSString *currentAreaStr = [NSString getStrWithoutWhitespace:tempClass.typeName];
            MainViewController *mainVC = [MainViewController getMianViewShareInstance];
            if (!dtMenuMainVC)
            {
                dtMenuMainVC = [[DtMenuMainViewController alloc] initWithNibName:@"DtMenuMainViewController" bundle:nil];
            }
            dtMenuMainVC.delegate = self;
            dtMenuMainVC.housingDataClass = dataClass;
            dtMenuMainVC.areaName = currentAreaStr;
            dtMenuMainVC.tag = cell.tag;
            dtMenuMainVC.housingStateType = dataClass.housingStatus;
            dtMenuMainVC.housingButtonCell = cell;
            [dtMenuMainVC showInView:mainVC withOriginPoint:kViewControllerOrigin withAnimated:YES];
        }
    }
}

- (void)getHousingInfoWhenModifyHousingState:(HousingDataClass *)dataClass withAddFlag:(BOOL)flag
{
    [dataClass modifyHousingState:housingInfoArray withAddFlag:flag];
}

#pragma mark - DtMenuMainViewControllerDelegate

- (void)dtMenuMainViewHavedDismiss:(HousingButtonCell *)cell withHousingData:(HousingDataClass *)dataClass flag:(BOOL)flag
{
    [self updateTopTitle];
    [dtMenuMainVC dismissViewControllerWithAnimated:NO];
    self.view.hidden = NO;
    
    int areaIndex = selectedAreaIndex - kAreaBtnTag;
    int housingIndex = dtMenuMainVC.tag;
    NSMutableArray *diningTableArray = diningTableDataClass.diningTableDataArray;
    NSMutableDictionary *areaDict = [[NSMutableDictionary alloc] initWithDictionary:[diningTableArray objectAtIndex:areaIndex]];
    NSMutableArray *housingArray = [[NSMutableArray alloc] initWithArray:[areaDict objectForKey:kAreaDataClassTableKey]];
    NSMutableDictionary *housingDict = [[NSMutableDictionary alloc] initWithDictionary:[housingArray objectAtIndex:housingIndex]];
    [housingDict setObject:[NSNumber numberWithInt:dtMenuMainVC.housingStateType] forKey:kHousingStatus];
    [housingArray replaceObjectAtIndex:housingIndex withObject:housingDict];
    [areaDict setObject:housingArray forKey:kAreaDataClassTableKey];
    [diningTableArray replaceObjectAtIndex:areaIndex withObject:areaDict];
    
    [self addHousingToScrollowView];
    
    if (flag) {
        // 响应返回是否要清台“确定”按键
        operationTypeStr = kDtSubAuthClearingIndexStr;
        [self updateHousingBtnCellWhenSwitchState:kHousingClearSwitchState];
        HousingDataClass *temp = [[HousingDataClass alloc] initWithHousingData:housingDict];
        [self getHousingInfoWhenModifyHousingState:temp withAddFlag:cell.bigButton.selected];
        [self performSelector:@selector(trueBtnClicked:) withObject:nil afterDelay:0.2];
    }
    
    dtMenuMainVC = nil;
}

#pragma mark - UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    int offsetx = offset.x;
    int PageControlWidth = self.housingPageControl.frame.size.width;
    if (offsetx % PageControlWidth==0)
    {
        CGPoint offset = scrollView.contentOffset;
        self.housingPageControl.currentPage = offset.x / PageControlWidth;
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (kMoreUIActionSheetTag == actionSheet.tag)
    {
        if (kZeroNumber <= buttonIndex && buttonIndex < [actionSheetSubAuthArray count] - 1)
        {
            StaffManagementSubAuthDataClass *subAuth = [actionSheetSubAuthArray objectAtIndex:buttonIndex];
            if ([subAuth.indexStr isEqualToString:kDtSubAuthBookingIndexStr])
            {
                operationTypeStr = kDtSubAuthBookingIndexStr;
                [self updateHousingBtnCellWhenSwitchState:kHousingOrderSwitchState];
            }
            else if([subAuth.indexStr isEqualToString:kDtSubAuthDisablingIndexStr])
            {
                operationTypeStr = kDtSubAuthDisablingIndexStr;
                [self updateHousingBtnCellWhenSwitchState:kHousingStopSwitchState];
            }
            else if([subAuth.indexStr isEqualToString:kDtSubAuthClearingIndexStr])
            {
                if (0 >= kDiningTableAreaCount)
                {
                    return;
                }
                
                UIAlertView *clearAlertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                clearAlertView.tag = kClearUIAlertViewTag;
                [clearAlertView addButtonWithTitle:kLoc(@"clear_all")];
                [clearAlertView addButtonWithTitle:kLoc(@"clear_one_by_one")];
                [clearAlertView addButtonWithTitle:kLoc(@"cancel")];
                [clearAlertView show];
            }
            else if([subAuth.indexStr isEqualToString:kDtSubAuthSettingIndexStr])
            {
                [self addAreaView];
            }
        }
    }
}

- (void)updateHousingBtnCellWhenSwitchState:(kHousingSwitchStateType)type
{
    [housingInfoArray removeAllObjects];
    int index = selectedAreaIndex - kAreaBtnTag;
    AreaDataClass *tempClass = [self getAreaData:index];
    if (0 >= [tempClass.housingDataArray count])
    {
        return;
    }
    [self whetherShowMoreBtn:NO];
    [self updateHousingCellUI:type withStatusSettingData:diningTableDataClass.statusSettingDict];
}

- (void)updateHousingCellUI:(kHousingSwitchStateType)type withStatusSettingData:(NSDictionary *)dict
{
    NSArray *btnCellArray = self.housingScrollView.subviews;
    int btnCellCount = [btnCellArray count];
    for (int i = 0; i < btnCellCount; i++)
    {
        id tempClass = [btnCellArray objectAtIndex:i];
        if ([tempClass isKindOfClass:NSClassFromString(kHousingBtnClassName)])
        {
            HousingButtonCell *tempBtnCell = (HousingButtonCell *)tempClass;
            [tempBtnCell updateHousingBtnCellUI:type withStatusSettingDict:dict];
        }
    }
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (kClearUIAlertViewTag == alertView.tag)
    {
        switch (buttonIndex)
        {
            case kButtonFirstIndex:
            {
                operationTypeStr = kDtSubAuthClearingIndexStr;
                [self clearAllHousingToUnOpenState];
                break;
            }
            case kButtonSecondIndex:
            {
                operationTypeStr = kDtSubAuthClearingIndexStr;
                [self updateHousingBtnCellWhenSwitchState:kHousingClearSwitchState];
                break;
            }
            case kButtonThirdIndex:
            {
                
                break;
            }
            default:
                break;
        }
    }
}

//清空所有房台,变成未开台状态
- (void)clearAllHousingToUnOpenState
{
    [housingInfoArray removeAllObjects];
    int areaCount = kDiningTableAreaCount;
    for (int j = 0; j < areaCount; j++)
    {
        AreaDataClass *tempClass = [self getAreaData:j];
        NSMutableArray *tempArray = tempClass.housingDataArray;
        int housingCount = [tempArray count];
        if (0 < housingCount)
        {
            for (int k = 0; k < housingCount; k++)
            {
                NSDictionary *housingDict = [tempArray objectAtIndex:k];
                HousingDataClass *tempClass = [[HousingDataClass alloc] initWithHousingData:housingDict];
                if (kHousingNotOpen != tempClass.housingStatus)
                {
                    [self getHousingInfoWhenModifyHousingState:tempClass withAddFlag:YES];
                }
            }
        }
    }
    [self updateHousingStatus:YES];
}

#pragma mark - JsonPickerDelegate

- (void)handleFirstJsonPicker:(NSDictionary *)dict
{
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    
    switch (dataClass.responseStatus) {
            
        case kSecondResponseStatus: {
            // 201没有获取到数据，根据可能显示引导页，并且进入case kFirstResponseStatus。
            BOOL isHavedShow = [[[NSUserDefaults standardUserDefaults] objectForKey:kISHavedShowAddGuideView] boolValue];
            if (!isHavedShow) {
                [self addGuideView];
            }
        }
        case kFirstResponseStatus: {
            diningTableDataClass = [[DiningTableDataClass alloc] initWithDiningTableData:dataClass.dataDict];
            [housingInfoArray removeAllObjects];
            [self addAreaToScrollowView];
            [self addHousingToScrollowView];
            [self whetherShowPicture];
            [self whetherShowMoreBtn:YES];
            NSString *alertMsgStr = [NSString getStrWithoutWhitespace:dataClass.alertMsg];
            
            if (![NSString strIsEmpty:alertMsgStr]) {
                [PSAlertView showWithMessage:dataClass.alertMsg];
            }
            
            NSDictionary *unreadCountDic = [dataClass.dataDict objectForKey:@"data"];
            if (unreadCountDic != nil) {
                duc = [[unreadCountDic objectForKey:@"duc"] intValue];
                puc = [[unreadCountDic objectForKey:@"puc"] intValue];
                tuc = [[unreadCountDic objectForKey:@"tuc"] intValue];
                muc = [[unreadCountDic objectForKey:@"muc"] intValue];
                ruc = [[unreadCountDic objectForKey:@"ruc"] intValue];
                
                [self updateBadge];
            }
            break;
        }
        default: {
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
            [self handleFirstJsonPicker:dict];
            break;
        }
        default:
        {
            break;
        }
    }
}

// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error{

}

// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error{
    
}

@end
