//
//  HousingButtonCell.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-24.
//
//

#import <UIKit/UIKit.h>
#import "CustomUIView.h"
#import "DiningTableCommon.h"

#define kHousingBtnClassName @"HousingButtonCell"

@class HousingDataClass;
@class HousingButtonCell;
@protocol HousingButtonCellDelegate <NSObject>

- (void)housingBtnCellSelected:(HousingButtonCell *)cell withHousingData:(HousingDataClass *)dataClass withStatusSetting:(BOOL)flag;

@end

@interface HousingButtonCell : CustomUIView

@property (nonatomic, weak) id <HousingButtonCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIImageView *coverImageView;
@property (nonatomic, weak) IBOutlet UIImageView *stateImageView;
@property (nonatomic, weak) IBOutlet UIImageView *dishLogoImageView;
@property (nonatomic, weak) IBOutlet UILabel *housingNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *bigButton;
@property (weak, nonatomic) IBOutlet UIImageView *isCheckedImageview;

- (id)initWithHousingData:(NSDictionary *)dict;
- (void)updateHousingBtnCellUI:(kHousingSwitchStateType)stateType withStatusSettingDict:(NSDictionary *)dict;

@end
