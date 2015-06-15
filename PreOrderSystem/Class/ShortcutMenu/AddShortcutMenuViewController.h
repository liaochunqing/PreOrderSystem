//
//  AddShortcutMenuViewController.h
//  PreOrderSystem
//
//  Created by mac on 14-7-19.
//
//

#import <UIKit/UIKit.h>
#import "AddShortcutMenuTableViewCell.h"
@class AddShortcutMenuViewController;
@protocol AddShortcutMenuProtocol <NSObject>
/**
 *  点击"取消"按钮直接返回的回调
 *
 *  @param ctl
 */
- (void)dismissEditDiscountViewController:(AddShortcutMenuViewController *)ctl;

///**
// *  完成编辑后,点击"确定"按钮后的回调函数.
// *
// *  @param discountDataModel 准备提交的套餐数据.
// *  @param flag              YES:当前编辑的是已存在的套餐, NO:当前是添加新套餐.
// */
//- (void)didFinishEditWithNewDiscountModel:(DiscountDataModel *)discountDataModel andIsExistingDiscount:(BOOL)flag;

@end


@interface AddShortcutMenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,AddShortcutMenuTableViewCellDelegate>

@property (nonatomic,weak)id <AddShortcutMenuProtocol> delegate;

//退出btn
@property (strong, nonatomic) IBOutlet UIButton *CancelBtn;

//OK btn
@property (strong, nonatomic) IBOutlet UIButton *SubmitBtn;

//略
@property (strong, nonatomic) IBOutlet UITableView *shortcutTableView;

//所有可用的快捷方式,据说会从服务器返回.
@property (nonatomic,strong) NSMutableArray *shotcutItemArr;


- (IBAction)cancelBtnPress:(id)sender;

- (IBAction)submitBtnPress:(id)sender;


@end
