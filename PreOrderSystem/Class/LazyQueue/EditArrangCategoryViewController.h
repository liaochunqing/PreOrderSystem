//
//  SettingAnswerViewController.h
//  PreOrderSystem
//
//  Created by sWen on 13-3-8.
//
//

#import <UIKit/UIKit.h>

#import "JsonPicker.h"
#import "EditArrangCategoryViewControllerCell.h"

@class MBProgressHUD;
@class EditArrangCategoryViewController;

@protocol EditArrangCategoryViewControllerDelegate <NSObject>

-(void)EditArrangCategoryViewController:(EditArrangCategoryViewController*)ctrl didDismissView:(BOOL)flag;

@end

@interface EditArrangCategoryViewController : UIViewController<UITextFieldDelegate, JsonPickerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, EditArrangCategoryViewControllerCellDelegate>

@property (nonatomic, weak) id <EditArrangCategoryViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIScrollView *arrangScrollView;
@property (nonatomic, weak) IBOutlet UITableView *arrangTableView;
@property (nonatomic, weak) IBOutlet UITextField *addCategoryTextField;
@property (nonatomic, weak) IBOutlet UITextField *addMinCapacityField;
@property (nonatomic, weak) IBOutlet UITextField *addMaxCapacityField;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) NSMutableArray *latestQueueListArray;
@property (nonatomic, strong) NSString *alertMsg;//有排队的类别不能删除，做出提醒
@property (nonatomic, assign) BOOL isEditAndSave;//判断是否对修改做了保存

- (void)dismissView;

@end
