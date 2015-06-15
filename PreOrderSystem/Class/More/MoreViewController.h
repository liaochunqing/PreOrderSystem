//
//  MoreViewController.h
//  PreOrderSystem
//
//  Created by sWen on 12-10-18.
//
//

#import <UIKit/UIKit.h>

#import "JsonPicker.h"

@interface MoreViewController : UIViewController

+ (MoreViewController *)getMoreVCShareInstance;
- (void)showInView:(UIView*)aView;
- (void)dismissView;

@end
