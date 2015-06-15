//
//  RuleSettingViewController.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RulePreorderSettingViewController.h"

#import "NsstringAddOn.h"
#import "DeskPicker.h"
#import "Constants.h"
#import "PSAlertView.h"
#import "NumPicker.h"
#import "WeekdayPicker.h"
#import "OfflineManager.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DetailTextView.h"
#import "CustomTimePicker.h"
#import "PSPopoverBckgroundView.h"
#import "WEPopoverController.h"
#import "MainViewController.h"

typedef enum
{
    kOrderNoticeCellType,
    kGeneralTimeCellType,
    kOpenTimeCellType,
    kCloseTimeCellType
}CustomCellType;

#define kNumberPickerTag 1101

#define kMinLimitDay 1
#define kMaxLimitDay 999

#define kOrderNoticeCellSection 1
#define kGeneralTimeCellSection 2
#define kOpenTimeCellSection 3
#define kCloseTimeCellSection 4
#define kCellHeadBgViewHeight 60
#define kGeneralTimeSetCellHeight 80
#define kOpenTimeSetCellHeight 80
#define kCloseTimeSetCellHeight 80
#define kShowWarnTime 2.0     //显示提示框的时间长
#define kHeadViewTitleColor [UIColor colorWithRed:104.0/255.0 green:145.0/255.0 blue:49.0/255.0 alpha:1.0]


@interface RulePreorderSettingViewController (Private)

- (IBAction)cancelButtonPressed:(UIButton*)sender;
- (IBAction)doneButtonPressed:(UIButton*)sender;
- (IBAction)ruleSwitchClicked:(id)sender;
- (void)getRuleSettingData;

//增加“订座开放通用时间（常规）”项
-(void)addNormalOpenTimeCell;
//删除“订座开放通用时间（常规）”项
-(void)deleteNormalOpenTimeCell:(UIButton*)sender;
//增加“订座开放指定时间”项
-(void)addSpecialOpenTimeCell;
//删除“订座开放指定时间”项
-(void)deleteSpecialOpenTimeCell:(UIButton*)sender;
//增加“订座指定关闭日期”项
-(void)addSpecialCloseTimeCell;
//删除“订座指定关闭日期”项
-(void)deleteSpecialCloseTimeCell:(UIButton*)sender;

@end

@implementation RulePreorderSettingViewController
@synthesize delegate;
@synthesize ruleSettingTableview;
@synthesize quitButton;
@synthesize trueButton;
@synthesize tableBgImageView;
@synthesize popoverController;
@synthesize isShowing;

#pragma mark LIFE CYCLE
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    limitTitlesArray = [[NSMutableArray alloc]init];
    textFieldArray = [[NSMutableArray alloc]initWithCapacity:2];
    WeekdayBtnArray = [[NSMutableArray alloc]initWithCapacity:2];
    DesktextFieldArray = [[NSMutableArray alloc]initWithCapacity:2];
    specailOpenDesktextFieldArray= [[NSMutableArray alloc]initWithCapacity:2];
    [self addNotifications];
    [self addPictureToView];
    [self addLocalizedString];
    
    /* 模拟看内存警告时是否有问题
     [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(didReceiveMemoryWarning) userInfo:nil repeats:YES];
     */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    preorderOpenRangeButton = nil;
    ruleSettingDict = nil;
    limitTitlesArray = nil;
    selectedPickerview = nil;
    selectedDatePicker = nil;
    selectdTimePicker = nil;
    popoverController = nil;
    jsonPicker = nil;
    textFieldArray = nil;
    WeekdayBtnArray = nil;
    DesktextFieldArray = nil;
    specailOpenDesktextFieldArray = nil;
#ifdef DEBUG
    NSLog(@"===RulePreorderSettingViewController,viewDidUnload===");
#endif
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"order_seat_setting") forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
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

-(void)dealloc
{
#ifdef DEBUG
    NSLog(@"===RulePreorderSettingViewController,dealloc===");
#endif
    
    [self removeNotification];
}

#pragma mark -
#pragma mark PUBLIC METHODS
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

-(void)showInView:(UIView*)aView
{
    isShowing = YES;
    isOpenRangeButtonClicked = NO;
    [textFieldArray removeAllObjects];
    [WeekdayBtnArray removeAllObjects];
    [DesktextFieldArray removeAllObjects];
    [specailOpenDesktextFieldArray removeAllObjects];
    [ruleSettingDict removeAllObjects];
    [self.ruleSettingTableview reloadData];
    
    self.view.alpha = 0.0f;
    [aView addSubview:self.view];
    
    [UIView beginAnimations:@"animationID" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationRepeatAutoreverses:NO];
    
    self.view.alpha = 1.0f;
    CGRect aFrame = self.view.frame;
    aFrame.origin.x = 0;
    aFrame.origin.y = kSystemVersionIsIOS7?15:0;
    self.view.frame = aFrame;
    
	[UIView commitAnimations];
    
    [self getRuleSettingData];
}

//跳出本页面
-(void)dismissView
{
    isShowing = NO;
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"order_seats") forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
    
    [self.view removeFromSuperview];
    
    if ([delegate respondsToSelector:@selector(RulePreorderSettingViewController:didDismissView:)])
    {
        [delegate RulePreorderSettingViewController:self didDismissView:YES];
    }
}

#pragma mark PRIVATE METHODS

- (void)addLocalizedString
{
    self.openLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"open_order_seat")];
    [self.trueButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
    [self.quitButton setTitle:kLoc(@"cancel") forState:UIControlStateNormal];
}

- (void)addPictureToView
{
    tableBgImageView.image = [UIImage imageFromMainBundleFile:@"rule_frameBg.png"];
}

//“取消”按钮点击
-(IBAction)cancelButtonPressed:(UIButton*)sender
{
    [self hideKeyboard];
    if (isEdited)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kLoc(@"data_is_not_saved_confirm_to_leave") delegate:self cancelButtonTitle:kLoc(@"cancel") otherButtonTitles:kLoc(@"confirm"), nil];
        alert.tag = 0;
        [alert show];
    }
    else
    {
        [self dismissView];
    }
}

//“保存”按钮点击
-(IBAction)doneButtonPressed:(UIButton*)sender
{
    [self hideKeyboard];
    if (isEdited)
    {
        [self saveRuleSettingData];
    }
    else
    {
        [self dismissView];
    }
}

//”提供订座“开关
- (IBAction)ruleSwitchClicked:(id)sender
{
    isEdited = YES;
    [ruleSettingDict setObject:[NSNumber numberWithBool:self.ruleSwitch.isOn] forKey:@"isOpen"];
    [self updateViewAfterGetData];
}

- (void)updateViewAfterGetData
{
    BOOL openFlag = [[ruleSettingDict objectForKey:@"isOpen"] boolValue];
    [self.ruleSwitch setOn:openFlag];
    //开放通用时间CELL，至少要有一个
    NSArray *generalTimeSet = [ruleSettingDict objectForKey:@"generalTime"];
    if (0 == [generalTimeSet count] && openFlag)
    {
        [self addNormalOpenTimeCell];
    }
    else
    {
        [self.ruleSettingTableview reloadData];
    }
}

//将开放期限的天数转换为X个月（如：30天转为一个月，60天转为两个月）
-(NSString*)openRangeDaysToIndex:(int)days
{
    [limitTitlesArray removeAllObjects];
    [limitTitlesArray addObjectsFromArray:[ruleSettingDict objectForKey:@"timeLimitOptions"]];
    
    NSString *text = nil;
    for (int i=0; i<[limitTitlesArray count]; i++)
    {
        NSDictionary *titles = [limitTitlesArray objectAtIndex:i];
        int value = [[titles objectForKey:@"value"] intValue];
        if (value==days)
        {
            text = [titles objectForKey:@"name"];
            break;
        }
    }
    return text;
}

//weekday的index转换为文字（如：，1对应于周一，6对应于周六,7对应于周日...）
-(NSString*)weekdayText:(NSArray*)week
{
    if (0 == [week count])
    {
        return kLoc(@"required_to_fill");
    }
    NSArray *array = [NSArray arrayWithObjects:kLoc(@"one"), kLoc(@"two"), kLoc(@"three"), kLoc(@"four"), kLoc(@"five"), kLoc(@"six"), kLoc(@"seven"), nil];
    NSMutableString *text = [[NSMutableString alloc] init];
    for (int i=0; i<[week count]; i++)
    {
        int week1 = [[week objectAtIndex:i] intValue]-1;
        [text appendString:[array objectAtIndex:week1]];
        if (i<[week count]-1)
        {
            [text appendString:@"、"];
        }
    }
    return text;
}


// 自定义数字键盘 //modify by liaochunqing
- (void)showNumPicker:(UIButton *)textField title:(NSString *)title
{
    NumPicker *picker = [[NumPicker alloc] init];
    picker.delegate = self;
    picker.pickerType = NumPickerTypeNormal;
    picker.numberText = title;
    picker.tag = kNumberPickerTag;
    picker.minimumNum = kMinLimitDay;
    picker.maximumNum = kMaxLimitDay;
//    picker.dotButton.hidden = YES;
    
    if (nil == popoverController) {
        if (kIsiPhone) {
            popoverController = [[WEPopoverController alloc] initWithContentViewController:picker];
        } else {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        }
    }
    
    if (!kIsiPhone) {
        if (kSystemVersionOfCurrentDevice >= 7.0) {
            // 更改iOS7默认样式
            [(UIPopoverController *)popoverController setPopoverBackgroundViewClass:[PSPopoverBckgroundView class]];
        } else {
            [(UIPopoverController *)popoverController setPopoverBackgroundViewClass:nil];
        }
    }
    
    [popoverController setContentViewController:picker];
    [popoverController setPopoverContentSize:picker.pickerSize];
    
    if (kIsiPhone) {
        MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
        CGRect showRect = [self.ruleSettingTableview convertRect:textField.frame toView:mainCtrl.view];
        [popoverController setParentView:mainCtrl.view];
        [popoverController presentPopoverFromRect:showRect
                                           inView:mainCtrl.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    } else {
        [popoverController presentPopoverFromRect:textField.frame
                                           inView:self.ruleSettingTableview
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    }
}

//"订座开放期限"按钮
-(void)preorderOpenRangeButtonPressed:(UIButton*)sender //modify by liaochunqing
{
#if 1
    NSString *days = nil;
    
    if (ruleSettingDict)
    {
        days = [NSString stringWithFormat:@"%@",[ruleSettingDict objectForKey:@"openTimelimit"]];
    }
    
    // 弹出自定义数字键盘
    [self showNumPicker:sender title:days];
    
#else
    NSString *title = @"";
    UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                  initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
    actionSheet.tag = 0;
    
    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 270, 300)];
    if (kIsiPhone) {
        picker.frame = CGRectMake(0.0, 0.0, actionSheet.bounds.size.width, 300.0);
    }
    picker.tag = 0;
    picker.dataSource = self;
    picker.delegate = self;
    
    
    
    for (int i=0; i<[limitTitlesArray count]; i++) {
        NSDictionary *titles = [limitTitlesArray objectAtIndex:i];
        NSString *text = [titles objectForKey:@"name"];
        if ([text isEqualToString:sender.titleLabel.text]) {
            [picker selectRow:i inComponent:0 animated:NO];
        }
    }
    picker.showsSelectionIndicator = YES;
    [actionSheet addSubview:picker];
    
    UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:sender.frame inView:cell.contentView animated:YES];
    }
    
    
    selectedPickerview = picker;
#endif
}


//设置“订座开放通用时间”的weekday
-(void)generalOpenTimeStartAtWeekday:(UIButton*)sender
{
    /*键盘在时，只收起键盘，不弹出UIPopoverController*/
    if (selectCell)
    {
        [self hideKeyboard];
        return;
    }
    
    NSInteger index = sender.tag - 1000;
    NSArray *generalTimeSet = [ruleSettingDict objectForKey:@"generalTime"];
    NSDictionary *general = [generalTimeSet objectAtIndex:index];
    NSArray *week = [general objectForKey:@"week"];
    
    WeekdayPicker *picker = [[WeekdayPicker alloc] init];
    picker.delegate = self;
    picker.tag = sender.tag;
    [picker updateWeekdays:week];
    
    if (nil == popoverController) {
        if (kIsiPhone) {
            popoverController = [[WEPopoverController alloc] initWithContentViewController:picker];
        } else {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        }
    }
    if (!kIsiPhone) {
        [popoverController setPopoverBackgroundViewClass:nil];
    }
    [popoverController setContentViewController:picker];
    [popoverController setPopoverContentSize:picker.pickerSize];
    UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kGeneralTimeCellSection]];
    
    if (kIsiPhone) {
        MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
        CGRect showRect = [cell.contentView convertRect:sender.frame toView:mainCtrl.view];
        [popoverController setParentView:mainCtrl.view];
        [popoverController presentPopoverFromRect:showRect
                                           inView:mainCtrl.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    } else {
        [popoverController presentPopoverFromRect:sender.frame
                                           inView:cell.contentView
                         permittedArrowDirections:UIPopoverArrowDirectionLeft
                                         animated:YES];
    }
}

#pragma mark customCell

//"订座须知"、“常规开放时间”、“指定开放时间”、“指定关闭日期”的cell
- (UITableViewCell *)getCustomCell:(CustomCellType)type withIndex:(int)index
{
    switch (type)
    {
        case kOrderNoticeCellType:
        {
            static NSString *cellIdentifier = kPreOrderNoticeCellTableViewCellReuseIdentifier;
            OrderNoticeCell *noticeCell = (OrderNoticeCell *)[self.ruleSettingTableview dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (nil == noticeCell)
            {
                noticeCell = [[[NSBundle mainBundle] loadNibNamed:@"OrderNoticeCell" owner:self options:nil] lastObject];
                noticeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            noticeCell.delegate = self;
            noticeCell.tag = index;
            
            //更新数据
            NSArray *noticeArray = [ruleSettingDict objectForKey:@"instruction"];
            [noticeCell reloadDataAfterLoadView:[noticeArray objectAtIndex:index]];
            
            return noticeCell;
        }
        default:
            break;
    }
    return nil;
}

//订座须知、“外卖时间”、“添加图片”、“折扣优惠”的横条
- (UIImageView *)barViewOfCell:(CustomCellType)type
{
    NSString *titleStr1 = nil;
    NSString *titleStr2 = nil;
    SEL addBtnClicked = nil;
    switch (type)
    {
        case kOrderNoticeCellType:
        {
            titleStr1 = kLoc(@"order_seat_notice");
            titleStr2 = @"";
            addBtnClicked = @selector(addOrderNoticeCell);
            
            break;
        }
        default:
            return nil;
    }
    
    UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-2, 0, 810, kCellHeadBgViewHeight)];
    bgImageView.userInteractionEnabled = YES;
    bgImageView.image = [UIImage imageFromMainBundleFile:@"rule_cellHeadBg.png"];
    
    DetailTextView *label = [[DetailTextView alloc]initWithFrame:CGRectMake(10, 15, 300, 30)];
    [label setText:[NSString stringWithFormat:@"%@ ：%@",titleStr1,titleStr2] WithFont:[UIFont boldSystemFontOfSize:20] AndColor:kHeadViewTitleColor];
    [label setKeyWordTextArray:[NSArray arrayWithObjects:titleStr2, nil] WithFont:[UIFont boldSystemFontOfSize:16] AndColor:kHeadViewTitleColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentLeft;
    [bgImageView addSubview:label];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setFrame:CGRectMake(735, 5, 47, 47)];
    [addBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_addButton.png"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:addBtnClicked forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:addBtn];
    
    return bgImageView;
}

- (void)addOrderNoticeCell
{
    NSMutableArray *noticeArray = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"instruction"]];
    //只能添加一个空须知
    for (NSString *instructionStr in noticeArray)
    {
        if ([NSString strIsEmpty:instructionStr])
        {
            return;
        }
    }
    [noticeArray addObject:@""];
    [ruleSettingDict setObject:noticeArray forKey:@"instruction"];
    [self.ruleSettingTableview reloadData];
    [self.ruleSettingTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[noticeArray count] inSection:kOrderNoticeCellSection] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

//增加“常规开放时间”项
-(void)addNormalOpenTimeCell
{
    isEdited = YES;
    NSMutableArray *generalTimeSetArray = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"generalTime"]];
    //只能有一个空的时间条
    for (NSDictionary *normalOpenTimeDict in generalTimeSetArray)
    {
        NSString *startTime = [normalOpenTimeDict objectForKey:@"startTime"];
        NSString *endTime = [normalOpenTimeDict objectForKey:@"endTime"];
        NSArray *weekArray = [normalOpenTimeDict objectForKey:@"week"];
        if ((![weekArray count])||[NSString strIsEmpty:startTime] || [NSString strIsEmpty:endTime])
        {
            return;
        }
    }
    //增加默认项：
    NSMutableDictionary *newCell = [[NSMutableDictionary alloc] init];
    [newCell setObject:[NSNumber numberWithInt:0] forKey:@"generalId"];
    [newCell setObject:[NSArray array] forKey:@"week"];
    [newCell setObject:@"" forKey:@"startTime"];
    [newCell setObject:@"" forKey:@"endTime"];
    [newCell setObject:[NSNumber numberWithInt:20] forKey:@"quantity"];
    [newCell setObject:[NSArray array] forKey:@"diningTable"];
    
    [generalTimeSetArray addObject:newCell];
    [ruleSettingDict setObject:generalTimeSetArray forKey:@"generalTime"];
    [ruleSettingTableview reloadData];
    [ruleSettingTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kGeneralTimeCellSection] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


//删除“订座开放通用时间（常规）”项
-(void)deleteNormalOpenTimeCell:(UIButton*)sender
{
    //订座开放通用时间（常规）必须至少有一项
    NSMutableArray *generalTimeSet = [ruleSettingDict objectForKey:@"generalTime"];
    if ([generalTimeSet count]>1)
    {
        int deleteIndex = sender.tag - 1600;
        NSMutableArray *generalTimeArray = [ruleSettingDict objectForKey:@"generalTime"];
        NSMutableDictionary *generalTimeDict = [generalTimeArray objectAtIndex:deleteIndex];
        NSString *startTimeStr = [generalTimeDict objectForKey:@"startTime"];
        NSString *endTimeStr = [generalTimeDict objectForKey:@"endTime"];
        NSArray *weekArray = [generalTimeDict objectForKey:@"week"];
        
        //没有输入内容时
        if ((0 == [weekArray count]) && (0 == [startTimeStr length]) && (0 == [endTimeStr length]))
        {
            [generalTimeArray removeObjectAtIndex:deleteIndex];
            [ruleSettingDict setObject:generalTimeArray forKey:@"generalTime"];
            [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kGeneralTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kLoc(@"are_you_sure_delete_order_default_time") delegate:self cancelButtonTitle:kLoc(@"cancel") otherButtonTitles:kLoc(@"confirm"), nil];
            alert.tag = sender.tag;
            [alert show];
        }
    }
    else
    {
        [PSAlertView showWithMessage:kLoc(@"order_default_time_describe")];
    }
}

//增加“指定开放时间”项
-(void)addSpecialOpenTimeCell
{
    isEdited = YES;
    NSMutableArray *openTimeSetArray = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"openTime"]];
    //只能有一个空的时间条
    for (NSDictionary *normalOpenTimeDict in openTimeSetArray)
    {
        NSString *startDate = [normalOpenTimeDict objectForKey:@"startDate"];
        NSString *endDate = [normalOpenTimeDict objectForKey:@"endDate"];
        NSString *startTime = [normalOpenTimeDict objectForKey:@"startTime"];
        NSString *endTime = [normalOpenTimeDict objectForKey:@"endTime"];
        if ([NSString strIsEmpty:startDate] || [NSString strIsEmpty:endDate] || [NSString strIsEmpty:startTime] || [NSString strIsEmpty:endTime])
        {
            return;
        }
    }
    //增加默认项：
    NSMutableDictionary *newCell = [[NSMutableDictionary alloc] init];
    [newCell setObject:[NSNumber numberWithInt:0] forKey:@"openId"];
    [newCell setObject:@"" forKey:@"startDate"];
    [newCell setObject:@"" forKey:@"endDate"];
    [newCell setObject:@"" forKey:@"startTime"];
    [newCell setObject:@"" forKey:@"endTime"];
    [newCell setObject:[NSNumber numberWithInt:20] forKey:@"quantity"];
    [newCell setObject:[NSArray array] forKey:@"diningTable"];
    
    [openTimeSetArray addObject:newCell];
    [ruleSettingDict setObject:openTimeSetArray forKey:@"openTime"];
    [ruleSettingTableview reloadData];
    [ruleSettingTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kOpenTimeCellSection] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


//删除“订座开放指定时间”项
-(void)deleteSpecialOpenTimeCell:(UIButton*)sender
{
    int deleteIndex = sender.tag - 2500;
    NSMutableArray *openTimeArray = [ruleSettingDict objectForKey:@"openTime"];
    NSMutableDictionary *openTimeDict = [openTimeArray objectAtIndex:deleteIndex];
    NSString *startTimeStr = [openTimeDict objectForKey:@"startTime"];
    NSString *endTimeStr = [openTimeDict objectForKey:@"endTime"];
    NSString *startDateStr = [openTimeDict objectForKey:@"startDate"];
    NSString *endDateStr = [openTimeDict objectForKey:@"endDate"];
    //没有输入内容时
    if ((0 == [startDateStr length]) && (0 == [endDateStr length]) && (0 == [startTimeStr length]) && (0 == [endTimeStr length]))
    {
        [openTimeArray removeObjectAtIndex:deleteIndex];
        [ruleSettingDict setObject:openTimeArray forKey:@"openTime"];
        
        if ([openTimeArray count]==0)
        {
            [ruleSettingDict setObject:[NSNumber numberWithBool:NO] forKey:@"assignTimeOpenFlag"];
        }
        [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kOpenTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kLoc(@"are_you_sure_delete_order_specified_open_time") delegate:self cancelButtonTitle:kLoc(@"cancel") otherButtonTitles:kLoc(@"confirm"), nil];
        alert.tag = sender.tag;
        [alert show];
    }
}

//增加“指定关闭日期”项
-(void)addSpecialCloseTimeCell
{
    isEdited = YES;
    NSMutableArray *closeTimeSetArray = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"closeTime"]];
    //只能有一个空的时间条
    for (NSDictionary *normalOpenTimeDict in closeTimeSetArray)
    {
        NSString *startDate = [normalOpenTimeDict objectForKey:@"startDate"];
        NSString *endDate = [normalOpenTimeDict objectForKey:@"endDate"];
        if ([NSString strIsEmpty:startDate] || [NSString strIsEmpty:endDate])
        {
            return;
        }
    }
    //增加默认项：
    NSMutableDictionary *newCell = [[NSMutableDictionary alloc] init];
    [newCell setObject:[NSNumber numberWithInt:0] forKey:@"closeId"];
    [newCell setObject:@"" forKey:@"startDate"];
    [newCell setObject:@"" forKey:@"endDate"];
    [closeTimeSetArray addObject:newCell];
    [ruleSettingDict setObject:closeTimeSetArray forKey:@"closeTime"];
    [ruleSettingTableview reloadData];
    [ruleSettingTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kCloseTimeCellSection] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

//删除“订座指定关闭日期”项
-(void)deleteSpecialCloseTimeCell:(UIButton*)sender
{
    int deleteIndex = sender.tag-3200;
    NSMutableArray *closeTimeArray = [ruleSettingDict objectForKey:@"closeTime"];
    NSMutableDictionary *closeTimeDict = [closeTimeArray objectAtIndex:deleteIndex];
    NSString *startDateStr = [closeTimeDict objectForKey:@"startDate"];
    NSString *endDateStr = [closeTimeDict objectForKey:@"endDate"];
    //没有输入内容时
    if ((0 == [startDateStr length]) && (0 == [endDateStr length]))
    {
        [closeTimeArray removeObjectAtIndex:deleteIndex];
        [ruleSettingDict setObject:closeTimeArray forKey:@"closeTime"];
        
        if ([closeTimeArray count]==0)
        {
            [ruleSettingDict setObject:[NSNumber numberWithBool:NO] forKey:@"assignTimeCloseFlag"];
        }
        [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kCloseTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kLoc(@"are_you_sure_delete_order_specified_shutdown_time") delegate:self cancelButtonTitle:kLoc(@"cancel") otherButtonTitles:kLoc(@"confirm"), nil];
        alert.tag = sender.tag;
        [alert show];
        
    }
}

//删除cell
- (void)deleteCustomCell:(int)index withSection:(int)cellSection withKey:(NSString *)keyStr
{
    isEdited = YES;
    NSMutableArray *contentArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:keyStr]];
    int contentCount = [contentArray count];
    if (index < contentCount)
    {
        [contentArray removeObjectAtIndex:index];
        [ruleSettingDict setObject:contentArray forKey:keyStr];
    }
    [self.ruleSettingTableview reloadSections:[NSIndexSet indexSetWithIndex:cellSection] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//修改cell
- (void)modifyCustomCell:(int)index withContent:(id)contentObject withKey:(NSString *)keyStr
{
    isEdited = YES;
    NSMutableArray *contentArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:keyStr]];
    if (index < [contentArray count])
    {
        [contentArray replaceObjectAtIndex:index withObject:contentObject];
        [ruleSettingDict setObject:contentArray forKey:keyStr];
    }
}

/*点击"取消"和"完成"时,先收起键盘*/
- (void)hideKeyboard
{
    OrderNoticeCell * noticeCell = (OrderNoticeCell *)selectCell;
    [noticeCell.noticeTextField resignFirstResponder];
    
}

#pragma mark Notifications

- (void)addNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification*)sender
{
    tableViewContentOffset = ruleSettingTableview.contentOffset;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    selectCell = nil;
    ruleSettingTableview.scrollEnabled = YES;
    [ruleSettingTableview setContentOffset:tableViewContentOffset];
}

#pragma mark network

//获取规则设置信息
-(void)getRuleSettingData
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"fetching_order_seat_setting_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withBaseRequest:@"booking/getsetting"];
}

//保存规则设置信息
-(void)saveRuleSettingData
{
    //是否开放
    int isOpen = [[ruleSettingDict objectForKey:@"isOpen"] integerValue];
    if (1 == isOpen)
    {
        //常规开放时间
        NSMutableArray *generalTimeArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:@"generalTime"]];
        for (int i = 0; i < [generalTimeArray count]; i++)
        {
            NSMutableDictionary *generalTimeDict = [[NSMutableDictionary alloc]initWithDictionary:[generalTimeArray objectAtIndex:i]];
            NSString *startTimeStr = [generalTimeDict objectForKey:@"startTime"];
            NSString *endTimeStr = [generalTimeDict objectForKey:@"endTime"];
            NSArray *weekArray = [generalTimeDict objectForKey:@"week"];
            
//            if ((0 == [startTimeStr length]) || (0 == [endTimeStr length]) || (0 == [weekArray count]))
//            {
//                [PSAlertView showWithMessage:kLoc(@"常规开放时间不能为空", nil)];
//                return;
//            }
            
            if (startTimeStr.length * endTimeStr.length * weekArray.count == 0 && startTimeStr.length + endTimeStr.length + weekArray.count != 0)
            {
                [PSAlertView showWithMessage:kLoc(@"please_enter_default_open_time_full")];
                return;
            }
        }
        //指定开放时间
        NSMutableArray *openTimeArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:@"openTime"]];
        for (int i = 0; i < [openTimeArray count]; i++)
        {
            NSMutableDictionary *openTimeDict = [[NSMutableDictionary alloc]initWithDictionary:[openTimeArray objectAtIndex:i]];
            NSString *startTimeStr = [openTimeDict objectForKey:@"startTime"];
            NSString *endTimeStr = [openTimeDict objectForKey:@"endTime"];
            NSString *startDateStr = [openTimeDict objectForKey:@"startDate"];
            NSString *endDateStr = [openTimeDict objectForKey:@"endDate"];
//            if ((0 == [startTimeStr length]) || (0 == [endTimeStr length]) || (0 == [startDateStr length]) || (0 == [endDateStr length]) )
//            {
//                [PSAlertView showWithMessage:kLoc(@"指定开放时间不能为空", nil)];
//                return;
//            }
            if (startTimeStr.length * endTimeStr.length * startDateStr.length * endDateStr.length == 0 && startTimeStr.length + endTimeStr.length + startDateStr.length + endDateStr.length != 0)
            {
                [PSAlertView showWithMessage:kLoc(@"please_enter_specified_open_time_full")];
                return;
            }
        }
        //指定关闭日期
        NSMutableArray *closeTimeArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:@"closeTime"]];
        for (int i = 0; i < [closeTimeArray count]; i++)
        {
            NSMutableDictionary *closeTimeDict = [[NSMutableDictionary alloc]initWithDictionary:[closeTimeArray objectAtIndex:i]];
            NSString *startDateStr = [closeTimeDict objectForKey:@"startDate"];
            NSString *endDateStr = [closeTimeDict objectForKey:@"endDate"];
//            if ((0 == [startDateStr length]) || (0 == [endDateStr length]) )
//            {
//                [PSAlertView showWithMessage:kLoc(@"指定关闭日期不能为空", nil)];
//                return;
//            }
            if (startDateStr.length * endDateStr.length == 0 && startDateStr.length + endDateStr.length != 0)
            {
                [PSAlertView showWithMessage:kLoc(@"please_enter_specified_shutdown_time_full")];
                return;
            }
        }
    }
    
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 1;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"saving_order_seat_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = kLoc(@"setting_success");
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] initWithDictionary:ruleSettingDict];
//    [postData setObject:ruleSettingDict forKey:@"optionSet"];
    [jsonPicker postData:postData withBaseRequest:@"booking/savesetting"];
}

#pragma mark UITableViewController datasource & delegate 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	tableView.backgroundColor = [UIColor clearColor];
	static NSString *CellIdentifier = @"CellIdentifier";
	UITableViewCell *cell = cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	int row = indexPath.row;
    int section = indexPath.section;
    
    //"订座开放期限"
    if (0 == row && 0 == section)
    {
        //"订座开放期限"
        NSString *text = [NSString stringWithFormat:@"%@ ：",kLoc(@"open_deadline")];
        
        CGSize size = [self accoutLabelWithByfont:text fontofsize:20.0 hight:40];
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, size.width, 40)];
        label1.backgroundColor = [UIColor clearColor];
        label1.textColor = [UIColor blackColor];
        label1.textAlignment = UITextAlignmentRight;
        label1.font = [UIFont systemFontOfSize:20.0];
        label1.text = text;
        [cell.contentView addSubview:label1];
        
        if (preorderOpenRangeButton==nil)
        {
            preorderOpenRangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        }
        [preorderOpenRangeButton setFrame:CGRectMake(120, (75 - 30)/2, 150, 30)];
        preorderOpenRangeButton.titleLabel.font = [UIFont systemFontOfSize:20];
//        preorderOpenRangeButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
        
        if (isOpenRangeButtonClicked == YES)
        {
            [preorderOpenRangeButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_days.png"] forState:UIControlStateNormal];
        }
        else
        {
            [preorderOpenRangeButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_days.png"] forState:UIControlStateNormal];
        }
        
        [preorderOpenRangeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [preorderOpenRangeButton addTarget:self action:@selector(preorderOpenRangeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *days = nil;
        
        if (ruleSettingDict)
        {
            days = [NSString stringWithFormat:@"%@",[ruleSettingDict objectForKey:@"openTimelimit"]];;
        }
        
        [preorderOpenRangeButton setTitle:[NSString stringWithFormat:@"%@",days] forState:UIControlStateNormal];
        [cell.contentView addSubview:preorderOpenRangeButton];
        
        //"天"
        text = kLoc(@"day");
        size = [self accoutLabelWithByfont:text fontofsize:20.0 hight:40];
        UILabel *labelDay = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(preorderOpenRangeButton.frame) + 10, 15, size.width, 40)];
        labelDay.backgroundColor = [UIColor clearColor];
        labelDay.textColor = [UIColor blackColor];
        labelDay.textAlignment = UITextAlignmentRight;
        labelDay.font = [UIFont systemFontOfSize:20.0];
        labelDay.text = text;
        [cell.contentView addSubview:labelDay];
        
        //加上一条横线
        UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 75, 812, 1)];
        lineImageView.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:lineImageView];
    }
    
    if (1 == section)
    {
        if (0 == indexPath.row)
        {
            [cell.contentView addSubview:[self barViewOfCell:kOrderNoticeCellType]];
        }
        else
        {
            //indexPath.row - 1是减去横条
            return [self getCustomCell:kOrderNoticeCellType withIndex:indexPath.row - 1];
        }
    }
    
    //订座开放通用时间（常规）
    if (0 == row && 2 == section)
    {
        NSArray *generalTimeSet = [ruleSettingDict objectForKey:@"generalTime"];
        int generalCount = [generalTimeSet count];
        NSString *generalString = [NSString stringWithFormat:@"( %d )",generalCount];
        
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-2, 0, 810, 60)];
        bgImageView.image = [UIImage imageFromMainBundleFile:@"rule_cellHeadBg.png"];
        [cell.contentView addSubview:bgImageView];
        
        DetailTextView *label = [[DetailTextView alloc]initWithFrame:CGRectMake(10, 15, 300, 30)];
        [label setText:[NSString stringWithFormat:@"%@ ：%@",kLoc(@"general_opening_time"),generalString] WithFont:[UIFont boldSystemFontOfSize:20] AndColor:kHeadViewTitleColor];
        [label setKeyWordTextArray:[NSArray arrayWithObjects:generalString, nil] WithFont:[UIFont boldSystemFontOfSize:16] AndColor:kHeadViewTitleColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentLeft;
        [cell.contentView addSubview:label];
        
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn setFrame:CGRectMake(735, 5, 47, 47)];
        [addBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_addButton.png"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addNormalOpenTimeCell) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:addBtn];
        
        //开放通用时间CELL
        int spaceY = 75;
        int originY = kGeneralTimeSetCellHeight;
        for (int i = 0; i < generalCount; i++)
        {
            NSDictionary *general = [generalTimeSet objectAtIndex:i];
            
            //开放的weekday，如：一;二;三;四;五
            UIButton *startWeekdayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            startWeekdayBtn.tag = 1000+i;
            [startWeekdayBtn setFrame:CGRectMake(20, spaceY+i*originY, 312, 35)];
            [startWeekdayBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_popupButton_long.png"] forState:UIControlStateNormal];
            
            //判断是否点击过
            for (int k = 0; k < [WeekdayBtnArray count]; k++)
            {
                if ( startWeekdayBtn.tag == [[WeekdayBtnArray objectAtIndex:k]integerValue])
                {
                    [startWeekdayBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_popupButtonSelected_long.png"] forState:UIControlStateNormal];
                    break;
                }
            }
            
            //设置startWeekdayBtn的text
            NSArray *week = [general objectForKey:@"week"];
            startWeekdayBtn.titleLabel.font = [UIFont systemFontOfSize:20];
            UIColor *titleColor = (0 == [week count])?[UIColor lightGrayColor]:[UIColor grayColor];
            [startWeekdayBtn setTitleColor:titleColor forState:UIControlStateNormal];
            [startWeekdayBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
            [startWeekdayBtn setTitle:[self weekdayText:week] forState:UIControlStateNormal];
            startWeekdayBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
            [startWeekdayBtn addTarget:self action:@selector(generalOpenTimeStartAtWeekday:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:startWeekdayBtn];
            
            
            //开始的时间，如：11:00
            UITextField *startTimeTextfield = [[UITextField alloc] initWithFrame:CGRectMake(400, spaceY+i*originY, 80, 35)];
            startTimeTextfield.tag = 1100+i;
            startTimeTextfield.delegate = self;
            startTimeTextfield.borderStyle = UITextBorderStyleNone;
            startTimeTextfield.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
            startTimeTextfield.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
            startTimeTextfield.textAlignment = UITextAlignmentCenter;
            startTimeTextfield.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            startTimeTextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            startTimeTextfield.font = [UIFont systemFontOfSize:20];
            startTimeTextfield.placeholder = kLoc(@"required_to_fill");
            startTimeTextfield.clearButtonMode = UITextFieldViewModeAlways;
            startTimeTextfield.text = [general objectForKey:@"startTime"];
            
            //判断是否点击过
            for (int k = 0; k < [textFieldArray count]; k++)
            {
                if ( startTimeTextfield.tag == [[textFieldArray objectAtIndex:k]integerValue])
                {
                    startTimeTextfield.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldSelectedBg.png"];
                    break;
                }
            }
            
            [cell.contentView addSubview:startTimeTextfield];
           
            
            //“至”
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(495, spaceY + i*originY, 30, 30)];
            label2.backgroundColor = [UIColor clearColor];
            label2.textColor = [UIColor blackColor];
            label2.text = kLoc(@"to");
            [cell.contentView addSubview:label2];
            
            
            //结束的时间，如：18:00
            UITextField *endTimeTextfield = [[UITextField alloc] initWithFrame:CGRectMake(525, spaceY+i*originY, 80, 35)];
            endTimeTextfield.tag = 1200+i;
            endTimeTextfield.delegate = self;
            endTimeTextfield.borderStyle = UITextBorderStyleNone;
            endTimeTextfield.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
            endTimeTextfield.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
            endTimeTextfield.textAlignment = UITextAlignmentCenter;
            endTimeTextfield.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            endTimeTextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            endTimeTextfield.font = [UIFont systemFontOfSize:20];
            endTimeTextfield.clearButtonMode = UITextFieldViewModeAlways;
            endTimeTextfield.placeholder = kLoc(@"required_to_fill");
            endTimeTextfield.text = [general objectForKey:@"endTime"];
            
            //判断是否点击过
            for (int k = 0; k < [textFieldArray count]; k++)
            {
                if ( endTimeTextfield.tag == [[textFieldArray objectAtIndex:k]integerValue])
                {
                    endTimeTextfield.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldSelectedBg.png"];
                    break;
                }
            }
            [cell.contentView addSubview:endTimeTextfield];
            
            if (1 < generalCount)
            {
                //删除CELL按钮
                UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                deleteBtn.tag = 1600 + i;
                [deleteBtn setFrame:CGRectMake(740, spaceY + i * originY, 40, 41)];
                [deleteBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_deleteButton.png"] forState:UIControlStateNormal];
                [deleteBtn addTarget:self action:@selector(deleteNormalOpenTimeCell:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:deleteBtn];
            }
            
            //加上一条横线
            if (generalCount > 1 && i != generalCount - 1)
            {
                UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, spaceY + 60 + i * originY, 812, 1)];
                lineImageView.backgroundColor = [UIColor lightGrayColor];
                [cell.contentView addSubview:lineImageView];
            }
        }
    }
    
    //订座指定的开放时间
    if (0 == row && 3 == section)
    {
        NSArray *openTimeSet = [ruleSettingDict objectForKey:@"openTime"];
        int openTimeCount = [openTimeSet count];
        NSString *openTimeString = [NSString stringWithFormat:@"( %d )",openTimeCount];
        
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-2, 0, 810, 60)];
        bgImageView.image = [UIImage imageFromMainBundleFile:@"rule_cellHeadBg.png"];
        [cell.contentView addSubview:bgImageView];
        
        DetailTextView *label = [[DetailTextView alloc]initWithFrame:CGRectMake(10, 15, 200, 30)];
        [label setText:[NSString stringWithFormat:@"%@ ：%@",kLoc(@"specify_opening_time"),openTimeString] WithFont:[UIFont boldSystemFontOfSize:20] AndColor:kHeadViewTitleColor];
        [label setKeyWordTextArray:[NSArray arrayWithObjects:openTimeString, nil] WithFont:[UIFont boldSystemFontOfSize:16] AndColor:kHeadViewTitleColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentLeft;
        [cell.contentView addSubview:label];
        
        //只有存在指定的开放时间CELL时，才显示＋按钮
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn setFrame:CGRectMake(735, 5, 47, 47)];
        [addBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_addButton.png"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addSpecialOpenTimeCell) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:addBtn];
        
        if (openTimeCount > 0)
        {
            //日期
            UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 75, 100, 30)];
            dateLabel.backgroundColor = [UIColor clearColor];
            dateLabel.textColor = [UIColor blackColor];
            dateLabel.text = [NSString stringWithFormat:@"%@ :", kLoc(@"date")];
            [cell.contentView addSubview:dateLabel];
            
            //每天时间段
            UILabel *hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(400, 75, 100, 30)];
            hourLabel.backgroundColor = [UIColor clearColor];
            hourLabel.textColor = [UIColor blackColor];
            hourLabel.text = [NSString stringWithFormat:@"%@ :", kLoc(@"day_period")];
            [cell.contentView addSubview:hourLabel];
        }
        
        //指定开放时间CELL
        int spaceY = 75 + 40;
        int originY = kOpenTimeSetCellHeight;
        for (int i=0; i<openTimeCount; i++)
        {
            NSDictionary *special = [[ruleSettingDict objectForKey:@"openTime"] objectAtIndex:i];
            
            //指定的订座开放日期，如：10月5日
            UITextField *startDatetextfield = [[UITextField alloc] initWithFrame:CGRectMake(20, spaceY+i*originY, 130, 35)];
            startDatetextfield.tag = 2000+i;
            startDatetextfield.delegate = self;
            startDatetextfield.borderStyle = UITextBorderStyleNone;
            startDatetextfield.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
            startDatetextfield.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
            startDatetextfield.textAlignment = UITextAlignmentCenter;
            startDatetextfield.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            startDatetextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            startDatetextfield.font = [UIFont systemFontOfSize:18];
            startDatetextfield.clearButtonMode = UITextFieldViewModeAlways;
            startDatetextfield.placeholder = kLoc(@"required_to_fill");
            NSString *startDateString = [special objectForKey:@"startDate"];
            NSDate *startDate = [startDateString stringToNSDateWithFormat:@"yyyy-MM-dd"];
            startDatetextfield.text = [NSString dateToNSString:startDate withFormat:@"yyyy-MM-dd"];
            
            //判断是否点击过
            for (int k = 0; k < [textFieldArray count]; k++)
            {
                if ( startDatetextfield.tag == [[textFieldArray objectAtIndex:k]integerValue])
                {
                    startDatetextfield.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldSelectedBg.png"];
                    break;
                }
            }
            
            [cell.contentView addSubview:startDatetextfield];
            
            
            //“至”
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(165, spaceY +i*originY, 30, 30)];
            label2.backgroundColor = [UIColor clearColor];
            label2.textColor = [UIColor blackColor];
            label2.text = kLoc(@"to");
            [cell.contentView addSubview:label2];
            
            
            //指定的订座结束日期，如：10月7日
            UITextField *endDatetextfield = [[UITextField alloc] initWithFrame:CGRectMake(200, spaceY+i*originY, 130, 35)];
            endDatetextfield.tag = 2100+i;
            endDatetextfield.delegate = self;
            endDatetextfield.borderStyle = UITextBorderStyleNone;
            endDatetextfield.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
            endDatetextfield.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
            endDatetextfield.textAlignment = UITextAlignmentCenter;
            endDatetextfield.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            endDatetextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            endDatetextfield.font = [UIFont systemFontOfSize:18];
            endDatetextfield.clearButtonMode = UITextFieldViewModeAlways;
            endDatetextfield.placeholder = kLoc(@"required_to_fill");
            NSString *endDateString = [special objectForKey:@"endDate"];
            NSDate *endDate = [endDateString stringToNSDateWithFormat:@"yyyy-MM-dd"];
            endDatetextfield.text = [NSString dateToNSString:endDate withFormat:@"yyyy-MM-dd"];
            
            //判断是否点击过
            for (int k = 0; k < [textFieldArray count]; k++)
            {
                if ( endDatetextfield.tag == [[textFieldArray objectAtIndex:k]integerValue])
                {
                    endDatetextfield.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldSelectedBg.png"];
                    break;
                }
            }
            
            [cell.contentView addSubview:endDatetextfield];
            
            
            //开始的时间，如：11：00
            UITextField *startTimeTextfield = [[UITextField alloc] initWithFrame:CGRectMake(400, spaceY+i*originY, 80, 35)];
            startTimeTextfield.tag = 2200+i;
            startTimeTextfield.delegate = self;
            startTimeTextfield.borderStyle = UITextBorderStyleNone;
            startTimeTextfield.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
            startTimeTextfield.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
            startTimeTextfield.textAlignment = UITextAlignmentCenter;
            startTimeTextfield.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            startTimeTextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            startTimeTextfield.textAlignment = UITextAlignmentCenter;
            startTimeTextfield.font = [UIFont systemFontOfSize:20];
            startTimeTextfield.placeholder = kLoc(@"required_to_fill");
            startTimeTextfield.clearButtonMode = UITextFieldViewModeAlways;
            NSString *startTimeString = [special objectForKey:@"startTime"];
            NSDate *startTime = [startTimeString stringToNSDateWithFormat:@"HH:mm"];
            startTimeTextfield.text = [NSString dateToNSString:startTime withFormat:@"HH:mm"];
            
            //判断是否点击过
            for (int k = 0; k < [textFieldArray count]; k++)
            {
                if ( startTimeTextfield.tag == [[textFieldArray objectAtIndex:k]integerValue])
                {
                    startTimeTextfield.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldSelectedBg.png"];
                    break;
                }
            }
            
            [cell.contentView addSubview:startTimeTextfield];
            
            //“至”
            UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(495, spaceY +i*originY, 30, 30)];
            label3.backgroundColor = [UIColor clearColor];
            label3.textColor = [UIColor blackColor];
            label3.text = kLoc(@"to");
            [cell.contentView addSubview:label3];
            
            
            //结束的时间，如：18：00
            UITextField *endTimeTextfield = [[UITextField alloc] initWithFrame:CGRectMake(525, spaceY+i*originY, 80, 35)];
            endTimeTextfield.tag = 2300+i;
            endTimeTextfield.delegate = self;
            endTimeTextfield.borderStyle = UITextBorderStyleNone;
            endTimeTextfield.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
            endTimeTextfield.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
            endTimeTextfield.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            endTimeTextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            endTimeTextfield.textAlignment = UITextAlignmentCenter;
            endTimeTextfield.font = [UIFont systemFontOfSize:20];
            endTimeTextfield.placeholder = kLoc(@"required_to_fill");
            endTimeTextfield.clearButtonMode = UITextFieldViewModeAlways;
            NSString *endTimeString = [special objectForKey:@"endTime"];
            NSDate *endTime = [endTimeString stringToNSDateWithFormat:@"HH:mm"];
            endTimeTextfield.text = [NSString dateToNSString:endTime withFormat:@"HH:mm"];
            
            //判断是否点击过
            for (int k = 0; k < [textFieldArray count]; k++)
            {
                if ( endTimeTextfield.tag == [[textFieldArray objectAtIndex:k]integerValue])
                {
                    endTimeTextfield.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldSelectedBg.png"];
                    break;
                }
            }
            [cell.contentView addSubview:endTimeTextfield];
            
            //删除CELL按钮
            UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteBtn.tag = 2500 + i;
            [deleteBtn setFrame:CGRectMake(740, spaceY + i * originY, 40, 41)];
            [deleteBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_deleteButton.png"] forState:UIControlStateNormal];
            [deleteBtn addTarget:self action:@selector(deleteSpecialOpenTimeCell:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:deleteBtn];
            
            //加上一条横线
            if (openTimeCount > 1 && i != openTimeCount - 1)
            {
                UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, spaceY + 60 + i * originY, 812, 1)];
                lineImageView.backgroundColor = [UIColor lightGrayColor];
                [cell.contentView addSubview:lineImageView];
            }
        }
    }
    
    //订座关闭指定时间
    if (0 == row && 4 == section)
    {
         NSArray *closeTimeSet = [ruleSettingDict objectForKey:@"closeTime"];
        int closeTimeCount = [closeTimeSet count];
        NSString *closeTimeString = [NSString stringWithFormat:@"( %d )",closeTimeCount];
        
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-2, 0, 810, 60)];
        bgImageView.image = [UIImage imageFromMainBundleFile:@"rule_cellHeadBg.png"];
        [cell.contentView addSubview:bgImageView];
        
        DetailTextView *label = [[DetailTextView alloc]initWithFrame:CGRectMake(10, 15, 200, 30)];
        [label setText:[NSString stringWithFormat:@"%@ ：%@",kLoc(@"specify_close_date"),closeTimeString] WithFont:[UIFont boldSystemFontOfSize:20] AndColor:kHeadViewTitleColor];
        [label setKeyWordTextArray:[NSArray arrayWithObjects:closeTimeString, nil] WithFont:[UIFont boldSystemFontOfSize:16] AndColor:kHeadViewTitleColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentLeft;
        [cell.contentView addSubview:label];
        
        //只有存在指定的关闭时间CELL时，才显示＋按钮
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn setFrame:CGRectMake(735, 5, 47, 47)];
        [addBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_addButton.png"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addSpecialCloseTimeCell) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:addBtn];
        
        
        //订座关闭指定时间CELL
        int spaceY = kCloseTimeSetCellHeight;
        for (int i = 0; i < closeTimeCount ; i++)
        {
            NSDictionary *special = [[ruleSettingDict objectForKey:@"closeTime"] objectAtIndex:i];
            
            //订座关闭指定时间的开始时间
            UITextField *textfield1 = [[UITextField alloc] initWithFrame:CGRectMake(20, spaceY+i*80, 150, 35)];
            textfield1.tag = 3000+i;
            textfield1.delegate = self;
            textfield1.borderStyle = UITextBorderStyleNone;
            textfield1.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
            textfield1.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
            textfield1.textAlignment = UITextAlignmentCenter;
            textfield1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            textfield1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textfield1.font = [UIFont systemFontOfSize:18];
            textfield1.clearButtonMode = UITextFieldViewModeAlways;
            textfield1.placeholder = kLoc(@"required_to_fill");
            //
            NSString *date1String = [special objectForKey:@"startDate"];
            NSDate *date1 = [date1String stringToNSDateWithFormat:@"yyyy-MM-dd"];
            textfield1.text = [NSString dateToNSString:date1 withFormat:@"yyyy-MM-dd"];
            
            //判断是否点击过
            for (int k = 0; k < [textFieldArray count]; k++)
            {
                if ( textfield1.tag == [[textFieldArray objectAtIndex:k]integerValue])
                {
                    textfield1.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldSelectedBg.png"];
                    break;
                }
            }
            
            [cell.contentView addSubview:textfield1];
            
            
            //“至”
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(190, spaceY + i*80, 30, 30)];
            label1.backgroundColor = [UIColor clearColor];
            label1.textColor = [UIColor blackColor];
            label1.text = kLoc(@"to");
            [cell.contentView addSubview:label1];
            
            
            //订座关闭指定时间的结束时间
            UITextField *textfield2 = [[UITextField alloc] initWithFrame:CGRectMake(225, spaceY+i*80, 150, 35)];
            textfield2.tag = 3100+i;
            textfield2.delegate = self;
            textfield2.borderStyle = UITextBorderStyleNone;
            textfield2.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
            textfield2.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
            textfield2.textAlignment = UITextAlignmentCenter;
            textfield2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            textfield2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textfield2.font = [UIFont systemFontOfSize:18];
            textfield2.clearButtonMode = UITextFieldViewModeAlways;
            textfield2.placeholder = kLoc(@"required_to_fill");
            //
            NSString *date2String = [special objectForKey:@"endDate"];
            NSDate *date2 = [date2String stringToNSDateWithFormat:@"yyyy-MM-dd"];
            textfield2.text = [NSString dateToNSString:date2 withFormat:@"yyyy-MM-dd"];
            
            //判断是否点击过
            for (int k = 0; k < [textFieldArray count]; k++)
            {
                if ( textfield2.tag == [[textFieldArray objectAtIndex:k]integerValue])
                {
                    textfield2.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldSelectedBg.png"];
                    break;
                }
            }
            
            [cell.contentView addSubview:textfield2];
            
            //删除CELL按钮
            UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteBtn.tag = 3200 + i;
            [deleteBtn setFrame:CGRectMake(740, spaceY+i*80, 40, 41)];
            [deleteBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_deleteButton.png"] forState:UIControlStateNormal];
            [deleteBtn addTarget:self action:@selector(deleteSpecialCloseTimeCell:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:deleteBtn];
            
            //加上一条横线
            if (closeTimeCount > 1 && i != closeTimeCount - 1)
            {
                UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, spaceY + 55 + i * 80, 810, 1)];
                lineImageView.backgroundColor = [UIColor lightGrayColor];
                [cell.contentView addSubview:lineImageView];
            }
        }

    }
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    if ([[ruleSettingDict objectForKey:@"isOpen"] boolValue])
    {
        switch (section)
        {
            case 0:
            {
                rows = 1;
                
                break;
            }
            case 1:
            {
                NSArray *noticeArray = [ruleSettingDict objectForKey:@"instruction"];
                //横条 + 须知设置
                rows = 1 + [noticeArray count];
                
                break;
            }
            case 2:
            {
                rows = 1;
                
                break;
            }
            case 3:
            {
                rows = 1;
                
                break;
            }
            case 4:
            {
                rows = 1;
                
                break;
            }
            default:
                break;
        }
    }
	return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0;
    switch (indexPath.section)
    {
        case 0:
        {
            height = 75;
            break;
        }
        //订座须知
        case 1:
        {
            height = 75;
             
            break;
        }
        //“订座的通用开放时间（常规）”
        case 2:
        {
            if (0 != [[ruleSettingDict objectForKey:@"generalTime"] count])
            {
                height = 45 + kGeneralTimeSetCellHeight * [[ruleSettingDict objectForKey:@"generalTime"] count];
            }
            else
            {
                height = kCellHeadBgViewHeight;
            }
            
            break;
        }
        //订座的指订开放时间
        case 3:
        {
            if (0 != [[ruleSettingDict objectForKey:@"openTime"] count])
            {
                /*背景 + 时间/日期标题 + 时间/日期内容*/
                height = 45 + 40 + kOpenTimeSetCellHeight * [[ruleSettingDict objectForKey:@"openTime"] count];
            }
            else
            {
                height = kCellHeadBgViewHeight;
            }
            break;
        }
        //订座指订关闭时间
        case 4:
        {
            if (0 != [[ruleSettingDict objectForKey:@"closeTime"] count])
            {
                height = 60+kCloseTimeSetCellHeight*[[ruleSettingDict objectForKey:@"closeTime"] count];
            }
            else
            {
                height = kCellHeadBgViewHeight;
            }
            break;
        }
    }
	return height;
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //是否要添加到数组的标记
    BOOL shouldAdd = YES;
    if ([textFieldArray count] == 0)
    {
        [textFieldArray addObject:[NSNumber numberWithInt:actionSheet.tag]];
    }
    else
    {
        for (int i = 0; i < [textFieldArray count]; i++)
        {
            if ([[textFieldArray objectAtIndex:i]integerValue] == actionSheet.tag)
            {
                shouldAdd = NO;
                break;
            }
        }
        if (shouldAdd == YES)
        {
            [textFieldArray addObject:[NSNumber numberWithInt:actionSheet.tag]];
        }
    }
    
    if (buttonIndex==0)
    {
        //标记规则己修改过
        isEdited = YES;
    }
    
    int tag = actionSheet.tag;
    //"订座开放期限"按钮
    if (tag==0)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                isOpenRangeButtonClicked = YES;
                int index = [selectedPickerview selectedRowInComponent:0];
                NSDictionary *titles = [limitTitlesArray objectAtIndex:index];
                NSString *text = [titles objectForKey:@"name"];
                [preorderOpenRangeButton setTitle:text forState:UIControlStateNormal];
                
                NSString *limit = [titles objectForKey:@"value"];
                [ruleSettingDict setObject:[NSNumber numberWithFloat:[limit floatValue]] forKey:@"openTimelimit"];
                
                //更新
                [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
                break;
            }
        }
        
    }
    
    //设置“订座开放通用时间”的开始weekday
    if (tag>=1000 && tag<1100) {
        switch (buttonIndex) {
            case 0:{
                int index = actionSheet.tag-1000;
                //修改该值
                NSMutableArray *generalTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"generalTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[generalTimeSet objectAtIndex:index]];
                [newCell setObject:[NSNumber numberWithInt:[selectedPickerview selectedRowInComponent:0]+1] forKey:@"week1"];
                [generalTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:generalTimeSet forKey:@"generalTime"];
                
                //更新Textfield
                [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kGeneralTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
        }
    }
    
    //设置“常规开放时间”的开始时间
    if (tag>=1100 && tag<1200)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                int index = actionSheet.tag-1100;
                //修改该值
                NSMutableArray *generalTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"generalTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[generalTimeSet objectAtIndex:index]];
                [newCell setObject:selectdTimePicker.selectedTimeStr forKey:@"startTime"];
                NSString *endTime = [newCell objectForKey:@"endTime"];
                NSComparisonResult result = [selectdTimePicker.selectedTimeStr compare:endTime];
                if (result >= NSOrderedSame && ![NSString strIsEmpty:endTime])
                {
                    [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                    
                    return;
                }
                [generalTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:generalTimeSet forKey:@"generalTime"];

                //更新Textfield
                [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kGeneralTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
                
                break;
            }
        }
    }
    
    
    //设置“常规开放时间”的结束时间
    if (tag>=1200 && tag<1300)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                int index = actionSheet.tag-1200;
                //修改该值
                NSMutableArray *generalTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"generalTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[generalTimeSet objectAtIndex:index]];
                [newCell setObject:selectdTimePicker.selectedTimeStr forKey:@"endTime"];
                NSString *startTime = [newCell objectForKey:@"startTime"];
                NSComparisonResult result = [startTime compare:selectdTimePicker.selectedTimeStr];
                if (result >= NSOrderedSame && ![NSString strIsEmpty:startTime])
                {
                    [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                    
                    return;
                }
                [generalTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:generalTimeSet forKey:@"generalTime"];
                
                //更新Textfield
                [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kGeneralTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
        }
    }
    
    
    //设置“订座指定开放时间”的订座开始日期，如：10月5日
    if (tag>=2000 && tag<2100) {
        switch (buttonIndex) {
            case 0:{
                int index = actionSheet.tag-2000;
                //修改该值
                NSMutableArray *generalTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"openTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[generalTimeSet objectAtIndex:index]];
                NSString *startDate = [NSString dateToNSString:selectedDatePicker.date withFormat:@"yyyy-MM-dd"];
                [newCell setObject:startDate forKey:@"startDate"];
                NSString *endDate = [newCell objectForKey:@"endDate"];
                NSComparisonResult result = [startDate compare:endDate];
                if (result >= NSOrderedSame && ![NSString strIsEmpty:endDate])
                {
                    [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                    
                    return;
                }
                [generalTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:generalTimeSet forKey:@"openTime"];
                
                //更新Textfield
                [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kOpenTimeCellSection]] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
    
    //设置“订座开放指定时间”的结束日期
    if (tag>=2100 && tag<2200) {
        switch (buttonIndex) {
            case 0:{
                int index = actionSheet.tag-2100;
                //修改该值
                NSMutableArray *generalTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"openTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[generalTimeSet objectAtIndex:index]];
                NSString *endDate = [NSString dateToNSString:selectedDatePicker.date withFormat:@"yyyy-MM-dd"];
                [newCell setObject:endDate forKey:@"endDate"];
                NSString *startDate = [newCell objectForKey:@"startDate"];
                [newCell setObject:startDate forKey:@"startDate"];
                NSComparisonResult result = [startDate compare:endDate];
                if (result > NSOrderedSame && ![NSString strIsEmpty:startDate])
                {
                    [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                    
                    return;
                }
                [generalTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:generalTimeSet forKey:@"openTime"];
                
                //更新Textfield
                [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:kOpenTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
        }
    }
    
    
    //设置“订座开放指定时间”的开始时间
    if (tag>=2200 && tag<2300) {
        switch (buttonIndex) {
            case 0:{
                int index = actionSheet.tag-2200;
                //修改该值
                NSMutableArray *openTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"openTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[openTimeSet objectAtIndex:index]];
                [newCell setObject:selectdTimePicker.selectedTimeStr forKey:@"startTime"];
                NSString *endTime = [newCell objectForKey:@"endTime"];
                NSComparisonResult result = [selectdTimePicker.selectedTimeStr compare:endTime];
                if (result >= NSOrderedSame && ![NSString strIsEmpty:endTime])
                {
                    [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                    
                    return;
                }
                [openTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:openTimeSet forKey:@"openTime"];
                
                //更新Textfield
                [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kOpenTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
        }
    }
    
    //设置“订座开放指定时间”的结束时间
    if (tag>=2300 && tag<2400) {
        switch (buttonIndex) {
            case 0:{
                int index = actionSheet.tag-2300;
                //修改该值
                NSMutableArray *openTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"openTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[openTimeSet objectAtIndex:index]];
                [newCell setObject:selectdTimePicker.selectedTimeStr forKey:@"endTime"];
                NSString *startTime = [newCell objectForKey:@"startTime"];
                NSComparisonResult result = [startTime compare:selectdTimePicker.selectedTimeStr];
                if (result >= NSOrderedSame && ![NSString strIsEmpty:startTime])
                {
                    [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                    
                    return;
                }
                [openTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:openTimeSet forKey:@"openTime"];
                
                //更新Textfield
                [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kOpenTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
        }
    }
    
    
    //设置“订座的指定关闭日期”的开始Date
    if (tag>=3000 && tag<3100) {
        switch (buttonIndex) {
            case 0:{
                int index = actionSheet.tag-3000;
                //修改该值
                NSMutableArray *closeTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"closeTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[closeTimeSet objectAtIndex:index]];
                
                NSString *date1 = [NSString dateToNSString:selectedDatePicker.date withFormat:@"yyyy-MM-dd"];
                [newCell setObject:date1 forKey:@"startDate"];
                NSString *endDateStr = [newCell objectForKey:@"endDate"];
                NSComparisonResult result = [date1 compare:endDateStr];
                if (result > NSOrderedSame && ![NSString strIsEmpty:endDateStr])
                {
                    [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                    
                    return;
                }
                [closeTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:closeTimeSet forKey:@"closeTime"];
                
                //更新Textfield
                [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kCloseTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
        }
    }
    
    
    //设置“订座开放通用时间”的结束Date
    if (tag>=3100 && tag<3200) {
        switch (buttonIndex) {
            case 0:{
                int index = actionSheet.tag-3100;
                //修改该值
                NSMutableArray *closeTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"closeTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[closeTimeSet objectAtIndex:index]];
                
                NSString *date2 = [NSString dateToNSString:selectedDatePicker.date withFormat:@"yyyy-MM-dd"];
                [newCell setObject:date2 forKey:@"endDate"];
                NSString *startDateStr = [newCell objectForKey:@"startDate"];
                NSComparisonResult result = [startDateStr compare:date2];
                if (result > NSOrderedSame && ![NSString strIsEmpty:startDateStr])
                {
                    [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                    
                    return;
                }
                [closeTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:closeTimeSet forKey:@"closeTime"];
                
                //更新Textfield
                [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kCloseTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
        }
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int tag = alertView.tag;
    //提示用户是否退出
    if (tag==0)
    {
        if (buttonIndex==1)
        {
            [self dismissView];
            return;
        }
    }
    
    //标记规则己修改过
    isEdited = YES;
    //删除“订座开放通用时间（常规）”项
    if (tag>=1600 && tag<1700)
    {
        if (buttonIndex==1)
        {
            //订座开放通用时间（常规）必须至少有一项
            NSMutableArray *generalTimeSet = [ruleSettingDict objectForKey:@"generalTime"];
            int deleteIndex = tag-1600;
            
            [generalTimeSet removeObjectAtIndex:deleteIndex];
            [ruleSettingDict setObject:generalTimeSet forKey:@"generalTime"];
            
            //UItextField Tag删除和替换，开始和结束时间必须分开处理
            //开始时间,
            for (int i = 0; i < [textFieldArray count]; i ++)
            {
                if ([[textFieldArray objectAtIndex:i]integerValue]==deleteIndex + 1100)
                {
                    [textFieldArray removeObject:[NSNumber numberWithInt:(deleteIndex + 1100)]];
                    break;
                }
            }
            //结束时间
            for (int i = 0; i < [textFieldArray count]; i ++)
            {
                if ([[textFieldArray objectAtIndex:i]integerValue]==deleteIndex + 1200)
                {
                    [textFieldArray removeObject:[NSNumber numberWithInt:(deleteIndex + 1200)]];
                    break;
                }
            }
            
            for (int k = 0; k < [textFieldArray count]; k ++)
            {
                int oldTag = [[textFieldArray objectAtIndex:k]integerValue];
                if ((deleteIndex + 1100) < oldTag && oldTag < 1200)
                {
                    [textFieldArray replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:(oldTag - 1)]];
                }
                if ((deleteIndex + 1200) < oldTag && oldTag < 1300)
                {
                    [textFieldArray replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:(oldTag - 1)]];
                }
            }
            
            //Button Tag删除和替换
            for (int i = 0; i < [WeekdayBtnArray count]; i ++)
            {
                if ([[WeekdayBtnArray objectAtIndex:i]integerValue]==deleteIndex + 1000)
                {
                    [WeekdayBtnArray removeObject:[NSNumber numberWithInt:(deleteIndex + 1000)]];
                    break;
                }
                
            }
        
            for (int k = 0; k < [WeekdayBtnArray count]; k ++)
            {
                int oldTag = [[WeekdayBtnArray objectAtIndex:k]integerValue];
                if ((deleteIndex + 1000) < oldTag)
                {
                    [WeekdayBtnArray replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:(oldTag - 1)]];
                }
            }
            
            //DesktextField Tag删除和替换
            for (int i = 0; i < [DesktextFieldArray count]; i ++)
            {
                if ([[DesktextFieldArray objectAtIndex:i]integerValue]==deleteIndex + 1500)
                {
                    [DesktextFieldArray removeObject:[NSNumber numberWithInt:(deleteIndex + 1500)]];
                    break;
                }
                
            }
            
            for (int k = 0; k < [DesktextFieldArray count]; k ++)
            {
                int oldTag = [[DesktextFieldArray objectAtIndex:k]integerValue];
                if ((deleteIndex + 1500) < oldTag)
                {
                    [DesktextFieldArray replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:(oldTag - 1)]];
                }
            }
        
            [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kGeneralTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    //删除“订座开放指定时间”项
    if (tag>=2500 && tag<2600)
    {
        if (buttonIndex==1)
        {
            int deleteIndex = tag-2500;
            NSMutableArray *openTimeSet = [ruleSettingDict objectForKey:@"openTime"];
            [openTimeSet removeObjectAtIndex:deleteIndex];
            [ruleSettingDict setObject:openTimeSet forKey:@"openTime"];
            
            if ([openTimeSet count]==0)
            {
                
                [ruleSettingDict setObject:[NSNumber numberWithBool:NO] forKey:@"assignTimeOpenFlag"];
            }
            
            //UItextField Tag删除和替换，开始和结束时间必须分开处理
            //开始日期,
            for (int i = 0; i < [textFieldArray count]; i ++)
            {
                if ([[textFieldArray objectAtIndex:i]integerValue]==deleteIndex + 2000)
                {
                    [textFieldArray removeObject:[NSNumber numberWithInt:(deleteIndex + 2000)]];
                    break;
                }
            }
            //结束日期
            for (int i = 0; i < [textFieldArray count]; i ++)
            {
                if ([[textFieldArray objectAtIndex:i]integerValue]==deleteIndex + 2100)
                {
                    [textFieldArray removeObject:[NSNumber numberWithInt:(deleteIndex + 2100)]];
                    break;
                }
            }
            
            //开始时间
            for (int i = 0; i < [textFieldArray count]; i ++)
            {
                if ([[textFieldArray objectAtIndex:i]integerValue]==deleteIndex + 2200)
                {
                    [textFieldArray removeObject:[NSNumber numberWithInt:(deleteIndex + 2200)]];
                    break;
                }
            }
            //结束时间
            for (int i = 0; i < [textFieldArray count]; i ++)
            {
                if ([[textFieldArray objectAtIndex:i]integerValue]==deleteIndex + 2300)
                {
                    [textFieldArray removeObject:[NSNumber numberWithInt:(deleteIndex + 2300)]];
                    break;
                }
            }
            
            for (int k = 0; k < [textFieldArray count]; k ++)
            {
                int oldTag = [[textFieldArray objectAtIndex:k]integerValue];
                if ((deleteIndex + 2000) < oldTag && oldTag < 2100)
                {
                    [textFieldArray replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:(oldTag - 1)]];
                }
                if ((deleteIndex + 2100) < oldTag && oldTag < 2200)
                {
                    [textFieldArray replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:(oldTag - 1)]];
                }
                if ((deleteIndex + 2200) < oldTag && oldTag < 2300)
                {
                    [textFieldArray replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:(oldTag - 1)]];
                }
                if ((deleteIndex + 2300) < oldTag && oldTag < 2400)
                {
                    [textFieldArray replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:(oldTag - 1)]];
                }
            }
            
            //specailOpenDesktextField Tag删除和替换
            for (int i = 0; i < [specailOpenDesktextFieldArray count]; i ++)
            {
                if ([[specailOpenDesktextFieldArray objectAtIndex:i]integerValue]==deleteIndex + 2400)
                {
                    [specailOpenDesktextFieldArray removeObject:[NSNumber numberWithInt:(deleteIndex + 2400)]];
                    break;
                }
                
            }
            
            for (int k = 0; k < [specailOpenDesktextFieldArray count]; k ++)
            {
                int oldTag = [[specailOpenDesktextFieldArray objectAtIndex:k]integerValue];
                if ((deleteIndex + 2400) < oldTag)
                {
                    [specailOpenDesktextFieldArray replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:(oldTag - 1)]];
                }
            }
            
            [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kOpenTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    //删除“订座指定关闭日期”项
    if (tag>=3200 && tag<3300)
    {
        if (buttonIndex==1)
        {
            int deleteIndex = tag-3200;
            NSMutableArray *closeTimeSet = [ruleSettingDict objectForKey:@"closeTime"];
            [closeTimeSet removeObjectAtIndex:deleteIndex];
            [ruleSettingDict setObject:closeTimeSet forKey:@"closeTime"];
            
            if ([closeTimeSet count]==0)
            {
                
                [ruleSettingDict setObject:[NSNumber numberWithBool:NO] forKey:@"assignTimeCloseFlag"];
            }
            
            //UItextField Tag删除和替换，开始和结束时间必须分开处理
            //开始日期,
            for (int i = 0; i < [textFieldArray count]; i ++)
            {
                if ([[textFieldArray objectAtIndex:i]integerValue]==deleteIndex + 3000)
                {
                    [textFieldArray removeObject:[NSNumber numberWithInt:(deleteIndex + 3000)]];
                    break;
                }
            }
            //结束日期
            for (int i = 0; i < [textFieldArray count]; i ++)
            {
                if ([[textFieldArray objectAtIndex:i]integerValue]==deleteIndex + 3100)
                {
                    [textFieldArray removeObject:[NSNumber numberWithInt:(deleteIndex + 3100)]];
                    break;
                }
            }
            
            
            for (int k = 0; k < [textFieldArray count]; k ++)
            {
                int oldTag = [[textFieldArray objectAtIndex:k]integerValue];
                if ((deleteIndex + 3000) < oldTag && oldTag < 3100)
                {
                    [textFieldArray replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:(oldTag - 1)]];
                }
                if ((deleteIndex + 3100) < oldTag && oldTag < 3200)
                {
                    [textFieldArray replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:(oldTag - 1)]];
                }
                
            }
            [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kCloseTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    _isTextFieldClearButtonClick = YES;
    isEdited = YES;
    
    //设置“常规开放时间”的开始时间
    if (textField.tag>=1100 && textField.tag<1200)
    {
        int index = textField.tag-1100;
        //修改该值
        NSMutableArray *generalTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"generalTime"]];
        NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[generalTimeSet objectAtIndex:index]];
        [newCell setObject:@"" forKey:@"startTime"];
        
        [generalTimeSet replaceObjectAtIndex:index withObject:newCell];
        [ruleSettingDict setObject:generalTimeSet forKey:@"generalTime"];
    }
    else if (textField.tag>=1200 && textField.tag<1300)//设置“常规开放时间”的结束时间
    {
        int index = textField.tag-1200;
        //修改该值
        NSMutableArray *generalTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"generalTime"]];
        NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[generalTimeSet objectAtIndex:index]];
        [newCell setObject:@"" forKey:@"endTime"];
        
        [generalTimeSet replaceObjectAtIndex:index withObject:newCell];
        [ruleSettingDict setObject:generalTimeSet forKey:@"generalTime"];
    }
    //设置“订座指定开放时间”的订座开始日期，如：10月5日
    else if (textField.tag>=2000 && textField.tag<2100)
    {
        int index = textField.tag-2000;
        //修改该值
        NSMutableArray *generalTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"openTime"]];
        NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[generalTimeSet objectAtIndex:index]];
        
        [newCell setObject:@"" forKey:@"startDate"];
        [generalTimeSet replaceObjectAtIndex:index withObject:newCell];
        [ruleSettingDict setObject:generalTimeSet forKey:@"openTime"];
        

    }
    //设置“订座开放指定时间”的结束日期
    else if (textField.tag>=2100 && textField.tag<2200)
    {
        int index = textField.tag-2100;
        //修改该值
        NSMutableArray *generalTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"openTime"]];
        NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[generalTimeSet objectAtIndex:index]];
        [newCell setObject:@"" forKey:@"endDate"];
        [generalTimeSet replaceObjectAtIndex:index withObject:newCell];
        [ruleSettingDict setObject:generalTimeSet forKey:@"openTime"];
    }
    //设置“订座开放指定时间”的开始时间
    else if (textField.tag>=2200 && textField.tag<2300)
    {
                int index = textField.tag-2200;
                //修改该值
                NSMutableArray *openTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"openTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[openTimeSet objectAtIndex:index]];
                [newCell setObject:@"" forKey:@"startTime"];
                [openTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:openTimeSet forKey:@"openTime"];
    }
    
    //设置“订座开放指定时间”的结束时间
    else if (textField.tag>=2300 && textField.tag<2400)
    {
                int index = textField.tag-2300;
                //修改该值
                NSMutableArray *openTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"openTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[openTimeSet objectAtIndex:index]];
                [newCell setObject:@"" forKey:@"endTime"];
                [openTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:openTimeSet forKey:@"openTime"];

    }
    //设置“订座的指定关闭日期”的开始Date
    else if (textField.tag>=3000 && textField.tag<3100)
    {
                int index = textField.tag-3000;
                //修改该值
                NSMutableArray *closeTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"closeTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[closeTimeSet objectAtIndex:index]];
                
                [newCell setObject:@"" forKey:@"startDate"];
                [closeTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:closeTimeSet forKey:@"closeTime"];

    }
    
    
    //设置“订座开放通用时间”的结束Date
    if (textField.tag>=3100 && textField.tag<3200)
    {
                int index = textField.tag-3100;
                //修改该值
                NSMutableArray *closeTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"closeTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[closeTimeSet objectAtIndex:index]];

                [newCell setObject:@"" forKey:@"endDate"];
                [closeTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:closeTimeSet forKey:@"closeTime"];

    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    /*键盘在时，只收起键盘，不弹出UIActionSheet*/
    if (selectCell)
    {
        [self hideKeyboard];
        return NO;
    }
    
    
    int tag = textField.tag;
    //设置“订座开放通用时间”的开始时间，如：18:00
    if (tag>=1100 && tag<1200) {
        if (_isTextFieldClearButtonClick)
        {
            _isTextFieldClearButtonClick = NO;
            return NO;
        }
        
        NSString *title = @"";
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
        actionSheet.tag = tag;
        
        
        int index = tag-1100;
        NSString *time1 = [[[ruleSettingDict objectForKey:@"generalTime"] objectAtIndex:index] objectForKey:@"startTime"];
        //时间选择器
        CustomTimePicker *timePicker = [[CustomTimePicker alloc]initWithLastTimeString:time1];
        if (kIsiPhone) {
            timePicker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
        } else {
            timePicker.frame = CGRectMake(-25.0, 0.0, 320.0, 216.0);
        }
        timePicker.backgroundColor = [UIColor clearColor];
        selectdTimePicker = timePicker;
        [actionSheet addSubview:timePicker];
        
        UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kGeneralTimeCellSection]];
        if (kIsiPhone) {
            [actionSheet showInView:self.view.window];
        } else {
            [actionSheet showFromRect:textField.frame inView:cell.contentView animated:YES];
        }
    }
    
    //设置“订座开放通用时间”的结束时间，如：20:00
    if (tag>=1200 && tag<1300) {
        if (_isTextFieldClearButtonClick)
        {
            _isTextFieldClearButtonClick = NO;
            return NO;
        }
        NSString *title = @"";
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
        actionSheet.tag = tag;
        
        
        int index = tag-1200;
        NSString *time2 = [[[ruleSettingDict objectForKey:@"generalTime"] objectAtIndex:index] objectForKey:@"endTime"];
        //时间选择器
        CustomTimePicker *timePicker = [[CustomTimePicker alloc]initWithLastTimeString:time2];
        if (kIsiPhone) {
            timePicker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
        } else {
            timePicker.frame = CGRectMake(-25.0, 0.0, 320.0, 216.0);
        }
        timePicker.backgroundColor = [UIColor clearColor];
        selectdTimePicker = timePicker;
        [actionSheet addSubview:timePicker];
        
        UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kGeneralTimeCellSection]];
        if (kIsiPhone) {
            [actionSheet showInView:self.view.window];
        } else {
            [actionSheet showFromRect:textField.frame inView:cell.contentView animated:YES];
        }
    }
    
    /*
    //设置“订座开放通用时间”的指定开放台号
    if (tag>=1500 && tag<1600) {
        int index = tag - 1500;
        NSArray *tables = [[[ruleSettingDict objectForKey:@"generalTime"] objectAtIndex:index] objectForKey:@"diningTable"];
        DeskPicker *picker = [[DeskPicker alloc] initWithSelectedList:tables];
        picker.tag = tag;
        picker.delegate = self;
        
        if (kIsiPhone) {
            popoverController = [[WEPopoverController alloc] initWithContentViewController:picker];
        } else {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        }
        if (!kIsiPhone) {
            [popoverController setPopoverBackgroundViewClass:nil];
        }
        [popoverController setDelegate:self];
        [popoverController setPopoverContentSize:picker.pickerSize];
        
        UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        
     
     if (kIsiPhone) {
        MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
        CGRect showRect = [cell.contentView convertRect:textField.frame  toView:mainCtrl.view];
        [popoverController setParentView:mainCtrl.view];
        [popoverController presentPopoverFromRect:showRect
                                           inView:mainCtrl.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
     } else {
        [popoverController presentPopoverFromRect:textField.frame 
                                           inView:cell.contentView
                         permittedArrowDirections:UIPopoverArrowDirectionLeft
                                         animated:YES];
     }
    }
    */
    
    //设置“订座指定开放时间”的订座开放日期，如：10月5日
    if (tag>=2000 && tag<2100) {
        if (_isTextFieldClearButtonClick)
        {
            _isTextFieldClearButtonClick = NO;
            return NO;
        }
        NSString *title = @"";
        UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                      initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
        actionSheet.tag = tag;
        
        
        int index = tag-2000;
        NSString *startDateStr = [[[ruleSettingDict objectForKey:@"openTime"] objectAtIndex:index] objectForKey:@"startDate"];
        NSDate *startDate = [NSDate date];
        if (0 != [startDateStr length])
        {
            startDate = [startDateStr stringToNSDateWithFormat:@"yyyy-MM-dd"];
        }
        
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-15.0, 0.0, 320.0, 216.0)];
        if (kIsiPhone) {
            picker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
        }
        picker.backgroundColor = [UIColor clearColor];
        picker.tag = tag;
        picker.datePickerMode = UIDatePickerModeDate;
        picker.date = startDate;
        selectedDatePicker = picker;
        [actionSheet addSubview:picker];
        
        UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kOpenTimeCellSection]];
        if (kIsiPhone) {
            [actionSheet showInView:self.view.window];
        } else {
            [actionSheet showFromRect:textField.frame inView:cell.contentView animated:YES];
        }
    }
    
    //设置“订座指定开放时间”的订座结束日期，如：10月8日
    if (tag>=2100 && tag<2200) {
        if (_isTextFieldClearButtonClick)
        {
            _isTextFieldClearButtonClick = NO;
            return NO;
        }
        NSString *title = @"";
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
        actionSheet.tag = tag;
        
        
        int index = tag-2100;
        NSString *endDateStr = [[[ruleSettingDict objectForKey:@"openTime"] objectAtIndex:index] objectForKey:@"endDate"];
        NSDate *endDate = [NSDate date];
        if (0 != [endDateStr length])
        {
            endDate = [endDateStr stringToNSDateWithFormat:@"yyyy-MM-dd"];
        }
        
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-15.0, 0.0, 320.0, 216.0)];
        if (kIsiPhone) {
            picker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
        }
        picker.backgroundColor = [UIColor clearColor];
        picker.tag = tag;
        picker.datePickerMode = UIDatePickerModeDate;
        picker.date = endDate;
        selectedDatePicker = picker;
        [actionSheet addSubview:picker];
        
        UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kOpenTimeCellSection]];
        if (kIsiPhone) {
            [actionSheet showInView:self.view.window];
        } else {
            [actionSheet showFromRect:textField.frame inView:cell.contentView animated:YES];
        }
    }
    
    //设置“订座指定开放时间”的订座开放时间，如：09:00
    if (tag>=2200 && tag<2300)
    {
        if (_isTextFieldClearButtonClick)
        {
            _isTextFieldClearButtonClick = NO;
            return NO;
        }
        NSString *title = @"";
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
        actionSheet.tag = tag;
        
        
        int index = tag-2200;
        NSString *startTimeStr = [[[ruleSettingDict objectForKey:@"openTime"] objectAtIndex:index] objectForKey:@"startTime"];
        //时间选择器
        CustomTimePicker *timePicker = [[CustomTimePicker alloc]initWithLastTimeString:startTimeStr];
        if (kIsiPhone) {
            timePicker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
        } else {
            timePicker.frame = CGRectMake(-25.0, 0.0, 320.0, 216.0);
        }
        timePicker.backgroundColor = [UIColor clearColor];
        selectdTimePicker = timePicker;
        [actionSheet addSubview:timePicker];
        
        UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kOpenTimeCellSection]];
        if (kIsiPhone) {
            [actionSheet showInView:self.view.window];
        } else {
            [actionSheet showFromRect:textField.frame inView:cell.contentView animated:YES];
        }
    }
    
    //设置“订座指定开放时间”的订座结束时间，如：18:00
    if (tag>=2300 && tag<2400)
    {
        if (_isTextFieldClearButtonClick)
        {
            _isTextFieldClearButtonClick = NO;
            return NO;
        }
        NSString *title = @"";
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
        actionSheet.tag = tag;
        
        
        int index = tag-2300;
        NSString *endTimeStr = [[[ruleSettingDict objectForKey:@"openTime"] objectAtIndex:index] objectForKey:@"endTime"];
        //时间选择器
        CustomTimePicker *timePicker = [[CustomTimePicker alloc]initWithLastTimeString:endTimeStr];
        if (kIsiPhone) {
            timePicker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
        } else {
            timePicker.frame = CGRectMake(-25.0, 0.0, 320.0, 216.0);
        }
        timePicker.backgroundColor = [UIColor clearColor];
        selectdTimePicker = timePicker;
        [actionSheet addSubview:timePicker];
        
        UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kOpenTimeCellSection]];
        if (kIsiPhone) {
            [actionSheet showInView:self.view.window];
        } else {
            [actionSheet showFromRect:textField.frame inView:cell.contentView animated:YES];
        }
    }
    
    //设置“订座开放通用时间”的指定开放台号
    if (tag>=2400 && tag<2500) {
        if (_isTextFieldClearButtonClick)
        {
            _isTextFieldClearButtonClick = NO;
            return NO;
        }
        int index = tag-2400;
        NSArray *tables = [[[ruleSettingDict objectForKey:@"openTime"] objectAtIndex:index] objectForKey:@"diningTable"];
        DeskPicker *picker = [[DeskPicker alloc] initWithSelectedList:tables];
        picker.delegate = self;
        picker.tag = tag;
        
        if (nil == popoverController) {
            if (kIsiPhone) {
                popoverController = [[WEPopoverController alloc] initWithContentViewController:picker];
            } else {
                popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
            }
        }
        if (!kIsiPhone) {
            [popoverController setPopoverBackgroundViewClass:nil];
        }
        [popoverController setContentViewController:picker];
        [popoverController setPopoverContentSize:picker.pickerSize];
        UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kOpenTimeCellSection]];
        
        if (kIsiPhone) {
            MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
            CGRect showRect = [cell.contentView convertRect:textField.frame toView:mainCtrl.view];
            [popoverController setParentView:mainCtrl.view];
            [popoverController presentPopoverFromRect:showRect
                                               inView:mainCtrl.view
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
        } else {
            [popoverController presentPopoverFromRect:textField.frame
                                               inView:cell.contentView
                             permittedArrowDirections:UIPopoverArrowDirectionLeft
                                             animated:YES];
        }
    }
    
    
    //设置“订座的指定关闭日期”的开始时间
    if (tag>=3000 && tag<3100) {
        if (_isTextFieldClearButtonClick)
        {
            _isTextFieldClearButtonClick = NO;
            return NO;
        }
        NSString *title = @"";
        UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                      initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
        actionSheet.tag = tag;
        
        
        int index = tag-3000;
        NSString *date1Str = [[[ruleSettingDict objectForKey:@"closeTime"] objectAtIndex:index] objectForKey:@"startDate"];
        NSDate *date1 = [NSDate date];
        if (0 != [date1Str length])
        {
            date1 = [date1Str stringToNSDateWithFormat:@"yyyy-MM-dd"];
        }
        
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-15.0, 0.0, 320.0, 216.0)];
        if (kIsiPhone) {
            picker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
        }
        picker.backgroundColor = [UIColor clearColor];
        picker.tag = tag;
        picker.datePickerMode = UIDatePickerModeDate;
        picker.date = date1;
        selectedDatePicker = picker;
        [actionSheet addSubview:picker];
        
        UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kCloseTimeCellSection]];
        if (kIsiPhone) {
            [actionSheet showInView:self.view.window];
        } else {
            [actionSheet showFromRect:textField.frame inView:cell.contentView animated:YES];
        }
    }
    
    
    //设置“订座的指定关闭日期”的结束时间
    if (tag>=3100 && tag<3200) {
        if (_isTextFieldClearButtonClick)
        {
            _isTextFieldClearButtonClick = NO;
            return NO;
        }
        NSString *title = @"";
        UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                      initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
        actionSheet.tag = tag;
        
        
        int index = tag-3100;
        NSString *date2Str = [[[ruleSettingDict objectForKey:@"closeTime"] objectAtIndex:index] objectForKey:@"endDate"];
        NSDate *date2 = [NSDate date];
        if (0 != [date2Str length])
        {
            date2 = [date2Str stringToNSDateWithFormat:@"yyyy-MM-dd"];
        }
        
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-15.0, 0.0, 320.0, 216.0)];
        if (kIsiPhone) {
            picker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
        }
        picker.backgroundColor = [UIColor clearColor];
        picker.tag = tag;
        picker.datePickerMode = UIDatePickerModeDate;
        picker.date = date2;
        selectedDatePicker = picker;
        [actionSheet addSubview:picker];
        
        UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kCloseTimeCellSection]];
        if (kIsiPhone) {
            [actionSheet showInView:self.view.window];
        } else {
            [actionSheet showFromRect:textField.frame inView:cell.contentView animated:YES];
        }
    }
    return NO;
}

#pragma mark UIPickerView Datasource & Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    int tag = pickerView.tag;
    int components = 0;
    
    //设置"订座开放期限"
    if (tag==0) {
        components = 1;
    }
    
    //设置“提前提醒时间”
    if (tag==1) {
        components = 2;
    }
    
    //设置“订座开放通用时间”的开始weekday
    if (tag>=1000 && tag<1100) {
        components = 1;
    }
    
    //设置“订座开放通用时间”的结束weekday
    if (tag>=1100 && tag<1200) {
        components = 1;
    }
    
    //设置“订座开放通用时间”的开放台数
    if (tag>=1400 && tag<1500) {
        components = 1;
    }
    
    //设置“订座的指定开放时间”的开放台数
    if (tag>=2300 && tag<2400) {
        components = 1;
    }
    return components;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    int tag = pickerView.tag;
    int rows = 0;
    
    //设置"订座开放期限"
    if (tag==0) {
        switch (component) {
            //小时
            case 0:
                rows = [limitTitlesArray count];
                break;
        }
    }
    
    
    //设置“提前提醒时间”
    if (tag==1) {
        switch (component) {
            //小时
            case 0:
                rows = 25;
                break;
            //分钟
            case 1:
                rows = 61;
                break;
        }
    }
    
    //设置“订座开放通用时间”的开始weekday
    if (tag>=1000 && tag<1100) {
        switch (component) {
            case 0:
                rows = 7;
                break;
        }
    }
    
    //设置“订座开放通用时间”的结束weekday
    if (tag>=1100 && tag<1200) {
        switch (component) {
            case 0:
                rows = 7;
                break;
        }
    }
    
    //设置“订座开放通用时间”的开放台数
    if (tag>=1400 && tag<1500) {
        switch (component) {
            case 0:
                rows = 20;
                break;
        }
    }
    
    //设置“订座的指定开放时间”的开放台数
    if (tag>=2300 && tag<2400) {
        switch (component) {
            case 0:
                rows = 20;
                break;
        }
    }
    return rows;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    int tag = pickerView.tag;
    NSString *title;
    //设置"订座开放期限"
    if (tag == 0) {
        switch (component) {
            case 0:{
                title = [[limitTitlesArray objectAtIndex:row] objectForKey:@"name"];
                break;
            }
        }
    }
    
    
    //设置“提前提醒时间”
    if (tag == 1) {
        switch (component) {
            case 0:{
                title = [NSString stringWithFormat:@"%i%@",row,kLoc(@"hour")];
                break;
            }
            case 1:{
                title = [NSString stringWithFormat:@"%i%@",row,kLoc(@"minute")];
                break;
            }
        }
    }
    
    
    //设置“订座开放通用时间”的开始weekday
    if (tag>=1000 && tag<1100) {
        switch (component) {
            case 0:{
                NSArray *array = [NSArray arrayWithObjects:
                                  kLoc(@"one_monday"),kLoc(@"two_tuesday"),
                                  kLoc(@"three_wednesday"),kLoc(@"four_thursday"),kLoc(@"five_friday"),kLoc(@"six_saturday"),kLoc(@"seven_sunday"), nil];
                title = [array objectAtIndex:row];
                break;
            }
        }
    }
    
    //设置“订座开放通用时间”的结束weekday
    if (tag>=1100 && tag<1200) {
        switch (component) {
            case 0:{
                NSArray *array = [NSArray arrayWithObjects:
                                  kLoc(@"one_monday"),kLoc(@"two_tuesday"),
                                  kLoc(@"three_wednesday"),kLoc(@"four_thursday"),kLoc(@"five_friday"),kLoc(@"six_saturday"),kLoc(@"seven_sunday"), nil];
                title = [array objectAtIndex:row];
                break;
            }
        }
    }
    
    //设置“订座开放通用时间”的开放台数
    if (tag>=1400 && tag<1500) {
        switch (component) {
            case 0:
                title = [NSString stringWithFormat:@"%i", row+1];
                break;
        }
    }
    
    //设置“订座的指定开放时间”的开放台数
    if (tag>=2300 && tag<2400) {
        switch (component) {
            case 0:
                title = [NSString stringWithFormat:@"%i", row+1];
                break;
        }
    }
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 270, 37)];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:17];
    label.text = title;
    return label;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    //[pickerView reloadAllComponents];
}



#pragma mark JsonPickerDelegate
-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    //获取规则设置信息
    if (picker.tag==0)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            case 200:
            {
                //刷新数据
                ruleSettingDict = [[NSMutableDictionary alloc] initWithDictionary:[dict objectForKey:@"data"]];
                [ruleSettingDict removeObjectForKey:@"diningTableList"];
                [self updateViewAfterGetData];
                
                isEdited = NO;
                
                break;
            }
        }
    }
    
    //保存规则设置信息
    if (picker.tag==1)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            //保存成功
            case 200:
            {
                
                ruleSettingDict = [[NSMutableDictionary alloc] initWithDictionary:[dict objectForKey:@"data"]];
                [ruleSettingTableview reloadData];
                
                [self dismissView];
                
                //
                isEdited = NO;
                break;
            }
            default:
            {
                sleep(1);
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


#pragma mark WeekdayPickerDelegate
-(void)WeekdayPicker:(WeekdayPicker*)picker didPickedWeekdays:(NSArray*)weekdays
{
    //是否要添加到数组的标记
    BOOL shouldAdd = YES;
    if ([WeekdayBtnArray count] == 0)
    {
        [WeekdayBtnArray addObject:[NSNumber numberWithInt:(int)picker.tag]];
    }
    else
    {
        for (int i = 0; i < [WeekdayBtnArray count]; i++)
        {
            if ([[WeekdayBtnArray objectAtIndex:i]integerValue] == picker.tag)
            {
                shouldAdd = NO;
                break;
            }
        }
        if (shouldAdd == YES)
        {
            [WeekdayBtnArray addObject:[NSNumber numberWithInt:(int)picker.tag]];
        }
    }
    

    isEdited = YES;
    [popoverController dismissPopoverAnimated:YES];
    
    int tag = (int)picker.tag;
    
    //设置订座开放通用时间的“开放星期”
    if (tag>=1000 && tag<1100) {
        int index = tag - 1000;
        NSMutableArray *generalTimeSet = [ruleSettingDict objectForKey:@"generalTime"];
        NSMutableDictionary *general = [generalTimeSet objectAtIndex:index];
        [general setObject:weekdays forKey:@"week"];
        [generalTimeSet replaceObjectAtIndex:index withObject:general];
        [ruleSettingDict setObject:generalTimeSet forKey:@"generalTime"];
        
        [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kGeneralTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
    }
}


-(void)WeekdayPicker:(WeekdayPicker*)picker didPressedCancelButton:(BOOL)flag
{
    [popoverController dismissPopoverAnimated:YES];
    
}

#pragma mark DeskPickerDelegate

-(void)DeskPicker:(DeskPicker*)picker didPressedCancelButton:(BOOL)flag
{
    [popoverController dismissPopoverAnimated:YES];
}


-(void)DeskPicker:(DeskPicker*)picker didPickedDesks:(NSArray*)desks
{
    isEdited = YES;
    [popoverController dismissPopoverAnimated:YES];
    
    int tag = (int)picker.tag;
    //设置订座开放通用时间的“指定开放台号”
    if (tag>=1500 && tag<1600)
    {
        //是否要添加到数组的标记
        BOOL shouldAdd = YES;
        if ([DesktextFieldArray count] == 0)
        {
            [DesktextFieldArray addObject:[NSNumber numberWithInt:(int)picker.tag]];
        }
        else
        {
            for (int i = 0; i < [DesktextFieldArray count]; i++)
            {
                if ([[DesktextFieldArray objectAtIndex:i]integerValue] == picker.tag)
                {
                    shouldAdd = NO;
                    break;
                }
            }
            if (shouldAdd == YES)
            {
                [DesktextFieldArray addObject:[NSNumber numberWithInt:(int)picker.tag]];
            }
        }
        
        
        
        int index = tag - 1500;
        NSMutableArray *generalTimeSet = [ruleSettingDict objectForKey:@"generalTime"];
        NSMutableDictionary *general = [generalTimeSet objectAtIndex:index];
        [general setObject:desks forKey:@"diningTable"];
        [generalTimeSet replaceObjectAtIndex:index withObject:general];
        [ruleSettingDict setObject:generalTimeSet forKey:@"generalTime"];
        
        [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kGeneralTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    //设置订座开放指定时间的“指定开放台号”
    if (tag>=2400 && tag<2500)
    {
        //是否要添加到数组的标记
        BOOL shouldAdd = YES;
        if ([specailOpenDesktextFieldArray count] == 0)
        {
            [specailOpenDesktextFieldArray addObject:[NSNumber numberWithInt:(int)picker.tag]];
        }
        else
        {
            for (int i = 0; i < [specailOpenDesktextFieldArray count]; i++)
            {
                if ([[specailOpenDesktextFieldArray objectAtIndex:i]integerValue] == picker.tag)
                {
                    shouldAdd = NO;
                    break;
                }
            }
            if (shouldAdd == YES)
            {
                [specailOpenDesktextFieldArray addObject:[NSNumber numberWithInt:(int)picker.tag]];
            }
        }
        
        
        int index = tag - 2400;
        NSMutableArray *openTimeSet = [ruleSettingDict objectForKey:@"openTime"];
        NSMutableDictionary *open = [openTimeSet objectAtIndex:index];
        [open setObject:desks forKey:@"diningTable"];
        [openTimeSet replaceObjectAtIndex:index withObject:open];
        [ruleSettingDict setObject:openTimeSet forKey:@"openTime"];
        
        [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kOpenTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark NumPickerDelegate
- (void)NumPicker:(NumPicker*)picker didPickedOverflowNumber:(NSString*)number
{
    if (kNumberPickerTag == picker.tag)
    {
        [PSAlertView showWithMessage:kLoc(@"please_enter_1_to_999")];
    }
}

-(void)NumPicker:(NumPicker *)picker didPickedNumber:(NSString *)number
{
    isEdited = YES;
    [popoverController dismissPopoverAnimated:YES];
    int tag = (int)picker.tag;
    
    //add by liaochunqing
    if (kNumberPickerTag == tag)//"订座开放期限"按钮
    {
        [preorderOpenRangeButton setTitle:[NSString stringWithFormat:@"%@",number]forState:UIControlStateNormal];
        [ruleSettingDict setObject:[NSNumber numberWithFloat:[number floatValue]] forKey:@"openTimelimit"];
        
//        //更新列表
//        [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    //设置“订座开放通用时间”的开放台数
    if (tag>=1400 && tag<1500) {
        int index = picker.tag-1400;
        //修改该值
        NSMutableArray *generalTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"generalTime"]];
        NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[generalTimeSet objectAtIndex:index]];
        
        [newCell setObject:number forKey:@"quantity"];
        [generalTimeSet replaceObjectAtIndex:index withObject:newCell];
        [ruleSettingDict setObject:generalTimeSet forKey:@"generalTime"];
        
        //更新Textfield
        [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kGeneralTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    //设置“订座的指订开放时间”的指定开放台数
    if (tag>=2300 && tag<2400) {
        int index = picker.tag-2300;
        //修改该值
        NSMutableArray *openTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"openTime"]];
        NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[openTimeSet objectAtIndex:index]];
        
        [newCell setObject:number forKey:@"quantity"];
        [openTimeSet replaceObjectAtIndex:index withObject:newCell];
        [ruleSettingDict setObject:openTimeSet forKey:@"openTime"];
        
        //更新Textfield
        [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kOpenTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark OrderNoticeCellDelegate

- (void)beginEditingOrderNoticeCell:(OrderNoticeCell *)cell
{
    selectCell = cell;
    ruleSettingTableview.scrollEnabled = NO;
    [ruleSettingTableview setContentOffset:CGPointMake(0, cell.frame.origin.y) animated:YES];
}

- (void)endEditingOrderNoticeCell:(OrderNoticeCell *)cell
{
    NSString *tempStr = [cell.noticeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *noticeStr = (0 == [tempStr length])?@"":tempStr;
    [self modifyCustomCell:cell.tag withContent:noticeStr withKey:@"instruction"];
}

- (void)deleteOrderNoticeCell:(int)index
{
    [self deleteCustomCell:index withSection:kOrderNoticeCellSection withKey:@"instruction"];
}

@end
