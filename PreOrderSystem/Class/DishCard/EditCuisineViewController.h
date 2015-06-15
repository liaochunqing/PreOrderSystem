//
//  SettingAnswerViewController.h
//  PreOrderSystem
//
//  Created by sWen on 13-5-15.
//
//

#import <UIKit/UIKit.h>

#import "JsonPicker.h"
#import "EditCuisineTableViewCell.h"

@class MBProgressHUD;
@class EditCuisineViewController;

@protocol EditCuisineViewControllerDelegate <NSObject>

- (void)dismissViewOfEditCuisineViewController:(EditCuisineViewController*)ctrl withLastestDishCardData:(NSDictionary *)dict;

@end

@interface EditCuisineViewController : UIViewController<UITextFieldDelegate, JsonPickerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, EditCuisineTableViewCellDelegate>
{
    __weak id <EditCuisineViewControllerDelegate>delegate;
    __weak UIScrollView *cuisineScrollView;
    __weak UITableView *cuisineTableView;
    __weak UITextField *addCuisineTextField;
    __weak UILabel *titleLabel;
    __weak UIImageView *bgImageView;
    __weak UIButton *addButton;
    __weak UIButton *cancelButton;
    __weak UIButton *doneButton;
    
    //保存类别数据
    NSMutableArray *cuisineArray;
    NSMutableArray *deleteCuisineArray;
    JsonPicker *jsonPicker;
    CGPoint tableviewContentOffset;
    EditCuisineTableViewCell *cuisineSelectedCell;
    NSInteger _cuisineNameMaxLen;
}

@property (nonatomic, weak) IBOutlet UIScrollView *cuisineScrollView;
@property (nonatomic, weak) IBOutlet UITableView *cuisineTableView;
@property (nonatomic, weak) IBOutlet UITextField *addCuisineTextField;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;
@property (nonatomic, weak) id delegate;

- (IBAction)cancelButtonPressed:(UIButton*)sender;
- (IBAction)doneButtonPressed:(UIButton*)sender;
- (IBAction)addButtonPressed:(UIButton*)sender;
- (void)dismissView:(NSDictionary *)dishCardDict;

@end
