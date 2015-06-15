//
//  DiningTableMainViewController.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-27.
//
//

#import <UIKit/UIKit.h>
#import "CustomUIView.h"
#import "DiningTableAreaListView.h"
#import "DiningTableGuideView.h"
#import "JsonPicker.h"
#import "HousingButtonCell.h"
#import "DtMenuMainViewController.h"

@interface DiningTableMainViewController : UIViewController<UIActionSheetDelegate, UIAlertViewDelegate, DiningTableGuideViewDelegate, JsonPickerDelegate, DiningTableAreaListViewDelegate, HousingButtonCellDelegate, DtMenuMainViewControllerDelegate>

- (void)showDiningTableMainViewInView:(UIView *)aView;
- (void)dismissDiningTableMainView;

@end

