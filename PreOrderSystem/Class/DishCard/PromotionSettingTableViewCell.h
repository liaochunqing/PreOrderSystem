//
//  PromotionSettingTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-7-2.
//
//

#import <UIKit/UIKit.h>

//#define kDetailTableViewHight 145
#define kTableViewCellHight 47

typedef void(^checkBtnClickBlock) ();
//typedef void(^speadBlock) ();

@interface PromotionSettingTableViewCell : UITableViewCell<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *upDownImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UIButton *upDownButton;
@property (nonatomic) BOOL isSpread; // 是否展开
@property (nonatomic, copy)checkBtnClickBlock checkBlock;

- (IBAction)checkBtnClick:(UIButton *)sender;
- (IBAction)upDownBtnClick:(UIButton *)sender;

- (void)updateData:(id) info;
- (void)didSelectedSetting;
- (void)didDeselectedSetting;
@end
