//
//  StaffSortTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-30.
//
//

#import <UIKit/UIKit.h>

#define kStaffSortTableViewCellIdentifier @"staffSortTableViewCellIdentifier"

@interface StaffSortTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property (nonatomic, weak) IBOutlet UILabel *styleLabel;

- (void)uopdatePostStyleCell:(NSString *)styleStr withShowLineFlag:(BOOL)lineFlag;

@end
