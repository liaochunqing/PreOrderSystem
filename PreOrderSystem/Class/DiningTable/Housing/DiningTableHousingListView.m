//
//  DiningTableHousingListView.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import "DiningTableHousingListView.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DiningTableDataClass.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"
#import "UIViewController+MJPopupViewController.h"
#import "MainViewController.h"
#import "DiningTableImageName.h"
#import "Constants.h"
#import "DiningTableCommon.h"

@interface DiningTableHousingListView ()
{
    NSMutableArray *deleteHousingArray;
}

- (IBAction)backBtnClicked:(id)sender;
- (IBAction)trueBtnClicked:(id)sender;
- (IBAction)clearAllBtnClicked:(id)sender;
- (IBAction)addManyBtnClicked:(id)sender;
- (IBAction)addOnlyBtnClicked:(id)sender;

@end

@implementation DiningTableHousingListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addPictureToView];
        [self addLocalizedString];
        [self addNotifications];
    }
    return self;
}

- (void)addPictureToView
{
    UIImage *btnBgFirstImg = [UIImage imageFromMainBundleFile:@"dt_btnFirstBg.png"];
    UIImage *btnBgSecondImg = [UIImage imageFromMainBundleFile:@"dt_btnSecondBg.png"];
    self.bgImageView.image = [UIImage imageFromMainBundleFile:kDtAddAreadBgImageName];
    [self.backButton setBackgroundImage:btnBgSecondImg forState:UIControlStateNormal];
    [self.trueButton setBackgroundImage:btnBgSecondImg forState:UIControlStateNormal];
    [self.clearAllButton setBackgroundImage:btnBgFirstImg forState:UIControlStateNormal];
    [self.addManyButton setBackgroundImage:btnBgFirstImg forState:UIControlStateNormal];
    [self.addOnlyButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dt_addButton.png"] forState:UIControlStateNormal];
}

- (void)addLocalizedString
{
    self.addHousingTextField.placeholder = kLoc(@"click_to_add_housing");
    [self.backButton setTitle:kLoc(@"cancel") forState:UIControlStateNormal];
    [self.trueButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
    [self.clearAllButton setTitle:kLoc(@"a_key_to_remove") forState:UIControlStateNormal];
    [self.addManyButton setTitle:kLoc(@"add_multiple_item") forState:UIControlStateNormal];
}

- (void)reloadTableView
{
    [self deleteZeroObjectWhenHousingIsEmpty];
    [self.housingTableView setEditing:YES animated:YES];
    [self.housingTableView reloadData];
}

- (void)delayReLoadTableView
{
    [self.housingTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

- (void)updateTopTitle
{
    NSMutableString *topTitleStr = [[NSMutableString alloc]initWithFormat:@"%@",kLoc(@"room_table_to_settings_table_nujmber")];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:topTitleStr forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
}

- (void)deleteZeroObjectWhenHousingIsEmpty
{
    for (NSInteger i = 0; i < [self.housingArray count]; i++)
    {
        HousingDataClass *tempDataClass = [[HousingDataClass alloc] initWithHousingData:[self.housingArray objectAtIndex:i]];
        if ([NSString strIsEmpty:tempDataClass.housingName])
        {
            [self.housingArray removeObjectAtIndex:i];
            i--;
        }
    }
}

- (void)hideKeyBoard
{
    [self endEditing:YES];
}

#pragma mark - Public

- (void)updateHousingListView
{
    [self updateTopTitle];
    [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:0.3];
}

- (void)dismissHousingListView:(NSMutableArray *)array
{
    [self hideKeyBoard];
    [self dismissViewWithAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(dismissHousingListView:WithNewData:)])
    {
        [self.delegate dismissHousingListView:self WithNewData:array];
    }
}

#pragma mark dealloc

- (void)dealloc
{
    [self removeNotification];
    
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

#pragma mark UIButton Clicked

- (IBAction)backBtnClicked:(id)sender
{
    [self dismissHousingListView:nil];
}

- (IBAction)trueBtnClicked:(id)sender
{
    [self.housingArray addObjectsFromArray:deleteHousingArray];
    [self dismissHousingListView:self.housingArray];
}

- (IBAction)clearAllBtnClicked:(id)sender
{
    if (!deleteHousingArray)
    {
        deleteHousingArray = [[NSMutableArray alloc] init];
    }
    int tempCount = [self.housingArray count];
    for (int i = 0; i < tempCount; i++)
    {
        [deleteHousingArray addObject:[HousingDataClass deleteHousingData:self.housingArray withIndex:i]];
    }
    [self.housingArray removeAllObjects];
    [self delayReLoadTableView];
}

- (IBAction)addManyBtnClicked:(id)sender
{
    AddMoreHousingViewController *moreHousingVC = [[AddMoreHousingViewController alloc] initWithNibName:@"AddMoreHousingViewController" bundle:nil];
    moreHousingVC.delegate = self;
    [[MainViewController getMianViewShareInstance] presentPopupViewController:moreHousingVC animationType:MJPopupViewAnimationSlideBottomBottom];
    // 缩放视图
    scaleView(moreHousingVC.view);
}

- (IBAction)addOnlyBtnClicked:(id)sender
{
    [self addHousingToAreaArray];
}

/**
 * 添加区域
 */
- (void)addHousingToAreaArray
{
    NSString *housingStr = [NSString getStrWithoutWhitespace:self.addHousingTextField.text];
    if ([NSString strIsEmpty:housingStr])
    {
        [self hideKeyBoard];
        [PSAlertView showWithMessage:kLoc(@"click_to_add_housing")];
        return;
    }
    //在添加新房台号的时候,判断房台号名称是否重复了
    BOOL isRepeat = NO;
    for (NSDictionary *housingDict in self.housingArray)
    {
        NSString *housingName = [housingDict objectForKey:kHousingName];
        if ([housingName isEqualToString:housingStr])
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
    if ([NSString strIsOverMaxLen:housingStr withMaxLen:kDtHousingNameMaxLen])
    {
        [self hideKeyBoard];
        [PSAlertView showWithMessage:kLoc(@"housing_name_has_reached_max")];
    }
    NSString *lastAreaStr = [NSString cutString:housingStr withMaxLengthOfStr:kDtHousingNameMaxLen];
    [HousingDataClass addNewHousingData:self.housingArray withHousingStr:lastAreaStr];
    self.addHousingTextField.text = @"";
    [self delayReLoadTableView];
}

/**
 * 显示提示语，当区域名重复时
 */
- (void)showWarnWhenAreaNameRepeat
{
    [self hideKeyBoard];
    [PSAlertView showWithMessage:kLoc(@"duplicated_housing_name")];
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
    keyboardRect = [self convertRect:keyboardRect fromView:window];
    CGRect intersectionOfKeyboardRectAndWindowRect = CGRectIntersection(window.frame, keyboardRect);
    CGFloat bottomInset = intersectionOfKeyboardRectAndWindowRect.size.height;
    self.housingTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset,0.0f);
    self.housingTableView.scrollEnabled = NO;
        
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
    
    self.housingTableView.scrollEnabled = YES;
    self.housingTableView.contentInset = UIEdgeInsetsZero;
        
    [UIView commitAnimations];
}

#pragma mark UITextFidld delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyBoard];
    return YES;
}

#pragma mark UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"HousingListTableViewCell";
    HousingListTableViewCell *cell = (HousingListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"HousingListTableViewCell" owner:self options:nil]lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
	}
    int indexForCell = indexPath.row;
    cell.tag = indexForCell;
    
    NSArray *tempArray = self.housingArray;
    if (indexForCell < [tempArray count])
    {
        HousingDataClass *tempDataClass = [[HousingDataClass alloc] initWithHousingData:[tempArray objectAtIndex:indexForCell]];
        [cell refreshCellAfterGetData:tempDataClass.housingName];
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
    return [self.housingArray count];
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
    
    id object = [self.housingArray objectAtIndex:fromRow];
    [self.housingArray removeObjectAtIndex:fromRow];
    [self.housingArray insertObject:object atIndex:toRow];
    
    [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - HousingListTableViewCell delegate

- (void)deleteHousing:(HousingListTableViewCell *)cell
{
    int index = cell.tag;
    if (index < [self.housingArray count])
    {
        if (!deleteHousingArray)
        {
            deleteHousingArray = [[NSMutableArray alloc] init];
        }
        NSDictionary *tempDict = [HousingDataClass deleteHousingData:self.housingArray withIndex:index];
        [deleteHousingArray addObject:tempDict];
        [self.housingArray removeObjectAtIndex:index];
        [self delayReLoadTableView];
    }
}

- (void)housingNameChange:(HousingListTableViewCell *)cell withNewHousingName:(NSString *)name
{
    NSInteger housingIndex = cell.tag;
    if (housingIndex < [self.housingArray count])
    {
        //在修改区域的时候,判断区域名称是否重复了
        BOOL isRepeat = NO;
        NSInteger tempIndex = 0;
        for (NSDictionary *housingDict in self.housingArray)
        {
            if (tempIndex != housingIndex)
            {
                NSString *areaName = [housingDict objectForKey:kHousingName];
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
            [HousingDataClass modifyHousingData:self.housingArray withHousingName:name withIndex:housingIndex];
        }
        [self delayReLoadTableView];
    }
}

#pragma mark AddMoreHousingViewControllerDelegate

- (void)addMoreHousingViewController:(AddMoreHousingViewController *)ctrl withNewHousingData:(NSArray *)housingArray
{
    [self.housingArray addObjectsFromArray:housingArray];
    [self deleteZeroObjectWhenHousingIsEmpty];
    [self delayReLoadTableView];
    [self dismissPopupViewController];
}

- (void)dismissPopupViewController
{
    if (kIsiPhone) {
        // iPhone版使用渐变动画，否则会出现215度角移动效果
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    } else {
        [[MainViewController getMianViewShareInstance] dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
}

@end
