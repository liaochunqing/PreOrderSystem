//
//  CallServiceViewController.h
//  PreOrderSystem
//
//  Created by sWen on 12-10-29.
//
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "JsonPicker.h"
#import "QRCodeViewController.h"

@class OrderListLoadMoreCell;
@class CustomBadge;

@interface CallServiceViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, EGORefreshTableHeaderDelegate, UIAlertViewDelegate, JsonPickerDelegate, QRCodeViewControllerDelegate>
{
    NSMutableArray *charViewArray;
    NSMutableArray *dataArray;
    
    //下拉刷新
    BOOL _reloading;
    EGORefreshTableHeaderView *_refreshHeaderView;
    OrderListLoadMoreCell *loadMoreOrdersCell;
    int currentPageIndex;
    int totalPage;
    
    /// 标记房台列表的“未读”的数目
    int duc;
    /// 标记订座列表的“未读”的数目
    int puc;
    /// 标记外卖列表的“未读”的数目
    int tuc;
    /// 标记服务列表的“未读”的数目
    int muc;
    /// 标记外卖列表的“催单”的数目
    int ruc;
    
    NSIndexPath *selectedIndex;
    JsonPicker *jsonPicker;
}

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UITableView *callServiceTableView;
@property (nonatomic, weak) IBOutlet UIButton *editButton;

- (IBAction)editButtonPressed:(UIButton*)sender;
- (void)showInView:(UIView*)aView;
- (void)dismissView;

@end
