//
//  EditAccountViewController.h
//  PreOrderSystem
//
//  Created by sWen on 12-10-24.
//
//

#import <UIKit/UIKit.h>
#import "JsonPicker.h"

#define kEditAccountViewControllerOrigin (CGPointMake(20, kSystemVersionIsIOS7?160:145))

@class EditAccountViewController;
@protocol EditAccountViewControllerDelegate <NSObject>

-(void)EditAccountViewController:(EditAccountViewController*)ctrl didDismissView:(BOOL)flag;

@end

@interface EditAccountViewController : UIViewController

@property (nonatomic, weak)id <EditAccountViewControllerDelegate> delegate;

@end
