//
//  DtPreOrderDishQueueInfoTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-21.
//
//

#import "DtPreOrderDishQueueInfoTableViewCell.h"
#import "DtMenuDataClass.h"

@interface DtPreOrderDishQueueInfoTableViewCell ()
{
    DtQueueDataClass *queueDataClass;
}

@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UILabel *arrangInfoLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak) IBOutlet UIButton *selectButton;
@property (nonatomic, weak) IBOutlet UIButton *bigButton;

- (IBAction)deleteBtnClicked:(id)sender;
- (IBAction)selectedBtnClicked:(id)sender;
- (IBAction)bigBtnClicked:(id)sender;

@end

@implementation DtPreOrderDishQueueInfoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDtPreOrderDishQueueInfoCell:(DtQueueDataClass *)queueClass
{
    self.backgroundColor = [UIColor clearColor];
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"dt_deleteButton.png"] forState:UIControlStateNormal];
    [self.selectButton setBackgroundImage:[UIImage imageNamed:(queueDataClass.isSelected?@"dt_menuPreOrderSelectedType.png":@"dt_menuPreOrderNormalType.png")] forState:UIControlStateNormal];
    
    queueDataClass = queueClass;
    NSString *serialNumberStr = @"";
    if (1 == [queueDataClass.serialNumberStr length])
    {
        serialNumberStr = [NSString stringWithFormat:@"00%@",queueDataClass.serialNumberStr];
    }
    else if(2 == [queueDataClass.serialNumberStr length])
    {
        serialNumberStr = [NSString stringWithFormat:@"0%@",queueDataClass.serialNumberStr];
    }
    self.arrangInfoLabel.text = [NSString stringWithFormat:@"%@ : %@/%d%@", queueDataClass.tableName, serialNumberStr, queueClass.people, kLoc(@"person")];
    self.phoneLabel.text = [NSString stringWithFormat:@"%@ : %@", kLoc(@"mobile"), queueDataClass.mobile];
}

- (IBAction)deleteBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(dtPreOrderDishQueueInfoTableViewCell:wihtDeleteIndex:)])
    {
        [self.delegate dtPreOrderDishQueueInfoTableViewCell:self wihtDeleteIndex:self.tag];
    }
}

- (IBAction)selectedBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(dtPreOrderDishQueueInfoTableViewCell:wihtNewDtQueueData:)])
    {
        queueDataClass.isSelected = !queueDataClass.isSelected;
        [self.delegate dtPreOrderDishQueueInfoTableViewCell:self wihtNewDtQueueData:queueDataClass];
    }
}

- (IBAction)bigBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(dtPreOrderDishQueueInfoTableViewCell:wihtNewDtQueueData:)])
    {
        queueDataClass.isUnfold = !queueDataClass.isUnfold;
        [self.delegate dtPreOrderDishQueueInfoTableViewCell:self wihtNewDtQueueData:queueDataClass];
    }
}

@end
