////
//  OrderByPhoneViewController.h
//  PreOrderSystem
//
//  Created by 溢航软件 on 14-4-3.
//
//

#import <UIKit/UIKit.h>

@class CustomTimePicker;
@class OrderByPhoneViewController;

@protocol OrderByPhoneViewControllerDelegate <NSObject>

- (void)orderByPhoneViewController:(OrderByPhoneViewController *)ctrl withLastestPreOrderData:(NSDictionary *)dict;

@end

@interface OrderByPhoneViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate,UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) id <OrderByPhoneViewControllerDelegate> delegate;
@property (nonatomic) NSInteger force;
@property (nonatomic, strong)NSMutableDictionary *dateDict;
@property (nonatomic, strong)NSMutableArray *dateArray;
@property (nonatomic, strong)NSMutableArray *timeArray;

@property (strong, nonatomic) UIPickerView *datePicker;
@property (strong, nonatomic) UIPickerView *timePicker;

@property (weak, nonatomic) IBOutlet UIScrollView *basicScrollview;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberPrefix;

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *phonenumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *hongkongLabel;
@property (weak, nonatomic) IBOutlet UILabel *outline;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *daluLabel;

@property (weak, nonatomic) IBOutlet UIButton *dalu;
@property (weak, nonatomic) IBOutlet UIButton *hongkong;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (weak, nonatomic) IBOutlet UITextField *date;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *time;
@property (weak, nonatomic) IBOutlet UITextField *number;
@property (weak, nonatomic) IBOutlet UITextField *name;

- (IBAction)hongkongBtnClick:(id)sender;
- (IBAction)btnDaluClick:(UIButton *)sender;
- (IBAction)btnCancelClick:(UIButton *)sender;
- (IBAction)sureBtnClick:(UIButton *)sender;

@end
