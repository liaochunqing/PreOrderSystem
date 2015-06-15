//
//  DtMenuRemarkPickerViewController.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-31.
//
//

#import <UIKit/UIKit.h>

#import "DtMenuRemarkOptionsCell.h"

@class DtMenuRemarkPickerViewController;
@protocol DtMenuRemarkPickerViewControllerDelegate <NSObject>

- (void)DtMenuRemarkPickerViewController:(DtMenuRemarkPickerViewController *)ctrl withDishRemarkData:(NSMutableArray *)array;

@end

@interface DtMenuRemarkPickerViewController : UIViewController<DtMenuRemarkOptionsCellDelegate>

@property (nonatomic, weak) id < DtMenuRemarkPickerViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIScrollView *remarkScrollView;
@property (nonatomic, weak) IBOutlet UILabel *noDataLabel;
@property (nonatomic, strong) NSArray *cuisineRemarkArray;
@property (nonatomic, strong) NSMutableArray *dishRemarkArray;
@property (nonatomic, assign) int vcTag;

@end
