//
//  PromotionSettingDetailTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-7-14.
//
//

#import <UIKit/UIKit.h>

@interface PromotionSettingDetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
- (void)updateData:(id) info;
@end
