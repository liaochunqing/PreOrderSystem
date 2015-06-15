//
//  PrintManagementTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-1-6.
//
//

#import <UIKit/UIKit.h>

#define kPrintTableViewCellReuseIdentifier @"PrintTableViewCellIdentifier"

@class PrinterDataClass;
@class PrintManagementTableViewCell;
@protocol PrintManagementTableViewCellDelegate <NSObject>

- (void)printManagementTableViewCell:(PrintManagementTableViewCell *)cell withPrinterName:(NSString *)name;
- (void)printManagementTableViewCell:(PrintManagementTableViewCell *)cell withPrinterIP:(NSString *)ipStr;
- (void)printManagementTableViewCell:(PrintManagementTableViewCell *)cell withPrinterType:(NSInteger)type;
- (void)printManagementTableViewCell:(PrintManagementTableViewCell *)cell withDeleteIndex:(NSInteger)
deleteIndex;
- (void)printManagementTableViewCell:(PrintManagementTableViewCell *)cell ;

@end

@interface PrintManagementTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, weak) id <PrintManagementTableViewCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *topLineImageView;
@property (nonatomic, weak) IBOutlet UIImageView *bottomLineImageView;
@property (nonatomic, weak) IBOutlet UILabel *printerNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *nameTextFieldBg;
@property (nonatomic, weak) IBOutlet UIImageView *IPTextFieldBg;
@property (nonatomic, weak) IBOutlet UITextField *printerNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *IPTextField;
@property (nonatomic, weak) IBOutlet UILabel *IPLabel;
@property (nonatomic, weak) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeFirstLabel;
@property (nonatomic, weak) IBOutlet UIButton *typeFirstButton;
@property (weak, nonatomic) IBOutlet UILabel *typeSecondLabel;
@property (nonatomic, weak) IBOutlet UIButton *typeSecondButton;
@property (nonatomic, weak) IBOutlet UIButton *testButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UIButton *kitchenBtn;
@property (weak, nonatomic) IBOutlet UIButton *orderDishesBtn;
@property (weak, nonatomic) IBOutlet UIButton *takeoutBtn;
@property (weak, nonatomic) IBOutlet UIButton *queueBtn;
@property (nonatomic) BOOL isStarPrinter;
@property (weak, nonatomic) IBOutlet UILabel *checkLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderDisherLabel;
@property (weak, nonatomic) IBOutlet UILabel *queueLabel;
@property (weak, nonatomic) IBOutlet UILabel *kitchLabel;
@property (weak, nonatomic) IBOutlet UILabel *takeoutLabel;

- (void)updatePrinterCell:(NSDictionary *)dataDict;
- (void)hidePrintManagementCellKeyBoard;
@end
