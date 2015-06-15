//
//  PromotionDishSelectView.m
//  PreOrderSystem
//
//  Created by SWen on 14-7-22.
//
//

#import "PromotionDishSelectView.h"
#import "SelectTableViewCell.h"
#import "CuisineDataModel.h"
#import "SelectionCell.h"
#import "DishSelectGridViewCell.h"
#import "Constants.h"
#import "NumPicker.h"
#import "PSPopoverBckgroundView.h"
#import "DishCardNewViewClass.h"
#import "PSAlertView.h"
#import "PackageDataModel.h"
#import "PackageMemberDataModel.h"
#import "DishCardNewViewClass.h"
#import "PSAlertView.h"
#import "WEPopoverController.h"
#import "MainViewController.h"


@implementation PromotionDishSelectView
{
    NumPicker *_picker;
    id _popoverController;
    UITextField *_ruleNumberTextField;
    UILabel *_itemLabel;
    UIView *_headView;
    NSMutableArray *_buttonArray;
    BOOL isComboBoxOpen_;
    NSArray *_ruleArray;
    UIButton *_cancelButton;
    UIButton *_sureButton;
    DishCardNewViewClass *dishCardClass;//编辑模式下传递过来的数据模型
    DishCardNewViewClass *dishCardClassBackup;//编辑模式下传递过来的数据模型的备份，取消的时候要恢复
    BOOL _isFound;//是否匹配到菜系
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.selectedCuisineIndex = -1;
//        self.selectedArr = [[NSMutableArray alloc] init];
        
        [self creatUI];
        _ruleArray = [[NSArray alloc] initWithObjects:kLoc(@"select_all"),kLoc(@"required"),kLoc(@"optional_choose"), nil];

        //编辑菜系的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(editDishAction:)
                                                     name:kEditDishFromDishCardNotification
                                                   object:nil];
        
        //kvo
        [self addObserver:self forKeyPath:@"isEdit" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"isEdit" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kEditDishFromDishCardNotification object:nil];
}

//- (void)

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isEdit"])
    {
        _cancelButton.hidden = !self.isEdit;
        _sureButton.hidden = !self.isEdit;
        _originalMenuTableView.hidden = !self.isEdit;
    }
}
#pragma mark Public method



- (void)setSelectDataModel:(NSArray *)dataArr selectedDishCardDict:(NSDictionary *)dishCardDict
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
        CuisineDataModel *cuisineData = [[CuisineDataModel alloc] initAllDetailWithData:dic];
        [self.allCuisineArr addObject:cuisineData];
    }
    
    [self.originalMenuTableView reloadData];
    [self.comboxTableView reloadData];
}
- (void)reloadData
{
    [self.originalMenuTableView reloadData];
    [self.comboxTableView reloadData];
}
- (void)creatUI
{
    //菜系选择框
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
    cuisinesNameBtn.backgroundColor = [UIColor clearColor];
    cuisinesNameBtn.frame = self.cuisinesNameTextField.frame;
    [cuisinesNameBtn addTarget:self action:@selector(comboxBtnClick:)
              forControlEvents:UIControlEventTouchUpInside];
    
    //菜系选择框右边的展开箭头按钮
    self.showCuisineListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.showCuisineListBtn.frame = CGRectMake(self.cuisinesNameTextField.frame.size.width + 5, 5, 30, 30);
    [self.showCuisineListBtn setImage:[UIImage imageNamed:@"dropdown"] forState:UIControlStateNormal];
    [self.showCuisineListBtn addTarget:self action:@selector(comboxBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //取消按钮
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.showCuisineListBtn.frame) + 5, 0, 60, 40)];
    [_cancelButton setTitle:kLoc(@"cancel") forState:UIControlStateNormal];
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"more_shortButton.png"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.hidden = YES;
    
    //确定按钮
    _sureButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cancelButton.frame) + 5, 0, 60, 40)];
    [_sureButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
    [_sureButton setBackgroundImage:[UIImage imageNamed:@"more_shortButton.png"] forState:UIControlStateNormal];
    [_sureButton addTarget:self action:@selector(sureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _sureButton.hidden = YES;
    
    //菜系明细下拉列表,默认为收起状态.
    self.comboxTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 33,self.cuisinesNameTextField.frame.size.width, 0)];
    self.comboxTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.comboxTableView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.comboxTableView.layer setBorderWidth:2];
    self.comboxTableView.delegate = self;
    self.comboxTableView.dataSource = self;
    
    //常规列表风格tableView
    self.originalMenuTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.cuisinesNameTextField.frame) + 3, self.frame.size.width - 30, self.frame.size.height - 30)];
    self.originalMenuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.originalMenuTableView.delegate = self;
    self.originalMenuTableView.dataSource = self;
    
    [self addSubview:self.cuisinesNameTextField];
    [self addSubview:cuisinesNameBtn];
    [self addSubview:_sureButton];
    [self addSubview:_cancelButton];
    [self addSubview:self.showCuisineListBtn];
    [self addSubview:self.originalMenuTableView];
    [self addSubview:self.comboxTableView];
    

}

//响应编辑通知
- (void)editDishAction:(NSNotification *)notification
{
    if (self.isEdit)
    {
        [PSAlertView showWithMessage:kLoc(@"please_save_current_editting_cusines")];
        return;
    }
    self.isEdit = YES;
    
    dishCardClass =  [notification object];
    dishCardClass.isSpread = YES;
    dishCardClassBackup = [[DishCardNewViewClass alloc] initWithOtherDish:dishCardClass];
    
    //设置菜品被选中
    [self DidCookbookDataSelectedMatchData:dishCardClass];
    
    
}

//根据通知设置当前菜系的数据
- (void)DidCookbookDataSelectedMatchData:(DishCardNewViewClass *)dish
{
    //与下拉列表菜系匹配
    _isFound = NO;
    for (int i = 0; i < self.allCuisineArr.count; i++)
    {
        CuisineDataModel *cuiData = self.allCuisineArr[i];
//        if ((cuiData.cuisineId == dish.cuisineID && dish.cuisineID!= 0) || ([cuiData.cuisineName isEqualToString:dish.groupName] && dish.cuisineID == 0))
        if (cuiData.cuisineId == dish.cuisineID && dish.cuisineID!= 0)
        {
            cuiData.choose = dish.choose;
            cuiData.chooseNum = dish.chooseNum;

            self.selectedCuisineIndex = i;
            if (i < self.allCuisineArr.count)
            {
                CuisineDataModel *cuiData = self.allCuisineArr[i];
                self.cuisinesNameTextField.text = cuiData.cuisineName;
            }
            _isFound = YES;
            break;
        }
    }
    
    if (_isFound)
    {
        _originalMenuTableView.hidden = NO;
        _sureButton.hidden = NO;
        
        //设置规则
        _ruleNumberTextField.text = [NSString stringWithFormat:@"%d", dish.chooseNum];
        UIButton *btn = _buttonArray[dish.choose];
        if (btn.selected == NO)
        {
            [self btnClick:btn];
        }
        
        //设置菜品被选中
        CuisineDataModel *cuiData = self.allCuisineArr[self.selectedCuisineIndex];
        
        //先全部置于NO
        for (CookbookDataClass *cookbook in cuiData.cookbookDataArr)
        {
            cookbook.isSelected = NO;
        }
        
        for (int i = 0; i < dish.cookArray.count; i++)
        {
            //先获得被选中的菜品ID和菜品名
            NSInteger cbID = 0;
            NSString *selectedName = nil;
            if ([dish.cookArray[i] isKindOfClass:[CookbookDataClass class]])
            {
                CookbookDataClass *cookbook = (CookbookDataClass *)dish.cookArray[i];
                cbID = cookbook.cookbookID;
                selectedName = cookbook.cookbookName;
            }
            else if ([dish.cookArray[i] isKindOfClass:[PackageMemberDataModel class]])
            {
                PackageMemberDataModel *packageMember = (PackageMemberDataModel *)dish.cookArray[i];
                cbID = packageMember.cbID;
                selectedName = packageMember.memberName;
            }
            
            //比较，设置被选
            for (CookbookDataClass *cookbook in cuiData.cookbookDataArr)
            {
                if (cookbook.isSelected == NO && (cbID == cookbook.cookbookID || [selectedName compare:cookbook.cookbookName] == NSOrderedSame) )
                {
                    cookbook.isSelected = YES;
                }
            }
        }
        [self.originalMenuTableView reloadData];
    }
    else//未发现匹配的菜系，则不做任何动作
    {
        _cuisinesNameTextField.text = dishCardClass.groupName;
        for (PackageMemberDataModel *PackageMember in dishCardClass.cookArray)
        {
            PackageMember.isChecked = YES;
        }
        [_originalMenuTableView reloadData];
    }
}

#pragma mark -private method

// 创建数字键盘
- (void)NumberPicker:(UITextField *)textField
{
    if (!_picker)
    {
        _picker = [[NumPicker alloc] init];
    }
    _picker.delegate = self;
    _picker.tag = 1;
    _picker.pickerType = NumPickerTypeWithDishPrice;
    _picker.numberText = textField.text;
    _picker.minimumNum = 0;
    _picker.maximumNum = 1000;
    
    if (!_popoverController)
    {
        if (kIsiPhone) {
            _popoverController = [[WEPopoverController alloc] initWithContentViewController:_picker];
        } else {
            _popoverController = [[UIPopoverController alloc] initWithContentViewController:_picker];
        }
    }
    
    if (!kIsiPhone) {
        if (kSystemVersionOfCurrentDevice >= 7.0) {
            // 更改iOS7默认样式
            [(UIPopoverController *)_popoverController setPopoverBackgroundViewClass:[PSPopoverBckgroundView class]];
        } else {
            [(UIPopoverController *)_popoverController setPopoverBackgroundViewClass:nil];
        }
    }
    
    [_popoverController setContentViewController:_picker];
    [_popoverController setPopoverContentSize:_picker.pickerSize];
    
    if (kIsiPhone) {
        MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
        CGRect showRect = [_ruleNumberTextField convertRect:_headView.frame toView:mainCtrl.view];
        [_popoverController setParentView:mainCtrl.view];
        [_popoverController presentPopoverFromRect:showRect
                                            inView:mainCtrl.view
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
    } else {
        [_popoverController presentPopoverFromRect:_headView.frame
                                            inView:_ruleNumberTextField
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
    }
}


#pragma mark -- button click
/**
 *  显示菜系下拉列表
 *
 *  @param sender: showCuisineListBtn
 */
- (IBAction)comboxBtnClick:(id)sender
{
    if (self.isEdit) {
        return;
    }
    
    self.comboxTableView.hidden = NO;
    if (isComboBoxOpen_)
    {
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
            [_showCuisineListBtn setImage:closeImage forState:UIControlStateNormal];
            
            CGRect frame= self.comboxTableView.frame;
            
            frame.size.height = 0;
            [self.comboxTableView setFrame:frame];
            
        } completion:^(BOOL finished){
            
            isComboBoxOpen_ = NO;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
            [_showCuisineListBtn setImage:openImage forState:UIControlStateNormal];
            CGRect frame = self.comboxTableView.frame;
            frame.size.height=200;
            [self.comboxTableView setFrame:frame];
        } completion:^(BOOL finished){
            
            isComboBoxOpen_ = YES;
        }];
    }
}


- (void)btnClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
    for (UIButton *tempButton in _buttonArray)
    {
        if (tempButton != btn)
        {
            tempButton.selected = NO;
        }
    }
    
    // 如果是全选则隐藏数量
    if (btn.tag == 0)
    {
        _itemLabel.hidden = YES;
        _ruleNumberTextField.hidden = YES;
    }
    else//其他显示数量
    {
        _itemLabel.hidden = NO;
        _ruleNumberTextField.hidden = NO;
    }
    
    // 保存到数据源
    if (self.isEdit && _isFound == NO)
    {
        dishCardClass.choose = btn.tag;
    }
    else
    {
        CuisineDataModel *cuisineData = self.allCuisineArr[self.selectedCuisineIndex];
        cuisineData.choose = btn.tag;
        dishCardClass.choose = btn.tag;
    }
    
}

- (void)cancelBtnClick:(UIButton *)btn
{
    if (self.isEdit)
    {
        //启用备份数据
        dishCardClass = [[DishCardNewViewClass alloc] initWithOtherDish:dishCardClassBackup];
        
        if ([self.delegate respondsToSelector:@selector(PromotionDishSelectView:pressSureButtonWithClass:)])
        {
            [self.delegate PromotionDishSelectView:self pressSureButtonWithClass:dishCardClass];
        }
        self.comboxTableView.hidden = YES;
        self.cuisinesNameTextField.text = @"";
        self.originalMenuTableView.hidden = YES;
        _sureButton.hidden = YES;
        
        self.isEdit = NO;
    }
}

- (void)sureBtnClick:(UIButton *)btn
{
    if (self.isEdit)
    {
        if (_isFound == NO)
        {
            NSMutableArray *packageArray = [[NSMutableArray alloc] init];
            for (PackageMemberDataModel *PackageMember in dishCardClass.cookArray)
            {
                if (PackageMember.isChecked == YES)
                {
                    [packageArray addObject:PackageMember];;
                }
            }
            dishCardClass.cookArray = packageArray;
        }
        
        if (dishCardClass.chooseNum > dishCardClass.cookArray.count)
        {
            [PSAlertView showWithMessage:kLoc(@"选项数不能大于被选中的菜品数")];
            return;
        }
        
        self.isEdit = NO;
        
        if ([self.delegate respondsToSelector:@selector(PromotionDishSelectView:pressSureButtonWithClass:)])
        {
            [self.delegate PromotionDishSelectView:self pressSureButtonWithClass:dishCardClass];
        }
        self.comboxTableView.hidden = YES;
        self.cuisinesNameTextField.text = @"";
        self.originalMenuTableView.hidden = YES;
        _sureButton.hidden = YES;
        return;
    }
    else
    {
        NSInteger choose = -1;
        UIButton *selectedRuleBtn = nil;
        for (UIButton *temp in _buttonArray)
        {
            if (temp.selected == YES)
            {
                choose = temp.tag;
                selectedRuleBtn = temp;
            }
        }
        
        if (choose == -1)
        {
        [PSAlertView showWithMessage:kLoc(@"no_select_rule")];
            return;
        }
        
        DishCardNewViewClass *dishClass = [[DishCardNewViewClass alloc] init];
        
        // 规则  （全选，任选，必选）
        dishClass.choose = choose;
        dishClass.chooseStringArray = [[NSMutableArray alloc] initWithArray:_ruleArray];
        
        if (selectedRuleBtn.tag == 1 || selectedRuleBtn.tag == 2)//(任选，必选判断）
        {
            // 项
            NSInteger number = [_ruleNumberTextField.text integerValue];
            if (_ruleNumberTextField.text.length == 0)
            {
            [PSAlertView showWithMessage:kLoc(@"no_select_rule_number")];
                return;
            }
            dishClass.chooseNum = number;
        }
        
        
        // 菜系名和菜系ID
        CuisineDataModel *cuisineData = _allCuisineArr[self.selectedCuisineIndex];
        dishClass.groupName = [[NSMutableString alloc] initWithString:cuisineData.cuisineName];
        dishClass.cuisineID = cuisineData.cuisineId;
        
        // 菜系索引
        dishClass.cuisineIndex = self.selectedCuisineIndex;
        
        // 被选中菜品数组
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (CookbookDataClass *cookData in cuisineData.cookbookDataArr)
        {
            if (cookData.isSelected == YES)
            {
                cookData.quantity = 1;
                [tempArray addObject:cookData];
            }
        }
        
        if (tempArray.count == 0)
        {
        [PSAlertView showWithMessage:kLoc(@"no_select_dishesInfo")];
            return;
        }
        dishClass.cookArray = tempArray;
        
        //展开
        dishClass.isSpread = NO;
        
        if (dishClass.chooseNum > dishClass.cookArray.count)
        {
            [PSAlertView showWithMessage:kLoc(@"选项数不能大于被选中的菜品数")];
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(PromotionDishSelectView:pressSureButtonWithClass:)])
        {
            [self.delegate PromotionDishSelectView:self pressSureButtonWithClass:dishClass];
        }
        
        self.comboxTableView.hidden = YES;
        self.cuisinesNameTextField.text = @"";
        self.originalMenuTableView.hidden = YES;
        _sureButton.hidden = YES;
    }
 }


#pragma mark UITableViewDataSource && UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.originalMenuTableView)
    {
        NSString *identify = @"identify";
        SelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        
        if (!cell)
        {
            cell = [[SelectTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.isTaoCanSetting = YES;
        }
        
        if (_isFound == NO && self.isEdit)//编辑模式下， 传入的菜系未与菜牌菜系匹配上
        {
            PackageMemberDataModel *PackageMember = dishCardClass.cookArray[indexPath.row];
            cell.titleLabel.text = PackageMember.memberName;
            [cell isSelected:PackageMember.isChecked];
        }
        else
        {
            if (self.allCuisineArr.count > self.selectedCuisineIndex)
            {
                CuisineDataModel *cuisineData = self.allCuisineArr[self.selectedCuisineIndex];
                
                if (cuisineData.cookbookDataArr.count > indexPath.row)
                {
                    CookbookDataClass *cookBookData = cuisineData.cookbookDataArr[indexPath.row];
                    cell.titleLabel.text = cookBookData.cookbookName;
                    [cell isSelected:cookBookData.isSelected];
                }
            }
        }
        
        return cell;
    }
    else if (tableView == self.comboxTableView)
    {
        SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        
        if (!cell)
        {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        CuisineDataModel *cuisineData = [_allCuisineArr objectAtIndex:indexPath.row];
        [cell.lb setText:cuisineData.cuisineName];
        return cell;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.originalMenuTableView)
    {
        if (_isFound == NO && self.isEdit)//编辑模式下， 传入的菜系未与菜牌菜系匹配上
        {
            return dishCardClass.cookArray.count;
        }
        else
        {
            if (self.selectedCuisineIndex == -1 )
            {
                return 0;
            }
            
            CuisineDataModel *cuiData = self.allCuisineArr[self.selectedCuisineIndex];
            return cuiData.cookbookDataArr.count;
        }
    }
    else if (tableView == self.comboxTableView)
    {
        return self.allCuisineArr.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (tableView == self.originalMenuTableView)
    {
        height = 44;
    }
    if (self.comboxTableView == tableView)
    {
        height = 40;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    if (tableView == self.originalMenuTableView)
    {
        height = 44.0;
    }
    
    return height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.originalMenuTableView)
    {
        if (self.isEdit && _isFound == NO)
        {
            PackageMemberDataModel *PackageMember = dishCardClass.cookArray[indexPath.row];
            PackageMember.isChecked = !PackageMember.isChecked;
            [_originalMenuTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
        
        CuisineDataModel *cuiData = self.allCuisineArr[self.selectedCuisineIndex];
        CookbookDataClass *cookbookData = (CookbookDataClass *) [cuiData.cookbookDataArr objectAtIndex:indexPath.row];
        cookbookData.cuisineIndex = self.selectedCuisineIndex;
        
        if (!cookbookData.isSelected)//选中某菜
        {
            cookbookData.isSelected = YES;
            
            if (self.isEdit)
            {
                cookbookData.quantity = 1;
                [dishCardClass.cookArray addObject:cookbookData];
            }

        }
        else//删除某菜
        {
            cookbookData.isSelected = NO;
            if (self.isEdit)
            {
                for (int i = 0; i < dishCardClass.cookArray.count; i++)
                {
                    if ([dishCardClass.cookArray[i] isKindOfClass:[CookbookDataClass class]])
                    {
                        CookbookDataClass *temp = (CookbookDataClass *)dishCardClass.cookArray[i];
                        if (temp.cookbookID == cookbookData.cookbookID || [temp.cookbookName compare:cookbookData.cookbookName] == NSOrderedSame)
                        {
                            [dishCardClass.cookArray removeObjectAtIndex:i];
                            break;
                        }
                    }
                    else if ([dishCardClass.cookArray[i] isKindOfClass:[PackageMemberDataModel class]])
                    {
                        PackageMemberDataModel *temp = (PackageMemberDataModel *)dishCardClass.cookArray[i];
                        if (temp.cbID == cookbookData.cookbookID  || [temp.memberName compare:cookbookData.cookbookName] == NSOrderedSame)
                        {
                            [dishCardClass.cookArray removeObjectAtIndex:i];
                            break;
                        }
                    }
                }
            }
        }
        
        [_originalMenuTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if (tableView == self.comboxTableView)
    {
        SelectionCell *cell = (SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
        if (cell == nil)
        {
            if (indexPath.row < self.allCuisineArr.count)
            {
                CuisineDataModel *cuiData = self.allCuisineArr[indexPath.row];
                self.cuisinesNameTextField.text = cuiData.cuisineName;
            }
        }
        else
        {
            self.cuisinesNameTextField.text = cell.lb.text;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
            [_showCuisineListBtn setImage:closeImage forState:UIControlStateNormal];
            CGRect frame= self.comboxTableView.frame;
            frame.size.height = 0;
            [self.comboxTableView setFrame:frame];
        } completion:^(BOOL finished){
            isComboBoxOpen_ = NO;
        }];
        self.selectedCuisineIndex = (int)indexPath.row;
        _originalMenuTableView.hidden = NO;
        _sureButton.hidden = NO;
        [_originalMenuTableView reloadData];
        
        //设置已经被选中的cookbook
        CuisineDataModel *cuiData = self.allCuisineArr[indexPath.row];
        for (DishCardNewViewClass *dishCard in self.detailArray)
        {
            if ((dishCard.cuisineID == cuiData.cuisineId && dishCard.cuisineID!= 0) || ([dishCard.groupName isEqualToString:cuiData.cuisineName] && dishCard.cuisineID == 0))
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kEditDishFromDishCardNotification object:dishCard];
                break;
            }
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.originalMenuTableView)
    {
        if (self.selectedCuisineIndex == -1)
        {
            if (self.isEdit && _isFound == NO)
            {
                return [self createHeadViewWithChooseIndex:dishCardClass.choose chooseNum:dishCardClass.chooseNum];
            }
            else
            {
                return nil;
            }
            
        }
        else
        {
            CuisineDataModel *cuisineData = self.allCuisineArr[self.selectedCuisineIndex];
            return [self createHeadViewWithChooseIndex:cuisineData.choose chooseNum:cuisineData.chooseNum];
        }
    }
    
    return nil;
}

- (UIView *)createHeadViewWithChooseIndex:(NSInteger)choose chooseNum:(NSInteger)chooseNum
{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _originalMenuTableView.frame.size.width, 44)];
    headView.backgroundColor = [UIColor lightGrayColor];
    
    float btn_wh = 28;
    float label_w = 42;
    float label_h = 28;
    float space = 6;// 间隔
    
    _buttonArray = [[NSMutableArray alloc] init];
    UILabel *rightLabel;// 最右边的label;
    
    for (int i = 0; i < 3; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom] ;
        button.frame  = CGRectMake((btn_wh + label_w) * i + space, (headView.frame.size.height - btn_wh) / 2, 28, 28);
        button.tag = i;
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"dishesPicker_packageNormal"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"dishesPicker_packageSelected.png"] forState:UIControlStateSelected];
        
        if (i == choose)
        {
            button.selected = YES;
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button.frame), (headView.frame.size.height - label_h) / 2, label_w, label_h)];
        label.text = _ruleArray[i];
        label.tag = i;
        rightLabel = label;
        
        [_buttonArray addObject:button];
        [headView addSubview:button];
        [headView addSubview:label];
    }
    
    //数量
    UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rightLabel.frame) + space, (headView.frame.size.height - 30) / 2, 70, 30)];
    textfield.delegate = self;
    textfield.textAlignment = UITextAlignmentCenter;
    textfield.borderStyle = UITextBorderStyleNone;
    textfield.background = [UIImage imageNamed:@"rule_timeFieldBg.png"];
    textfield.textColor = [UIColor blackColor];
    textfield.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textfield.font = [UIFont systemFontOfSize:17];
        //textfield.placeholder = kLoc(@"（必填）", nil);
        textfield.placeholder = [NSString stringWithFormat:@"（%@）",kLoc(@"required_to_fill")];
    textfield.text = [NSString stringWithFormat:@"%d",chooseNum];
    _ruleNumberTextField = textfield;
    [headView addSubview:textfield];
    
    //项
    _itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textfield.frame) + space, (headView.frame.size.height - label_h) / 2, label_w, label_h)];
    _itemLabel.text = NSLocalizedString(@"项", nil);
    [headView addSubview:_itemLabel];
    
    //如果是全选，数量和项隐藏
    if (choose == 0)
    {
        textfield.hidden = YES;
        _itemLabel.hidden = YES;
    }
    
    return _headView = headView;
}
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _ruleNumberTextField)
    {
//        [self performSelector:@selector(NumberPicker:) withObject:textField afterDelay:0.5];
        [self NumberPicker:textField];
        return NO;
    }
    
    return YES;
}

#pragma mark NumPickerDelegate

-(void)NumPicker:(NumPicker*)picker didPickedNumber:(NSString*)number
{
    [_popoverController dismissPopoverAnimated:YES];
    _ruleNumberTextField.text = number;
    // 保存到数据源
    if (self.isEdit && _isFound == NO)
    {
        
    }
    else
    {
        CuisineDataModel *cuisineData = self.allCuisineArr[self.selectedCuisineIndex];
        cuisineData.chooseNum = [number integerValue];
    }

    dishCardClass.chooseNum = [number integerValue];
}
- (void)NumPicker:(NumPicker*)picker didPickedOverflowNumber:(NSString*)number
{
    [PSAlertView showWithMessage:NSLocalizedString(@"请输入0~1000", nil)];
}
@end
