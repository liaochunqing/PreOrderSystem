//
//  QueueLookDishViewController.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import "QueueLookDishViewController.h"
#import "QueueLookDishTableViewCell.h"
#import "QueueArrangDataClass.h"
#import "Constants.h"
#import "NsstringAddOn.h"
#import "QueueLookDishTotalRemarkTableViewCell.h"
#import "DetailTextView.h"
#import "OfflineManager.h"

@interface QueueLookDishViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    
}

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *arrangInfoLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak) IBOutlet UITableView *dishTableView;
@property (nonatomic, weak) IBOutlet DetailTextView *totalPriceLabel;

@end

@implementation QueueLookDishViewController

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
    
    self.bgImageView.image = LoadImageWithPNGType(@"queue_editArrageBg");
    [self addLocalizedString];
    [self addTapGesture];
    [self updateQueueLookDishView];
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

- (void)updateQueueLookDishView
{
    NSString *serialNumberStr = @"";
    if (1 == [self.arrangClass.serialNumberStr length])
    {
        serialNumberStr = [NSString stringWithFormat:@"00%@",self.arrangClass.serialNumberStr];
    }
    else if(2 == [self.arrangClass.serialNumberStr length])
    {
        serialNumberStr = [NSString stringWithFormat:@"0%@",self.arrangClass.serialNumberStr];
    }
    self.arrangInfoLabel.text = [NSString stringWithFormat:@"%@ : %@/%d%@", self.categoryName, serialNumberStr, self.arrangClass.peopleNumber, kLoc(@"person")];
    self.phoneLabel.text = [NSString stringWithFormat:@"%@ : %@", kLoc(@"mobile"), self.arrangClass.mobileNumber];
    
    //总价
    CGRect totalPriceFrame = self.totalPriceLabel.frame;
    totalPriceFrame.origin.y = self.dishTableView.frame.origin.y + self.dishTableView.frame.size.height + 10;
    self.totalPriceLabel.frame = totalPriceFrame;
    CGFloat totalPrice = 0;
    for (QueueArrangDishDataClass *dishClass in self.arrangClass.dishesArray)
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
        if ([self.delegate respondsToSelector:@selector(dismissQueueLookDishViewController)])
        {
            [self.delegate dismissQueueLookDishViewController];
        }
    }
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger indexRow = indexPath.row;
    if ([NSString strIsEmpty:self.arrangClass.remark])
    {
        QueueLookDishTableViewCell *cell = [self getQueueLookDishTableViewCell:tableView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = indexRow;
        
        [cell updateQueueLookDishCell:[self.arrangClass.dishesArray objectAtIndex:indexRow]];
        
        return cell;
    }
    else
    {
        if (indexRow == [self.arrangClass.dishesArray count])
        {
            QueueLookDishTotalRemarkTableViewCell *cell = [self getQueueLookDishTotalRemarkTableViewCell:tableView];
            
            [cell updateQueueLookDishTotalRemarkCell:self.arrangClass.remark];
            
            return cell;
        }
        else
        {
            QueueLookDishTableViewCell *cell = [self getQueueLookDishTableViewCell:tableView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexRow;
            
            [cell updateQueueLookDishCell:[self.arrangClass.dishesArray objectAtIndex:indexRow]];
            
            return cell;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*菜的数量 + 总价/总备注*/
    if ([NSString strIsEmpty:self.arrangClass.remark])
    {
        return [self.arrangClass.dishesArray count];
    }
    else
    {
        return [self.arrangClass.dishesArray count] + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger indexRow = indexPath.row;
    if ([NSString strIsEmpty:self.arrangClass.remark])
    {
        QueueLookDishTableViewCell *cell = [self getQueueLookDishTableViewCell:tableView];
        return [cell getQueueLookDishTableViewCellHeight:[self.arrangClass.dishesArray objectAtIndex:indexRow]];
    }
    else
    {
        if (indexRow == [self.arrangClass.dishesArray count])
        {
            QueueLookDishTotalRemarkTableViewCell *cell = [self getQueueLookDishTotalRemarkTableViewCell:tableView];
            return [cell getQueueLookDishTotalRemarkTableViewCellHeight:self.arrangClass.remark];
        }
        else
        {
            QueueLookDishTableViewCell *cell = [self getQueueLookDishTableViewCell:tableView];
            return [cell getQueueLookDishTableViewCellHeight:[self.arrangClass.dishesArray objectAtIndex:indexRow]];
        }
    }
}

- (QueueLookDishTableViewCell *)getQueueLookDishTableViewCell:(UITableView *)tableView
{
    QueueLookDishTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"QueueLookDishTableViewCell" owner:self options:nil]lastObject];
    return cell;
}

- (QueueLookDishTotalRemarkTableViewCell *)getQueueLookDishTotalRemarkTableViewCell:(UITableView *)tableView
{
    static NSString *cellIdentifier = kQueueLookDishTotalRemarkTableViewCellReuseIdentifier;
    QueueLookDishTotalRemarkTableViewCell *cell = (QueueLookDishTotalRemarkTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"QueueLookDishTotalRemarkTableViewCell" owner:self options:nil]lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

@end
