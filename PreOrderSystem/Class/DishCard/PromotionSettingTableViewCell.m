//
//  PromotionSettingTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-7-2.
//
//

#import "PromotionSettingTableViewCell.h"
#import "PromoteCookBookGroupDataModel.h"
#import "PromotionSettingDetailTableViewCell.h"

@implementation PromotionSettingTableViewCell
{
    PromoteCookBookGroupDataModel *_PromoteCookBookGroup;
    NSMutableDictionary *_PromoteCookBookDict;
    NSArray *_cookbookArray;
    UITableView *_tableView; // 详情列表
}

- (void)awakeFromNib
{
    // Initialization code
    _tableView = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)updateData:(id) info;
{
    //设置图片
    [self.checkButton setBackgroundImage:[UIImage imageNamed:@"more_item_unchecked.png"] forState:UIControlStateNormal];
    [self.checkButton setImage:[UIImage imageNamed:@"more_item_checked.png"] forState:UIControlStateSelected];
    [self.checkButton setBackgroundImage:[UIImage imageNamed:@"more_item_unchecked.png"] forState:UIControlStateSelected];
     
    self.upDownImageView.image = [UIImage imageNamed:@"order_shopDownArrow"];
    
    _PromoteCookBookGroup = (PromoteCookBookGroupDataModel *)info;
    self.checkButton.selected = _PromoteCookBookGroup.isSelected;
    
    if ([_PromoteCookBookGroup.promoteName isKindOfClass:[NSNull class]])
    {
        self.nameLabel.text = @"";
    }
    else
    {
        self.nameLabel.text = _PromoteCookBookGroup.promoteName;
    }
    
    if (_PromoteCookBookGroup.isSpread)
    {
        [self didSelectedSetting];
    }
    else
    {
        [self didDeselectedSetting];
    }
}

- (void)didSelectedSetting
{
    self.upDownImageView.image = [UIImage imageNamed:@"order_shopUpArrow"];
//    self.contentView.backgroundColor = [UIColor lightGrayColor];
    
    if (_tableView == nil)//
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.contentView.frame) - 1, self.contentView.frame.size.width , _PromoteCookBookGroup.groupCookbookArr.count * kTableViewCellHight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        _tableView.backgroundColor = [UIColor lightGrayColor];
        _tableView.layer.borderWidth = 1;
        _tableView.bounces = NO;
        _tableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.contentView addSubview:_tableView];
    }
    else
    {
        _tableView.hidden = NO;
        CGRect frame = _tableView.frame;
        frame.size.height = _PromoteCookBookGroup.groupCookbookArr.count * kTableViewCellHight;
        _tableView.frame = frame;
        [_tableView reloadData];
    }
}

- (void)didDeselectedSetting
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    _tableView.hidden = YES;
    self.upDownImageView.image = [UIImage imageNamed:@"order_shopDownArrow"];
}

#pragma mark -button click
- (IBAction)checkBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (self.checkBlock) {
        self.checkBlock();
    }
}

- (IBAction)upDownBtnClick:(UIButton *)sender
{

}

#pragma mark - UITableViewController datasource & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"PromotionSettingDetailTableViewCell";
    PromotionSettingDetailTableViewCell *cell = (PromotionSettingDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PromotionSettingDetailTableViewCell" owner:self options:nil] lastObject];
	}

    [cell updateData:_PromoteCookBookGroup.groupCookbookArr[indexPath.row]];
	return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _PromoteCookBookGroup.groupCookbookArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableViewCellHight;
}
@end
