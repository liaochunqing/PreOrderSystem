//
//  DishCardRemarkViewController.m
//  PreOrderSystem
//
//  Created by sWen on 13-5-15.
//
//  jhh_菜牌_编辑备注

#import "DishCardRemarkViewController.h"
#import "RemarkCuisineTableViewCell.h"
#import "RemarkItemTableViewCell.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "PSAlertView.h"
#import "DishCardDataClass.h"

#define kRemarkListCount [remarkListDataClass.remarkListArray count]
#define kRemarkNameLength 6

@interface DishCardRemarkViewController ()
{
    JsonPicker *jsonPicker;
    DishCardRemarkListDataClass *remarkListDataClass;
    int selectIndexOfCuisine;
    RemarkItemTableViewCell *selectTableViewCell;
}

- (IBAction)cancelButtonPressed:(UIButton*)sender;
- (IBAction)doneButtonPressed:(UIButton*)sender;
- (IBAction)addRemarkButtonPressed:(UIButton*)sender;
- (void)addPictureToView;
- (void)dismissView;
- (void)getRemarkData;
- (void)saveRemarkData;

@end

@implementation DishCardRemarkViewController

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
    
    [self addPictureToView];
    [self addLocalizedString];
    [self addNotifications];
    selectIndexOfCuisine = 0;
    
    //避免视图遮住MBProgressHUD
    [self performSelector:@selector(getRemarkData) withObject:nil afterDelay:0.8];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self removeNotification];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self.remarkTableView];
#ifdef DEBUG
    NSLog(@"===%s===", __FUNCTION__);
#endif
}

- (void)addPictureToView
{
    self.bgImageView.image = [UIImage imageFromMainBundleFile:@"dishCard_editBg.png"];
    self.cuisineBgImageView.image = [UIImage imageFromMainBundleFile:@"dishCard_remarkBg.png"];
}

- (void)addLocalizedString
{
    self.titleLabel.text = kLoc(@"editing_remark");
    self.addRemarkTextField.placeholder = kLoc(@"click_to_input_new_remark");
}

- (void)dismissView
{
    if ([self.delegate respondsToSelector:@selector(dismissViewOfRemarkViewController:)])
    {
        [self.delegate dismissViewOfRemarkViewController:self];
    }
}

- (void)hideKeyBoard
{
    [self.addRemarkTextField resignFirstResponder];
    [selectTableViewCell.nameTextField resignFirstResponder];
}

- (DishCardRemarkDataClass *)getDishCardRemarkDataClass:(int)index
{
    NSMutableArray *tempArray = remarkListDataClass.remarkListArray;
    int remarkListCount = [tempArray count];
    DishCardRemarkDataClass *tempDataClass = nil;
    if (index < remarkListCount)
    {
        tempDataClass = [[DishCardRemarkDataClass alloc] initWithDishCardRemarkData:[tempArray objectAtIndex:index]];
    }
    return tempDataClass;
}

#pragma mark - UIButton

- (IBAction)cancelButtonPressed:(UIButton*)sender
{
    [self hideKeyBoard];
    [self dismissView];
}

- (IBAction)doneButtonPressed:(UIButton*)sender
{
    [self hideKeyBoard];
    [self saveRemarkData];
}

- (IBAction)addRemarkButtonPressed:(UIButton*)sender
{
    NSString *remarkStr = [self.addRemarkTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (0 >= [remarkStr length] )
    {
        [self hideKeyBoard];
        [PSAlertView showWithMessage:kLoc(@"please_enter_remark")];
        return;
    }
    if (selectIndexOfCuisine < kRemarkListCount)
    {
        DishCardRemarkDataClass *tempDataClass = [self getDishCardRemarkDataClass:selectIndexOfCuisine];
        //判断备注名称是否重复了
        BOOL isRepeat = NO;
        for (NSDictionary *remarkDict in tempDataClass.remarkArray)
        {
            NSString *ramarkName = [remarkDict objectForKey:kRemarkName];
            if ([ramarkName isEqualToString:remarkStr])
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
        [DishCardRemarkDetailDataClass addNewRemarkDetailData:tempDataClass.remarkArray withRemarkStr:remarkStr];
        [self.remarkTableView reloadData];
        self.addRemarkTextField.text = @"";
    }
}

/**
 * 显示提示语，当备注名重复时
 */
- (void)showWarnWhenAreaNameRepeat
{
    [self hideKeyBoard];
    [PSAlertView showWithMessage:kLoc(@"duplicated_remark_content")];
}

#pragma mark network

//读取菜系数据
- (void)getRemarkData
{
    if (!jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withBaseRequest:@"cookbook/getRemarkList"];
}

//保存菜系数据
- (void)saveRemarkData
{
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    NSMutableArray *listArray = [[NSMutableArray alloc] initWithArray:remarkListDataClass.remarkListArray];
    int listCount = [listArray count];
    for (int j = 0; j < listCount; j++)
    {
        NSMutableDictionary *remarkDict = [[NSMutableDictionary alloc] initWithDictionary:[listArray objectAtIndex:j]];
        NSMutableArray *remarkArray = [[NSMutableArray alloc] initWithArray:[remarkDict objectForKey:kDishCardRemarkDataClassRemarkKey]];
        NSArray *deleteRemarkArray = [[NSMutableArray alloc] initWithArray:[remarkDict objectForKey:kDishCardRemarkDataClassDeleteRemarkKey]];
        if ([deleteRemarkArray count])
        {
            [remarkArray addObjectsFromArray:deleteRemarkArray];
            [remarkDict removeObjectForKey:kDishCardRemarkDataClassDeleteRemarkKey];
            [remarkDict setValue:remarkArray forKey:kDishCardRemarkDataClassRemarkKey];
            [listArray replaceObjectAtIndex:j withObject:remarkDict];
        }
    }
    [postData setObject:listArray forKey:@"remarkList"];
    
    if (!jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerSecondTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"saving_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = kLoc(@"save_succeed");
    [jsonPicker postData:postData withBaseRequest:@"cookbook/saveRemarkList"];
    
#ifdef DEBUG
    NSLog(@"===%s,postData:%@===", __FUNCTION__, postData);
#endif
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
    self.remarkTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset  - 120,0.0f);
    self.remarkTableView.scrollEnabled = NO;
    
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
    
    self.remarkTableView.scrollEnabled = YES;
    self.remarkTableView.contentInset = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}

#pragma mark UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int indexRow = indexPath.row;
    if (self.cuisineTableView == tableView)
    {
        static NSString *cellIdentifier = kRemarkCuisineTableViewCellReuseIdentifier;
        RemarkCuisineTableViewCell * cell = (RemarkCuisineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"RemarkCuisineTableViewCell" owner:self options:nil]lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (indexRow < kRemarkListCount)
        {
            BOOL flag = NO;
            DishCardRemarkDataClass *tempDataClass = [self getDishCardRemarkDataClass:indexRow];
            if (selectIndexOfCuisine >= 0 && selectIndexOfCuisine == indexRow)
            {
                flag = YES;
            }
            [cell updateViewAfterGetData:tempDataClass.cuisineName withSelected:flag];
        }
        cell.tag = indexRow;
        
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = kRemarkItemTableViewCellReuseIdentifier;
        RemarkItemTableViewCell * cell = (RemarkItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"RemarkItemTableViewCell" owner:self options:nil]lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }
        if (selectIndexOfCuisine >= 0 && selectIndexOfCuisine < kRemarkListCount)
        {
            DishCardRemarkDataClass *tempDataClass = [self getDishCardRemarkDataClass:selectIndexOfCuisine];
            DishCardRemarkDetailDataClass *detailClass = [[DishCardRemarkDetailDataClass alloc] initWithDishCardRemarkDetailData:[tempDataClass.remarkArray objectAtIndex:indexRow]];
            [cell updateViewAfterGetData:detailClass.name];
        }
        cell.tag = indexRow;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 40;
    if (self.cuisineTableView == tableView)
    {
        height = 60;
    }
    if (self.remarkTableView == tableView)
    {
         height = 65;
    }
	return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int number = 0;
    int cuisineCount = kRemarkListCount;
    if (self.cuisineTableView == tableView)
    {
        number = cuisineCount;
    }
    if (self.remarkTableView == tableView)
    {
        if (selectIndexOfCuisine < cuisineCount && selectIndexOfCuisine >= 0)
        {
            DishCardRemarkDataClass *tempDataClass = [self getDishCardRemarkDataClass:selectIndexOfCuisine];
            number = [tempDataClass.remarkArray count];
        }
    }
    
    return number;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cuisineTableView == tableView)
    {
        selectIndexOfCuisine = indexPath.row;
    }
    [self.cuisineTableView reloadData];
    [self.remarkTableView reloadData];
}

#pragma mark UITextFidld delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location >= kRemarkNameLength)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyBoard];
    return YES;
}

#pragma mark RemarkItemTableViewCell delegate

- (void)deleteRemarkItem:(RemarkItemTableViewCell *)cell
{
    NSInteger index = cell.tag;
    NSMutableArray *listArray = remarkListDataClass.remarkListArray;
    if (selectIndexOfCuisine < [listArray count])
    {
        NSMutableDictionary *remarkDict = [[NSMutableDictionary alloc] initWithDictionary:[listArray objectAtIndex:selectIndexOfCuisine]];
        NSMutableArray *remarkArray = [[NSMutableArray alloc] initWithArray:[remarkDict objectForKey:kDishCardRemarkDataClassRemarkKey]];
        NSMutableArray *deleteRemarkArray = [[NSMutableArray alloc] initWithArray:[remarkDict objectForKey:kDishCardRemarkDataClassDeleteRemarkKey]];
        if (index < [remarkArray count])
        {
            NSDictionary *tempDict = [DishCardRemarkDetailDataClass deleteRemarkData:remarkArray withIndex:index];
            [deleteRemarkArray addObject:tempDict];
            [remarkArray removeObjectAtIndex:index];
            [remarkDict setValue:deleteRemarkArray forKey:kDishCardRemarkDataClassDeleteRemarkKey];
            [remarkDict setValue:remarkArray forKey:kDishCardRemarkDataClassRemarkKey];
            [listArray replaceObjectAtIndex:selectIndexOfCuisine withObject:remarkDict];
            [self.remarkTableView reloadData];
        }
    }
}

- (void)remarkItemChange:(RemarkItemTableViewCell *)cell withNewItem:(NSString *)itemStr
{
    DishCardRemarkDataClass *tempDataClass = [self getDishCardRemarkDataClass:selectIndexOfCuisine];
    int ramarkIndex = cell.tag;
    NSMutableArray *tempArray = tempDataClass.remarkArray;
    if (ramarkIndex < [tempArray count])
    {
        //判断备注名称是否重复了
        BOOL isRepeat = NO;
        NSInteger tempIndex = 0;
        for (NSDictionary *ramarkDict in tempArray)
        {
            if (tempIndex != ramarkIndex)
            {
                NSString *ramarkName = [ramarkDict objectForKey:kRemarkName];
                if ([ramarkName isEqualToString:itemStr])
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
            [DishCardRemarkDetailDataClass modifyRemarkData:tempArray withRemarkName:itemStr withIndex:ramarkIndex];
        }
        [self.remarkTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    }
}

- (void)keyboardShow:(id)cell
{
    selectTableViewCell = cell;
}

- (void)keyboardHide:(id)cell
{
    selectTableViewCell = nil;
}

#pragma mark JsonPickerDelegate

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
#ifdef DEBUG
    NSLog(@"===DishCardRemarkViewController,dict:%@====",dict);
#endif
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    int responseStatus = dataClass.responseStatus;
    
    if (kJsonPickerFirstTag == picker.tag)
    {
        switch (responseStatus)
        {
            case 200:
            {
                remarkListDataClass = [[DishCardRemarkListDataClass alloc] initWithDishCardRemarkListData:dataClass.dataDict];
                [self.remarkTableView reloadData];
                [self.cuisineTableView reloadData];
                
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:dataClass.alertMsg];
                break;
            }
        }
    }
    else if (kJsonPickerSecondTag == picker.tag)
    {
        switch (responseStatus)
        {
                //保存成功
            case 200:
            {
                [self performSelector:@selector(dismissView) withObject:dict afterDelay:1.0];
                break;
            }
                //保存失败
            default:
            {
                [PSAlertView showWithMessage:dataClass.alertMsg];
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
