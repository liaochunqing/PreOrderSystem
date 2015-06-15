//
//  DisplayHelper.h
//  Ordering
//
//  Created by AaronKwok on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#define kHUDIntervalTime 2.0

@interface DisplayHelper : NSObject<MBProgressHUDDelegate>

+ (DisplayHelper *)shareDisplayHelper;

- (void)showLoading;
- (void)hideLoading;

//用于显示成功提示信息的浮动框
- (void)displaySuccessAlert:(NSString*)title message:(NSString*)message;
- (void)displaySuccessAlert:(NSString*)message;
- (void)displaySuccessAlert:(NSString*)message interval:(float)interval;
- (void)displaySuccessAlert:(NSString*)title message:(NSString*)message onView:(UIView*)aView;
- (void)displaySuccessAlert:(NSString*)message onView:(UIView*)aView;

//用于显示失败提示信息的浮动框
- (void)displayWarningAlert:(NSString*)message;
- (void)displayWarningAlert:(NSString*)message interval:(float)interval;
- (void)displayWarningAlert:(NSString*)title message:(NSString*)message;
- (void)displayWarningAlert:(NSString*)message onView:(UIView*)aView;
- (void)displayWarningAlert:(NSString*)title message:(NSString*)message onView:(UIView*)aView;

@end
