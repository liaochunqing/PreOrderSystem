//
//  PromotionMainViewTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-6-30.
//
//

#import <UIKit/UIKit.h>
#define kPromotionMainViewTableViewCellHight 90

@class PromotionMainViewTableViewCell;

@protocol PromotionMainViewTableViewCellDelegate <NSObject>

- (void)PromotionMainViewTableViewCell:(PromotionMainViewTableViewCell *)cell didDeletedAtIndex:(NSInteger)index;
@end

@interface PromotionMainViewTableViewCell : UITableViewCell <UIActionSheetDelegate>
@property (weak,nonatomic)id <PromotionMainViewTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *identifyLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UISwitch *swicthView;

- (IBAction)deleteBtnClick:(UIButton *)sender;

- (IBAction)switchAction:(UISwitch *)sender;
- (void)updateData:(NSDictionary *)dict status:(BOOL)isSelected;
@end
