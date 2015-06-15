//
//  ReasonViewController.h
//  PreOrderSystem
//
//  Created by sWen on 13-7-3.
//
//

#import <UIKit/UIKit.h>

@class ReasonViewController;

@protocol ReasonViewControllerDelegate <NSObject>

- (void)reasonViewController:(ReasonViewController *)ctrl didDismissView:(BOOL)flag;
- (void)reasonViewController:(ReasonViewController *)ctrl submitReason:(NSString *)reasonStr;

@end

@interface ReasonViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <ReasonViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIImageView *textBgView;
@property (nonatomic, weak) IBOutlet UIButton *cancelBtn;
@property (nonatomic, weak) IBOutlet UIButton *finishBtn;
@property (nonatomic, weak) IBOutlet UITextView *reasonTextView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITableView *reasonTableView;
@property (nonatomic, strong) NSArray *reasonOptionsArray;//可以选择的原因

@end
