//
//  DtMenuCookbookViewController.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-28.
//
//

#import <UIKit/UIKit.h>

#define kTitleFirstColor [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0]
#define kTitleSecondColor [UIColor colorWithRed:116.0/255.0 green:159.0/255.0 blue:0.0 alpha:1.0]

@class DtMenuCookbookRemarkDataClass;
@class DtMenuCookbookRemarkTableViewCell;
@protocol DtMenuCookbookRemarkTableViewCellDelegate <NSObject>

- (void)dtMenuCookbookRemarkTableViewCell:(DtMenuCookbookRemarkTableViewCell *)cell withRemarkQuantityChange:(int)quantity;
- (void)showDtMenuCookbookRemarkOptionPicker:(DtMenuCookbookRemarkTableViewCell *)cell;

@end

@interface DtMenuCookbookRemarkTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, weak) id <DtMenuCookbookRemarkTableViewCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *remarkBgImageView;
@property (nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property (nonatomic, weak) IBOutlet UILabel *remarkBgLabel;
@property (nonatomic, weak) IBOutlet UIScrollView *remarkScrollView;
@property (nonatomic, weak) IBOutlet UILabel *remarkLabel;
@property (nonatomic, weak) IBOutlet UIButton *remarkButton;
@property (nonatomic, weak) IBOutlet UIButton *reduceButton;
@property (nonatomic, weak) IBOutlet UITextField *quantityTextField;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, assign) int dishQuantity;
@property (nonatomic, assign) int remarkQuantity;
@property (nonatomic, assign) int sectionIndex;
@property (nonatomic, assign) BOOL isShopCar;

- (void)updateDtMenuCookbookRemarkCell:(DtMenuCookbookRemarkDataClass *)dataClass withModifyFlag:(BOOL)flag;

@end
