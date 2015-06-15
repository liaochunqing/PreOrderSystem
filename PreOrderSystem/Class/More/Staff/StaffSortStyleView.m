//
//  StaffSortStyleView.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-30.
//
//

#import "StaffSortStyleView.h"
#import "NsstringAddOn.h"
#import "StaffManagementSuperDataClass.h"
#import "StaffSortTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface StaffSortStyleView ()
{
    NSArray *styleArray;
}

@end

@implementation StaffSortStyleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 1.0;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%s===", __FUNCTION__);
#endif
}

- (void)updateStaffSortStyleView:(NSArray *)array
{
    styleArray = array;
    [self.styleTableView reloadData];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = kStaffSortTableViewCellIdentifier;
    NSInteger indexRow = indexPath.row;
    StaffSortTableViewCell *cell = (StaffSortTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"StaffSortTableViewCell" owner:self options:nil] lastObject];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.tag = indexRow;
    BOOL lineFlag = YES;
    if (indexRow == ([styleArray count] - 1))
    {
        lineFlag = NO;
    }
    StaffManagementSortDataClass *sortClass = [styleArray objectAtIndex:indexRow];
    [cell uopdatePostStyleCell:sortClass.name withShowLineFlag:lineFlag];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [styleArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(sortStyleHavedSelected:withSelectStyle:)])
    {
        self.styleIndex = indexPath.row;
        StaffManagementSortDataClass *sortClass = [styleArray objectAtIndex:self.styleIndex];
        [self.delegate sortStyleHavedSelected:self withSelectStyle:sortClass.name];
    }
}

@end
