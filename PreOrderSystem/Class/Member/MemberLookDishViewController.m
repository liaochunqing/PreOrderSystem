//
//  MemberLookDishViewController.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import "MemberLookDishViewController.h"
#import "MemberLookDishTableViewCell.h"
#import "MemberSuperDataClass.h"
#import "Constants.h"
#import "NsstringAddOn.h"
#import "MemberLookDishTotalRemarkTableViewCell.h"
#import "DetailTextView.h"
#import "OfflineManager.h"

@interface MemberLookDishViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    
}

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak) IBOutlet UITableView *dishTableView;
@property (nonatomic, weak) IBOutlet DetailTextView *totalPriceLabel;

@end

@implementation MemberLookDishViewController

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
    
    self.bgImageView.image = LoadImageWithPNGType(@"member_lookDishBg");
    [self addLocalizedString];
    [self addTapGesture];
    [self updateMemberLookDishView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addLocalizedString
{
    self.titleLabel.text = kLoc(@"view_list");
}

- (void)updateMemberLookDishView
{
    self.nameLabel.text = [NSString stringWithFormat:@"%@ : %@", kLoc(@"user_name"), self.useCountDataClass.userName];
    self.phoneLabel.text = [NSString stringWithFormat:@"%@ : %@", kLoc(@"mobile"), self.useCountDataClass.userMobile];
    //总价
    CGRect totalPriceFrame = self.totalPriceLabel.frame;
    totalPriceFrame.origin.y = self.dishTableView.frame.origin.y + self.dishTableView.frame.size.height + 10;
    self.totalPriceLabel.frame = totalPriceFrame;
    CGFloat totalPrice = 0;
    for (MemberDishDataClass *dishClass in self.useCountDataClass.dishesArray)
    {
        totalPrice = totalPrice + [dishClass.currentPriceStr floatValue] * dishClass.quantity;
    }
    NSString *titleStr = kLoc(@"total_price");
    NSString *priceStr = [NSString stringWithFormat:@"%.2f",totalPrice];
    NSString *totalPriceStr = [NSString stringWithFormat:@"%@  %@ %@", titleStr, [[OfflineManager sharedOfflineManager] getCurrencySymbol], [NSString oneDecimalOfPrice:[priceStr floatValue]]];
    [self.totalPriceLabel setText:totalPriceStr WithFont:self.totalPriceLabel.font AndColor:[UIColor orangeColor]];
    [self.totalPriceLabel setKeyWordTextArray:[NSArray arrayWithObjects:titleStr, nil] WithFont:self.totalPriceLabel.font AndColor:[UIColor blackColor]];
}

#pragma mark - UIGestureRecognizer

- (void)addTapGesture
{
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] init];
    [tapGR addTarget:self action:@selector(handleTapGestureRecognizer:)];
    [self.view addGestureRecognizer:tapGR];
}

- (void)handleTapGestureRecognizer:(UIGestureRecognizer *)tapGR
{
    CGPoint touchPoint = [tapGR locationInView:self.view];
    if (!CGRectContainsPoint(self.bgImageView.frame, touchPoint))
    {
        if ([self.delegate respondsToSelector:@selector(dismissMemberLookDishViewController)])
        {
            [self.delegate dismissMemberLookDishViewController];
        }
    }
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger indexRow = indexPath.row;
    if ([NSString strIsEmpty:self.useCountDataClass.remark])
    {
        MemberLookDishTableViewCell *cell = [self getMemberLookDishTableViewCell:tableView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = indexRow;
        
        [cell updateMemberLookDishCell:[self.useCountDataClass.dishesArray objectAtIndex:indexRow]];
        
        return cell;
    }
    else
    {
        if (indexRow == [self.useCountDataClass.dishesArray count])
        {
            MemberLookDishTotalRemarkTableViewCell *cell = [self getMemberLookDishTotalRemarkTableViewCell:tableView];
            
            [cell updateMemberLookDishTotalRemarkCell:self.useCountDataClass.remark];
            
            return cell;
        }
        else
        {
            MemberLookDishTableViewCell *cell = [self getMemberLookDishTableViewCell:tableView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexRow;
            
            [cell updateMemberLookDishCell:[self.useCountDataClass.dishesArray objectAtIndex:indexRow]];
            
            return cell;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*菜的数量 + 总价/总备注*/
    if ([NSString strIsEmpty:self.useCountDataClass.remark])
    {
        return [self.useCountDataClass.dishesArray count];
    }
    else
    {
        return [self.useCountDataClass.dishesArray count] + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger indexRow = indexPath.row;
    if ([NSString strIsEmpty:self.useCountDataClass.remark])
    {
        MemberLookDishTableViewCell *cell = [self getMemberLookDishTableViewCell:tableView];
        return [cell getMemberLookDishTableViewCellHeight:[self.useCountDataClass.dishesArray objectAtIndex:indexRow]];
    }
    else
    {
        if (indexRow == [self.useCountDataClass.dishesArray count])
        {
            MemberLookDishTotalRemarkTableViewCell *cell = [self getMemberLookDishTotalRemarkTableViewCell:tableView];
            return [cell getMemberLookDishTotalRemarkTableViewCellHeight:self.useCountDataClass.remark];
        }
        else
        {
            MemberLookDishTableViewCell *cell = [self getMemberLookDishTableViewCell:tableView];
            return [cell getMemberLookDishTableViewCellHeight:[self.useCountDataClass.dishesArray objectAtIndex:indexRow]];
        }
    }
}

- (MemberLookDishTableViewCell *)getMemberLookDishTableViewCell:(UITableView *)tableView
{
    MemberLookDishTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"MemberLookDishTableViewCell" owner:self options:nil]lastObject];
    return cell;
}

- (MemberLookDishTotalRemarkTableViewCell *)getMemberLookDishTotalRemarkTableViewCell:(UITableView *)tableView
{
    static NSString *cellIdentifier = kMemberLookDishTotalRemarkTableViewCellReuseIdentifier;
    MemberLookDishTotalRemarkTableViewCell *cell = (MemberLookDishTotalRemarkTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MemberLookDishTotalRemarkTableViewCell" owner:self options:nil]lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

@end
