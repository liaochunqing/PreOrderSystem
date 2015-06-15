//
//  ReasonViewController.m
//  PreOrderSystem
//
//  Created by sWen on 13-7-3.
//
//

#import "ReasonViewController.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "ReasonTableViewCell.h"

@interface ReasonViewController ()
{
    int selectedIndex;
    BOOL isSelected;
}

- (IBAction)cancelBtnClicked:(id)sender;
- (IBAction)trueBtnClicked:(id)sender;

@end

@implementation ReasonViewController

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
    
    self.titleLabel.text = kLoc(@"confirm_to_cancel_order_please_leave_a_reason");
    [self addPictureToView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (IBAction)cancelBtnClicked:(id)sender
{
    [self.reasonTextView resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(reasonViewController:didDismissView:)])
    {
        [self.delegate reasonViewController:self didDismissView:YES];
    }
}

- (IBAction)trueBtnClicked:(id)sender
{
    [self.reasonTextView resignFirstResponder];
    
    NSString *selectReasonStr = @"";
    if (selectedIndex > -1 && isSelected && selectedIndex < [self.reasonOptionsArray count])
    {
        selectReasonStr = [self.reasonOptionsArray objectAtIndex:selectedIndex];
    }
    NSString *tempStr = [self.reasonTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *writeReasonStr = (0 == [tempStr length])?@"":tempStr;
    
    NSString *reasonStr = [NSString stringWithFormat:@"%@ %@",writeReasonStr,selectReasonStr];
    NSString *reasonStrWithOutSpace = [reasonStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([self.delegate respondsToSelector:@selector(reasonViewController:submitReason:)])
    {
        [self.delegate reasonViewController:self submitReason:reasonStrWithOutSpace];
    }
}

- (void)addPictureToView
{
    self.bgImageView.image = [UIImage imageFromMainBundleFile:@"order_reasonBg.png"];
    self.textBgView.image = [UIImage imageFromMainBundleFile:@"order_reasonTextField.png"];
    [self.cancelBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"order_cancleBtn.png"] forState:UIControlStateNormal];
    [self.finishBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"order_trueBtn.png"] forState:UIControlStateNormal];
}

#pragma mark UITableViewController datasource & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    ReasonTableViewCell *cell = (ReasonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReasonTableViewCell" owner:self options:nil] lastObject];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    [cell updateViewAfterGetData:[self.reasonOptionsArray objectAtIndex:indexPath.row]];
    
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.reasonOptionsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.reasonTextView resignFirstResponder];
    
    int indexRow = indexPath.row;
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedIndex
                                                   inSection:0];
    ReasonTableViewCell *oldCell = (ReasonTableViewCell *)[tableView cellForRowAtIndexPath:oldIndexPath];
    ReasonTableViewCell *newCell = (ReasonTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (selectedIndex == indexRow && isSelected)
    {
        newCell.titleImageView.image = [UIImage imageFromMainBundleFile:@"order_sexNormalButton.png"];
        isSelected = NO;
    }
    else
    {
        oldCell.titleImageView.image = [UIImage imageFromMainBundleFile:@"order_sexNormalButton.png"];
        newCell.titleImageView.image = [UIImage imageFromMainBundleFile:@"order_sexSelectedButton.png"];
        isSelected = YES;
    }
    selectedIndex = indexPath.row;
}

@end
