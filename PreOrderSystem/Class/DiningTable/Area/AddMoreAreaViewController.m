//
//  AddMoreAreaViewController.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-23.
//
//

#import "AddMoreAreaViewController.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DiningTableDataClass.h"
#import "NsstringAddOn.h"
#import "DiningTableCommon.h"
#import "PSAlertView.h"

@interface AddMoreAreaViewController ()
{
    NSMutableArray *areaArray;
    AddMoreAreaTableViewCell *selectTableViewCell;
}

- (IBAction)cancelBtnClicked:(UIButton*)sender;
- (IBAction)finishBtnClicked:(UIButton*)sender;

@end

@implementation AddMoreAreaViewController

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
    
    areaArray = [[NSMutableArray alloc] init];
    [self addPictureToView];
    [self addNotifications];
    [self.addAreaTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.3];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self removeNotification];
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (void)addPictureToView
{
    self.bgImageView.image = [UIImage imageFromMainBundleFile:@"dt_addHousingBg.png"];
    self.lineImageView.image = [UIImage imageFromMainBundleFile:@"dt_addLine.png"];
    [self.cancelButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dt_cancleBtn.png"] forState:UIControlStateNormal];
    [self.finishButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dt_trueBtn.png"] forState:UIControlStateNormal];
}

- (void)addLocalizedString
{
    self.titleLabel.text = kLoc(@"input_multi_area");
    self.promptLabel.text = kLoc(@"press_return_key_to_add_multiple_areas");
    self.maxLenLabel.text = kLoc(@"area_name_has_reached_max");
}

- (void)executeDelegateMethod:(NSArray *)array
{
    [self hideKeyBoard];
    if ([self.delegate respondsToSelector:@selector(addMoreAreaViewController:withNewAreaData:)])
    {
        [self.delegate addMoreAreaViewController:self withNewAreaData:array];
    }
}

- (void)delayReLoadTableView
{
    [self.areaTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

- (void)hideKeyBoard
{
    [self.addAreaTextField resignFirstResponder];
    [selectTableViewCell.areaTextField resignFirstResponder];
}

- (IBAction)cancelBtnClicked:(UIButton*)sender
{
    [self executeDelegateMethod:nil];
}

- (IBAction)finishBtnClicked:(UIButton*)sender
{
    [self executeDelegateMethod:areaArray];
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
    self.areaTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset - 180,0.0f);
    self.areaTableView.scrollEnabled = NO;
    
    [UIView commitAnimations];
    
#ifdef DEBUG
    NSLog(@"===%@,keyboardWillShow:%@,bottomInset:%f",self.class,NSStringFromCGRect(keyboardRect),bottomInset);
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

#pragma mark - AddMoreAreaTableViewCellDelegate

- (void)deleteArea:(AddMoreAreaTableViewCell *)cell;
{
    int index = cell.tag;
    if (index < [areaArray count])
    {
        [areaArray removeObjectAtIndex:index];
        [self delayReLoadTableView];
    }
}

- (void)areaNameChange:(AddMoreAreaTableViewCell *)cell withNewAreaName:(NSString *)name
{
    int index = cell.tag;
    if (index < [areaArray count])
    {
        [AreaDataClass modifyAreaData:areaArray withAreaName:name withIndex:index];
        [self delayReLoadTableView];
    }
#ifdef DEBUG
    NSLog(@"===%@,areaNameChange:%@===",self.class,areaArray);
#endif
}

- (void)keyboardShow:(id)cell
{
    selectTableViewCell = cell;
}

- (void)keyboardHide:(id)cell
{
    selectTableViewCell = nil;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *tempStr = [NSString getStrWithoutWhitespace:self.addAreaTextField.text];
    if (!([NSString strIsEmpty:tempStr]))
    {
        NSString *lastAreaStr = [NSString cutString:tempStr withMaxLengthOfStr:kDtAreaNameMaxLen];
        [areaArray addObject:[AreaDataClass addNewAreaData:lastAreaStr]];
        self.addAreaTextField.text = @"";
        [self delayReLoadTableView];
    }
    return YES;
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AddMoreAreaTableViewCell";
    AddMoreAreaTableViewCell *cell = (AddMoreAreaTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"AddMoreAreaTableViewCell" owner:self options:nil]lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
	}
    int indexForCell = indexPath.row;
    cell.tag = indexForCell;
    
    int tempCount = [areaArray count];
    if (indexForCell < tempCount)
    {
         AreaDataClass *tempDataClass = [[AreaDataClass alloc] initWithAreaData:[areaArray objectAtIndex:indexForCell]];
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
    return [areaArray count];
}

@end
