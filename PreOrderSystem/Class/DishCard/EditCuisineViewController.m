//
//  SettingAnswerViewController.m
//  PreOrderSystem
//
//  Created by sWen on 13-5-15.
//
//  jhh_菜牌_编辑菜系

#import "EditCuisineViewController.h"
#import "PSAlertView.h"
#import "Constants.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "NsstringAddOn.h"

//cell每行有3列
#define kRowNumberOfCell 3
#define kCuisineNameLength 6

@interface EditCuisineViewController ()

- (void)getCuisineData;
- (void)saveCuisineData;
- (void)dismissView:(NSDictionary *)dishCardDict;

@end

@implementation EditCuisineViewController

@synthesize cuisineScrollView;
@synthesize cuisineTableView;
@synthesize addCuisineTextField;
@synthesize titleLabel;
@synthesize bgImageView;
@synthesize addButton;
@synthesize cancelButton;
@synthesize doneButton;
@synthesize delegate;

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
    
    [self.cuisineTableView setEditing:YES animated:YES];
    cuisineArray = [[NSMutableArray alloc]initWithCapacity:1];
    deleteCuisineArray = [[NSMutableArray alloc]initWithCapacity:1];
    [self addPictureToView];
    [self addNotifications];
    [self addLocalizedString];
    //避免视图遮住MBProgressHUD
    [self performSelector:@selector(getCuisineData) withObject:nil afterDelay:0.8];
    
    
    /* 模拟看内存警告时是否有问题
     [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(didReceiveMemoryWarning) userInfo:nil repeats:YES];
    */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self removeNotification];
    cuisineArray = nil;
    deleteCuisineArray = nil;
    jsonPicker = nil;
    cuisineSelectedCell = nil;
    
#ifdef DEBUG
    NSLog(@"===EditCuisineViewController,viewDidUnload===");
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
    NSLog(@"===EditCuisineViewController,dealloc===");
#endif
}

#pragma mark PUBLIC METHODS

- (void)addLocalizedString
{
    self.titleLabel.text = kLoc(@"editing_cuisine");
    self.addCuisineTextField.placeholder = kLoc(@"please_enter_cuisine_name");
}

- (void)addPictureToView
{
    bgImageView.image = [UIImage imageFromMainBundleFile:@"dishCard_editBg.png"];
}

//在dishCardDict不为空的情况下，更新菜牌主页面的数据
- (void)dismissView:(NSDictionary *)dishCardDict
{
    if ([delegate respondsToSelector:@selector(dismissViewOfEditCuisineViewController: withLastestDishCardData:)])
    {
        [delegate dismissViewOfEditCuisineViewController:self withLastestDishCardData:dishCardDict];
    }
}

- (void)hideKeyBoard
{
    [addCuisineTextField resignFirstResponder];
    [cuisineSelectedCell.cuisineTextField resignFirstResponder];
}

#pragma mark - UIButton Clicked

- (IBAction)cancelButtonPressed:(UIButton*)sender
{
    [self hideKeyBoard];
    [self dismissView:nil];
}

- (IBAction)doneButtonPressed:(UIButton*)sender
{
    [self hideKeyBoard];
    for (int i = 0; i < [cuisineArray count]; i++)
    {
        NSString *tempString = [[[cuisineArray objectAtIndex:i]objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (0 == [tempString length])
        {
            [PSAlertView showWithMessage:kLoc(@"cuisine_name_can_not_be_empty")];
            return;
        }
    }
    [self saveCuisineData];
}

- (IBAction)addButtonPressed:(UIButton*)sender
{
    NSString *tempString = [addCuisineTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (0 == [tempString length])
    {
        [self hideKeyBoard];
        [PSAlertView showWithMessage:kLoc(@"please_enter_cuisine_name")];
        addCuisineTextField.text = @"";
        return;
    }
    //截取字符串
    NSString *cutString = [NSString cutString:addCuisineTextField.text withMaxLengthOfStr:kCuisineNameLength];
    addCuisineTextField.text = cutString;
    //判断菜系名称是否重复了
    BOOL isRepeat = NO;
    for (NSDictionary *cuisineDict in cuisineArray)
    {
        NSString *cuisineName = [cuisineDict objectForKey:@"name"];
        if ([cuisineName isEqualToString:self.addCuisineTextField.text])
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
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithCapacity:3];
    [tempDict setObject:addCuisineTextField.text forKey:@"name"];
    [tempDict setObject:@"0" forKey:@"id"];
    [cuisineArray insertObject:tempDict atIndex:0];
    [cuisineTableView reloadData];
    [cuisineTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    addCuisineTextField.text = @"";
}

/**
 * 显示提示语，当区域名重复时
 */
- (void)showWarnWhenAreaNameRepeat
{
    [self hideKeyBoard];
    [PSAlertView showWithMessage:kLoc(@"duplicated_cuisine_name")];
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

- (void)keyboardWillShow:(NSNotification*)sender
{
    cuisineTableView.scrollEnabled = NO;
    [cuisineTableView setContentOffset:CGPointMake(0, cuisineSelectedCell.frame.origin.y) animated:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    cuisineTableView.scrollEnabled = YES;
    [cuisineTableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark network

//读取菜系数据
- (void)getCuisineData
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
   [jsonPicker postData:postData withBaseRequest:@"cookbook/getCuisineList"];
}

//保存菜系数据
- (void)saveCuisineData
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 1;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"saving_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = kLoc(@"submit_succeed");
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:cuisineArray];
    [tempArray addObjectsFromArray:deleteCuisineArray];
    [postData setObject:tempArray forKey:@"cuisineList"];
    ///jhh_changed_保存菜系
    [jsonPicker postData:postData withBaseRequest:@"cookbook/saveCuisineList"];
}

#pragma mark EditCuisineTableViewCell delegate

- (void)deleteCuisine:(EditCuisineTableViewCell*)ctrl
{
    if (ctrl.tag < [cuisineArray count])
    {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[cuisineArray objectAtIndex:ctrl.tag]];
        [tempDict setObject:@"" forKey:@"name"];
        [deleteCuisineArray addObject:tempDict];
        [cuisineArray removeObjectAtIndex:ctrl.tag];
        [cuisineTableView reloadData];
    }
}

- (void)cuisineNameChange:(EditCuisineTableViewCell *)cell withNewCuisineName:(NSString *)name
{
    NSInteger cuisineIndex = cell.tag;
    if (cuisineIndex < [cuisineArray count])
    {
        //判断菜系名称是否重复了
        BOOL isRepeat = NO;
        NSInteger tempIndex = 0;
        for (NSDictionary *cuisineDict in cuisineArray)
        {
            if (tempIndex != cuisineIndex)
            {
                NSString *areaName = [cuisineDict objectForKey:@"name"];
                if ([areaName isEqualToString:name])
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
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[cuisineArray objectAtIndex:cuisineIndex]];
            [tempDict setObject:name forKey:@"name"];
            [cuisineArray replaceObjectAtIndex:cuisineIndex withObject:tempDict];
        }
        /*避免收键盘与刷新冲突*/
        [self.cuisineTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }
}

- (void)moveViewUpWhenKeyboardShow:(EditCuisineTableViewCell *)cell
{
    cuisineSelectedCell = cell;
    //tableviewContentOffset = cuisineTableView.contentOffset;
    //cuisineTableView.scrollEnabled = NO;
    [cuisineTableView setContentOffset:CGPointMake(0, cell.frame.origin.y) animated:YES];
}

//键盘输入的界面调整
- (void)moveViewBackWhenKeyboardHide:(EditCuisineTableViewCell *)cell
{
    //cuisineTableView.scrollEnabled = YES;
    //[cuisineTableView setContentOffset:tableviewContentOffset animated:YES];
}

#pragma mark UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kEditCuisineTableViewCellReuseIdentifier;
    EditCuisineTableViewCell *cell = (EditCuisineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"EditCuisineTableViewCell" owner:self options:nil]lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
	}
    int indexForCell = indexPath.row;
    cell.tag = indexForCell;
    int cuisineCount = [cuisineArray count];
    if (indexForCell < cuisineCount)
    {
        [cell refreshCellAfterGetData:[cuisineArray objectAtIndex:indexForCell]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 65;
	return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cuisineArray count];
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

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSUInteger fromRow = [sourceIndexPath row];
    NSUInteger toRow = [destinationIndexPath row];
    
    id object = [cuisineArray objectAtIndex:fromRow];
    [cuisineArray removeObjectAtIndex:fromRow];
    [cuisineArray insertObject:object atIndex:toRow];
    
    [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITextFidld delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    cuisineTableView.scrollEnabled = NO;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //截取字符串
    NSString *tempString = [NSString cutString:textField.text withMaxLengthOfStr:kCuisineNameLength];
    textField.text = tempString;
    cuisineTableView.scrollEnabled = YES;
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (_cuisineNameMaxLen != 0 && range.location >= _cuisineNameMaxLen)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [addCuisineTextField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

#pragma mark JsonPickerDelegate
-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    if (picker.tag==0)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            case 200:
            {
                [cuisineArray removeAllObjects];
                [cuisineArray addObjectsFromArray:[[dict objectForKey:@"data"]objectForKey:@"cuisineList"]];
                _cuisineNameMaxLen = [[[dict objectForKey:@"data"] objectForKey:@"cuisineNameMaxLen"] intValue];
                //刷新页面
                [cuisineTableView reloadData];
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                break;
            }
        }
    }
    
    if (picker.tag==1)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            //保存成功
            case 200:
            {
                [self performSelector:@selector(dismissView:) withObject:dict afterDelay:1.0];
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
