//
//  DtMenuCookbookPackageTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-1-2.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    kPackageFirstChoiceType = 0,
    kPackageSecondChoiceType,
    kPackageThirdChoiceType
}kPackageChoiceType;

#define kDtMenuPackageCellNum 2  /*有两个小cell*/

@class DtMenuCookbookPackageTableViewCell;
@protocol  DtMenuCookbookPackageTableViewCellDelegate<NSObject>

- (void)dtMenuCookbookPackageTableViewCell:(DtMenuCookbookPackageTableViewCell *)cell withMemberDict:(NSDictionary *)selectedDict withMemberIndex:(int)index;

@end

@interface DtMenuCookbookPackageTableViewCell : UITableViewCell

@property (nonatomic, weak) id <DtMenuCookbookPackageTableViewCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *firstNormalImageView;
@property (nonatomic, weak) IBOutlet UIImageView *secondNormalImageView;
@property (nonatomic, weak) IBOutlet UIImageView *firstSelectedImageView;
@property (nonatomic, weak) IBOutlet UIImageView *secondSelectedImageView;
@property (nonatomic, weak) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *firstPriceLabel;
@property (nonatomic, weak) IBOutlet UIButton *firstBigButton;
@property (nonatomic, weak) IBOutlet UILabel *secondNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondPriceLabel;
@property (nonatomic, weak) IBOutlet UIButton *secondBigButton;
@property (nonatomic, assign) int sectionIndex;
@property (nonatomic, assign) int selectedTotalNum;
@property (nonatomic, assign) int choiceType;
@property (nonatomic, assign) int choiceNum;

- (void)updateDtMenuCookbookPackageCell:(NSDictionary *)firstItemDict withSecondItemDict:(NSDictionary *)secondItemDict;

@end
