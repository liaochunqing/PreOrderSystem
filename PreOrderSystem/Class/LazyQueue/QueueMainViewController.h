//
//  QueueMainViewController.h
//  PreOrderSystem
//
//  Created by sWen on 13-3-7.
//
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "JsonPicker.h"
#import "EditArrangCategoryViewController.h"
#import "QueueMainViewControllerCell.h"

@interface QueueMainViewController : UIViewController<UIAlertViewDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate, JsonPickerDelegate, EditArrangCategoryViewControllerDelegate, QueueMainViewControllerCellDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchPhoneNumberTextfield;
@property (nonatomic, strong) NSString *mobileSearchNumber;
- (void)showInView:(UIView*)aView;
- (void)dismissView;

@end
