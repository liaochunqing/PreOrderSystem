//
//  AdvancedSearchViewController.m
//  PreOrderSystem
//
//  Created by 溢航软件 on 14-4-11.
//
//

#import "AdvancedSearchViewController.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"
#import "MainViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "Constants.h"

#define kStartTimeActionSheetTag 1
#define kEndTimeActionSheetTag 2
#define kStartTimeDatePickerTag 3
#define kEndTimeDatePickerTag 4


#define kDateFirstFormat @"yyyy-MM-dd"

@interface AdvancedSearchViewController () <UIGestureRecognizerDelegate> {
    /// 优惠类型清单
    NSMutableArray *_btnArray;
}
@end

@implementation AdvancedSearchViewController

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
    // Do any additional setup after loading the view from its nib.
    
    self.startDateField.delegate = self;
    self.endDateField.delegate = self;
    self.dateSelectedButton.backgroundColor = [UIColor whiteColor];
    self.arrowImageView.image = [UIImage imageNamed:@"order_shopDownArrow"];
    
    // 标题
    self.titleLabel.text = kLoc(@"advanced_search");
    self.titleLabel.textColor = [UIColor colorWithRed:233/255.0 green:122/255.0 blue:27/255.0 alpha:1];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    
    // 时间选择
    self.dateLabel.text = kLoc(@"start_end_date");
    self.startDateField.text = self.memberDataClass.startDate;
    self.endDateField.text = self.memberDataClass.endDate;
    
    // 时间字符串
    if (self.memberDataClass.dateStrIndex >= 0 &&
        self.memberDataClass.dateStrIndex < self.memberDataClass.dateTypeArray.count) {
        
        NSDictionary *dict = nil;
        dict = [self.memberDataClass.dateTypeArray objectAtIndex:self.memberDataClass.dateStrIndex];
        [self.dateSelectedButton setTitle:[dict objectForKey:@"name"]
                                 forState:UIControlStateNormal];
        [self.dateSelectedButton setTitleColor:[UIColor blackColor]
                                      forState:UIControlStateNormal];
    } else {
        [self.dateSelectedButton setTitle:kLoc(@"please_to_selected")
                                 forState:UIControlStateNormal];
        [self.dateSelectedButton setTitleColor:[UIColor lightGrayColor]
                                      forState:UIControlStateNormal];
    }
    
    CGFloat space = 10;
    CGFloat baseX = CGRectGetMaxX(self.youhuiLabel.frame) + space;
    CGFloat baseY = self.youhuiLabel.frame.origin.y;
    CGFloat w = 75;
    CGFloat h = 30;
    UIImage *bgImage = [UIImage imageFromMainBundleFile:@"more_shortButton.png"];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:37.0 topCapHeight:15.0];
    
    // 优惠劵
    self.youhuiLabel.text = kLoc(@"coupons_money");
    _btnArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.memberDataClass.couponTypeArray.count; i++) {
        int row = i % 7;
        int col = floor(i / 7);
        CGFloat yPos = baseY - 4.0 + col * (h + space);
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(baseX + row * (space + w), yPos, w, h)];
        btn.tag = i;
        
        MemberCouponTypeDataClass *typeClass = nil;
        typeClass = [self.memberDataClass.couponTypeArray objectAtIndex:i];
        
        [btn setTitle:typeClass.name forState:UIControlStateNormal];
        btn.selected = typeClass.isChecked;
        
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        btn.titleLabel.minimumFontSize = 12.0;
        [btn addTarget:self action:@selector(typeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:bgImage forState:UIControlStateSelected];
       
        [self.scrollView addSubview:btn];
        [_btnArray addObject:btn];
    }
    
    //取消
    [self.cancelButton setTitle:kLoc(@"cancel") forState:UIControlStateNormal];
    //搜索
    [self.searchButton setTitle:kLoc(@"search") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 隐藏键盘
- (void)hideKeyBoard
{
    [self.view endEditing:YES];
}

- (IBAction)cancelButtonClick:(id)sender
{
    [self hideKeyBoard];
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

- (IBAction)sureButtonClick:(id)sender
{
    [self hideKeyBoard];
    
    UIButton *btn = nil;
    for (btn in _btnArray) {
        if (btn.selected) {
            break;
        }
    }
    
    // 保存选择的优惠券类型
    for (int i = 0; i < self.memberDataClass.couponTypeArray.count; i++) {
        MemberCouponTypeDataClass *typeClass = nil;
        typeClass = [self.memberDataClass.couponTypeArray objectAtIndex:i];
        
        if (i == btn.tag) {
            typeClass.isChecked = YES;
        } else {
            typeClass.isChecked = NO;
        }
    }
    
    // 保存时间
    self.memberDataClass.startDate = self.startDateField.text;
    self.memberDataClass.endDate = self.endDateField.text;
    
    // 保存时间索引
    NSString *currentDateStr = [self.dateSelectedButton titleForState:UIControlStateNormal];
    for (int i = 0; i < self.memberDataClass.dateTypeArray.count; i++) {
        NSDictionary *dateDict = [self.memberDataClass.dateTypeArray objectAtIndex:i];
        if ([[dateDict objectForKey:@"name"] isEqualToString:currentDateStr]) {
            self.memberDataClass.dateStrIndex = i;
            break;
        } else {
            self.memberDataClass.dateStrIndex = -1;
        }
    }
    
    // 回调
    if ([self.delegate respondsToSelector:@selector(advancedSearchViewController:)]) {
        [self.delegate advancedSearchViewController:self];
    }
    
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

- (IBAction)dateSelectedButtonClick:(id)sender
{
    if (!self.tableView) {
        CGRect tableFrame = [self.dateSelectedButton convertRect:self.dateSelectedButton.bounds
                                                          toView:self.view];
        tableFrame.origin.y += tableFrame.size.height;
        tableFrame.size.height = MIN(tableFrame.size.height * self.memberDataClass.dateTypeArray.count, 300.0);
        
        self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.layer.borderWidth = 1;
        self.tableView.layer.borderColor =  [[UIColor lightGrayColor] CGColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        UIView *tableContainer = [[UIView alloc] initWithFrame:self.view.bounds];
        tableContainer.backgroundColor = [UIColor clearColor];
        [tableContainer addSubview:self.tableView];
        tableContainer.hidden = YES;
        [self.view addSubview:tableContainer];
        
        UITapGestureRecognizer *tapGesture = nil;
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                             action:@selector(hideDateList:)];
        tapGesture.delegate = self;
        [tableContainer addGestureRecognizer:tapGesture];
    }
    
    [self.tableView.superview setHidden:!self.tableView.superview.hidden];
    
    if (self.tableView.superview.hidden) {
        self.arrowImageView.image = [UIImage imageNamed:@"order_shopDownArrow"];
    } else {
        self.arrowImageView.image = [UIImage imageNamed:@"order_shopUpArrow"];
    }
}

- (void)typeButtonClick:(UIButton *)btn
{
    for (UIButton *tempBtn in _btnArray) {
        tempBtn.selected = NO;
    }
    
    btn.selected = YES;
}


//字符串是否为空
+ (BOOL)strIsEmpty:(NSString *)str
{
    return ([str length] > 0) ? NO : YES;
}

//显示时间ActionSheet
- (void)showStartTimeActionSheet:(NSInteger)actionSheetTag
              withDatePickerDate:(NSDate *)pickerDate
               withDatePickerTag:(NSInteger)datePickerTag
                        withRect:(CGRect)showRect
{
    NSString *title = @"";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
    actionSheet.tag = actionSheetTag;
    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-15.0, 0.0, 320.0, 216.0)];
    if (kIsiPhone) {
        picker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
    }
    picker.backgroundColor = [UIColor clearColor];
    picker.tag = datePickerTag;
    picker.datePickerMode = UIDatePickerModeDate;
    picker.date = pickerDate;
    [actionSheet addSubview:picker];
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:showRect inView:self.scrollView animated:YES];
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (void)hideDateList:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint tapPoint = [tapGestureRecognizer locationInView:self.tableView.superview];
    if (CGRectContainsPoint(self.tableView.frame, tapPoint) == NO) {
        self.tableView.superview.hidden = YES;
        self.arrowImageView.image = [UIImage imageNamed:@"order_shopDownArrow"];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:self.tableView.superview];
    if (CGRectContainsPoint(self.tableView.frame, tapPoint)) {
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.startDateField == textField) {
        NSDate *startDate = [NSDate date];
        NSString *startDateStr = self.startDateField.text;
        if ([startDateStr length] > 0) {
            startDate = [startDateStr stringToNSDateWithFormat:kDateFirstFormat];
        }
        [self showStartTimeActionSheet:kStartTimeActionSheetTag
                    withDatePickerDate:startDate
                     withDatePickerTag:kStartTimeDatePickerTag
                              withRect:self.startDateField.frame];
        
        return NO;
    } else if (self.endDateField == textField) {
        NSDate *endDate = [NSDate date];
        NSString *endDateStr = [NSString getStrWithoutWhitespace:self.endDateField.text];
        if (![NSString strIsEmpty:endDateStr]) {
            endDate = [endDateStr stringToNSDateWithFormat:kDateFirstFormat];
        }
        [self showStartTimeActionSheet:kEndTimeActionSheetTag
                    withDatePickerDate:endDate
                     withDatePickerTag:kEndTimeDatePickerTag
                              withRect:self.endDateField.frame];
        
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case kStartTimeActionSheetTag: {
            //确定
            if (0 == buttonIndex) {
                UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:kStartTimeDatePickerTag];
                NSString *dateStr = [NSString dateToNSString:datePicker.date withFormat:kDateFirstFormat];
                
                NSComparisonResult result = [dateStr compare:self.endDateField.text];
                if (result > NSOrderedSame && ![NSString strIsEmpty:self.endDateField.text]) {
                    [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                    
                    return;
                }
                
                self.startDateField.text = dateStr;
                [self.tableView reloadData];
                [self.dateSelectedButton setTitle:kLoc(@"please_to_selected")
                                         forState:UIControlStateNormal];
                [self.dateSelectedButton setTitleColor:[UIColor lightGrayColor]
                                              forState:UIControlStateNormal];
            }
            
            break;
        }
        
        case kEndTimeActionSheetTag: {
            //确定
            if (0 == buttonIndex) {
                UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:kEndTimeDatePickerTag];
                NSString *dateStr = [NSString dateToNSString:datePicker.date withFormat:kDateFirstFormat];
                
                NSComparisonResult result = [self.startDateField.text compare:dateStr];
                if (result > NSOrderedSame && ![NSString strIsEmpty:self.startDateField.text]) {
                    [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                    
                    return;
                }
                
                self.endDateField.text = dateStr;
                [self.tableView reloadData];
                
                [self.dateSelectedButton setTitle:kLoc(@"please_to_selected")
                                         forState:UIControlStateNormal];
                [self.dateSelectedButton setTitleColor:[UIColor lightGrayColor]
                                              forState:UIControlStateNormal];
            }
            
            break;
        }
        
        default:
            break;
    }
}



#pragma mark - UITableViewController datasource & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *adSearchCellIdentifier = @"adSearchCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:adSearchCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:adSearchCellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:20.0];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    NSDictionary *dict = [self.memberDataClass.dateTypeArray objectAtIndex:indexPath.row];
    
    if (dict) {
        cell.textLabel.text = [dict objectForKey:@"name"];
    } else {
        cell.textLabel.text = @"";
    }
    
    // 添加分割线
    CGRect separatorRect = CGRectMake(0.0,
                                      cell.contentView.frame.size.height - 1.0,
                                      cell.contentView.frame.size.width,
                                      1.0);
    UIImageView *separator = [[UIImageView alloc] initWithFrame:separatorRect];
    separator.backgroundColor = [UIColor lightGrayColor];
    separator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [cell.contentView addSubview:separator];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.memberDataClass.dateTypeArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.dateSelectedButton.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView.superview.hidden = YES;
    self.arrowImageView.image = [UIImage imageNamed:@"order_shopDownArrow"];
    
    NSDictionary *dict = [self.memberDataClass.dateTypeArray objectAtIndex:indexPath.row];
    
    if (dict) {
        [self.dateSelectedButton setTitle:[dict objectForKey:@"name"] forState:UIControlStateNormal];
        self.startDateField.text = [dict objectForKey:@"start"];
        self.endDateField.text = [dict objectForKey:@"end"];
        
        [self.dateSelectedButton setTitleColor:[UIColor blackColor]
                                      forState:UIControlStateNormal];
    }
}

@end
