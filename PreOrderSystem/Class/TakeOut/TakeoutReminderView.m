//
//  TakeoutReminderView.m
//  PreOrderSystem
//
//  Created by YorkIT on 14-6-21.
//
//

#import "TakeoutReminderView.h"
#import "Constants.h"

/**
 * @brief   催单行视图。
 *
 */
@interface TakeoutReminderTableCell : UITableViewCell

/// 内容视图
@property (nonatomic, strong) UILabel *titleLabel;
/// 分割线视图
@property (nonatomic, strong) UIView *separatorView;
/// 选择框视图
@property (nonatomic, strong) UIImageView *checkView;
/// 选中状态
@property (nonatomic, assign) BOOL isChecked;

/**
 * @brief   根据内容计算cell的高度。
 *
 * @param   contentString   内容字符串。
 *
 * @return  cell的高度。
 */
+ (CGFloat)cellHeightForContent:(NSString *)contentString;

@end

@implementation TakeoutReminderTableCell

#pragma mark - initlization methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 内容视图
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0,
                                                                0.0,
                                                                self.contentView.frame.size.width - 88.0,
                                                                self.contentView.frame.size.height)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        if (kSystemVersionIsIOS7) {
            _titleLabel.textColor = [UIColor darkGrayColor];
        } else {
            _titleLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        }
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_titleLabel];
        
        // 分割线视图
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                  self.contentView.bounds.size.height - 1.0,
                                                                  self.contentView.bounds.size.width,
                                                                  1.0)];
        if (kSystemVersionIsIOS7) {
            _separatorView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        } else {
            _separatorView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        }
        _separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addSubview:_separatorView];
        
        // 选择框视图
        CGRect checkFrame = CGRectMake(self.contentView.bounds.size.width - 44.0,
                                       self.contentView.bounds.size.height / 2.0 - 10.0, 21.0, 20.0);
        _checkView = [[UIImageView alloc] initWithFrame:checkFrame];
        _checkView.image = [UIImage imageNamed:@"more_item_checked.png"];
        _checkView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        _checkView.hidden = YES;
        [self.contentView addSubview:_checkView];
    }
    return self;
}

- (void)setIsChecked:(BOOL)isChecked
{
    _isChecked = isChecked;
    _checkView.hidden = !isChecked;
}

+ (CGFloat)cellHeightForContent:(NSString *)contentString
{
    CGSize containerSize = CGSizeMake(192.0, MAXFLOAT);
    CGSize contentSize = [contentString sizeWithFont:[UIFont boldSystemFontOfSize:16.0]
                                   constrainedToSize:containerSize
                                       lineBreakMode:NSLineBreakByWordWrapping];
    containerSize.height = MAX(ceil(contentSize.height) + 10.0, 40.0);
    return containerSize.height;
}

@end


@interface TakeoutReminderView () <UITableViewDataSource, UITableViewDelegate> {
    /// 表视图
    UITableView *tableView_;
}

@end

@implementation TakeoutReminderView

#pragma mark - memory management

- (void)dealloc
{
    
}

#pragma mark - initlization methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // 选择列表视图
        tableView_ = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView_.delegate = self;
        tableView_.dataSource = self;
        tableView_.scrollsToTop = NO;
        tableView_.backgroundColor = [UIColor clearColor];
        tableView_.backgroundView = nil;
        tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:tableView_];
    }
    return self;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *reminderInfo = [self.dataSource objectAtIndex:indexPath.row];
    return [TakeoutReminderTableCell cellHeightForContent:[reminderInfo objectForKey:@"name"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reminderCellIdentifier = @"reminderCellIdentifier";
    TakeoutReminderTableCell *cell = [tableView dequeueReusableCellWithIdentifier:reminderCellIdentifier];
    if (cell == nil) {
        cell = [[TakeoutReminderTableCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:reminderCellIdentifier];
    }

    // 设置内容
    NSDictionary *reminderInfo = [self.dataSource objectAtIndex:indexPath.row];
    cell.titleLabel.text = [reminderInfo objectForKey:@"name"];
    
    if (indexPath.row == self.dataSource.count - 1) {
        cell.separatorView.hidden = YES;
    } else {
        cell.separatorView.hidden = NO;
    }
    
    // 选中状态
    cell.isChecked = (indexPath.row == self.selectedIndex);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != self.selectedIndex) {
        _selectedIndex = indexPath.row;
    }
    
    [tableView reloadData];
}

#pragma mark - public methods

- (void)setDataSource:(NSArray *)dataSource
{
    if ([_dataSource isEqualToArray:dataSource]) {
        return;
    }
    _dataSource = [dataSource mutableCopy];
    
    if (_dataSource.count > 0) {
        _selectedIndex = NSNotFound;
    } else {
        _selectedIndex = NSNotFound;
    }
    
    [tableView_ reloadData];
}

@end
