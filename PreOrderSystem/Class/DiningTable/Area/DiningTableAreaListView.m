//
//  DiningTableAreaListView.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import "DiningTableAreaListView.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DiningTableDataClass.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"
#import "UIViewController+MJPopupViewController.h"
#import "MainViewController.h"
#import "DiningTableImageName.h"
#import "Constants.h"
#import "DiningTableCommon.h"

@interface DiningTableAreaListView ()
{
    JsonPicker *jsonPicker;
    NSMutableArray *deleteAreaArray;
    DiningTableHousingListView *housingListView;
}

- (IBAction)backBtnClicked:(id)sender;
- (IBAction)trueBtnClicked:(id)sender;
- (IBAction)clearAllBtnClicked:(id)sender;
- (IBAction)addManyBtnClicked:(id)sender;
- (IBAction)addOnlyBtnClicked:(id)sender;

@end

@implementation DiningTableAreaListView

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
    self.addAreaTextField.placeholder = kLoc(@"click_to_add_area");
    [self.backButton setTitle:kLoc(@"cancel") forState:UIControlStateNormal];
    [self.trueButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
    [self.clearAllButton setTitle:kLoc(@"a_key_to_remove") forState:UIControlStateNormal];
    [self.addManyButton setTitle:kLoc(@"add_multiple_item") forState:UIControlStateNormal];
}

- (void)reloadTableView
{
    [self.areaTableView setEditing:YES animated:YES];
    [self.areaTableView reloadData];
}

- (void)delayReLoadTableView
{
    [self.areaTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

- (void)updateTopTitle
{
    NSMutableString *topTitleStr = [[NSMutableString alloc]initWithFormat:@"%@",kLoc(@"room_table_to_settings_area")];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:topTitleStr forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
}

- (void)hideKeyBoard
{
    [self endEditing:YES];
}

#pragma mark - Public

- (void)updateAreaListView
{
    [self updateTopTitle];
    [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:0.3];
}

- (void)dismissAreaListView:(NSMutableArray *)areaArray
{
    [housingListView dismissHousingListView:nil];
    [self hideKeyBoard];
    [self dismissViewWithAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(dismissAreaViewWithNewData:)])
    {
        [self.delegate dismissAreaViewWithNewData:areaArray];
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
    [self dismissAreaListView:nil];
}

- (IBAction)trueBtnClicked:(id)sender
{
    [self hideKeyBoard];
    [self commitDiningTableData:YES];
}

- (IBAction)clearAllBtnClicked:(id)sender
{
    if (!deleteAreaArray)
    {
        deleteAreaArray = [[NSMutableArray alloc] init];
    }
    int tempCount = [self.diningTableListArray count];
    for (int i = 0; i < tempCount; i++)
    {
        [deleteAreaArray addObject:[AreaDataClass deleteAreaData:self.diningTableListArray withIndex:i]];
    }
    [self.diningTableListArray removeAllObjects];
    [self delayReLoadTableView];
}

- (IBAction)addManyBtnClicked:(id)sender
{
    AddMoreAreaViewController *moreAreaVC = [[AddMoreAreaViewController alloc] initWithNibName:@"AddMoreAreaViewController" bundle:nil];
    moreAreaVC.delegate = self;
    [[MainViewController getMianViewShareInstance] presentPopupViewController:moreAreaVC animationType:MJPopupViewAnimationSlideBottomBottom];
    // 缩放视图
    scaleView(moreAreaVC.view);
}

- (IBAction)addOnlyBtnClicked:(id)sender
{
    [self addAreaToDTListArray];
}

/**
 * 添加区域
 */
- (void)addAreaToDTListArray
{
    NSString *newAreaStr = [NSString getStrWithoutWhitespace:self.addAreaTextField.text];
    if ([NSString strIsEmpty:newAreaStr])
    {
        [self hideKeyBoard];
        [PSAlertView showWithMessage:kLoc(@"click_to_add_area")];
        return;
    }
    //在添加新区域的时候,判断区域名称是否重复了
    BOOL isRepeat = NO;
    for (NSDictionary *areaDict in self.diningTableListArray)
    {
        NSString *areaName = [areaDict objectForKey:kAreaDataClassTypeNameKey];
        if ([areaName isEqualToString:newAreaStr])
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
    if ([NSString strIsOverMaxLen:newAreaStr withMaxLen:kDtAreaNameMaxLen])
    {
        [self hideKeyBoard];
        [PSAlertView showWithMessage:kLoc(@"area_name_has_reached_max")];
    }
    NSString *lastAreaStr = [NSString cutString:newAreaStr withMaxLengthOfStr:kDtAreaNameMaxLen];
    [self.diningTableListArray addObject:[AreaDataClass addNewAreaData:lastAreaStr]];
    self.addAreaTextField.text = @"";
    [self delayReLoadTableView];
}

/**
 * 显示提示语，当区域名重复时
 */
- (void)showWarnWhenAreaNameRepeat
{
    [self hideKeyBoard];
    [PSAlertView showWithMessage:kLoc(@"duplicated_area_name")];
}

#pragma mark network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

- (void)commitDiningTableData:(BOOL)animated
{
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    /*避免提交数据失败，self.diningTableListArray受影响*/
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:self.diningTableListArray];
    [tempArray addObjectsFromArray:deleteAreaArray];
    [postData setObject:tempArray forKey:@"diningTable"];
    
    if (!jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = YES;
    if (!animated) {
        jsonPicker.loadingMessage = nil;
    }
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:@"diningtable/edit"];
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
    keyboardRect = [self convertRect:keyboardRect fromView:window];
    CGRect intersectionOfKeyboardRectAndWindowRect = CGRectIntersection(window.frame, keyboardRect);
    CGFloat bottomInset = intersectionOfKeyboardRectAndWindowRect.size.height;
    self.areaTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset,0.0f);
    self.areaTableView.scrollEnabled = NO;
        
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
    
    self.areaTableView.scrollEnabled = YES;
    self.areaTableView.contentInset = UIEdgeInsetsZero;
        
    [UIView commitAnimations];
}

#pragma mark UITextFidld delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyBoard];
    return YES;
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AreaListTableViewCell";
    AreaListTableViewCell *cell = (AreaListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"AreaListTableViewCell" owner:self options:nil]lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
	}
    int indexForCell = indexPath.row;
    cell.tag = indexForCell;
    
    NSArray *tempArray = self.diningTableListArray;
    if (indexForCell < [tempArray count])
    {
        AreaDataClass *tempDataClass = [[AreaDataClass alloc] initWithAreaData:[tempArray objectAtIndex:indexForCell]];
        [cell refreshCellAfterGetData:tempDataClass.typeName];
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
    return [self.diningTableListArray count];
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
    
    id object = [self.diningTableListArray objectAtIndex:fromRow];
    [self.diningTableListArray removeObjectAtIndex:fromRow];
    [self.diningTableListArray insertObject:object atIndex:toRow];
    
    [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark AreaListTableViewCell delegate

- (void)deleteArea:(AreaListTableViewCell*)cell
{
    int index = cell.tag;
    if (index < [self.diningTableListArray count])
    {
        if (!deleteAreaArray)
        {
            deleteAreaArray = [[NSMutableArray alloc] init];
        }
        NSDictionary *tempDict = [AreaDataClass deleteAreaData:self.diningTableListArray withIndex:index];
        [deleteAreaArray addObject:tempDict];
        [self.diningTableListArray removeObjectAtIndex:index];
        [self delayReLoadTableView];
    }
}

- (void)areaNameChange:(AreaListTableViewCell*)cell withNewAreaName:(NSString *)name
{
    int areaIndex = cell.tag;
    if (areaIndex < [self.diningTableListArray count])
    {
        //在修改区域的时候,判断区域名称是否重复了
        BOOL isRepeat = NO;
        NSInteger tempIndex = 0;
        for (NSDictionary *areaDict in self.diningTableListArray)
        {
            if (tempIndex != areaIndex)
            {
                NSString *areaName = [areaDict objectForKey:kAreaDataClassTypeNameKey];
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
            [AreaDataClass modifyAreaData:self.diningTableListArray withAreaName:name withIndex:areaIndex];
        }
        [self delayReLoadTableView];
    }
}

- (void)gotoHousingListView:(AreaListTableViewCell*)cell
{
    int index = cell.tag;
    if (index < [self.diningTableListArray count])
    {
         NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[self.diningTableListArray objectAtIndex:index]];
        AreaDataClass *tempClass = [[AreaDataClass alloc] initWithAreaData:tempDict];
        
        if (!housingListView)
        {
            housingListView = [[DiningTableHousingListView alloc] initWithFrame:CGRectZero];
        }
        housingListView.delegate = self;
        housingListView.tag = index;
        housingListView.housingArray = [[NSMutableArray alloc] initWithArray:tempClass.housingDataArray];
        [housingListView showInView:self withOriginPoint:CGPointZero withAnimated:YES];
        [housingListView updateHousingListView];
    }
}

#pragma mark - DiningTableHousingListViewDelegate

- (void)dismissHousingListView:(DiningTableHousingListView *)listView WithNewData:(NSMutableArray *)housingArray
{
    int index = listView.tag;
    if ((index < [self.diningTableListArray count]) && housingArray)
    {
        [AreaDataClass modifyAreaData:self.diningTableListArray withHousingData:housingArray withIndex:index];
    }
    [self updateTopTitle];
}

#pragma mark - AddMoreAreaViewControllerDelegete

- (void)addMoreAreaViewController:(AddMoreAreaViewController *)ctrl withNewAreaData:(NSArray *)areaArray
{
    int tempCount = [areaArray count];
    for (int i = 0; i < tempCount; i++)
    {
        [self.diningTableListArray addObject:[areaArray objectAtIndex:i]];
    }
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

#pragma mark - JsonPickerDelegate

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    if (kJsonPickerFirstTag == picker.tag)
    {
        SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
        switch (dataClass.responseStatus)
        {
            case kFirstResponseStatus:
            {
                DiningTableDataClass *tempClass = [[DiningTableDataClass alloc] initWithDiningTableData:dataClass.dataDict];
                self.diningTableListArray = tempClass.diningTableDataArray;
                [self dismissAreaListView:self.diningTableListArray];
 
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:dataClass.alertMsg];
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
