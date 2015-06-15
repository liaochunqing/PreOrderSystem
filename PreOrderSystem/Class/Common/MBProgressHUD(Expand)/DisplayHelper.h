//
//  DisplayHelper.h
//  Ordering
//
//  Created by AaronKwok on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#define kIntervalTime 2.0   //显示提示框的时间长

@interface DisplayHelper : NSObject<MBProgressHUDDelegate>

+ (DisplayHelper *)shareDisplayHelper;

//用于显示成功提示信息的浮动框
- (void)displaySuccessAlert:(NSString*)title message:(NSString*)message;
- (void)displaySuccessAlert:(NSString*)message;
- (void)displaySuccessAlert:(NSString*)message interval:(float)interval;
- (void)displaySuccessAlert:(NSString*)title message:(NSString*)message onView:(UIView*)aView;
- (void)displaySuccessAlert:(NSString*)message onView:(UIView*)aView;
- (void)displaySuccessAlert:(NSString *)message onHUD:(MBProgressHUD *)HUD;
- (void)displaySuccessAlert:(NSString*)message interval:(float)interval onHUD:(MBProgressHUD *)HUD;

//用于显示失败提示信息的浮动框
- (void)displayWarningAlert:(NSString*)message;
- (void)displayWarningAlert:(NSString*)message interval:(float)interval;
- (void)displayWarningAlert:(NSString*)title message:(NSString*)message;
- (void)displayWarningAlert:(NSString*)message onView:(UIView*)aView;
- (void)displayWarningAlert:(NSString*)title message:(NSString*)message onView:(UIView*)aView;
- (void)displayWarningAlert:(NSString*)message onHUD:(MBProgressHUD *)HUD;

@end
