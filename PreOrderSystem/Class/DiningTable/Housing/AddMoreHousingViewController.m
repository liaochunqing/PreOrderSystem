//
//  AddMoreHousingViewController.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-23.
//
//

#import "AddMoreHousingViewController.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DiningTableDataClass.h"
#import "NsstringAddOn.h"
#import "DiningTableCommon.h"

@interface AddMoreHousingViewController ()
{
    NSMutableArray *housingArray;
    AddMoreHousingTableViewCell *selectTableViewCell;
}

- (IBAction)cancelBtnClicked:(UIButton*)sender;
- (IBAction)finishBtnClicked:(UIButton*)sender;

@end

@implementation AddMoreHousingViewController

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
    
    housingArray = [[NSMutableArray alloc] init];
    [self addPictureToView];
    [self addNotifications];
    [self.addHousingTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.3];
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
    self.titleLabel.text = kLoc(@"input_multi_table_number");
    self.promptLabel.text = kLoc(@"press_return_key_to_add_multiple_housings");
    self.maxLenLabel.text = kLoc(@"housing_name_has_reached_max");
}

- (void)executeDelegateMethod:(NSArray *)array
{
    [self hideKeyBoard];
    if ([self.delegate respondsToSelector:@selector(addMoreHousingViewController:withNewHousingData:)])
    {
        [self.delegate addMoreHousingViewController:self withNewHousingData:array];
    }
}

- (void)delayReLoadTableView
{
    [self.housingTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

- (void)hideKeyBoard
{
    [self.addHousingTextField resignFirstResponder];
    [selectTableViewCell.housingTextField resignFirstResponder];
}

- (IBAction)cancelBtnClicked:(UIButton*)sender
{
    [self executeDelegateMethod:nil];
}

- (IBAction)finishBtnClicked:(UIButton*)sender
{
    [self executeDelegateMethod:housingArray];
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
    self.housingTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset - 180,0.0f);
    self.housingTableView.scrollEnabled = NO;
    
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
    
    self.housingTableView.scrollEnabled = YES;
    self.housingTableView.contentInset = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}

#pragma mark - AddMoreHousingTableViewCellDelegate

- (void)deleteHousing:(AddMoreHousingTableViewCell*)cell;
{
    int index = cell.tag;
    if (index < [housingArray count])
    {
        [housingArray removeObjectAtIndex:index];
        [self delayReLoadTableView];
    }
}

- (void)housingNameChange:(AddMoreHousingTableViewCell*)cell withNewHousingName:(NSString *)name 
{
    int index = cell.tag;
    if (index < [housingArray count])
    {
        [HousingDataClass modifyHousingData:housingArray withHousingName:name withIndex:index];
        [self delayReLoadTableView];
    }
#ifdef DEBUG
    NSLog(@"===%@,housingArray:%@===",self.class,housingArray);
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
    NSString *tempStr = [NSString getStrWithoutWhitespace:self.addHousingTextField.text];
    if (!([NSString strIsEmpty:tempStr]))
    {
        NSString *lastAreaStr = [NSString cutString:tempStr withMaxLengthOfStr:kDtHousingNameMaxLen];
        [HousingDataClass addNewHousingData:housingArray withHousingStr:lastAreaStr];
        self.addHousingTextField.text = @"";
        [self delayReLoadTableView];
    }
    return YES;
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AddMoreHousingTableViewCell";
    AddMoreHousingTableViewCell *cell = (AddMoreHousingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"AddMoreHousingTableViewCell" owner:self options:nil]lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
	}
    int indexForCell = indexPath.row;
    cell.tag = indexForCell;
    
    int tempCount = [housingArray count];
    if (indexForCell < tempCount)
    {
        HousingDataClass *tempDataClass = [[HousingDataClass alloc] initWithHousingData:[housingArray objectAtIndex:indexForCell]];
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
    return [housingArray count];
}

@end
