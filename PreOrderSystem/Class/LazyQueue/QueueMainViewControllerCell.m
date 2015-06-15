//
//  QueueMainViewControllerCell.m
//  PreOrderSystem
//
//  Created by sWen on 13-3-7.
//
//

#import "QueueMainViewControllerCell.h"
#import "UIDevice+platform.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "Constants.h"
#import "QueueCommon.h"

//cell中bgImageView以上部分的高度
#define kHeightForCellTop 230

@interface QueueMainViewControllerCell ()

@property (nonatomic, weak) IBOutlet UILabel *categoryNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *arrangNumLabel;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UILabel *totalNumberLabel;
@property (nonatomic, weak) IBOutlet UIImageView *showAllArrangBtnBg;
@property (nonatomic, weak) IBOutlet UIButton *showAllArrangButton;

- (IBAction)whetherShowAllArrangButtonPressed:(UIButton *)sender;

@end

@implementation QueueMainViewControllerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateViewAfterGetData:(NSDictionary *)dict withShowAllArrangFlag:(BOOL)flag
{
    if (![[UIDevice platformString] isEqualToString:@"iPad 1"])
    {
        [self addTapGesture];
    }
    [self addPictureToView:flag];
    // 更新数据
    if (dict) {
        self.categoryNameLabel.text = [NSString stringWithFormat:@"%@ (%@~%@人)",
                                       [dict objectForKey:@"categoryName"],
                                       [dict objectForKey:@"minCapacity"],
                                       [dict objectForKey:@"maxCapacity"]];//modify by liaochunqing
        self.totalNumberLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"maxNumber"]];
        NSMutableArray *arrangListArray = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"arrangList"]];
        int arrangCount = [arrangListArray count];
        int totalRow = 0;
        if (0 == arrangCount) {
            totalRow = 1;
        } else {
            int arrangNum = [[dict objectForKey:@"queueCount"] intValue];
            if (0 < arrangNum) {
                self.arrangNumLabel.text = [NSString stringWithFormat:@"%d%@",arrangNum,kLoc(@"in_arranging")];
            }
            // 是否显示全部排号
            if (flag) {
                if (arrangCount % kArrangNumberForPerCell == 0) {
                    totalRow = arrangCount / kArrangNumberForPerCell;
                } else {
                    totalRow = arrangCount / kArrangNumberForPerCell + 1;
                }
            } else {
                totalRow = 1;
            }
        }
        self.showAllArrangButton.enabled = (arrangCount > kArrangNumberForPerCell);
        // 加载排号cell
        [self addArrangCell:totalRow withArrangListArray:arrangListArray];
    }
}

- (void)addArrangCell:(int)totalRow withArrangListArray:(NSArray *)arrangListArray
{
    for (int i = 0; i < totalRow; i++)
    {
        ArrangTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"ArrangTableViewCell"
                                                                   owner:self
                                                                 options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.tag = i;
        cell.superCellTag = self.tag;
        CGRect cellFrame = cell.frame;
        cellFrame.origin.x = 5;
        cellFrame.origin.y = cellFrame.size.height * i + 10;
        cell.frame = cellFrame;
        [self.bgImageView addSubview:cell];
        
        // 更新数据
        BOOL hideFlag = (i == totalRow - 1);
        [cell updateViewAfterGetData:arrangListArray withLineFlag:hideFlag];
    }
}

- (IBAction)whetherShowAllArrangButtonPressed:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(whetherShowAllArrang:)])
    {
        [self.delegate whetherShowAllArrang:(int)self.tag];
    }
    self.showAllArrangButton.selected = !self.showAllArrangButton.selected;
}

- (void)addPictureToView:(BOOL)flag
{
    self.bgImageView.image = [[UIImage imageFromMainBundleFile:@"queue_cellBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.showAllArrangBtnBg.image = [UIImage imageFromMainBundleFile:(flag)?@"queue_upArrow.png":@"queue_downArrow.png"];
}

- (void)addTapGesture
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer addTarget:self action:@selector(handleTapGestureRecognizer:)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)handleTapGestureRecognizer:(UIGestureRecognizer *)tapGR
{
    CGPoint touchPoint = [tapGR locationInView:self];
    CGRect receiveTouchRect = CGRectMake(5, 5, self.frame.size.width, 230);
    /*只有背景图片顶部处理UITapGestureRecognizer事件*/
    if (CGRectContainsPoint(receiveTouchRect, touchPoint))
    {
        if ([self.delegate respondsToSelector:@selector(queueMainViewControllerCellTopHavedTap:)])
        {
            [self.delegate queueMainViewControllerCellTopHavedTap:self];
        }
    }
    
#ifdef DEBUG
    NSLog(@"===QueueTableViewCell,touchPoint:%f,%f===",touchPoint.x,touchPoint.y);
#endif
}

#pragma mark ArrangTableViewCellDelegate

- (void)handleArrang:(int)index
{
    if ([self.delegate respondsToSelector:@selector(handleArrang: wihtIndex: withCategoryName:)])
    {
        [self.delegate handleArrang:self wihtIndex:index withCategoryName:self.categoryNameLabel.text];
    }
}

@end
