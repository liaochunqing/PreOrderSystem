//
//  TakeOutShopListView.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-30.
//
//

#import "TakeOutShopListView.h"
#import "NsstringAddOn.h"
#import "TakeOutShopTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface TakeOutShopListView ()
{
    NSArray *shopArray;
}

@end

@implementation TakeOutShopListView

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

- (void)updateTakeOutShopListView:(NSArray *)array
{
    // 限制最大高度
    int height = 40 * array.count;
    height = MIN(200, height);
    
    CGRect selfFrame = self.frame;
    selfFrame.size.height = height;
    self.frame = selfFrame;
    
    shopArray = array;
    [self.styleTableView reloadData];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = kTakeOutShopTableViewCellIdentifier;
    NSInteger indexRow = indexPath.row;
    TakeOutShopTableViewCell *cell = (TakeOutShopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TakeOutShopTableViewCell" owner:self options:nil] lastObject];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.tag = indexRow;
    BOOL lineFlag = YES;
    if (indexRow == ([shopArray count] - 1))
    {
        lineFlag = NO;
    }
    NSString *shopName = [[shopArray objectAtIndex:indexRow] objectForKey:@"name"];
    [cell uopdateTakeOutShopListCell:shopName withShowLineFlag:lineFlag];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [shopArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(takeOutShopListView:withSelectedShop:)])
    {
        NSInteger indexRow = indexPath.row;
        NSString *shopName = [[shopArray objectAtIndex:indexRow] objectForKey:@"name"];
        self.branchId = [[[shopArray objectAtIndex:indexRow] objectForKey:@"id"] integerValue];
        [self.delegate takeOutShopListView:self withSelectedShop:shopName];
    }
}

@end
