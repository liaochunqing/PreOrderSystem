//
//  SettingAnswerViewController.m
//  PreOrderSystem
//
//  Created by sWen on 13-3-8.
//
//

#import "EditArrangCategoryViewController.h"
#import "PSAlertView.h"
#import "Constants.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "NsstringAddOn.h"
#import "QueueCommon.h"
#import "QueueCategoryDataClass.h"
#import "UITextFieldAddition.h"

#define kMaxCategoryQuantity 8

@interface EditArrangCategoryViewController ()
{
    NSMutableArray *categoryArray;//保存类别数据
    BOOL isOverLap;//是否允许重复
    NSMutableArray *deleteCategoryArray;
    JsonPicker *jsonPicker;
    CGPoint tableviewContentOffset;
    EditArrangCategoryViewControllerCell *categorySelectedCell;
}
@property (weak, nonatomic) IBOutlet UILabel *isOverlapLabel;
@property (weak, nonatomic) IBOutlet UIButton *yesBtn;
@property (weak, nonatomic) IBOutlet UILabel *yesLabel;
@property (weak, nonatomic) IBOutlet UIButton *noBtn;
@property (weak, nonatomic) IBOutlet UILabel *noLabel;

- (IBAction)cancelButtonPressed:(UIButton*)sender;
- (IBAction)doneButtonPressed:(UIButton*)sender;
- (IBAction)addButtonPressed:(UIButton*)sender;
- (void)readArrangCategoryData;
- (void)saveArrangCategoryData;
- (IBAction)yesBtnClick:(UIButton *)sender;
- (IBAction)noBtnClick:(UIButton *)sender;

@end

@implementation EditArrangCategoryViewController

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
    
    // 添加关闭按钮
    [self.addMinCapacityField bindCloseButton];
    [self.addMaxCapacityField bindCloseButton];
    
    [self addPictureToView];
    [self addNotifications];
    [self addLocalizedString];
    
    [self.arrangTableView setEditing:YES animated:YES];
    categoryArray = [[NSMutableArray alloc]initWithCapacity:3];
    deleteCategoryArray = [[NSMutableArray alloc]initWithCapacity:3];
    //避免视图遮住MBProgressHUD
    [self performSelector:@selector(readArrangCategoryData) withObject:nil afterDelay:0.5];
    
    /* 模拟看内存警告时是否有问题
     [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(didReceiveMemoryWarning) userInfo:nil repeats:YES];
    */
    
//    允许重复按钮图标
    [self.yesBtn setBackgroundImage:[UIImage imageNamed:@"order_by_phone_area_unselected.png"] forState:UIControlStateNormal];
    [self.yesBtn setBackgroundImage:[UIImage imageNamed:@"order_by_phone_area_selected.png"] forState:UIControlStateSelected];
    
    [self.noBtn setBackgroundImage:[UIImage imageNamed:@"order_by_phone_area_unselected.png"] forState:UIControlStateNormal];
    [self.noBtn setBackgroundImage:[UIImage imageNamed:@"order_by_phone_area_selected.png"] forState:UIControlStateSelected];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self removeNotification];
    categoryArray = nil;
    deleteCategoryArray = nil;
    self.latestQueueListArray = nil;
    jsonPicker = nil;
    self.alertMsg = nil;
    categorySelectedCell = nil;
    
#ifdef DEBUG
    NSLog(@"===EditArrangCategoryViewController,viewDidUnload===");
#endif
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

- (void)dealloc
{
    [self removeNotification];
    
#ifdef DEBUG
    NSLog(@"===EditArrangCategoryViewController,dealloc===");
#endif
}

// 是否允许重复按钮
- (void)setOverLapYes :(BOOL)flag
{
    if (flag)
    {
        self.yesBtn.selected = YES;
        self.noBtn.selected = NO;
    }
    else
    {
        self.yesBtn.selected = NO;
        self.noBtn.selected = YES;
    }
}

- (void)addLocalizedString
{
    self.titleLabel.text = kLoc(@"edit_arranging_category");
    self.addCategoryTextField.placeholder = kLoc(@"please_enter_the_category_name");
    self.addMaxCapacityField.placeholder = kLoc(@"people_number");
    self.addMinCapacityField.placeholder = kLoc(@"people_number");
    
    self.yesLabel.text = kLoc(@"yes");
    self.noLabel.text = kLoc(@"no");
    self.isOverlapLabel.text = [NSString stringWithFormat:@"%@:",kLoc(@"arrow_duplicate")] ;
}

- (void)addPictureToView
{
    self.bgImageView.image = [UIImage imageFromMainBundleFile:@"queue_editArrageBg.png"];
}

//退出
- (void)dismissView
{
    [self hideKeyBoard];
    if ([self.delegate respondsToSelector:@selector(EditArrangCategoryViewController:didDismissView:)])
    {
        [self.delegate EditArrangCategoryViewController:self didDismissView:YES];
    }
}

- (void)hideKeyBoard
{
    [self.addCategoryTextField resignFirstResponder];
    [self.addMaxCapacityField resignFirstResponder];
    [self.addMinCapacityField resignFirstResponder];
    [categorySelectedCell.categoryTextField resignFirstResponder];
    [categorySelectedCell.minCapacityField resignFirstResponder];
    [categorySelectedCell.maxCapacityField resignFirstResponder];
}

#pragma mark - UIButton Clicked

- (IBAction)yesBtnClick:(UIButton *)sender
{
    [self hideKeyBoard];
    [self setOverLapYes:YES];
}


- (IBAction)noBtnClick:(UIButton *)sender
{
    [self hideKeyBoard];
    [self setOverLapYes:NO];
}

- (IBAction)cancelButtonPressed:(UIButton*)sender
{
    [self hideKeyBoard];
    [self dismissView];
}

- (IBAction)doneButtonPressed:(UIButton*)sender
{
    [self hideKeyBoard];
    for (int i = 0; i < [categoryArray count]; i++)
    {
        NSString *tempString = [[[categoryArray objectAtIndex:i]objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (0 == [tempString length])
        {
            [PSAlertView showWithMessage:kLoc(@"category_name_can_not_be_empty")];
            return;
        }
    }
    [self saveArrangCategoryData];
}

- (IBAction)addButtonPressed:(UIButton*)sender
{
    //当不允许重叠时，做判断， 并提示
    if (self.noBtn.selected)
    {
        //当前需要添加的人数数据
        int iMin = [self.addMinCapacityField.text intValue];
        int iMax = [self.addMaxCapacityField.text intValue];
        
        for (int i = 0; i < categoryArray.count; i++)
        {
            int iCurrentMin = [[categoryArray[i] objectForKey:@"minCapacity"] intValue];
            int iCurrentMax = [[categoryArray[i] objectForKey:@"maxCapacity"] intValue];
            
            if ((iMin >= iCurrentMin && iMin <= iCurrentMax)
                || (iMax >= iCurrentMin && iMax <= iCurrentMax)
                || (iCurrentMin >= iMin && iCurrentMin <= iMax)
                || (iCurrentMax >= iMin && iCurrentMax <= iMax))
            {
                [PSAlertView showWithMessage:kLoc(@"duplicate_quene_person_number")];
                return;
            }
        }
        
        BOOL isSuccession = FALSE;
        for (int i = 0; i < categoryArray.count; i++)//检测是否和其中一个连续
        {
            int iCurrentMin = [[categoryArray[i] objectForKey:@"minCapacity"] intValue];
            int iCurrentMax = [[categoryArray[i] objectForKey:@"maxCapacity"] intValue];
            
            if (iMin == iCurrentMax + 1 || iMax == iCurrentMin - 1)
            {
                isSuccession = YES;
            }
        }
        
        if (isSuccession == FALSE)
        {
            [PSAlertView showWithMessage:kLoc(@"quene_person_numnber_must_continuou")];
            return;
        }
    }
    
    if (kMaxCategoryQuantity > [categoryArray count])
    {
        //名称
        NSString *nameStr = [NSString getStrWithoutWhitespace:self.addCategoryTextField.text];
        if ([NSString strIsEmpty:nameStr])
        {
            [self hideKeyBoard];
            [PSAlertView showWithMessage:kLoc(@"please_enter_the_category_name")];
            self.addCategoryTextField.text = @"";
            return;
        }
        self.addCategoryTextField.text = nameStr;
        //最小
        NSString *minCapacityStr = [NSString getStrWithoutWhitespace:self.addMinCapacityField.text];
        //最大
        NSString *maxCapacityStr = [NSString getStrWithoutWhitespace:self.addMaxCapacityField.text];
        if ([NSString strIsEmpty:minCapacityStr] || [NSString strIsEmpty:maxCapacityStr])
        {
            [self hideKeyBoard];
            [PSAlertView showWithMessage:kLoc(@"person_number_cannot_be_empty")];
            return;
        }
        //判断排号类别名称是否重复了
        BOOL isRepeat = NO;
        for (NSDictionary *categoryDict in categoryArray)
        {
            NSString *categoryName = [categoryDict objectForKey:kQueueCategoryDataClassNameKey];
            if ([categoryName isEqualToString:nameStr])
            {
                isRepeat = YES;
                break;
            }
        }
        if (isRepeat)
        {
            [self showWarnWhenAreaNameRepeat];
            return;
        }
        else
        {
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithCapacity:3];
            [tempDict setObject:self.addCategoryTextField.text forKey:kQueueCategoryDataClassNameKey];
            [tempDict setObject:@"0" forKey:kQueueCategoryDataClassIdKey];
            [tempDict setObject:minCapacityStr forKey:kQueueCategoryDataClassMinCapacityKey];
            [tempDict setObject:maxCapacityStr forKey:kQueueCategoryDataClassMaxCapacityKey];
            [categoryArray insertObject:tempDict atIndex:0];
            [self.arrangTableView reloadData];
            [self.arrangTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
    else
    {
        [self hideKeyBoard];
        [PSAlertView showWithMessage:kLoc(@"category_number_has_reached_max")];
    }
    self.addCategoryTextField.text = @"";
    self.addMinCapacityField.text = @"";
    self.addMaxCapacityField.text = @"";
}

/**
 * 显示提示语，当区域名重复时
 */
- (void)showWarnWhenAreaNameRepeat
{
    [self hideKeyBoard];
    [PSAlertView showWithMessage:kLoc(@"duplicated_category_name")];
}

#pragma mark - Notifications

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
    self.arrangTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset - 120,0.0f);
    self.arrangTableView.scrollEnabled = NO;
    
    [UIView commitAnimations];
    
#ifdef DEBUG
    NSLog(@"===%@,keyboardWillShow:%@",self.class,NSStringFromCGRect(keyboardRect));
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
    
    self.arrangTableView.scrollEnabled = YES;
    self.arrangTableView.contentInset = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}

#pragma mark - network

//读取类别数据
- (void)readArrangCategoryData
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
//    [jsonPicker postData:postData withBaseRequest:@"QueueSort/read"];
    
    [jsonPicker postData:postData withBaseRequest:@"queue/getSortList"];
}

//保存类别数据
- (void)saveArrangCategoryData
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerSecondTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"saving_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:categoryArray];
    [tempArray addObjectsFromArray:deleteCategoryArray];
//    [postData setObject:tempArray forKey:@"arrangCategory"];
//    [jsonPicker postData:postData withBaseRequest:@"QueueSort/save"];
    if (self.yesBtn.selected)
    {
        [postData setObject:[NSNumber numberWithBool:YES] forKey:@"overlap"];
    }
    else
    {
        [postData setObject:[NSNumber numberWithBool:NO] forKey:@"overlap"];
    }
    
    [postData setObject:tempArray forKey:@"sortList"];
    [jsonPicker postData:postData withBaseRequest:@"queue/saveSortList"];
}



#pragma mark - EditArrangCategoryViewControllerCell delegate

- (void)deleteArrangCategory:(EditArrangCategoryViewControllerCell *)cell
{
    int index = cell.tag;
    if (index < [categoryArray count])
    {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[categoryArray objectAtIndex:index]];
        [tempDict setObject:@"" forKey:kQueueCategoryDataClassNameKey];
        [deleteCategoryArray addObject:tempDict];
        [categoryArray removeObjectAtIndex:index];
        [self.arrangTableView reloadData];
    }
}

- (void)ArrangCategoryChange:(EditArrangCategoryViewControllerCell *)cell withNewCategory:(NSString *)category withNewMinCapacity:(int)minCapacity withNewMaxCapacity:(int)maxCapacity
{
    int categoryIndex = cell.tag;
    if (categoryIndex < [categoryArray count])
    {
        //在修改区域的时候,判断区域名称是否重复了
        BOOL isRepeat = NO;
        NSInteger tempIndex = 0;
        for (NSDictionary *categoryDict in categoryArray)
        {
            if (tempIndex != categoryIndex)
            {
                NSString *categoryName = [categoryDict objectForKey:kQueueCategoryDataClassNameKey];
                if ([categoryName isEqualToString:category])
                {
                    isRepeat = YES;
                    break;
                }
            }
            tempIndex++;
        }
        if (isRepeat)
        {
            [self showWarnWhenAreaNameRepeat];
        }
        else
        {
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[categoryArray objectAtIndex:categoryIndex]];
            [tempDict setObject:category forKey:kQueueCategoryDataClassNameKey];
            [tempDict setObject:[NSNumber numberWithInt:minCapacity] forKey:kQueueCategoryDataClassMinCapacityKey];
            [tempDict setObject:[NSNumber numberWithInt:maxCapacity] forKey:kQueueCategoryDataClassMaxCapacityKey];
            [categoryArray replaceObjectAtIndex:categoryIndex withObject:tempDict];
        }
        [self.arrangTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    }
}

- (void)moveViewUpWhenKeyboardShow:(EditArrangCategoryViewControllerCell *)cell
{
    categorySelectedCell = cell;
}

//键盘输入的界面调整
- (void)moveViewBackWhenKeyboardHide:(EditArrangCategoryViewControllerCell *)cell
{
    categorySelectedCell = nil;
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kEditArrangCategoryCellReuseIdentifier;

    EditArrangCategoryViewControllerCell *cell = (EditArrangCategoryViewControllerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"EditArrangCategoryViewControllerCell" owner:self options:nil]lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    int indexRow = indexPath.row;
    cell.delegate = self;
    cell.tag = indexRow;
    [cell updateEditArrangCategoryCell:[categoryArray objectAtIndex:indexRow]];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [categoryArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 65;
	return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id object=[categoryArray objectAtIndex:sourceIndexPath.row] ;
    [categoryArray removeObjectAtIndex:sourceIndexPath.row];
    [categoryArray insertObject:object atIndex:destinationIndexPath.row];
    
    [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UITextFidld delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.addMinCapacityField == textField || self.addMaxCapacityField == textField)
    {
        if ((![NSString isValidateNumber:string]) || range.location >= kArrangCategoryCapacityLen)
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyBoard];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

#pragma mark - JsonPickerDelegate

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    if (kJsonPickerFirstTag == picker.tag)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            case 200:
            {
                [categoryArray removeAllObjects];
                
                NSDictionary *dataDict = [dict objectForKey:@"data"];
                if (dataDict)
                {
                    [categoryArray addObjectsFromArray:[dataDict objectForKey:@"sortList"]];
                }
                
                // 允许重叠根据网络返回值设置
                if (dataDict && [dataDict objectForKey:@"overlap"])
                {
                    isOverLap = [[dataDict objectForKey:@"overlap"] boolValue];
                    [self setOverLapYes:isOverLap];
                }
                else
                {
                    [self setOverLapYes:NO];
                }
                
                //刷新页面
                [self.arrangTableView reloadData];
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                break;
            }
        }
    }
    
    if (kJsonPickerSecondTag == picker.tag)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            //保存成功
            case 200:
            {
                if (nil == self.latestQueueListArray)
                {
                    self.latestQueueListArray = [[NSMutableArray alloc]initWithCapacity:3];
                }
                [self.latestQueueListArray removeAllObjects];
                [self.latestQueueListArray addObjectsFromArray:[[dict objectForKey:@"data"] objectForKey:@"queueList"]];
                
                NSString *tempString = [[dict objectForKey:@"desc"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if (0 != [tempString length])
                {
                    self.alertMsg = [dict objectForKey:@"desc"];
                    [PSAlertView showWithMessage:kLoc(self.alertMsg)];
                    
                }
                else
                {
                    [PSAlertView showWithMessage:kLoc(@"submit_succeed")];
                }
                
                [self performSelector:@selector(dismissView) withObject:nil afterDelay:2.0];
                self.isEditAndSave = YES;
                
                break;
            }
            //保存失败
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
