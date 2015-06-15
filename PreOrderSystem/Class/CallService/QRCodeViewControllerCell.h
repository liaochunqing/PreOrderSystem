//
//  QRCodeViewControllerCell.h
//  PreOrderSystem
//
//  Created by sWen on 12-10-30.
//
//

#import <UIKit/UIKit.h>

@class QRCodeViewControllerCell;

@protocol QRCodeViewControllerCellDelegate <NSObject>

- (void)selectedHousingDesk:(QRCodeViewControllerCell*)ctrl;
- (void)deleteHousingDesk:(QRCodeViewControllerCell*)ctrl;
- (void)housingDeskContentChange:(QRCodeViewControllerCell*)ctrl withNewName:(NSString *)name;
- (void)moveViewUpWhenKeyboardShow:(QRCodeViewControllerCell*)ctrl;
- (void)moveViewBackWhenKeyboardHide:(QRCodeViewControllerCell*)ctrl;

@end

@interface QRCodeViewControllerCell : UITableViewCell<UITextFieldDelegate>
{
    __weak id <QRCodeViewControllerCellDelegate> delegate;
    __weak UIImageView *bgImageView1;
    __weak UITextField *nameTextField1;
    __weak UIButton *deleteButton1;
    __weak UIImageView *bgImageView2;
    __weak UITextField *nameTextField2;
    __weak UIButton *deleteButton2;
    int cellTag;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView1;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField1;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton1;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView2;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField2;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton2;
@property (nonatomic, assign) int cellTag;

@property (nonatomic) int id1;
@property (nonatomic) int id2;

- (IBAction)deleteButtonPressed:(UIButton *)sender;
- (void)refreshCellAfterGetData:(NSDictionary *)firstCellHousingDeskName withSceond:(NSDictionary *)secondCellHousingDeskName;

@end
