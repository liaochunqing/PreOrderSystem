//
//  EditPasswordViewController.h
//  PreOrderSystem
//
//  Created by sWen on 12-10-24.
//
//

#import <UIKit/UIKit.h>
#import "JsonPicker.h"

#define kEditPasswordViewControllerOrigin (CGPointMake(20, kSystemVersionIsIOS7?160:145))

@class EditPasswordViewController;
@protocol EditPasswordViewControllerDelegate <NSObject>

-(void)EditPasswordViewController:(EditPasswordViewController*)ctrl didDismissView:(BOOL)flag;

@end

@interface EditPasswordViewController : UIViewController

@property (nonatomic, weak) id <EditPasswordViewControllerDelegate> delegate;

@end
