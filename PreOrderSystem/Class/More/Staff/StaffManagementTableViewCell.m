//
//  StaffManagementTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-7.
//
//

#import "StaffManagementTableViewCell.h"
#import "StaffInfoCell.h"

@interface StaffManagementTableViewCell ()<StaffInfoCellDelegate>
{
    StaffInfoCell *firstInfoCell;
    StaffInfoCell *secondInfoCell;
}


@end

@implementation StaffManagementTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        CGRect tempBtnCellFrame = CGRectZero;
        const CGFloat cellSpace = 10;
        
        firstInfoCell = [[StaffInfoCell alloc] initWithFrame:CGRectZero];
        firstInfoCell.delegate = self;
        tempBtnCellFrame = firstInfoCell.frame;
        tempBtnCellFrame.origin.y = cellSpace;
        firstInfoCell.frame = tempBtnCellFrame;
        [self.contentView addSubview:firstInfoCell];
        
        secondInfoCell = [[StaffInfoCell alloc] initWithFrame:CGRectZero];
        secondInfoCell.delegate = self;
        tempBtnCellFrame = secondInfoCell.frame;
        tempBtnCellFrame.origin.x = kStaffManagementCellWidth -  secondInfoCell.frame.size.width;
        tempBtnCellFrame.origin.y = cellSpace;
        secondInfoCell.frame = tempBtnCellFrame;
        [self.contentView addSubview:secondInfoCell];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateStaffManagementCell:(StaffManagementStaffInfoDataClass *)firstStaffInfo withSecondStaffData:(StaffManagementStaffInfoDataClass *)secondStaffInfo
{
    firstInfoCell.tag = self.tag * kStaffManagementCellHaveTwoSubCell + kStaffManagementCellFirstSubCellIndex;
    secondInfoCell.tag = self.tag * kStaffManagementCellHaveTwoSubCell + kStaffManagementCellSecondSubCellIndex;
    
    if (firstStaffInfo)
    {
        firstInfoCell.hidden = NO;
        [firstInfoCell updateStaffInfoCell:firstStaffInfo];
    }
    else
    {
        firstInfoCell.hidden = YES;
    }
    
    if (secondStaffInfo)
    {
        secondInfoCell.hidden = NO;
        [secondInfoCell updateStaffInfoCell:secondStaffInfo];
    }
    else
    {
        secondInfoCell.hidden = YES;
    }
}

#pragma mark - StaffInfoCellDelegate

- (void)staffInfoCell:(StaffInfoCell *)cell withEidtData:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(staffManagementTableViewCell:withEidtData:)])
    {
        [self.delegate staffManagementTableViewCell:self withEidtData:index];
    }
}

- (void)staffInfoCell:(StaffInfoCell *)cell withDeleteStaff:(NSString *)staffIdStr
{
    if ([self.delegate respondsToSelector:@selector(staffManagementTableViewCell:withDeleteStaff:)])
    {
        [self.delegate staffManagementTableViewCell:self withDeleteStaff:staffIdStr];
    }
}

@end
