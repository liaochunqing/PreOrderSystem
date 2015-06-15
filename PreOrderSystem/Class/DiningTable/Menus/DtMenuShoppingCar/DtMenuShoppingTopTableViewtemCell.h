//
//  DtMenuShoppingTopTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-1-3.
//
//


#import <UIKit/UIKit.h>

#define kDtMenuPackageItemNameHeight 30
#define kDtMenuShoppingTopTableViewCellNormalHeight 136.0//100

@class DtMenuShoppingCarDataClass;
@class DtMenuShoppingTopTableViewtemCell;
@protocol DtMenuShoppingTopTableViewCellDelegate <NSObject>

- (void)dtMenuShoppingTopTableViewCell:(DtMenuShoppingTopTableViewtemCell *)cell withDishQuantityChange:(int)quantity;
- (void)dtMenuShoppingTopTableViewCellreloadCell:(DtMenuShoppingTopTableViewtemCell *)cell ;//foldOrspreadStatus:(int)foldOrspreadStatus;

@end

@interface DtMenuShoppingTopTableViewtemCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, weak) id < DtMenuShoppingTopTableViewCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UIScrollView *dishNameScrollView;
@property (nonatomic, weak) IBOutlet UILabel *dishNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *quantityImageView;
@property (nonatomic, weak) IBOutlet UIButton *quantityReduceButton;
@property (nonatomic, weak) IBOutlet UITextField *quantityTextField;
@property (nonatomic, weak) IBOutlet UIButton *quantityAddButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UILabel *togetherLabel;
@property (nonatomic, weak) IBOutlet UILabel *partLabel;
@property (weak, nonatomic) IBOutlet UIButton *spreadOrfoldButton;
@property (nonatomic) int foldOrspreadStatus; //  0表示处于折叠状态, 1表示处于展开状态，
@property (nonatomic, assign) int sectionIndex;
@property (nonatomic, assign) int remarkTotalQuantity;


//当前优惠价
@property (strong, nonatomic) IBOutlet UILabel *promotePrice;

- (void)updateDtMenuShoppingCarCell:(DtMenuShoppingCarDataClass *)dataClass;
- (IBAction)spreadOrfoldButtonClick:(UIButton *)sender;

@end
