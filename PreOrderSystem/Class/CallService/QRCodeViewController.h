//
//  SettingAnswerViewController.h
//  PreOrderSystem
//
//  Created by sWen on 12-10-29.
//
//

#import <UIKit/UIKit.h>

#import "JsonPicker.h"
#import "QRCodeViewControllerCell.h"
#import "WEPopoverController.h"
#import "DataDownloader.h"
#import "MBProgressHUD.h"

@class QRCodeViewController;

@protocol QRCodeViewControllerDelegate <NSObject>

-(void)QRCodeViewController:(QRCodeViewController*)ctrl didDismissView:(BOOL)flag;

@end

@interface QRCodeViewController : UIViewController<UITextFieldDelegate, JsonPickerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, QRCodeViewControllerCellDelegate, WEPopoverControllerDelegate, DataDownloaderDelegate, MBProgressHUDDelegate>
{
    __weak id <QRCodeViewControllerDelegate>delegate;
    __weak UIScrollView *codeScrollView;
    __weak UITableView *codeTableView;
    __weak UITextField *nameTextField;
    __weak UILabel *titleLabel;
    __weak UIImageView *bgImageView;
    __weak UIImageView *tableViewBgImageView;
    __weak UIButton *cancelButton;
    __weak UIButton *doneButton;
    __weak UIButton *addButton;
    __weak UIButton *synchronousButton;
    __weak UIImageView *lineImageView;
    __weak UIButton *infoButton;
    
//    NSMutableArray *cellArray;
    NSMutableArray *selectedhousingDeskArray;
    NSMutableArray *housingDeskArray;
    NSMutableDictionary *QRCodeDataDict;//保存二维码提交成功后返回的数据
    NSMutableArray *QRCodeImageArray;//保存二维码的图片数
    MBProgressHUD *saveQRCodeImageHUD;
    JsonPicker *jsonPicker;
    WEPopoverController *popoverController;
    CGPoint tableviewContentOffset;
    QRCodeViewControllerCell *qrCodeSelectedCell;
    
    UIAlertView *failAlert;//保存二维码的图片失败时，弹出提示
}

@property (weak, nonatomic) IBOutlet UIButton *selectedAllBtn;
@property (nonatomic, weak) IBOutlet UIScrollView *codeScrollView;
@property (nonatomic, weak) IBOutlet UITableView *codeTableView;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;
@property (nonatomic, weak) IBOutlet UIButton *synchronousButton;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) WEPopoverController *popoverController;
- (IBAction)selectedAllBtnClick:(id)sender;

- (IBAction)cancelButtonPressed:(UIButton*)sender;
- (IBAction)doneButtonPressed:(UIButton*)sender;
- (IBAction)addButtonPressed:(UIButton*)sender;
- (IBAction)synchronousButtonPressed:(UIButton*)sender;
- (IBAction)infoButtonPressed:(UIButton*)sender;

- (void)dismissView;

@end
