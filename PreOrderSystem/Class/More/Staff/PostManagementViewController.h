//
//  PostManagementViewController.h
//  PreOrderSystem
//
//  Created by sWen on 13-5-15.
//
//

#import <UIKit/UIKit.h>

@class PostManagementViewController;
@protocol PostManagementViewControllerDelegate <NSObject>

- (void)dismissPostManagementViewController:(PostManagementViewController *)ctrl withUpdateStaffListFlag:(BOOL)flag;

@end

@interface PostManagementViewController : UIViewController

@property (nonatomic, weak) id <PostManagementViewControllerDelegate> delegate;

@end
