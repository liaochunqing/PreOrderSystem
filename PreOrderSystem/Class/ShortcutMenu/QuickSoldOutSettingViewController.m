//
//  QuickSoldOutSettingViewController.m
//  PreOrderSystem
//
//  Created by mac on 14-7-19.
//
//

#import "QuickSoldOutSettingViewController.h"
#import "Constants.h"
#import "CuisineDataModel.h"
#import "PSAlertView.h"
#import "SelectionCell.h"

#define kOriginalTableView 198601
#define kDiscoutTableView 198602
#define kOriginalTableViewCellReuseIdentifier @"OriginalTableViewCellReuseIdentifier"
#define kDiscoutTableViewCellReuseIdentifier @"kDiscoutTableViewCellReuseIdentifier"

@interface QuickSoldOutSettingViewController ()

@end

@implementation QuickSoldOutSettingViewController\
{
    JsonPicker *jsonPicker;
    
    //菜系下拉列表是否处于打开状态
    BOOL isComboBoxOpen_;
    
    //标记选中了哪一个菜系
    NSInteger selectedCuisineIndex_;
    
    
    //放进快捷沽清列表内的菜品数据quickSoldOut
    NSMutableArray *quickSoldOutDataArr_;
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
    [self addLocalizedString];
    self.originalMenuTableView.tag = kOriginalTableView;
    self.soldOutTableView.tag = kDiscoutTableView;
    self.soldOutTableView.delegate = self;
    self.soldOutTableView.dataSource = self;
    [self.soldOutTableView setEditing:YES animated:YES];
    
    self.originalMenuTableView.delegate = self;
    self.originalMenuTableView.dataSource = self;
    
    _cuisineDataArr = [[NSMutableArray alloc]init];
    quickSoldOutDataArr_ = [[NSMutableArray alloc]init];
    
    //获取菜系菜品数据
    [self performSelector:@selector(getCuisineData) withObject:nil afterDelay:0.8];
    [self addNotifications];
    UITapGestureRecognizer *tapFreeSpace = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapFreeSpace:)];
    self.backgroundImageView.userInteractionEnabled = YES;
    [self.backgroundImageView addGestureRecognizer:tapFreeSpace];
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

- (void)addLocalizedString
{
    
}

/**
 *  设置菜系下拉菜单
 */
- (void)setComboBox
{
    isComboBoxOpen_ = NO;
    NSInteger diskCount = (NSInteger)_cuisineDataArr.count;
    [self.showCuisineTableView initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
        return diskCount;
        
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        if (!cell) {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        CuisineDataModel *cuisineData = [_cuisineDataArr objectAtIndex:indexPath.row];
        [cell.lb setText:cuisineData.cuisineName];
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
        _cuisineNameTextField.text=cell.lb.text;
        [_showCuisineListBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        selectedCuisineIndex_ = indexPath.row;
        [_originalMenuTableView reloadData];
        
    }];
    
    [_showCuisineTableView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_showCuisineTableView.layer setBorderWidth:2];
}

#pragma mark Private Methods
/**
 *  滚动tableView到底部
 *
 *  @param animated 是否显示滚动动画
 */
- (void)scrollTableToFoot:(BOOL)animated
{
    NSInteger s = [self.soldOutTableView numberOfSections];
    if (s<1) return;
    NSInteger r = [self.soldOutTableView numberOfRowsInSection:s-1];
    if (r<1) return;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
    [self.soldOutTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

/**
 *  从右边tableView删除或添加菜品
 *
 *  @param indexPath --
 */
- (void)addOrDeleteDishAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isAdd;
    CuisineDataModel *cuiData = (CuisineDataModel *)[_cuisineDataArr objectAtIndex:selectedCuisineIndex_];
    CookbookDataClass *cookbookData = (CookbookDataClass *) [cuiData.cookbookDataArr objectAtIndex:indexPath.row];
    cookbookData.cuisineIndex = selectedCuisineIndex_;
    if (!cookbookData.isSelected)
    {
        isAdd = YES;
        [quickSoldOutDataArr_ addObject:cookbookData];
        for (int i = 0;i < cuiData.cookbookDataArr.count;i++)
        {
            CookbookDataClass *cookData = [cuiData.cookbookDataArr objectAtIndex:i];
            cookbookData.isSelected = YES;
            if (!cookData.isSelected)
            {
                cuiData.isSelectedAllCookbook = NO;
                break;
            }
            if ((i == cuiData.cookbookDataArr.count - 1) && cookData.isSelected)
            {
                cuiData.isSelectedAllCookbook = YES;
            }
        }
    }
    else
    {
        isAdd = NO;
        cuiData.isSelectedAllCookbook = NO;
        cookbookData.isSelected = NO;
        [quickSoldOutDataArr_ removeObject:cookbookData];
    }
    
    [_originalMenuTableView reloadData];
    [_soldOutTableView reloadData];
    if (isAdd)
    {
        [self scrollTableToFoot:YES];
    }
}

/**
 *  解析hotkey/getSoldOutList接口数据
 *
 *  @param soldOutListDic 服务器返回的原始数据
 *
 */
- (void)analyzingQuickSoldOutList:(NSDictionary *)dict
{
    [_cuisineDataArr removeAllObjects];
    [quickSoldOutDataArr_ removeAllObjects];
    
    NSArray *quickSoldOutArr = [[dict objectForKey:@"data"]objectForKey:@"list"];
    NSMutableArray *temSoldOutCookIDArr = [[NSMutableArray alloc]init];
    for (NSDictionary *temDic in quickSoldOutArr)
    {
        [temSoldOutCookIDArr addObject:[temDic objectForKey:@"cookbookID"]];
        
        //占位,以便待会按服务器返回的数据顺序排放元素:
        [quickSoldOutDataArr_ addObject:@""];
    }
    //解析出所有菜品以及放入快捷沽清列表的菜品,并设置菜品的勾选状态.
    NSArray *allDishArr = [[[dict objectForKey:@"data"] objectForKey:@"cookbook"]objectForKey:@"list"];
    for (NSDictionary *dic in allDishArr)
    {
        CuisineDataModel *cuisineDataModel = [[CuisineDataModel alloc]initAllDetailWithData:dic];
        [self.cuisineDataArr addObject:cuisineDataModel];
        int selectedNum = 0;
        for (int i = 0; i < cuisineDataModel.cookbookDataArr.count; i++)
        {
            CookbookDataClass *cook = [cuisineDataModel.cookbookDataArr objectAtIndex:i];
            for (int j = 0; j < temSoldOutCookIDArr.count; j++)
            {
                NSUInteger soldID = [[temSoldOutCookIDArr objectAtIndex:j]integerValue];
                if (soldID == cook.cookbookID)//该菜品已被放入快捷沽清列表中
                {
                    cook.isSelected = YES;
                    [quickSoldOutDataArr_ replaceObjectAtIndex:j withObject:cook];
                   // [temSoldOutCookIDArr removeObjectAtIndex:j];
                    selectedNum++;
                    break;
                }
            }
            if (selectedNum == cuisineDataModel.cookbookDataArr.count)
            {
                //该菜系已被全选
                cuisineDataModel.isSelectedAllCookbook = YES;
            }
        }
    }
    
}

#pragma mark Notifications

- (void)addNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardWillShow:(NSNotification*)notify
{
    NSDictionary *userInfo = [notify userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    keyboardRect = [self.view convertRect:keyboardRect fromView:window];
    CGRect intersectionOfKeyboardRectAndWindowRect = CGRectIntersection(window.frame, keyboardRect);
    CGFloat bottomInset = intersectionOfKeyboardRectAndWindowRect.size.height;
    self.soldOutTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset - 100,0.0f);
    self.soldOutTableView.scrollEnabled = NO;
    
    [UIView commitAnimations];
    
#ifdef DEBUG
    NSLog(@"===%@,keyboardWillShow:%@,bottomInset:%f",self.class,NSStringFromCGRect(keyboardRect),bottomInset);
#endif
}

- (void)keyboardWillHide:(NSNotification*)notify
{
    NSDictionary *userInfo = [notify userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    self.soldOutTableView.scrollEnabled = YES;
    self.soldOutTableView.contentInset = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}

#pragma mark - UIButton Clicked
/**
 *  点击空白处收起键盘和菜系下拉列表
 *
 *  @param tap 手势
 */
- (void)didTapFreeSpace:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
    if (isComboBoxOpen_)
    {
        [self showCuisineList:nil];
    }
    
}

- (IBAction)cancelBtnPress:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissEditDiscountViewController:)])
    {
        [self.delegate dismissEditDiscountViewController:self];
    }
}

- (IBAction)sureBtnPress:(id)sender
{
    NSMutableArray *cookSwitchArr = [[NSMutableArray alloc]init];
    for (CookbookDataClass *cook in quickSoldOutDataArr_)
    {
        NSDictionary *switchDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithBool:cook.isSoldOut],@"isSoldOut",
                                   [NSString stringWithFormat:@"%lu",(unsigned long)cook.cookbookID],@"cookbookID", nil];
        [cookSwitchArr addObject:switchDic];
    }
    NSDictionary *submitDic = [NSDictionary dictionaryWithObjectsAndKeys:cookSwitchArr,@"list",
                               self.hotkeyKey,@"hotkey_key", nil];
    [self submitSoldOutStatus:submitDic];
}



/**
 *  从右边的优惠套餐TableView中删除某项.
 *
 *  @param sender cell中的删除按钮
 */
- (void)deleteCookbookQ:(UIButton *)sender
{
    QuickSoldOutSettingTableViewCell * cell = nil;
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        cell = (QuickSoldOutSettingTableViewCell *)sender.superview.superview;
    }
    else
    {
        cell = (QuickSoldOutSettingTableViewCell *)sender.superview.superview.superview;
    }
    
    NSIndexPath * path = [self.soldOutTableView indexPathForCell:cell];
    if (quickSoldOutDataArr_.count > path.row)
    {
        CookbookDataClass *cookbookData = (CookbookDataClass *) [quickSoldOutDataArr_ objectAtIndex:path.row];
        cookbookData.isSelected = NO;
        [self deleteCookbookFromRightView:cookbookData];
        [quickSoldOutDataArr_ removeObjectAtIndex:path.row];
        [self.originalMenuTableView reloadData];
        [self.soldOutTableView reloadData];
    }
}

- (void)deleteCookbookFromRightView:(CookbookDataClass *)cookBookData
{
    for (CuisineDataModel *cuisineData in self.cuisineDataArr)
    {
        if ([cuisineData.cuisineName isEqualToString:cookBookData.cuisineName])
        {
            cuisineData.isSelectedAllCookbook = NO;
            break;
        }
    }
}



/**
 *  显示菜系下拉列表
 *
 *  @param sender: showCuisineListBtn
 */
- (IBAction)showCuisineList:(id)sender
{
    [self.view endEditing:YES];
    if (isComboBoxOpen_)
    {
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
            [_showCuisineListBtn setImage:closeImage forState:UIControlStateNormal];
            
            CGRect frame= _showCuisineTableView.frame;
            
            frame.size.height = 0;
            [_showCuisineTableView setFrame:frame];
            
        } completion:^(BOOL finished){
            
            isComboBoxOpen_ = NO;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
            [_showCuisineListBtn setImage:openImage forState:UIControlStateNormal];
            
            CGRect frame = _showCuisineTableView.frame;
            
            frame.size.height=380;
            [_showCuisineTableView setFrame:frame];
        } completion:^(BOOL finished){
            
            isComboBoxOpen_ = YES;
        }];
    }
}

#pragma mark - Notifications


#pragma mark network

/**
 *  获取菜系菜品数据
 */
- (void)getCuisineData
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = NSLocalizedString(@"正在获取数据，请稍候...", nil);
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:self.hotkeyKey forKey:@"hotkey_key"];
    [postData setObject:[NSNumber numberWithBool:YES] forKey:@"returnCookbookList"];
    [jsonPicker postData:postData withBaseRequest:@"hotkey/getSoldOutList"];
}

- (void)submitSoldOutStatus:(NSDictionary *)submitDic
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 1;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = NSLocalizedString(@"正在提交数据，请稍候...", nil);
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:submitDic withBaseRequest:@"hotkey/saveSoldOutList"];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"])
    {
        return NO;
    }
    return  YES;
}

#pragma mark UITableView delegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == kOriginalTableView)
    {
        if (_cuisineDataArr.count > selectedCuisineIndex_)
        {
            CuisineDataModel *cuiData = (CuisineDataModel *)[_cuisineDataArr objectAtIndex:selectedCuisineIndex_];
            NSInteger count = cuiData.cookbookDataArr.count;
            return count;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return quickSoldOutDataArr_.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == kOriginalTableView)
    {
        return 40;
    }
    else
    {
        return 0.0;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *OrigCellIdentifier = kOriginalTableViewCellReuseIdentifier;
    static NSString *DiscounCellIdentifier = kDiscoutTableViewCellReuseIdentifier;
    if (kOriginalTableView == tableView.tag)
    {
        OriginalMenuTableViewCell *cell = (OriginalMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:OrigCellIdentifier];
        if (!cell)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"OriginalMenuTableViewCell" owner:self options:nil]lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }
        CuisineDataModel *cuiData = (CuisineDataModel *)[_cuisineDataArr objectAtIndex:selectedCuisineIndex_];
        CookbookDataClass *cookbookData = (CookbookDataClass *) [cuiData.cookbookDataArr objectAtIndex:indexPath.row];
        cell.titleLabel.text = cookbookData.cookbookName;
        [cell isSelected:cookbookData.isSelected];
        
        return cell;
        
    }
    else
    {
        QuickSoldOutSettingTableViewCell *cell = (QuickSoldOutSettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:DiscounCellIdentifier];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"QuickSoldOutSettingTableViewCell" owner:self options:nil]lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            [cell.deleteBtn addTarget:self action:@selector(deleteCookbookQ:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (quickSoldOutDataArr_.count > indexPath.row)
        {
            CookbookDataClass *cookbookData = (CookbookDataClass *) [quickSoldOutDataArr_ objectAtIndex:indexPath.row];
            cell.cuisineNameLabel.text = cookbookData.cuisineName;
            cell.cookbookNameLabel.text = cookbookData.cookbookName;
            cell.soldOutSwitch.on = cookbookData.isSoldOut;
        }
        return cell;
    }
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.tag == kOriginalTableView)//左边tableView
    {
        [self addOrDeleteDishAtIndexPath:indexPath];
    }
    else//点击右边Cell左边跳转到相应菜系.
    {
        NSString *cuiStr = self.cuisineNameTextField.text;
        if (self.cuisineDataArr.count > indexPath.row)
        {
            CookbookDataClass *cook = [quickSoldOutDataArr_ objectAtIndex:indexPath.row];
            if (![cook.cuisineName isEqualToString:cuiStr])
            {
                for (int i = 0; i < self.cuisineDataArr.count; i++)
                {
                    CuisineDataModel *cuiData = [self.cuisineDataArr objectAtIndex:i];
                    if ([cuiData.cuisineName isEqualToString:cook.cuisineName])
                    {
                        selectedCuisineIndex_ = i;
                        self.cuisineNameTextField.text = cuiData.cuisineName;
                        [self.originalMenuTableView reloadData];
                        break;
                    }
                }
            }
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == kOriginalTableView)
    {
        if ([tableView numberOfRowsInSection:0])
        {
            return [self creatHeadViewToTableView:tableView];
        }
        else
        {
            return nil;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{

    
    if (quickSoldOutDataArr_.count >sourceIndexPath.row && quickSoldOutDataArr_.count > destinationIndexPath.row)
    {
        [quickSoldOutDataArr_ exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        [self.soldOutTableView reloadData];
    }
}

/**
 *  为OriginalTableView创建section头,用于全选/全不选
 *
 *  @param tableView
 *
 *  @return section head 视图.
 */
- (UIView *)creatHeadViewToTableView:(UITableView *)tableView
{
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    headView.backgroundColor = [UIColor whiteColor];
    UILabel *selectAllLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 191, 38)];
    selectAllLable.textAlignment = UITextAlignmentCenter;
    selectAllLable.textColor = [UIColor redColor];
    selectAllLable.font = [UIFont systemFontOfSize:18];
    selectAllLable.text = NSLocalizedString(@"全选该菜系:", nil);
    UIImageView *unselectedImv = [[UIImageView alloc]initWithFrame:CGRectMake(205,0, 40, 40)];
    UIImageView *didSelectedImv = [[UIImageView alloc]initWithFrame:unselectedImv.frame];
    
    unselectedImv.image = [UIImage imageNamed:@"dishesPicker_packageNormal"];
    didSelectedImv.image = [UIImage imageNamed:@"dishesPicker_packageSelected.png"];
    
    CuisineDataModel *cuiData = (CuisineDataModel *)[_cuisineDataArr objectAtIndex:selectedCuisineIndex_];
    if (cuiData.isSelectedAllCookbook)
    {
        didSelectedImv.hidden = NO;
    }
    else
    {
        didSelectedImv.hidden = YES;
    }
    [headView addSubview:selectAllLable];
    [headView addSubview:unselectedImv];
    [headView addSubview:didSelectedImv];
    UITapGestureRecognizer *selectTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectAllDish:)];
    [headView addGestureRecognizer:selectTap];
    
    return headView;
}

/**
 *  全选/取消全选某菜系的所有菜品
 *
 *  @param tap 手势
 */
- (void)selectAllDish:(UITapGestureRecognizer *)tap
{
    CuisineDataModel *cuiData = (CuisineDataModel *)[_cuisineDataArr objectAtIndex:selectedCuisineIndex_];
    if (cuiData.isSelectedAllCookbook)//取消全选
    {
        cuiData.isSelectedAllCookbook = NO;
        for (CookbookDataClass *cookBookData in cuiData.cookbookDataArr)
        {
            cookBookData.isSelected = NO;
        }
        [quickSoldOutDataArr_ removeObjectsInArray:cuiData.cookbookDataArr];
    }
    else//全选
    {
        cuiData.isSelectedAllCookbook = YES;
        for (CookbookDataClass *cookBookData in cuiData.cookbookDataArr)
        {
            if (!cookBookData.isSelected)
            {
                cookBookData.isSelected = YES;
                cookBookData.cuisineIndex = selectedCuisineIndex_;
                [quickSoldOutDataArr_ addObject:cookBookData];
            }
        }
    }
    [self.originalMenuTableView reloadData];
    [self.soldOutTableView reloadData];
}
#pragma mark - originalMenueTableViewCellDelegate
//选中/取消选中某菜
- (void)tableViewCell:(OriginalMenuTableViewCell *)cell didPressBtn:(UIButton *)btn
{
    NSIndexPath *indexPath = [self.originalMenuTableView indexPathForCell:cell];
    [self addOrDeleteDishAtIndexPath:indexPath];
}

#pragma mark - QuickSoldOutSettingTableViewCellProtocol
//switch开关被点击.
- (void)QuickSoldOutSettingTableViewCell:(QuickSoldOutSettingTableViewCell *)cell soldOutSwitchChanged:(UISwitch *)soldOutSwitch
{
    NSIndexPath *indexPath = [self.soldOutTableView indexPathForCell:cell];
    if (quickSoldOutDataArr_.count > indexPath.row)
    {
        CookbookDataClass *cookData = [quickSoldOutDataArr_ objectAtIndex:indexPath.row];
        cookData.isSoldOut = soldOutSwitch.on;
    }
}

#pragma mark JsonPickerDelegate
-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    int responseStatus = [[dict objectForKey:@"status"] intValue];
    
    if (picker.tag == 0)//获取菜品数据
    {
        switch (responseStatus)
        {
            case 200:
            {
                [self analyzingQuickSoldOutList:dict];
                //设置菜系下拉列表
                [self setComboBox];
                [self.soldOutTableView reloadData];
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                break;
            }
        }
    }
    else if (picker.tag == 1)//沽清
    {
        switch (responseStatus)
        {
            case 200:
            {
                [self cancelBtnPress:nil];//提交成功则退出.
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                break;
            }
        }

    }
    
    
}


// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error
{
    
}


// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error
{
    
}

@end
