//
//  DtMenuListTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-27.
//
//

#import <UIKit/UIKit.h>

#define kDtMenuListTableViewCellReuseIdentifier @"dtMenuListTableViewCellIdentifier"
#define kDtMenuSmallCellNumForPerListCell 3  /*有三个小cell*/


@class DtMenuCookbookDataClass;
@class DtMenuListTableViewCell;
@protocol DtMenuListTableViewCellDelegate <NSObject>

- (void)dishCellSelectedAtIndex:(DtMenuCookbookDataClass *)dishDataClass;

@end

@interface DtMenuListTableViewCell : UITableViewCell

@property(weak, nonatomic) id <DtMenuListTableViewCellDelegate> delegate;
@property(weak, nonatomic) IBOutlet UIImageView *colFirstBgImageview;
@property(weak, nonatomic) IBOutlet UILabel *colFirstDishNameLabel;
@property(weak, nonatomic) IBOutlet UIButton *colFirstBigBtn;
@property(weak, nonatomic) IBOutlet UIImageView *colSecondBgImageview;
@property(weak, nonatomic) IBOutlet UILabel *colSecondDishNameLabel;
@property(weak, nonatomic) IBOutlet UIButton *colSecondBigBtn;
@property(weak, nonatomic) IBOutlet UIImageView *colThirdBgImageview;
@property(weak, nonatomic) IBOutlet UILabel *colThirdDishNameLabel;
@property(weak, nonatomic) IBOutlet UIButton *colThirdBigBtn;
@property (weak, nonatomic) IBOutlet UIImageView *firstIsSoldOutImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondSoldOutImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdSoldOutImageView;

@property (strong, nonatomic) IBOutlet UIImageView *firstIsStopImv;

@property (strong, nonatomic) IBOutlet UIImageView *secondIsStopImv;

@property (strong, nonatomic) IBOutlet UIImageView *thirdIsStopImv;


- (void)updateCellInfo:(DtMenuCookbookDataClass *)firstClass withColumnSecond:(DtMenuCookbookDataClass *)secondClass withColumnThird:(DtMenuCookbookDataClass *)thirdClass;

@end
