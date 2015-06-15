//
//  ReLoginAlert.m
//  PreOrderSystem_iPhone
//
//  Created by sWen on 13-9-5.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import "ReLoginAlert.h"
#import "AccountManager.h"
#import "OfflineManager.h"

#define kResetPasswordAlertViewTag 1000

@interface ReLoginAlert ()
{
    UIAlertView *loginAlertView;//重新登录对话框
    NSString *accountStr;
    NSString *passwordStr;
    JsonPicker *jsonPicker;
}

@end

@implementation ReLoginAlert

+ (ReLoginAlert *)sharedReLoginAlert
{
    static ReLoginAlert *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ReLoginAlert alloc]init];
    });
    return sharedInstance;
}

//重置密码后，显示密码对话框
- (void)showLoginAlertView
{
    if (loginAlertView.isVisible)
    {
        return;
    }
    if (nil == loginAlertView)
    {
        loginAlertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:kLoc(@"cancel") otherButtonTitles:kLoc(@"confirm"), nil];
        loginAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
        loginAlertView.tag = kResetPasswordAlertViewTag;
    }
    loginAlertView.title = kLoc(@"password_has_been_changed_please_enter_the_new_password");
    [loginAlertView show];
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===", self.class);
#endif
}

#pragma mark network

- (void)reLogin:(NSString *)password
{
    AccountManager *accountMgr = [AccountManager sharedAccountManager];
    accountStr = [accountMgr userName];
    passwordStr = password;
    
    //登录帐号
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowLoginAlertView = NO;
    jsonPicker.loadingMessage = kLoc(@"verifying_account_information_please_wait");
    jsonPicker.loadedSuccessfulMessage = kLoc(@"verify_successful");
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:accountStr forKey:@"code"];
    [postData setObject:passwordStr forKey:@"password"];
    
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSString *lastUpdatedDate = [offlineMgr data_LastUpdatedDate];
    if (lastUpdatedDate!=nil)
    {
        [postData setObject:lastUpdatedDate forKey:@"lastUpdatedDate"];
    }
    [jsonPicker postData:postData withBaseRequest:@"CorpLogin"];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (kResetPasswordAlertViewTag == alertView.tag)
    {
        if (1 == buttonIndex)
        {
            NSString *password = [alertView textFieldAtIndex:0].text;
            if (0 == [password length])
            {
                password = @"";
            }
            [self reLogin:password];
        }
        //清空密码对话框的内容
        [loginAlertView textFieldAtIndex:0].text = @"";
    }
}

#pragma mark JsonPickerDelegatr

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    if (kJsonPickerFirstTag == picker.tag)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            case 200:
            {
                //登录成功，保存OAuthToken
                AccountManager *accountMgr = [AccountManager sharedAccountManager];
                NSString *oAuthToken = [[dict objectForKey:@"data"] objectForKey:@"oauthToken"];
                [accountMgr loginAccountWithUserName:accountStr withPassword:passwordStr andToken:oAuthToken];
                
                break;
            }
            default:
            {
                sleep(1.5);
                
                loginAlertView.title = kLoc(@"the_password_is_incorrect");
                [loginAlertView show];
                
                break;
            }
        }
    }
}

// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error
{
    
}

// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error
{
    
}

@end
