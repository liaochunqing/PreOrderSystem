//
//  PromotionSettingViewController.m
//  PreOrderSystem
//
//  Created by SWen on 14-7-1.
//
//

#import "PromotionSettingViewController.h"
#import "MainViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "PromotionSettingTableViewCell.h"
#import "WeekdayPicker.h"
#import "PSPopoverBckgroundView.h"
#import "NsstringAddOn.h"
#import "CustomTimePicker.h"
#import "PromotionTimePriceTableViewCell.h"
#import "JsonPicker.h"
#import "PSAlertView.h"
#import "PromoteCookBookDataModel.h"
#import "PromoteCookBookGroupDataModel.h"
#import "NumPicker.h"
#import "PSPopoverBckgroundView.h"
#import "Constants.h"
#import "WEPopoverController.h"

#define kDateFirstFormat @"yyyy-MM-dd"

@interface PromotionSettingViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate, WeekdayPickerDelegate>
{
    NSMutableArray *_timePriceArray;
    UITableView *_tableView;// 优惠套餐选择表格
    WeekdayPicker *_weekPicker;
    UIDatePicker *_datePicker;
    CustomTimePicker *_timePicker;
    NumPicker *_picker;
    id _popoverController;
    JsonPicker *_jsonPicker;
    NSMutableArray *_selectedCookbookGroupKeyArray;
    UITextField *_startTimeTextField;
    UITextField *_endTimeTextField ;
    UITextField *_priceTextField;
    UIView *_timePriceHeadView;
    BOOL _isTextFieldClearButtonClick;
}

@end

@implementation PromotionSettingViewController



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
    
    // 优惠列表创建
    float y = CGRectGetMaxY(self.packageImageView.frame);
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(_timePriceTabelView.frame.origin.x, y, _timePriceTabelView.frame.size.width, self.scrollView.frame.size.height - y - 10) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.layer.borderWidth = 1;
    _tableView.layer.borderColor = [UIColor grayColor].CGColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.scrollView addSubview:_tableView];
    
    //解析优惠套餐（方便使用）
    self.promoteCookbookGroupParsedArray = [self getDataWithPromoteCookbookGroup:self.promoteCookbookGroupArray];
    
    //获得被选优惠ID
    _selectedCookbookGroupKeyArray = [self.promoteActivity objectForKey:@"cookbookGroupKeys"];
    // 设置初始被选中数据
    for (NSDictionary *dict in _selectedCookbookGroupKeyArray) {
        for (PromoteCookBookGroupDataModel *temp in self.promoteCookbookGroupParsedArray) {
            NSString *str = [dict objectForKey:@"cookbookGroupKey"];
            if (str && [str isEqualToString:temp.promoteKey]) {
                temp.isSelected = YES;
            }
        }
    }
    
    //当有详情数据时
    if (self.promoteActivity)
    {
        self.identifieTextField.text = [self.promoteActivity objectForKey:@"number"];
        self.nameTextField.text = [self.promoteActivity objectForKey:@"name"];
        self.weekTextField.text = [self weekdayText:[self.promoteActivity objectForKey:@"weekly"]];
        self.startDateTextField.text = [self.promoteActivity objectForKey:@"fromDate"];
        self.endDateTextField.text = [self.promoteActivity objectForKey:@"toDate"];
        
        // 时间+优惠数据
        _timePriceArray = [[NSMutableArray alloc] initWithArray:[self.promoteActivity objectForKey:@"timeOffer"]];
    }
    else//新建时
    {
        _timePriceArray = [[NSMutableArray alloc] init];
    }
    
    [_timePriceTabelView reloadData];
    [self addLocalizedString];
    
    //自适应字体宽度
    [self resizeLabel:self.numberLabel Textfield:self.identifieTextField totalWidth:296];
    [self resizeLabel:self.promotionActivityLabel Textfield:self.nameTextField totalWidth:296];
    [self resizeLabel:self.dateLabel Textfield:self.startDateTextField totalWidth:296];
    [self resizeLabel:self.weekLabel Textfield:self.weekTextField totalWidth:630];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark PRIVATE METHODS
- (void)addLocalizedString
{
    self.titleLabel.text = kLoc(@"privilege_activity_set");
    self.numberLabel.text = [NSString stringWithFormat:@"%@:",kLoc(@"serial_number")];
    self.promotionActivityLabel.text = [NSString stringWithFormat:@"%@:",kLoc(@"privilege_activity")];
    self.dateLabel.text = [NSString stringWithFormat:@"%@:",kLoc(@"date")];
    self.weekLabel.text = [NSString stringWithFormat:@"%@:",kLoc(@"week")];
    self.packageLabel.text = [NSString stringWithFormat:@"%@:",kLoc(@"privilege_group")];
    self.identifieTextField.placeholder = kLoc(@"optional");
    self.nameTextField.placeholder = self.startDateTextField.placeholder = self.endDateTextField.placeholder = self.weekTextField.placeholder = kLoc(@"required_to_fill");
}

//根据字体计算需要的宽度
- (CGSize)accoutLabelWithByfont:(NSString *)text fontofsize:(CGFloat)fontofsize hight:(CGFloat)hight
{
    CGSize actualsize;
    //ios7方法，获取文本需要的size，限制宽度
    if (kSystemVersionIsIOS7)
    {
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:fontofsize],NSFontAttributeName,nil];
        actualsize =[text boundingRectWithSize:CGSizeMake( MAXFLOAT,hight) options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    }
    else//ios7以下方法，获取文本需要的size，限制宽度
    {
        actualsize = [text sizeWithFont:[UIFont systemFontOfSize:fontofsize] constrainedToSize:CGSizeMake(MAXFLOAT, hight) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return actualsize;
}

-(void)resizeLabel:(UILabel *)label Textfield:(UITextField *)textfield totalWidth:(CGFloat)totalWidth
{
    // 重设label的宽度
    CGSize size = [self accoutLabelWithByfont:label.text fontofsize:20.0 hight:label.frame.size.height];
    CGRect frame = label.frame;
    frame.size.width = size.width;
    label.frame = frame;
    
    //textfield的宽度
    CGFloat textfieldWidth = totalWidth - size.width;
    frame = textfield.frame;
    frame.size.width = textfieldWidth;
    frame.origin.x += textfield.frame.size.width - textfieldWidth;
    textfield.frame = frame;
}

- (void)hideKeyboard
{
    [self.nameTextField resignFirstResponder];
    [self.identifieTextField resignFirstResponder];
}

- (void)addTimePriceFirstCellData
{
    NSString *fromTime = @"";
    NSString *toTime = @"";
    NSString *offer = @"";
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:fromTime,@"fromTime",toTime,@"toTime",offer,@"offer", nil];
    [_timePriceArray insertObject:dict atIndex:0];
    
    [_timePriceTabelView reloadData];
//    [self scrollTableToFoot:YES];
}

// 获取优惠组合数据
- (NSMutableArray *)getDataWithPromoteCookbookGroup:(NSMutableArray *)promoteCookbookGroupArray
{
    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:promoteCookbookGroupArray,@"promoteCookbookGroup", nil];
    PromoteCookBookDataModel *promoteCookBookData = [[PromoteCookBookDataModel alloc]initWithData:dic andAllCuisineDataArr:self.allCuisineDataArr];
    return promoteCookBookData.promoteCookbookGroupArr;
}


//weekday的index转换为文字（如：，1对应于周一，6对应于周六,7对应于周日...）
-(NSString*)weekdayText:(NSArray*)week
{
    NSMutableString *text = [[NSMutableString alloc] init];
    if (0 == week.count)
    {
        return text;
    }
    
NSArray *array = [NSArray arrayWithObjects:kLoc(@"one"), kLoc(@"two"), kLoc(@"three"), kLoc(@"four"), kLoc(@"five"), kLoc(@"six"), kLoc(@"seven"), nil];
    
    for (int i=0; i<week.count; i++)
    {
        int index = [week[i] intValue] - 1;
        
        if (index < array.count && index >= 0)
        {
            [text appendString:array[index]];
        }
        
        if (i < week.count - 1)
        {
            [text appendString:@"、"];
        }
    }
    
    return text;
}


// uitableview滚动到最后一行
- (void)scrollTableToFoot:(BOOL)animated
{
    NSInteger s = [_timePriceTabelView numberOfSections];
    if (s<1) return;
    NSInteger r = [_timePriceTabelView numberOfRowsInSection:s-1];
    if (r<1) return;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
    
    [_timePriceTabelView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

#pragma mark - button Click
- (IBAction)quitBtnClick:(UIButton *)sender
{
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

- (IBAction)sureBtnClick:(UIButton *)sender
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    //key
    if (self.promoteActivity && [self.promoteActivity objectForKey:@"key"])
    {
        [dict setObject:[self.promoteActivity objectForKey:@"key"] forKey:@"key"];
    }
    else
    {
        [dict setObject:@"" forKey:@"key"];
    }
    
    //编号
    [dict setObject:self.identifieTextField.text forKey:@"number"];
    //名
    [dict setObject:self.nameTextField.text forKey:@"name"];
    
    //星期
    NSArray *weekArray = [self.promoteActivity objectForKey:@"weekly"];
    NSMutableString *weekString = [[NSMutableString alloc] init];
    for (int i = 0; i < weekArray.count; i++)
    {
        NSString *string = weekArray[i];
        [weekString appendString:[NSString stringWithFormat:@"%@", string]];
        if (i < weekArray.count - 1)
        {
            [weekString appendString:@","];
        }
    }
    [dict setObject:weekString forKey:@"weekly"];
    
    //日期
    [dict setObject:self.startDateTextField.text forKey:@"fromDate"];
    [dict setObject:self.endDateTextField.text forKey:@"toDate"];
    
    //时间+优惠价格
    if (_startDateTextField.text.length || _endDateTextField.text.length || _priceTextField.text.length)
    {
        if (_startTimeTextField.text.length == 0 || _endTimeTextField.text.length
            == 0 || _priceTextField.text.length == 0)
        {
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil
                                                               message:kLoc(@"please_input_privilege_time_full")
                                                              delegate:self
                                                     cancelButtonTitle:kLoc(@"confirm")
                                                     otherButtonTitles:nil, nil];
            [alerView show];
            return;
        }
        [self addCellBtnClick:nil];
    }
    [dict setObject:_timePriceArray forKey:@"timeOffer"];
    
    //cookbookGroupKeys
    NSMutableArray *cookbookGroupArray = [[NSMutableArray alloc] init];
    for (PromoteCookBookGroupDataModel *pcbg in self.promoteCookbookGroupParsedArray)
    {
        if (pcbg.isSelected == YES)
        {
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
            [tempDict setValue:pcbg.promoteKey forKey:@"cookbookGroupKey"];
            [cookbookGroupArray addObject:tempDict];
        }
    }
    [dict setValue:cookbookGroupArray forKey:@"cookbookGroupKeys"];
    
    [self uploadPromoteCookbookGroup:YES withDict:dict];
}

- (IBAction)addCellBtnClick:(UIButton *)sender
{
    if (_startTimeTextField.text.length == 0 || _endTimeTextField.text.length
        == 0 || _priceTextField.text.length == 0) {
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil
                                                           message:kLoc(@"please_input_privilege_time_full")
                                                          delegate:self
                                                 cancelButtonTitle:kLoc(@"confirm")
                                                 otherButtonTitles:nil, nil];
        [alerView show];
        return;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_startTimeTextField.text,@"fromTime", _endTimeTextField.text,@"toTime",_priceTextField.text,@"offer", nil];
    [_timePriceArray addObject:dict];
    _startTimeTextField.text = _endTimeTextField.text = _priceTextField.text = @"";
    [_timePriceTabelView reloadData];
    [self scrollTableToFoot:YES];
}
#pragma mark --picker
//数字选择器
- (void)numberPicker:(UITextField *)textField
{
    if (!_picker)
    {
        _picker = [[NumPicker alloc] init];
    }
    _picker.delegate = self;
    _picker.tag = 1;
    _picker.pickerType = NumPickerTypeNormal;
    _picker.numberText = textField.text;
    
    if (!_popoverController) {
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
        CGRect showRect = [_timePriceHeadView convertRect:textField.frame toView:mainCtrl.view];
        [_popoverController setParentView:mainCtrl.view];
        [_popoverController presentPopoverFromRect:showRect
                                            inView:mainCtrl.view
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
        
        // 移动到navController并调整位置
        WEPopoverController *popCtrl = _popoverController;
        CGRect originRect = popCtrl.view.superview.frame;
        UINavigationController *navController = [AppDelegate appDelegate].viewController;
        [popCtrl.view.superview removeFromSuperview];
        popCtrl.parentView = navController.view;
        [navController.view addSubview:popCtrl.view.superview];
        scaleView(popCtrl.view.superview);
        CGAffineTransform transform = popCtrl.view.superview.transform;
        CGAffineTransform translation = CGAffineTransformMakeTranslation(0.0 - originRect.size.width * (0.5 - transform.a / 2.0), 0.0 - originRect.size.height * (0.5 - transform.d / 2.0));
        popCtrl.view.superview.transform = CGAffineTransformConcat(transform, translation);
    } else {
        [_popoverController presentPopoverFromRect:textField.frame
                                            inView:_timePriceHeadView
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
    }
}

//时间选择器
-(void) timePickerCreate: (UITextField *)textField
{
    [self hideKeyboard];
    
    NSString *title = @"";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
    actionSheet.tag = 3;
    NSString *timeStr = textField.text;
    if (0 == timeStr.length)
    {
        timeStr = [NSString dateToNSString:[NSDate date] withFormat:@"HH:mm"];
    }
    
    //时间选择器
    _timePicker = [[CustomTimePicker alloc]initWithLastTimeString:timeStr];
    if (kIsiPhone) {
        _timePicker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
    } else {
        _timePicker.frame = CGRectMake(-25.0, 0.0, 320.0, 216.0);
    }
    _timePicker.backgroundColor = [UIColor clearColor];
    _timePicker.tag = textField.tag;
    [actionSheet addSubview:_timePicker];
    
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:textField.frame inView:_timePriceHeadView animated:YES];
    }
}

// 日期选择器
- (void)datePickerCreate:(UITextField *)textField
{
    /*键盘在时，收起键盘*/
    [self hideKeyboard];
    
    NSString *title = @"";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
    NSDate *date = [NSDate date];
    
    if (textField == self.startDateTextField)
    {
        if (0 != [self.startDateTextField.text length])
        {
            date = [self.startDateTextField.text stringToNSDateWithFormat:@"yyyy-MM-dd"];
        }
        actionSheet.tag = 1;
    }
    else if(textField == self.endDateTextField)
    {
        if (0 != [self.endDateTextField.text length])
        {
            date = [self.endDateTextField.text stringToNSDateWithFormat:@"yyyy-MM-dd"];
        }
        actionSheet.tag = 2;
    }
    
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-15.0, 0.0, 320.0, 216.0)];
    if (kIsiPhone) {
        _datePicker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
    }
    _datePicker.backgroundColor = [UIColor clearColor];
    _datePicker.tag = 1;
    _datePicker.date = date;
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [actionSheet addSubview:_datePicker];
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:textField.frame inView:self.scrollView animated:YES];
    }
}


//创建星期选择器
-(void)weekPickerCreate:(UIButton*)sender
{
    /*键盘在时，收起键盘*/
    [self hideKeyboard];
    
    _weekPicker = [[WeekdayPicker alloc] init];
    _weekPicker.delegate = self;
    [_weekPicker updateWeekdays:[self.promoteActivity objectForKey:@"weekly"]];
    
    if (nil == _popoverController)
    {
        if (kIsiPhone) {
            _popoverController = [[WEPopoverController alloc] initWithContentViewController:_weekPicker];
        } else {
            _popoverController = [[UIPopoverController alloc] initWithContentViewController:_weekPicker];
        }
    }
    
    if (!kIsiPhone) {
        [_popoverController setPopoverBackgroundViewClass:nil];
    }
    [_popoverController setContentViewController:_weekPicker];
    [_popoverController setPopoverContentSize:_weekPicker.pickerSize];
    
    if (kIsiPhone) {
        MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
        CGRect showRect = [self.scrollView convertRect:self.weekTextField.frame toView:mainCtrl.view];
        [_popoverController setParentView:mainCtrl.view];
        [_popoverController presentPopoverFromRect:showRect
                                            inView:mainCtrl.view
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
    } else {
        [_popoverController presentPopoverFromRect:self.weekTextField.frame
                                            inView:self.scrollView
                          permittedArrowDirections:UIPopoverArrowDirectionLeft
                                          animated:YES];
    }
}


#pragma mark - UITableViewController datasource & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView)
    {
        static NSString *CellIdentifier = @"PromotionSettingTableViewCell";
        PromotionSettingTableViewCell *cell = (PromotionSettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PromotionSettingTableViewCell" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.checkBlock = ^{
            PromoteCookBookGroupDataModel *temp = self.promoteCookbookGroupParsedArray[indexPath.row];
            temp.isSelected = !temp.isSelected;
        };
        
        [cell updateData:self.promoteCookbookGroupParsedArray[indexPath.row]];
        
        return cell;
    }
    else if (tableView == self.timePriceTabelView)
    {
        static NSString *CellIdentifier = @"PromotionTimePriceTableViewCell";
        PromotionTimePriceTableViewCell *cell = (PromotionTimePriceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PromotionTimePriceTableViewCell" owner:self options:nil] lastObject];
        }
        
        NSDictionary *dict = _timePriceArray[indexPath.row];
        cell.tag = indexPath.row;
        [cell updateCellInfo:dict];
        
        cell.deleteBlock = ^{
            [_timePriceArray removeObjectAtIndex:indexPath.row];
            [_timePriceTabelView reloadData];
        };
        
        cell.hideKeyboardBlock = ^{
            [self hideKeyboard];
        };
        
        return cell;
    }
	
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView)
    {
        return self.promoteCookbookGroupParsedArray.count;
    }
    else if (tableView == self.timePriceTabelView)
    {
        return _timePriceArray.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == _tableView)
    {
        //判断，若是展开的CELL。则增加高度
        PromoteCookBookGroupDataModel *temp = self.promoteCookbookGroupParsedArray[indexPath.row];
        if (temp.isSpread)
        {
            return 43 + kTableViewCellHight * temp.groupCookbookArr.count;
        }
        
        return 43;
    }
    else if (tableView == self.timePriceTabelView)
    {
        return 50;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView)
    {
        // 选中项， 展开
        PromoteCookBookGroupDataModel *data = self.promoteCookbookGroupParsedArray[indexPath.row];
        data.isSpread = !data.isSpread;
        
        // 非选中项，全部不展开
        for (int i = 0; i < self.promoteCookbookGroupParsedArray.count; i++)
        {
            PromoteCookBookGroupDataModel *temp = self.promoteCookbookGroupParsedArray[i];
            if (i != indexPath.row)
            {
                temp.isSpread = NO;
            }
        }
        
        //刷新列表
        [tableView reloadData];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        [self.scrollView scrollRectToVisible:_tableView.frame animated:YES];
    }
    else if (tableView == self.timePriceTabelView)
    {
        
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.timePriceTabelView)
    {
        float space = 5;
        float baseX = 5;
        float h = 35;//textField高度
        float w = 100;//textField宽度
        float y = 8;//每一行textfield的y坐标
        float labelY = 12;// 每行label的坐标
        UIColor *color = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
        
        //headView
        _timePriceHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.timePriceTabelView.frame.size.width, 50)];
        _timePriceHeadView.backgroundColor = [UIColor whiteColor];
        
        //背景图
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_timePriceHeadView.bounds];
        imageView.userInteractionEnabled = YES;
        imageView.image = [UIImage imageNamed:@"rule_cellHeadBg.png"];
        
        //时间：
        UILabel *_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(baseX, labelY, 52, 25)];
        _timeLabel.tag = 0;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor blackColor];
        _timeLabel.text = [NSString stringWithFormat:@"%@:",kLoc(@"time")];

        [_timePriceHeadView addSubview:_timeLabel];
        [_timePriceHeadView addSubview:imageView];
        
        //开始时间
        UITextField *textfield1 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_timeLabel.frame) , y , w, h)];
        textfield1.tag = 1;
        textfield1.delegate = self;
        textfield1.borderStyle = UITextBorderStyleNone;
        textfield1.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
        textfield1.textColor = color;
        textfield1.textAlignment = UITextAlignmentCenter;
        textfield1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        textfield1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textfield1.font = [UIFont systemFontOfSize:18];
        textfield1.clearButtonMode = UITextFieldViewModeAlways;
        textfield1.placeholder = kLoc(@"required_to_fill");
        _startTimeTextField = textfield1;
        [_timePriceHeadView addSubview:textfield1];
        
        
        //“至”
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textfield1.frame) + space, labelY, 20, 25)];
        //    label1.tag = 2;
        label1.backgroundColor = [UIColor clearColor];
        label1.textColor = [UIColor blackColor];
        label1.text = NSLocalizedString(@"~", nil);
        [_timePriceHeadView addSubview:label1];
        
        
        //结束时间
        UITextField *textfield2 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame) + space, y, w, h)];
        textfield2.tag = 2;
        textfield2.delegate = self;
        textfield2.borderStyle = UITextBorderStyleNone;
        textfield2.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
        textfield2.textColor = color;
        textfield2.textAlignment = UITextAlignmentCenter;
        textfield2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        textfield2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textfield2.font = [UIFont systemFontOfSize:18];
        textfield2.clearButtonMode = UITextFieldViewModeAlways;
        textfield2.placeholder = kLoc(@"required_to_fill");
        _endTimeTextField = textfield2;
        [_timePriceHeadView addSubview:textfield2];
        
        // 折扣：
        UILabel *_priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textfield2.frame) + 100, labelY, 52, 25)];
        //    label2.tag = 0;
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.textColor = [UIColor blackColor];
        //_priceLabel.text = kLoc(@"优惠：", nil);
        _priceLabel.text = [NSString stringWithFormat:@"%@:",kLoc(@"cash_discount")];

        [_timePriceHeadView addSubview:_priceLabel];
        
        //折扣TextField
        UITextField *textfield3 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_priceLabel.frame) , y, w, h)];
        textfield3.tag = 3;
        textfield3.delegate = self;
        textfield3.borderStyle = UITextBorderStyleNone;
        textfield3.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
        textfield3.textColor = color;
        textfield3.textAlignment = UITextAlignmentCenter;
        textfield3.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        textfield3.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textfield3.font = [UIFont systemFontOfSize:18];
        textfield3.placeholder = kLoc(@"required_to_fill");
        _priceTextField = textfield3;
        [_timePriceHeadView addSubview:textfield3];
        
        //添加CELL按钮
        UIButton *_deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.tag = 4;
        [_deleteButton setFrame:CGRectMake(_timePriceHeadView.frame.size.width - 37 - 6, y, 37, 37)];
        [_deleteButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_addButton.png"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(addCellBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_timePriceHeadView addSubview:_deleteButton];
    
        return _timePriceHeadView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.timePriceTabelView)
    {
        return 50;
    }
    
    return 0;
}
#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    _isTextFieldClearButtonClick = YES;
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.weekTextField)
    {
        [self weekPickerCreate:nil];
        return NO;
    }
    else if (textField == _startDateTextField || textField == _endDateTextField)//日期
    {
        if (_isTextFieldClearButtonClick)
        {
            _isTextFieldClearButtonClick = NO;
            return NO;
        }
        [self datePickerCreate:textField];
        return  NO;
    }
    else if (textField == _startTimeTextField || textField == _endTimeTextField)//时间
    {
        if (_isTextFieldClearButtonClick)
        {
            _isTextFieldClearButtonClick = NO;
            return NO;
        }
        [self timePickerCreate:textField];
        return NO;
    }
    else if (textField == _priceTextField)
    {
        [self numberPicker:textField];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag >= 3000)
    {
        [self.basicScrollView setContentOffset:CGPointZero animated:YES];
    }
    
    return YES;
}
#pragma mark NumPickerDelegate

-(void)NumPicker:(NumPicker*)picker didPickedNumber:(NSString*)number
{
    _priceTextField.text = number;
    [_popoverController dismissPopoverAnimated:YES];
}
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case 1://startdate
        {
            //确定
            if (0 == buttonIndex)
            {
                NSString *dateStr = [NSString dateToNSString:_datePicker.date withFormat:kDateFirstFormat];
                
                self.startDateTextField.text = dateStr;
            }
            
            break;
        }
            
        case 2://enddate
        {
            //确定
            if (0 == buttonIndex)
            {
                NSString *dateStr = [NSString dateToNSString:_datePicker.date withFormat:kDateFirstFormat];
                
                self.endDateTextField.text = dateStr;
            }
            
            break;
        }
            
        case 3:// timepicker
        {
            //确定
            if (0 == buttonIndex)
            {
                if (_timePicker.tag == _startTimeTextField.tag)// fromtime
                {
                    _startTimeTextField.text = _timePicker.selectedTimeStr;
                }
                else if (_timePicker.tag == _endTimeTextField.tag)// totime
                {
                    _endTimeTextField.text = _timePicker.selectedTimeStr;
                }
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark WeekdayPickerDelegate
-(void)WeekdayPicker:(WeekdayPicker*)picker didPickedWeekdays:(NSArray*)weekdays
{
    self.weekTextField.text = [self weekdayText:weekdays];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSNumber *temp in weekdays)
    {
        NSString *str = [NSString stringWithFormat:@"%@", temp];
        [array addObject:str];
    }
    
    if (self.promoteActivity == nil)
    {
        self.promoteActivity = [[NSMutableDictionary alloc] init];
    }
    [self.promoteActivity setObject:array forKey:@"weekly"];
    [_popoverController dismissPopoverAnimated:YES];
}


-(void)WeekdayPicker:(WeekdayPicker*)picker didPressedCancelButton:(BOOL)flag
{
    [_popoverController dismissPopoverAnimated:YES];
}

#pragma mark - network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

- (void)uploadPromoteCookbookGroup:(BOOL)animated withDict:(NSDictionary *)dict
{
    if (!_jsonPicker)
    {
        _jsonPicker = [[JsonPicker alloc] init];
    }
    
    _jsonPicker.delegate = self;
    _jsonPicker.tag = 1;
    _jsonPicker.showActivityIndicator = animated;
    _jsonPicker.isShowUpdateAlert = YES;
    
    if (animated)
    {
        _jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
    }
    else
    {
        _jsonPicker.loadingMessage = nil;
    }
    
    _jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] initWithDictionary:dict];
    [_jsonPicker postData:postData withBaseRequest:@"CookbookPromote/savePromoteActivity"];
}

#pragma mark - JsonPickerDelegate
-(void)dismissPopupView
{
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    if (picker.tag==1)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            case 200:
            {
//                [PSAlertView showWithMessage:kLoc(@"submit_succeed")];
                
                if (self.sureBlock)
                {
                    self.sureBlock(nil);
                }
                
                [self dismissPopupView];
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
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error{
}


// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error{
}

@end
