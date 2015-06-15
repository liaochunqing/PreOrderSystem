//
//  EditDiscountViewController.m
//  PreOrderSystem
//
//  Created by mac on 14-6-30.
//  jhh_菜牌_优惠套餐设置
//

#import "EditDiscountViewController.h"
#import "Constants.h"
#import "CuisineDataModel.h"
#import "PSAlertView.h"
#import "SelectionCell.h"
#import "OfflineManager.h"
#import "NsstringAddOn.h"

#define kOriginalTableView 198601
#define kDiscoutTableView 198602
#define kDiscoutIDTextField 1990
#define KDiscoutNameTextField 1991
#define kOriginalTableViewCellReuseIdentifier @"OriginalTableViewCellReuseIdentifier"
#define kDiscoutTableViewCellReuseIdentifier @"kDiscoutTableViewCellReuseIdentifier"

@interface EditDiscountViewController ()
{
    JsonPicker *jsonPicker;
    
    //菜系下拉列表是否处于打开状态
    BOOL isComboBoxOpen_;
    
    //标记选中了哪一个菜系
    NSInteger selectedCuisineIndex_;
    
    //优惠组合中菜品数组的备份,当取消编辑时用以还原数据.
    NSMutableArray *backupGroupCookbookArr;
}

@end

@implementation EditDiscountViewController

- (id)initWithDiscountDataModel:(DiscountDataModel *)discountData
{
    self = [super initWithNibName:@"EditDiscountViewController" bundle:nil];
    if (self)
    {
        self.promoteCookbookGroupData = [[PromoteCookBookGroupDataModel alloc]init];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.cuisineDataArr = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedCuisineIndex_ = -1;
    [self prepareData];
    [self addLocalizedString];
    self.originalMenuTableView.tag = kOriginalTableView;
    self.discoutMenuTableView.tag = kDiscoutTableView;
    self.discoutIdentifierTextField.delegate = self;
    self.discoutIdentifierTextField.tag = kDiscoutIDTextField;
    self.discoutNameTextField.delegate = self;
    self.discoutNameTextField.tag = KDiscoutNameTextField;
    [self addNotifications];
    UITapGestureRecognizer *tapFreeSpace = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapFreeSpace:)];
    self.backgroundImageView.userInteractionEnabled = YES;
    [self.backgroundImageView addGestureRecognizer:tapFreeSpace];
    [self setComboBox];
    backupGroupCookbookArr = [[NSMutableArray alloc]initWithArray:self.promoteCookbookGroupData.groupCookbookArr];
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
    self.discoutIdentifierTextField.placeholder = kLoc(@"optional");
    self.discoutNameTextField.placeholder = kLoc(@"required_to_fill");
    self.promotionGroupSetLabel.text = kLoc(@"privilege_group_set");
    self.numberLabel.text = [NSString stringWithFormat:@"%@:",kLoc(@"serial_number")];
    self.nameLabel.text = [NSString stringWithFormat:@"%@:",kLoc(@"privilege_group_name")];
    self.groupLabel.text = kLoc(@"cuisine");
    self.cookName.text = kLoc(@"dish_name");
    self.priceLabel.text = kLoc(@"price");
    self.cuisineNameTextField.placeholder = kLoc(@"please_select_cusines");
}

/**
 *  设置菜系下拉菜单
 */
- (void)setComboBox
{
    isComboBoxOpen_ = NO;
    NSInteger diskCount = self.cuisineDataArr.count;
    [self.showCuisineTableView initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
        return diskCount;
        
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        if (!cell)
        {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        CuisineDataModel *cuisineData = [self.cuisineDataArr objectAtIndex:indexPath.row];
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

#pragma mark PUBLIC METHODS

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
    self.discoutMenuTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset - 100,0.0f);
    self.discoutMenuTableView.scrollEnabled = NO;
    
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
    
    self.discoutMenuTableView.scrollEnabled = YES;
    self.discoutMenuTableView.contentInset = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}

#pragma mark - Private method
- (void)prepareData
{
    if (!self.promoteCookbookGroupData)
    {
        self.promoteCookbookGroupData = [[PromoteCookBookGroupDataModel alloc]init];
    }
    else
    {
        self.discoutNameTextField.text = self.promoteCookbookGroupData.promoteName;
        self.discoutIdentifierTextField.text = self.promoteCookbookGroupData.promoteNumber;
        for (CuisineDataModel *cuisine in self.cuisineDataArr)
        {
            int selectedCount = 0;
            for (CookbookDataClass *cook in cuisine.cookbookDataArr)
            {
                for (CookbookDataClass *promoteCook in self.promoteCookbookGroupData.groupCookbookArr)
                {
                    if (promoteCook.cookbookID == cook.cookbookID)
                    {
                        cook.isSelected = YES;
                        selectedCount ++;
                        break;
                    }
                }
            }
            if (selectedCount == cuisine.cookbookDataArr.count)
            {
                cuisine.isSelectedAllCookbook = YES;
            }
        }
    }
}

/**
 *  滚动tableView到底部
 *
 *  @param animated 是否显示滚动动画
 */
- (void)scrollTableToFoot:(BOOL)animated
{
    NSInteger s = [self.discoutMenuTableView numberOfSections];
    if (s<1) return;
    NSInteger r = [self.discoutMenuTableView numberOfRowsInSection:s-1];
    if (r<1) return;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
    [self.discoutMenuTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

/**
 *  找出菜品价格范围并返回
 *
 *  @param cook 菜品数据
 *
 *  @return (例:$4 - 9)
 */
- (NSString *)getDishPrice:(CookbookDataClass *)cook
{
    NSString *priceStr = nil;
    CookbookPriceDataClass *firstPrice = (CookbookPriceDataClass *)[cook.priceArr objectAtIndex:0];
    if (cook.priceArr.count == 1)
    {
        priceStr = [NSString stringWithFormat:@"%@ %@", [[OfflineManager sharedOfflineManager] getCurrencySymbol],[NSString trimmingZeroInPrice:[NSString stringWithFormat:@"%.2f",firstPrice.price]]];
    }
    else
    {
        float maxPrice = firstPrice.price;
        float minPrice = firstPrice.price;
        for (CookbookPriceDataClass *price in cook.priceArr)
        {
            if (maxPrice < price.price)
            {
                maxPrice = price.price;
            }
            if (minPrice > price.price)
            {
                minPrice = price.price;
            }
        }
        NSString *minStr = [NSString trimmingZeroInPrice:[NSString stringWithFormat:@"%.2f",minPrice]];
        NSString *maxStr = [NSString trimmingZeroInPrice:[NSString stringWithFormat:@"%.2f",maxPrice]];
        priceStr = [NSString stringWithFormat:@"%@%@ ~ %@",
                    [[OfflineManager sharedOfflineManager]getCurrencySymbol],minStr,maxStr];
    }
    return priceStr;
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
        self.promoteCookbookGroupData.groupCookbookArr = backupGroupCookbookArr;
        [self.delegate dismissEditDiscountViewController:self];
    }
}

- (IBAction)sureBtnPress:(id)sender
{
    //组合名重名检测
    if ([self isDiscoutNameExist:self.discoutNameTextField.text])
    {
        return;
    }
    
    //编号重名检测
    if ([self isDiscoutIDExist:self.discoutIdentifierTextField.text])
    {
        return;
    }
    [self.view endEditing:YES];
    /*
    if (!self.discoutIdentifierTextField.text.length)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:kLoc(@"privilege_package_number_cannot_be_empty") delegate:nil cancelButtonTitle:kLoc(@"confirm") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
     */
    
    if (!self.discoutNameTextField.text.length)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:kLoc(@"privilege_package_name_cannot_be_empty") delegate:nil cancelButtonTitle:kLoc(@"confirm") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    self.promoteCookbookGroupData.isActive = YES;
    self.promoteCookbookGroupData.promoteName =self.discoutNameTextField.text;
    self.promoteCookbookGroupData.promoteNumber = self.discoutIdentifierTextField.text;
    [self submitData];
}

/**
 *  从右边的优惠套餐TableView中删除某项.
 *
 *  @param sender cell中的删除按钮
 */
- (void)deleteCookbook:(UIButton *)sender
{
    EditDiscountTableViewCell * cell = nil;
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        cell = (EditDiscountTableViewCell *)sender.superview.superview;
    }
    else
    {
        cell = (EditDiscountTableViewCell *)sender.superview.superview.superview;
    }
    NSIndexPath * path = [self.discoutMenuTableView indexPathForCell:cell];
    CookbookDataClass *cookbookData = (CookbookDataClass *) [self.promoteCookbookGroupData.groupCookbookArr objectAtIndex:path.row];
    cookbookData.isSelected = NO;
    [self deleteCookbookFromRightView:cookbookData];
    [self.promoteCookbookGroupData.groupCookbookArr  removeObjectAtIndex:path.row];
    [self.originalMenuTableView reloadData];
    [self.discoutMenuTableView reloadData];
}


- (void)deleteCookbookFromRightView:(CookbookDataClass *)cookBookData
{
    for (CuisineDataModel *cuisineData in self.cuisineDataArr)
    {
        if ([cuisineData.cuisineName isEqualToString:cookBookData.cuisineName])
        {
            cuisineData.isSelectedAllCookbook = NO;
            for (CookbookDataClass *temCookData in cuisineData.cookbookDataArr)
            {
                if ([temCookData.cookbookName isEqualToString:cookBookData.cookbookName])
                {
                    temCookData.isSelected = NO;
                    break;
                }
            }
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
 *  添加/编辑优惠组合,将数据提交服务器
 */
- (void)submitData
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:self.promoteCookbookGroupData.promoteNumber forKey:@"number"];
    [postData setObject:self.promoteCookbookGroupData.promoteName forKey:@"name"];
    if (self.isEditExistItem)
    {
        [postData setObject:self.promoteCookbookGroupData.promoteKey forKey:@"key"];
    }
    NSMutableArray *submitCookArr = [[NSMutableArray alloc]init];
    for (CookbookDataClass *temCookData in self.promoteCookbookGroupData.groupCookbookArr)
    {
        NSString *cookbookIDstr = [NSString stringWithFormat:@"%lu",(unsigned long)temCookData.cookbookID];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:cookbookIDstr,@"cb_id",temCookData.userDefinedPrice,@"cb_price_userDefined",nil];
        [submitCookArr addObject:dic];
    }
    [postData setObject:submitCookArr forKey:@"cookbook"];
    
    [jsonPicker postData:postData withBaseRequest:@"CookbookPromote/savePromoteCookbookGroup"];
}



#pragma mark UITableView delegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == kOriginalTableView)
    {
        if (selectedCuisineIndex_ == -1)
        {
            return 0;
        }
        else
        {
            if (self.cuisineDataArr.count > selectedCuisineIndex_)
            {
                CuisineDataModel *cuiData = (CuisineDataModel *)[self.cuisineDataArr objectAtIndex:selectedCuisineIndex_];
                NSInteger count = cuiData.cookbookDataArr.count;
                return count;
            }
            else
            {
                return 0;
            }
        }
    }
    else
    {
        return self.promoteCookbookGroupData.groupCookbookArr.count;
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
        CuisineDataModel *cuiData = (CuisineDataModel *)[self.cuisineDataArr objectAtIndex:selectedCuisineIndex_];
        CookbookDataClass *cookbookData = (CookbookDataClass *) [cuiData.cookbookDataArr objectAtIndex:indexPath.row];
        cell.titleLabel.text = cookbookData.cookbookName;
        [cell isSelected:cookbookData.isSelected];
        return cell;
    }
    else
    {
        EditDiscountTableViewCell *cell = (EditDiscountTableViewCell *)[tableView dequeueReusableCellWithIdentifier:DiscounCellIdentifier];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"EditDiscountTableViewCell" owner:self options:nil]lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            [cell.deleteBtn addTarget:self action:@selector(deleteCookbook:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (self.promoteCookbookGroupData.groupCookbookArr.count > indexPath.row)
        {
            CookbookDataClass *cookbookData = (CookbookDataClass *) [self.promoteCookbookGroupData.groupCookbookArr objectAtIndex:indexPath.row];
            //价格有多个规格,则显示价格区间
            CookbookPriceDataClass *priceData = (CookbookPriceDataClass *)[cookbookData.priceArr lastObject];
            cell.cuisineNameLabel.text = cookbookData.cuisineName;
            cell.cookbookNameLabel.text = cookbookData.cookbookName;
            cell.cookBook = cookbookData;
            if (!cookbookData.userDefinedPrice.length)
            {
                //NSString *originPriceStr = [NSString trimmingZeroInPrice:[NSString stringWithFormat:@"%.2f",priceData.price]];
                //[NSString stringWithFormat:@"%@ %@",[[OfflineManager sharedOfflineManager] getCurrencySymbol],originPriceStr];
                cell.CustomPrice.placeholder = [self getDishPrice:cookbookData];
            }
            else
            {
                cell.CustomPrice.text = cookbookData.userDefinedPrice;//[NSString stringWithFormat:@"%@ %@",[[OfflineManager sharedOfflineManager]getCurrencySymbol],[NSString trimmingZeroInPrice:cookbookData.userDefinedPrice]];
            }

            
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
    
    if (tableView.tag == kOriginalTableView)
    {
        /*
         cell点击选菜功能暂时屏蔽:
         
        CuisineDataModel *cuiData = (CuisineDataModel *)[self.cuisineDataArr objectAtIndex:selectedCuisineIndex_];
        CookbookDataClass *cookbookData = (CookbookDataClass *) [cuiData.cookbookDataArr objectAtIndex:indexPath.row];
        cookbookData.cuisineIndex = selectedCuisineIndex_;
        if (!cookbookData.isSelected)
        {
            //添加到优惠组合中.
            [self.promoteCookbookGroupData.groupCookbookArr addObject:cookbookData];
        }
        else
        {
            cuiData.isSelectedAllCookbook = NO;
            [self.promoteCookbookGroupData.groupCookbookArr removeObject:cookbookData];
        }
        cookbookData.isSelected = !cookbookData.isSelected;
        for (int i = 0;i < cuiData.cookbookDataArr.count;i++)
        {
            CookbookDataClass *cookData = [cuiData.cookbookDataArr objectAtIndex:i];
            if (!cookData.isSelected)
            {
                cuiData.isSelectedAllCookbook = NO;
                break;
            }
            if ((i == cuiData.cookbookDataArr.count - 1) && cookData.isSelected) {
                cuiData.isSelectedAllCookbook = YES;
            }
        }
        
        [_originalMenuTableView reloadData];
        [_discoutMenuTableView reloadData];
        */
    }
    else//点击右边某一行时,左边跳到相应菜系.
    {
        NSString *cuiStr = self.cuisineNameTextField.text;
        if (self.promoteCookbookGroupData.groupCookbookArr.count > indexPath.row)
        {
            CookbookDataClass *cook = [self.promoteCookbookGroupData.groupCookbookArr objectAtIndex:indexPath.row];
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
    headView.backgroundColor = [UIColor lightGrayColor];
    UILabel *selectAllLable = [[UILabel alloc]initWithFrame:CGRectMake(60, 8, 91, 38)];
    selectAllLable.textAlignment = UITextAlignmentLeft;
    selectAllLable.textColor = [UIColor redColor];
    selectAllLable.font = [UIFont systemFontOfSize:18];
    selectAllLable.text = kLoc(@"select_all");
    UIImageView *unselectedImv = [[UIImageView alloc]initWithFrame:CGRectMake(10,0, 40, 40)];
    UIImageView *didSelectedImv = [[UIImageView alloc]initWithFrame:unselectedImv.frame];
    unselectedImv.image = [UIImage imageNamed:@"dishesPicker_packageNormal"];
    didSelectedImv.image = [UIImage imageNamed:@"dishesPicker_packageSelected.png"];
    CuisineDataModel *cuiData = (CuisineDataModel *)[self.cuisineDataArr objectAtIndex:selectedCuisineIndex_];
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
    CuisineDataModel *cuiData = (CuisineDataModel *)[self.cuisineDataArr objectAtIndex:selectedCuisineIndex_];
    BOOL isAdd = NO;
    if (cuiData.isSelectedAllCookbook)//取消全选
    {
        cuiData.isSelectedAllCookbook = NO;
        for (CookbookDataClass *cookBookData in cuiData.cookbookDataArr)
        {
            cookBookData.isSelected = NO;
        }
        //从优惠组合中删除该菜系下的所有菜.
        for (int i = 0 ;i < self.promoteCookbookGroupData.groupCookbookArr.count;i++)
        {
            CookbookDataClass *promoteCookData = (CookbookDataClass *)[self.promoteCookbookGroupData.groupCookbookArr objectAtIndex:i];
            if ([promoteCookData.cuisineName isEqualToString:cuiData.cuisineName])
            {
                [self.promoteCookbookGroupData.groupCookbookArr removeObject:promoteCookData];
                i--;
            }
        }
        [self.promoteCookbookGroupData.groupCookbookArr removeObjectsInArray:cuiData.cookbookDataArr];
    }
    else//全选
    {
        isAdd = YES;
        cuiData.isSelectedAllCookbook = YES;
        for (CookbookDataClass *cookBookData in cuiData.cookbookDataArr)
        {
            if (!cookBookData.isSelected)
            {
                cookBookData.isSelected = YES;
                cookBookData.cuisineIndex = selectedCuisineIndex_;
                [self.promoteCookbookGroupData.groupCookbookArr addObject:cookBookData];
            }
        }
    }
    [self.originalMenuTableView reloadData];
    [self.discoutMenuTableView reloadData];
    if (isAdd)
    {
        [self scrollTableToFoot:YES];
    }
}


#pragma mark UITextFidld delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    cuisineTableView.scrollEnabled = NO;
    return YES;
}

/**
 *  检测输入的编号是否已存在
 *
 *  @param discoutID 输入的编号
 *
 *  @return YES:已存在
 */
- (BOOL)isDiscoutIDExist:(NSString *)discoutID
{
    BOOL isExist = NO;
    for (PromoteCookBookGroupDataModel *promote in self.promoteCookbookGroupArr)
    {
        if ([promote.promoteNumber isEqualToString:discoutID])
        {
            if ((self.isEditExistItem && ![self.promoteCookbookGroupData.promoteKey isEqualToString:promote.promoteKey])
                || !self.isEditExistItem)
            {
                UIAlertView *sameIDAlert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"编号已存在,请更改", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"好", nil) otherButtonTitles:nil, nil];
                [sameIDAlert show];
                isExist = YES;
                break;
            }
        }
    }
    return isExist;
}


/**
 *  检测输入的优惠组合名是否已存在
 *
 *  @param discoutName 输入的优惠组合名
 *
 *  @return YES:已存在
 */
- (BOOL)isDiscoutNameExist:(NSString *)discoutName
{
    BOOL isExist = NO;
    for (PromoteCookBookGroupDataModel *promote in self.promoteCookbookGroupArr)
    {
        if ([promote.promoteName isEqualToString:discoutName])
        {
            if ((self.isEditExistItem && ![self.promoteCookbookGroupData.promoteKey isEqualToString:promote.promoteKey]) || !self.isEditExistItem)
            {
                UIAlertView *sameNameAlert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"优惠组合名已存在,请更改", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"好", nil) otherButtonTitles:nil, nil];
                [sameNameAlert show];
                isExist = YES;
                break;
            }
        }
    }
    return isExist;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (kDiscoutIDTextField == textField.tag)
    {
        NSString *temID = textField.text;
        [self isDiscoutIDExist:temID];
        
    }
    else if (KDiscoutNameTextField == textField.tag)
    {
        NSString *temName = textField.text;
        [self isDiscoutNameExist:temName];

    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

#pragma mark -EditDiscountTableViewCellProtocol

- (void)EditDiscountTableViewCellDidBeginEditingPrice:(EditDiscountTableViewCell *)cell
{
    [self.view endEditing:YES];
}

/**
 *  完成编辑自定义价格
 *
 *  @param cell        右边cell
 *  @param customPrice 自定义价格
 */
- (void)EditDiscountTableViewCell:(EditDiscountTableViewCell *)cell didFinishEditingPrice:(NSString *)customPrice
{
    NSIndexPath *indexPath = [self.discoutMenuTableView indexPathForCell:cell];
    if (self.promoteCookbookGroupData.groupCookbookArr.count > indexPath.row)
    {
        CookbookDataClass *cookbookData = (CookbookDataClass *) [self.promoteCookbookGroupData.groupCookbookArr objectAtIndex:indexPath.row];
        cookbookData.userDefinedPrice = customPrice;        
    }
}

#pragma mark JsonPickerDelegate
-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    if (picker.tag == 0)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            case 200:
            {
                NSDictionary *allDataDic = [dict objectForKey:@"data"];
                self.promoteCookbookGroupData.promoteKey = [allDataDic objectForKey:@"key"];
                if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishEditWithNewDiscountModel:isEditExistItem:)])
                {
                    [self.delegate didFinishEditWithNewDiscountModel:self.promoteCookbookGroupData isEditExistItem:self.isEditExistItem];
                }
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

#pragma mark - originalMenueTableViewCellDelegate
//选中/取消选中某菜
- (void)tableViewCell:(OriginalMenuTableViewCell *)cell didPressBtn:(UIButton *)btn
{
    NSIndexPath *indexPath = [self.originalMenuTableView indexPathForCell:cell];
    CuisineDataModel *cuiData = (CuisineDataModel *)[self.cuisineDataArr objectAtIndex:selectedCuisineIndex_];
    CookbookDataClass *cookbookData = (CookbookDataClass *) [cuiData.cookbookDataArr objectAtIndex:indexPath.row];
    cookbookData.cuisineIndex = selectedCuisineIndex_;
    BOOL isAdd;//标记是添加还是删除
    if (!cookbookData.isSelected)
    {
        //添加到优惠组合中.
        isAdd = YES;
        [self.promoteCookbookGroupData.groupCookbookArr addObject:cookbookData];
    }
    else
    {
        isAdd = NO;
        cuiData.isSelectedAllCookbook = NO;
        for (int i = 0; i < self.promoteCookbookGroupData.groupCookbookArr.count; i++)
        {
            CookbookDataClass *prCookbookData = [self.promoteCookbookGroupData.groupCookbookArr objectAtIndex:i];
            if ([prCookbookData.cookbookName isEqualToString:cookbookData.cookbookName])
            {
                [self.promoteCookbookGroupData.groupCookbookArr removeObject:prCookbookData];
            }
        }
    }
    cookbookData.isSelected = !cookbookData.isSelected;
    for (int i = 0;i < cuiData.cookbookDataArr.count;i++)
    {
        CookbookDataClass *cookData = [cuiData.cookbookDataArr objectAtIndex:i];
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
    
    [_originalMenuTableView reloadData];
    [_discoutMenuTableView reloadData];
    if (isAdd)
    {
        [self scrollTableToFoot:YES];
    }
}


@end
