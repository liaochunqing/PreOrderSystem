//
//  PostStyleView.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-30.
//
//

#import "PostStyleView.h"
#import "NsstringAddOn.h"
#import "StaffManagementSuperDataClass.h"
#import "PostStyleTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface PostStyleView ()
{
    NSArray *styleArray;
}

@end

@implementation PostStyleView

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

- (void)updatePostStyleView:(NSArray *)array
{
    styleArray = array;
    [self.styleTableView reloadData];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = kPostStyleTableViewCellIdentifier;
    NSInteger indexRow = indexPath.row;
    PostStyleTableViewCell *cell = (PostStyleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PostStyleTableViewCell" owner:self options:nil] lastObject];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.tag = indexRow;
    BOOL lineFlag = YES;
    if (indexRow == ([styleArray count] - 1))
    {
        lineFlag = NO;
    }
    StaffManagementPostDataClass *postClass = [styleArray objectAtIndex:indexRow];
    [cell uopdatePostStyleCell:postClass.postName withShowLineFlag:lineFlag];
    
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
    if ([self.delegate respondsToSelector:@selector(postStyleHavedSelected:withSelectStyle:)])
    {
        self.styleIndex = indexPath.row;
        StaffManagementPostDataClass *postClass = [styleArray objectAtIndex:self.styleIndex];
        [self.delegate postStyleHavedSelected:self withSelectStyle:postClass.postName];
    }
}

@end
