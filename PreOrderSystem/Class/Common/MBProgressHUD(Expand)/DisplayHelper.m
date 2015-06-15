//
//  DisplayHelper.m
//  Ordering
//
//  Created by AaronKwok on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DisplayHelper.h"
#import "MBProgressHUD.h"
#import "UIImage+imageWithContentsOfFile.h"

@implementation DisplayHelper

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===DisplayHelper,dealloc===");
#endif
}

- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

+ (DisplayHelper *)shareDisplayHelper
{
    static DisplayHelper *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[DisplayHelper alloc]init];
    });
    return shareInstance;
}

- (void)displaySuccessAlert:(NSString*)message{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
    HUD.delegate = self;
    [window addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_success.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = message;
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.5];
}

- (void)displaySuccessAlert:(NSString*)title message:(NSString*)message{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
    HUD.delegate = self;
    [window addSubview:HUD];
    
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_success.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = title;
    HUD.detailsLabelText = message;
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.5];
}

- (void)displaySuccessAlert:(NSString*)message interval:(float)interval{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
    HUD.delegate = self;
    [window addSubview:HUD];
    
    HUD.mode = MBProgressHUDModeCustomView;
    //HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_success.png"]] autorelease];
    
    HUD.labelText = message;
    [HUD show:YES];
    [HUD hide:YES afterDelay:interval];
}

- (void)displaySuccessAlert:(NSString*)message onView:(UIView*)aView{
    //UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:aView];
    HUD.delegate = self;
    [aView addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_success.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = message;
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.5];
}

- (void)displaySuccessAlert:(NSString*)title message:(NSString*)message onView:(UIView*)aView{
    //UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:aView];
    HUD.delegate = self;
    [aView addSubview:HUD];
    
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_success.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = title;
    HUD.detailsLabelText = message;
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.5];
}

- (void)displaySuccessAlert:(NSString *)message onHUD:(MBProgressHUD *)HUD{
    if (HUD) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        //MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
        HUD.delegate = self;
        [window addSubview:HUD];
        
        
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_success.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = message;
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
    }
}

- (void)displaySuccessAlert:(NSString*)message interval:(float)interval onHUD:(MBProgressHUD *)HUD{
    if (HUD) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        //MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
        HUD.delegate = self;
        [window addSubview:HUD];
        
        
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_success.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = message;
        [HUD show:YES];
        [HUD hide:YES afterDelay:interval];
    }
}

- (void)displayWarningAlert:(NSString*)message{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
    HUD.delegate = self;
    [window addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_failed.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = message;
    [HUD show:YES];
    [HUD hide:YES afterDelay:2.0];
}

- (void)displayWarningAlert:(NSString*)title message:(NSString*)message{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
    HUD.delegate = self;
    [window addSubview:HUD];
    
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_failed.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = title;
    HUD.detailsLabelText = message;
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.5];
}

- (void)displayWarningAlert:(NSString*)message interval:(float)interval{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
    HUD.delegate = self;
    [window addSubview:HUD];
    
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_failed.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = message;
    [HUD show:YES];
    [HUD hide:YES afterDelay:interval];
}

- (void)displayWarningAlert:(NSString*)title message:(NSString*)message onView:(UIView*)aView{
    //UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:aView];
    HUD.delegate = self;
    [aView addSubview:HUD];
    
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_failed.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = title;
    HUD.detailsLabelText = message;
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.5];
}

//用于显示提示信息的浮动框
- (void)displayWarningAlert:(NSString*)message onView:(UIView*)aView{
    //UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:aView];
    HUD.delegate = self;
    [aView addSubview:HUD];
    
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_failed.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = message;
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.5];
}

- (void)displayWarningAlert:(NSString*)message onHUD:(MBProgressHUD *)HUD{
    if (HUD) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        //MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
        HUD.delegate = self;
        [window addSubview:HUD];
        
        
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_failed.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = message;
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.0];
    }
    else {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        HUD = [[MBProgressHUD alloc] initWithView:window];
        HUD.delegate = self;
        [window addSubview:HUD];
        
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_failed.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = message;
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.0];
    }
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
	hud = nil;
}

@end
