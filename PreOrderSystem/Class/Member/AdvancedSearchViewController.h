//
//  AdvancedSearchViewController.h
//  PreOrderSystem
//
//  Created by 溢航软件 on 14-4-11.
//
//

#import <UIKit/UIKit.h>
#import "MemberSuperDataClass.h"

@class AdvancedSearchViewController;

@protocol AdvancedSearchViewControllerDelegate <NSObject>

- (void)advancedSearchViewController:(AdvancedSearchViewController *)ctrl;

@end


@interface AdvancedSearchViewController : UIViewController <UIActionSheetDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UIButton *dateSelectedButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) id <AdvancedSearchViewControllerDelegate> delegate;
/// 数据源
@property (nonatomic, weak) MemberSuperDataClass *memberDataClass;

@property (weak, nonatomic) IBOutlet UILabel *youhuiLabel;
@property (weak, nonatomic) IBOutlet UITextField *startDateField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *endDateField;

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (nonatomic, strong) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)dateSelectedButtonClick:(id)sender;

- (IBAction)cancelButtonClick:(id)sender;

- (IBAction)sureButtonClick:(id)sender;


@end
