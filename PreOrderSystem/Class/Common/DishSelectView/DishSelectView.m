//
//  DishSelectView.m
//  PreOrderSystem
//
//  Created by mac on 14-7-4.
//
//

#import "DishSelectView.h"
#import "SelectTableViewCell.h"
#import "CuisineDataModel.h"
#import "SelectionCell.h"
#import "DishSelectGridViewCell.h"
#import "Constants.h"
#import "OfflineManager.h"  
#import "CookbookPriceDataClass.h"
#import "NsstringAddOn.h"
#import "NumPicker.h"
#import "PSPopoverBckgroundView.h"

#import "WEPopoverController.h"
#import "MainViewController.h"

#define columnNum 3


@implementation DishSelectView
{
    BOOL isComboBoxOpen_;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.selectedCuisineIndex = -1;
        self.selectedArr = [[NSMutableArray alloc]init];
        [self creatUI];
        self.backgroundColor  =  [UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
    [self removeNotification];
}
- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDelectDishFromCarNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDishNumChangedFromRightTable object:nil];
}

- (void)creatUI
{
    //菜系选择.
    self.cuisinesNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width/2, 40)];

    self.cuisinesNameTextField.textAlignment = UITextAlignmentCenter;
    self.cuisinesNameTextField.placeholder = kLoc(@"please_select_cusines");
    // 圆角幅度
    self.cuisinesNameTextField.layer.cornerRadius = 10.0;
    // 边框的颜色 将UIColor转化为CGColorRed
    self.cuisinesNameTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    // 设置边框的线宽
    self.cuisinesNameTextField.layer.borderWidth = 2.0;

    
    UIButton *cuisinesNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cuisinesNameBtn.frame = self.cuisinesNameTextField.frame;
    [cuisinesNameBtn addTarget:self action:@selector(showCuisineList:)
              forControlEvents:UIControlEventTouchUpInside];
    
    //菜系选择框右边的展开箭头按钮
    self.showCuisineListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.showCuisineListBtn.frame = CGRectMake(self.cuisinesNameTextField.frame.size.width, 0, 30, 30);
    
    [self.showCuisineListBtn setBackgroundImage:[UIImage imageNamed:@"dropdown"] forState:UIControlStateNormal];
    [self.showCuisineListBtn addTarget:self action:@selector(showCuisineList:) forControlEvents:UIControlEventTouchUpInside];
    
    //切换列表按钮
    self.styleListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.styleListBtn.frame = CGRectMake(self.showCuisineListBtn.frame.origin.x + 40, 0, 35, 35);    [self.styleListBtn setBackgroundImage:[UIImage imageNamed:@"List"] forState:UIControlStateNormal];
    [self.styleListBtn addTarget:self
                          action:@selector(changeToList:)
                forControlEvents:UIControlEventTouchUpInside];
    
    //切换九宫格按钮
    self.styleBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.styleBoxBtn.frame = CGRectMake(self.styleListBtn.frame.origin.x + 55, 0, 35, 35);
    [self.styleBoxBtn setBackgroundImage:[UIImage imageNamed:@"Grid"] forState:UIControlStateNormal];
    [self.styleBoxBtn addTarget:self
                    action:@selector(changeToStyleBox:)
          forControlEvents:UIControlEventTouchUpInside];
    
    //菜系明细下拉列表,默认为收起状态.
    self.showCuisineTableView = [[TableViewWithBlock alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.cuisinesNameTextField.frame),self.cuisinesNameTextField.frame.size.width, 0)];
    
    //常规列表风格tableView
    self.originalMenuTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.cuisinesNameTextField.frame), self.frame.size.width-30, self.frame.size.height - 30)];
    self.originalMenuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.originalMenuTableView.delegate = self;
    self.originalMenuTableView.dataSource = self;
    
    //九宫格风格tableView (默认隐藏)
    self.styleBoxGridView = [[UIGridView alloc]initWithFrame:self.originalMenuTableView.frame];
    self.styleBoxGridView.uiGridViewDelegate = self;
    self.styleBoxGridView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.styleBoxGridView.hidden = YES;
    
    //默认头视图
    self.commonHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.styleBoxBtn.frame.origin.x+36, 40)];
    self.commonHeadView.backgroundColor = [UIColor clearColor];
    [self.commonHeadView addSubview:self.cuisinesNameTextField];
    [self.commonHeadView addSubview:cuisinesNameBtn];
    [self.commonHeadView addSubview:self.showCuisineListBtn];
    [self.commonHeadView addSubview:self.styleBoxBtn];
    [self.commonHeadView addSubview:self.styleListBtn];


    
    //添加手势,点击空白区域则收起菜系下拉列表
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                         action:@selector(tapBackground:)];
    tap.delegate = self;
    
    [self addGestureRecognizer:tap];
    [self addSubview:self.commonHeadView];
    [self addSubview:self.originalMenuTableView];
    [self addSubview:self.showCuisineTableView];
    [self addSubview:self.styleBoxGridView];

    
    //购物车中增加或删除某菜一份或多份.
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(dishCountChangedFromRightTable:)
                                                name:kDishNumChangedFromRightTable
                                              object:nil];
    
    //删除某菜的通知(非购物车)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(delectDishFromCar:)
                                                 name:kDelectDishFromCarNotification
                                               object:nil];
}


#pragma mark Public method

//通过输入ID添加菜品.
- (void)addDishByID
{
    //切换输入菜品ID/常规头部视图按钮(暂时将btn改为switch)
    self.switchHeadViewBtn = [[UISwitch alloc]init];//[UIButton buttonWithType:UIButtonTypeCustom];
    self.switchHeadViewBtn.frame = CGRectMake(self.styleBoxBtn.frame.origin.x + 40, 0, 35, 35);
    //[self.switchHeadViewBtn setBackgroundImage:[UIImage imageNamed:@"switchHeadViewBtn"] forState:UIControlStateNormal];
    [self.switchHeadViewBtn addTarget:self
                               action:@selector(switchHeadView:)
                     forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.switchHeadViewBtn];
    
    //菜品ID输入框
    self.cookbookIDTextFied = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width/2, 38)];
    self.cookbookIDTextFied.clearButtonMode = UITextFieldViewModeAlways;
    self.cookbookIDTextFied.placeholder = kLoc(@"please_enter_dishID_to_order");
    self.cookbookIDTextFied.textAlignment = UITextAlignmentCenter;
    self.cookbookIDTextFied.layer.cornerRadius = 10.0;
    self.cookbookIDTextFied.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.cookbookIDTextFied.layer.borderWidth = 2.0;
    
    //"添加"按钮
    UIButton *addDishBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addDishBtn.frame = CGRectMake(self.cookbookIDTextFied.frame.size.width + 20, 0, 35, 35);
    [addDishBtn addTarget:self
                   action:@selector(addDishByID:)
         forControlEvents:UIControlEventTouchUpInside];
    
    //通过输入菜品ID添加菜式,当按下switchHeadViewBtn时显示.
    self.addDishByIDView = [[UIView alloc]initWithFrame:self.commonHeadView.frame];
    self.addDishByIDView.backgroundColor = [UIColor clearColor];
    self.addDishByIDView.hidden = YES;
    [self.addDishByIDView addSubview:self.cookbookIDTextFied];
    [self.addDishByIDView addSubview:addDishBtn];
    [self addSubview:self.addDishByIDView];
}


/**
 *  初始化“下拉刷新”控件
 */
- (void)setEGORefreshView
{
    _reloading = NO;
    
    if (_originalRefreshHeaderView == nil)
    {
        CGRect refreshRect = CGRectMake(0.0f,
                                        0.0f - self.originalMenuTableView.bounds.size.height,
                                        self.originalMenuTableView.bounds.size.width,
                                        self.originalMenuTableView.bounds.size.height);
		_originalRefreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:refreshRect];
		_originalRefreshHeaderView.delegate = self;
        _originalRefreshHeaderView.backgroundColor = [UIColor clearColor];
		[self.originalMenuTableView addSubview:_originalRefreshHeaderView];
	}
    
    //九宫格tableView在本界面设置下拉刷新无效,只能在原始TabelView所在类中设置:
    [self.styleBoxGridView setEGORefreshView];
}



- (void)setSelectDataModel:(NSArray *)dataArr
{
    if (!self.allCuisineArr)
    {
        self.allCuisineArr = [[NSMutableArray alloc]init];
    }
    else
    {
        [self.allCuisineArr removeAllObjects];
    }
    for (NSDictionary *dic in dataArr)
    {
        CuisineDataModel *cuisineData = [[CuisineDataModel alloc]initAllDetailWithData:dic];
        [self.allCuisineArr addObject:cuisineData];
    }
    [self reloadData];
}

/**
 *  刷新列表
 */
- (void)reloadData
{
    [self setComboBox];
    [self.originalMenuTableView reloadData];
    [self.styleBoxGridView reloadData];
}

/**
 *  显示菜系下拉列表
 *
 *  @param sender: showCuisineListBtn
 */
- (IBAction)showCuisineList:(id)sender
{
    //[self endEditing:YES];
    if (isComboBoxOpen_)
    {
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
            [_showCuisineListBtn setBackgroundImage:closeImage forState:UIControlStateNormal];
            
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
            [_showCuisineListBtn setBackgroundImage:openImage forState:UIControlStateNormal];
            
            CGRect frame = _showCuisineTableView.frame;
            
            frame.size.height = 380;
            
            [_showCuisineTableView setFrame:frame];
        } completion:^(BOOL finished){
            
            isComboBoxOpen_ = YES;
        }];
    }
}


#pragma mark -private method

- (void)tapBackground:(UITapGestureRecognizer *)tap
{
    [self hideComboBox];
}

/**
 *  隐藏菜系下拉列表
 */
- (void)hideComboBox
{
    if (isComboBoxOpen_)
    {
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
            [_showCuisineListBtn setBackgroundImage:closeImage forState:UIControlStateNormal];
            
            CGRect frame= _showCuisineTableView.frame;
            
            frame.size.height = 0;
            [_showCuisineTableView setFrame:frame];
            
        } completion:^(BOOL finished){
            
            isComboBoxOpen_ = NO;
        }];
    }
}

- (void)dishCountChangedFromRightTable:(NSNotification *)notification
{
    NSDictionary *dic = notification.object;
    int changedCount = [[dic objectForKey:@"changeNum"]intValue];
    NSString *dishName = [dic objectForKey:@"dishName"];
    
    for (int i = 0;i < self.selectedArr.count;i++)
    {
        CookbookDataClass *coData = [self.selectedArr objectAtIndex:i];
        if ([coData.cookbookName isEqualToString:dishName])
        {
            coData.dishCount += changedCount;
            break;
        }
    }
    [_originalMenuTableView reloadData];
    [_styleBoxGridView reloadData];
}



/**
 *  选中了某个菜
 *
 *  @param index 该菜的位置.
 */
- (void)didSelectDishAtIndex:(int)index
{
    CuisineDataModel *cuiData = (CuisineDataModel *)[self.allCuisineArr objectAtIndex:_selectedCuisineIndex];
    CookbookDataClass *cookbookData = (CookbookDataClass *) [cuiData.cookbookDataArr objectAtIndex:index];
    cookbookData.cuisineIndex = _selectedCuisineIndex;
    CookbookPath *cpath = [[CookbookPath alloc]initWithCuisineIndex:_selectedCuisineIndex andCookbookIndex:index];
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:cpath, nil];
    if (self.isAddDishOnly)//数字模式
    {
        if (cookbookData.isSoldOut || !cookbookData.isActive)
        {
            return;//沽清或该菜品已暂停
        }
        if (cookbookData.dishCount == 0)
        {
            [self.selectedArr addObject:cookbookData];
        }
        cookbookData.dishCount += 1;
        if (self.delegate && [self.delegate respondsToSelector:@selector(DishSelectVieW:didSelectedCookbookPathArr:)])
        {
            [self.delegate DishSelectVieW:self didSelectedCookbookPathArr:arr];
        }
        
    }
    else//勾选模式
    {
        if (!cookbookData.isSelected)//选中某菜
        {
            cookbookData.isSelected = YES;
            [self.selectedArr addObject:cookbookData];
            if (self.delegate && [self.delegate respondsToSelector:@selector(DishSelectVieW:didSelectedCookbookPathArr:)])
            {
                [self.delegate DishSelectVieW:self didSelectedCookbookPathArr:arr];
            }
            for (int i = 0;i < cuiData.cookbookDataArr.count;i++)
            {
                //判断当前菜系是否已经处于全选状态;
                CookbookDataClass *cook = (CookbookDataClass *) [cuiData.cookbookDataArr objectAtIndex:i];
                if (!cook.isSelected)
                {
                    break;
                }
                if (i == cuiData.cookbookDataArr.count-1)
                {
                    cuiData.isSelectedAllCookbook = YES;
                }
            }
        }
        else//删除某菜
        {
            cuiData.isSelectedAllCookbook = NO;
            cookbookData.isSelected = NO;
            [self.selectedArr removeObject:cookbookData];
            if (self.delegate && [self.delegate respondsToSelector:@selector(DishSelectVieW:didRemovedCookbookPathArr:)])
            {
                [self.delegate DishSelectVieW:self didRemovedCookbookPathArr:arr];
            }
        }

    }
    [_originalMenuTableView reloadData];
    [_styleBoxGridView reloadData];
}

/**
 *  将tableView切换到九宫格模式
 *
 *  @param btn
 */
- (void)changeToStyleBox:(UIButton *)btn
{
    self.isUseStyleBoxCell = YES;
    self.originalMenuTableView.hidden = YES;
    self.styleBoxGridView.hidden = NO;
    [self.styleBoxGridView reloadData];
}

/**
 *  将tableView切换到列表模式
 *
 *  @param btn
 */
- (void)changeToList:(UIButton *)btn
{
    self.isUseStyleBoxCell = NO;
    self.styleBoxGridView.hidden = YES;
    self.originalMenuTableView.hidden = NO;
    [self.originalMenuTableView reloadData];
}

/**
 *  设置菜系下拉菜单,
 */
- (void)setComboBox
{
    isComboBoxOpen_ = NO;
    NSInteger diskCount = (NSInteger)self.allCuisineArr.count;
    [self bringSubviewToFront:self.showCuisineTableView];
    [self.showCuisineTableView initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
        return diskCount;
        
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        if (!cell) {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        CuisineDataModel *cuisineData = [_allCuisineArr objectAtIndex:indexPath.row];
        [cell.lb setText:cuisineData.cuisineName];
        
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
        self.cuisinesNameTextField.text=cell.lb.text;
        [_showCuisineListBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        _selectedCuisineIndex = indexPath.row;
        [_originalMenuTableView reloadData];
        [_styleBoxGridView reloadData];
        
    }];
    
    [_showCuisineTableView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_showCuisineTableView.layer setBorderWidth:2];
}


#pragma mark -- button click

/**
 *  点击了切换头视图按钮.
 *
 *  @param btn self.switchHeadViewBtn
 */
- (void)switchHeadView:(UIButton *)btn
{
    [self hideComboBox];
    [self endEditing:YES];
    if (self.addDishByIDView.hidden)
    {
        self.addDishByIDView.hidden = NO;
        self.commonHeadView.hidden = YES;
    }
    else
    {
        self.addDishByIDView.hidden = YES;
        self.commonHeadView.hidden = NO;
    }
}

/**
 *  通过输入菜品名添加菜品到购物车
 *
 *  @param btn 
 */
- (void)addDishByID:(UIButton *)btn
{
    [self endEditing:YES];
    NSString *cookIDStr = self.cookbookIDTextFied.text;
    if (!cookIDStr.length)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:kLoc(@"please_enter_dishID") delegate:nil cancelButtonTitle:kLoc(@"good") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    BOOL isFound = NO;
    for (int i = 0;i < self.allCuisineArr.count;i++)
    {
        CuisineDataModel *cui = [self.allCuisineArr objectAtIndex:i];
        for (int j = 0;j < cui.cookbookDataArr.count;j++)
        {
            CookbookDataClass *cook = [cui.cookbookDataArr objectAtIndex:j];
            if ([cookIDStr isEqualToString:cook.cookbookCode])
            {
                if (cook.isActive)
                {
                    if (!cook.isSoldOut)
                    {
                        self.selectedCuisineIndex = i;
                        [self.originalMenuTableView reloadData];
                        [self.styleBoxGridView reloadData];
                        [self didSelectDishAtIndex:j];
                    }
                    else//该菜品已沽清
                    {
                        UIAlertView *soldOutAlert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"该菜品已沽清", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles:nil, nil];
                        [soldOutAlert show];
                    }
                }
                else//该菜品已暂停
                {
                    UIAlertView *stopAlert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"该菜品已暂停", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles:nil, nil];
                    [stopAlert show];
                }
                isFound = YES;
                break;
            }
            if (i == self.allCuisineArr.count - 1 && j == cui.cookbookDataArr.count - 1)
            {
                //没找到对应的菜品
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:kLoc(@"no_result_of_dishesID") delegate:nil cancelButtonTitle:kLoc(@"sure") otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        if (i == self.allCuisineArr.count - 1 && !cui.cookbookDataArr.count)
        {
            //没找到对应的菜品
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:kLoc(@"no_result_of_dishesID") delegate:nil cancelButtonTitle:kLoc(@"sure") otherButtonTitles:nil, nil];
            [alert show];
        }
        if (isFound)
        {
            break;
        }
    }
}

- (void)btnClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
}

/**
 *  为originalMenuTableView创建section头,用于全选/全不选
 *
 *  @param tableView
 *
 *  @return section head 视图.
 */
- (UIView *)creatHeadViewToTableView:(UITableView *)tableView
{
    if (_selectedCuisineIndex == -1)
    {
        return nil;
    }
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    headView.backgroundColor = [UIColor lightGrayColor];

    UILabel *selectAllLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 191, 38)];
    selectAllLable.textAlignment = UITextAlignmentCenter;
    selectAllLable.textColor = [UIColor redColor];
    selectAllLable.font = [UIFont systemFontOfSize:18];
    selectAllLable.text = kLoc(@"all_the_dishes");
    
    UIImageView *unselectedImv = [[UIImageView alloc]initWithFrame:CGRectMake(192,0, 40, 40)];
    UIImageView *didSelectedImv = [[UIImageView alloc]initWithFrame:unselectedImv.frame];
    
    UIButton *selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectAllBtn.frame = CGRectMake(0, 0, unselectedImv.frame.origin.x + unselectedImv.frame.size.width, 44);
    [selectAllBtn addTarget:self action:@selector(selectAllDish:) forControlEvents:UIControlEventTouchUpInside];
    
    unselectedImv.image = [UIImage imageNamed:@"dishesPicker_packageNormal"];
    didSelectedImv.image = [UIImage imageNamed:@"dishesPicker_packageSelected.png"];
    

    CuisineDataModel *cuiData = (CuisineDataModel *)[self.allCuisineArr objectAtIndex:_selectedCuisineIndex];
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
    [headView addSubview:selectAllBtn];
    
    return headView;
}

/**
 *  全选/取消全选某菜系的所有菜品
 *
 *  @param btn 按钮
 */
- (void)selectAllDish:(UIButton *)btn
{
    CuisineDataModel *cuiData = (CuisineDataModel *)[self.allCuisineArr objectAtIndex:_selectedCuisineIndex];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    if (cuiData.isSelectedAllCookbook)//取消全选
    {
        cuiData.isSelectedAllCookbook = NO;
        for (int i = 0;i<cuiData.cookbookDataArr.count;i++)
        {
            CookbookDataClass *cookBookData = (CookbookDataClass *)[cuiData.cookbookDataArr objectAtIndex:i];
            if (cookBookData.isSelected)
            {
                CookbookPath *cpath = [[CookbookPath alloc]initWithCuisineIndex:_selectedCuisineIndex andCookbookIndex:i];
                [arr addObject:cpath];
            }
            cookBookData.isSelected = NO;
        }
        [self.selectedArr removeObjectsInArray:cuiData.cookbookDataArr];
        if (self.delegate && [self.delegate respondsToSelector:@selector(DishSelectVieW:didRemovedCookbookPathArr:)])
        {
            [self.delegate DishSelectVieW:self didRemovedCookbookPathArr:arr];
        }
    }
    else//全选
    {
        cuiData.isSelectedAllCookbook = YES;
        for (int i = 0;i < cuiData.cookbookDataArr.count;i++)
        {
            CookbookDataClass *cookBookData = (CookbookDataClass *)[cuiData.cookbookDataArr objectAtIndex:i];
            if (!cookBookData.isSelected)
            {
                cookBookData.isSelected = YES;
                cookBookData.cuisineIndex = _selectedCuisineIndex;
                [self.selectedArr addObject:cookBookData];
                
                CookbookPath *cpath = [[CookbookPath alloc]initWithCuisineIndex:_selectedCuisineIndex andCookbookIndex:i];
                [arr addObject:cpath];
            }
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(DishSelectVieW:didSelectedCookbookPathArr:)])
        {
            [self.delegate DishSelectVieW:self didSelectedCookbookPathArr:arr];
        }
    }
    [self.originalMenuTableView reloadData];
    [self.styleBoxGridView reloadData];
}

/**
 *  购物车删除某菜
 *
 *  @param notification.object --被删除的菜的名称
 */
- (void)delectDishFromCar:(NSNotification *)notification
{
    if (!self.isAddDishOnly)
    {
        NSString *deleName = notification.object;
        for (int i = 0;i < self.selectedArr.count;i++)
        {
            CookbookDataClass *coData = [self.selectedArr objectAtIndex:i];
            if ([coData.cookbookName isEqualToString:deleName])
            {
                coData.isSelected = NO;
                [self.selectedArr removeObject:coData];
                CuisineDataModel *cuiData = (CuisineDataModel *)[self.allCuisineArr objectAtIndex:coData.cuisineIndex];
                cuiData.isSelectedAllCookbook = NO;
                break;
            }
        }
        [_originalMenuTableView reloadData];
        [_styleBoxGridView reloadData];
    }
}

#pragma mark UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_selectedCuisineIndex != -1)
    {
        if (self.allCuisineArr.count > _selectedCuisineIndex)
        {
            CuisineDataModel *cuiData = (CuisineDataModel *)[self.allCuisineArr objectAtIndex:_selectedCuisineIndex];
            return cuiData.cookbookDataArr.count;
        }
        else
        {
            return 0;
        }
    }
    else//刚进入电话外卖界面,未选中菜系.
    {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.isAddDishOnly)
    {
        return 0;
    }
    else
    {
        return 44.0;
    }
    
}

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identify = @"identify";
    SelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell)
    {
        cell = [[SelectTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        
        if (self.isAddDishOnly)
        {
            [cell resetPriceLabelWidth];
        }
    }
    if (self.allCuisineArr.count > self.selectedCuisineIndex)
    {
        CuisineDataModel *cuisineData = [self.allCuisineArr objectAtIndex:self.selectedCuisineIndex];
        if (cuisineData.cookbookDataArr.count > indexPath.row)
        {
            CookbookDataClass *cookBookData = [cuisineData.cookbookDataArr objectAtIndex:indexPath.row];
            cell.titleLabel.text = cookBookData.cookbookName;

            if (cookBookData.priceArr.count)
            {
                cell.priceLabel.text = [self getDishPrice:cookBookData];
                //cell.priceLabel.text = [NSString stringWithFormat:@"%@ %.2f /%@", [[OfflineManager sharedOfflineManager] getCurrencySymbol], firstPrice.price,firstPrice.priceStyle];
            }
            
            if (self.isAddDishOnly)
            {
                [cell setSelectNum:cookBookData.dishCount];
                if (cookBookData.isActive)//若菜品没被暂停
                {
                    [cell setShowSoldOutImv:!cookBookData.isSoldOut];
                    [cell setStopSupplyImv:YES];
                }
                else//若菜品已被暂停,优先显示"暂停"图标,"沽清"图标不再显示.
                {
                    [cell setStopSupplyImv:cookBookData.isActive];
                    [cell setShowSoldOutImv:YES];
                }
            }
            else
            {
                [cell isSelected:cookBookData.isSelected];
			}
        }
    }
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self didSelectDishAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath: indexPath animated:NO];
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.isAddDishOnly)
    {
        return nil;
    }
    else
    {
        if (_selectedCuisineIndex == -1)
        {
            return nil;
        }
        else
        {
            CuisineDataModel *cuiData = (CuisineDataModel *)[self.allCuisineArr objectAtIndex:_selectedCuisineIndex];
            if (!cuiData.cookbookDataArr.count)
            {
                return nil;
            }
        }
        return [self creatHeadViewToTableView:tableView];
    }
}

#pragma mark - UIGridViewDelegate
- (void)gridView:(UIGridView *)grid didTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(DishSelectView:DidTriggerRefresh:)])
    {
        [self.delegate DishSelectView:self DidTriggerRefresh:view];
    }
}

- (CGFloat) gridView:(UIGridView *)grid widthForColumnAt:(int)columnIndex
{

	return 127;
}

- (CGFloat) gridView:(UIGridView *)grid heightForRowAt:(int)rowIndex
{

    
	return 120;
}

- (UIView *)gridView:(UIGridView *)grid viewForHeaderInSection:(NSInteger)section
{
    if (self.isAddDishOnly)
    {
        return nil;
    }
    else
    {
        if (_selectedCuisineIndex == -1)
        {
            return nil;
        }
        else
        {
            CuisineDataModel *cuiData = (CuisineDataModel *)[self.allCuisineArr objectAtIndex:_selectedCuisineIndex];
            if (!cuiData.cookbookDataArr.count)
            {
                return nil;
            }
        }
        return [self creatHeadViewToTableView:self.styleBoxGridView];
    }
}

- (CGFloat) gridView:(UIGridView *)grid heightForHeaderInSection:(NSInteger)section
{
    if (self.isAddDishOnly)
    {
        return 0;
    }
    else
    {
        return 44.0;
    }
}

- (NSInteger) numberOfColumnsOfGridView:(UIGridView *) grid
{
	return 3;
}


- (NSInteger) numberOfCellsOfGridView:(UIGridView *) grid
{
    if (self.selectedCuisineIndex != -1)
    {
        CuisineDataModel *selectedCu = (CuisineDataModel *)[self.allCuisineArr objectAtIndex:self.selectedCuisineIndex];
        return selectedCu.cookbookDataArr.count;
    }
    else
    {
        return 0;
    }

}

- (UIGridViewCell *) gridView:(UIGridView *)grid cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex
{
	DishSelectGridViewCell *cell = (DishSelectGridViewCell *)[grid dequeueReusableCell];
	
//	if (cell == nil)
    {
		cell = [[DishSelectGridViewCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	}
    CuisineDataModel *cuData = (CuisineDataModel *)[self.allCuisineArr objectAtIndex:self.selectedCuisineIndex];
    
    int cookBookIndex = 0;
    cookBookIndex = rowIndex * 3 + columnIndex;
    
    CookbookDataClass *cookBookData = (CookbookDataClass *)[cuData.cookbookDataArr objectAtIndex:cookBookIndex];
    
    if (cookBookIndex % 2)
    {
        cell.backgroungImgView.image = [UIImage imageNamed:@"CellBackground_a"];
        [cell setWordColor:[UIColor blackColor]];
    }
    else
    {
        cell.backgroungImgView.image = [UIImage imageNamed:@"CellBackground_b"];
        [cell setWordColor:[UIColor whiteColor]];
    }
    cell.selectedImv.hidden = !cookBookData.isSelected;
    cell.cookbookNameLabel.text = cookBookData.cookbookName;
    if (cookBookData.priceArr.count)
    {
        cell.cookbookPriceLabel.text = [self getDishPrice:cookBookData];
    }
    

    if (self.isAddDishOnly)
    {
        if (cookBookData.dishCount != 0)
        {
            cell.dishCountBtn.hidden = NO;
            [cell.dishCountBtn setTitle:[NSString stringWithFormat:@"%d",cookBookData.dishCount]
                               forState:UIControlStateNormal];
        }
        else
        {
            cell.dishCountBtn.hidden = YES;
        }
        
        if (cookBookData.isActive)//若菜品没被暂停
        {
            [cell setShowSoldOutImv:!cookBookData.isSoldOut];
            [cell setStopSupplyImv:YES];
        }
        else//若菜品已被暂停,优先显示"暂停"图标,"沽清"图标不再显示.
        {
            [cell setStopSupplyImv:cookBookData.isActive];
            [cell setShowSoldOutImv:YES];
        }
    }
    else
    {
        cell.selectedImv.hidden = !cookBookData.isSelected;
    }
    
	return cell;
}

- (void) gridView:(UIGridView *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)colIndex
{
    [self didSelectDishAtIndex:(rowIndex * 3 + colIndex)];
}
#pragma mark - UITextFieldDelegate


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_originalRefreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_originalRefreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark Data Source Loading / Reloading Methods

- (void)doneLoadingTableViewData
{
	_reloading = NO;
    [_originalRefreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.originalMenuTableView];
}

//结束加载数据,无论是否成功加载数据
- (void)finishLoading
{
    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(DishSelectView:DidTriggerRefresh:)])
    {
        [self.delegate DishSelectView:self DidTriggerRefresh:view];
    }
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doneLoadingTableViewData) userInfo:nil repeats:NO];
}



- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date];
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

@end
