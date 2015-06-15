//
//  SystemUpdateAlert.m
//  PreOrderSystem_iPhone
//
//  Created by sWen on 13-8-27.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import "SystemUpdateAlert.h"
#import "Constants.h"

#define kUpdateFirstAlertViewTag 1000
#define kUpdateSecondAlertViewTag 1500

@interface SystemUpdateAlert ()
{
    NSDictionary *networkDict;//联网返回的数据
    BOOL isAlwaysShowAlert;/*默认情况更新情况一天提示一次，但是关于页面点击“检测更新”按钮，如果有更新，每次都提示*/
    UIAlertView *noAlertView;//没有更新
    UIAlertView *smallAlertView;//小版本更新
    UIAlertView *largeAlertView;//大版本更新
}

@end

@implementation SystemUpdateAlert

+ (SystemUpdateAlert *)sharedSystemUpdateAlert
{
    static SystemUpdateAlert *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SystemUpdateAlert alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===", self.class);
#endif
}

//判断是否要更新
- (void)checkForSystemUpdate:(NSDictionary *)dict withAlwaysShowAlert:(BOOL)flag
{
    //避免重复弹出
    if (noAlertView.isVisible || smallAlertView.isVisible || largeAlertView.isVisible)
    {
        return;
    }
    
    
    networkDict = [[NSDictionary alloc]initWithDictionary:dict ];
    NSDictionary *versonDict = [[NSDictionary alloc]initWithDictionary:[dict objectForKey:@"version"]];
    isAlwaysShowAlert = flag;
    
    int updateStatus = [[versonDict objectForKey:@"status"] intValue];
    long serverTime = [[networkDict objectForKey:@"time"] longValue];
    long lastServerTime = [[[NSUserDefaults standardUserDefaults] objectForKey:@"time"]longValue];
    
    BOOL isTrue = NO;
    //更新时间是否大于24小时
    if (((serverTime - lastServerTime) > kOnedayTranferToSecond) || isAlwaysShowAlert)
    {
        isTrue = YES;
    }
    
#ifdef DEBUG
    NSLog(@"===SystemUpdateAlert,distantTime:%ld,isTrue:%d,updateStatus:%d===",serverTime - lastServerTime,isTrue,updateStatus);
#endif
    
    switch (updateStatus)
    {
        case 0:
        {
            // 没有更新
            if (isAlwaysShowAlert) {
                NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
                NSString *messageString = [NSString stringWithFormat:@"%@V%@%@",
                                           kLoc(@"your_current_version"),
                                           version, kLoc(@"is_the_new_version")];
                
                if (nil == noAlertView) {
                    noAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                             message:nil
                                                            delegate:nil
                                                   cancelButtonTitle:kLoc(@"confirm")
                                                   otherButtonTitles:nil];
                }
                noAlertView.title = messageString;
                [noAlertView show];
            }
            
            break;
        }
        case 1:
        {
            if (isTrue)
            {
                if (nil == smallAlertView)
                {
                    smallAlertView = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:kLoc(@"update_now") otherButtonTitles:kLoc(@"later"), nil];
                    smallAlertView.tag = kUpdateFirstAlertViewTag;
                }
                smallAlertView.title = [versonDict objectForKey:@"desc"];
                [smallAlertView show];
            }
            
            break;
        }
        case 2:
        {
            if (nil == largeAlertView)
            {
                largeAlertView = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:kLoc(@"confirm2") otherButtonTitles:kLoc(@"quit"), nil];
                largeAlertView.tag = kUpdateSecondAlertViewTag;
            }
            largeAlertView.title = [versonDict objectForKey:@"desc"];
            [largeAlertView show];
            
            break;
        }
        default:
            break;
    }
}

-(void)jumpToAppStore
{
    NSDictionary *versonDict = [networkDict objectForKey:@"version"];
    NSURL *url = [NSURL URLWithString:[versonDict objectForKey:@"url"]];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case kUpdateFirstAlertViewTag://小版本更新
        {
            if (0 == buttonIndex)
            {
                [self jumpToAppStore];
            }
            //保存时间
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            [pref setObject:[networkDict objectForKey:@"time"] forKey:@"time"];
            [pref synchronize];
            
            break;
        }
        case kUpdateSecondAlertViewTag://大版本更新
        {
            if (buttonIndex == 0)
            {
                [self jumpToAppStore];
            }
            else
            {
                //登出帐号
                [[NSNotificationCenter defaultCenter]postNotificationName:kLogoutAccount object:nil];
            }
            
            break;
        }
        default:
            break;
    }
}

@end
