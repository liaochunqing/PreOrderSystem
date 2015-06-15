//
//  JsonPicker.m
//  AllOfCarParts
//
//  Created by AaronKwok on 12-4-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JsonPicker.h"
#import "Constants.h"
#import "UIDevice+platform.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "SystemUpdateAlert.h"
#import "ReLoginAlert.h"
#import "Reachability.h"
#import "PSAlertView.h"

@implementation JsonPicker

@synthesize HUD;
@synthesize delegate;
@synthesize tag;

@synthesize debug;
@synthesize showActivityIndicator;

@synthesize loadingMessage;
@synthesize loadedSuccessfulMessage;
@synthesize loadedFailedMessage;


-(id)init
{
    if (self = [super init]) {
        self.isShowLoginAlertView = YES;
        self.isAlwaysShowUpdateAlert = NO;
        self.isShowUpdateAlert = NO;
        self.loadingMessage = kLoc(@"fetching_data_please_wait");
    }
    return self;
}

// 检测版本更新
- (void)checkAppUpdate:(NSDictionary *)dict
{
    SystemUpdateAlert *systemUpdate = [SystemUpdateAlert sharedSystemUpdateAlert];
    [systemUpdate checkForSystemUpdate:dict withAlwaysShowAlert:self.isAlwaysShowUpdateAlert];
}

// 修改密码后，重新登录
- (void)showReLoginAlert
{
    ReLoginAlert *loginAlert = [ReLoginAlert sharedReLoginAlert];
    [loginAlert showLoginAlertView];
}

-(void)cancelConnection
{
    [jsonConnection cancel];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (showActivityIndicator)
    {
        //超时：提示错误
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_failed.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = kLoc(@"connection_timed_out_please_check_your_network_status_or_try_again_later");
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
    }
	if ([delegate respondsToSelector:@selector(JsonPicker:didFailWithError:)]) {
        [delegate JsonPicker:self didFailWithError:nil];
    }
}


//连接失败
-(void)connectionFailed
{
    [timeoutTimer invalidate];
    //
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    //
    if (showActivityIndicator)
    {
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageFromMainBundleFile:@"MBProgressHUD_con_failed.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = kLoc(@"connection_failed_please_try_again_later");
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
    }
    
	if ([delegate respondsToSelector:@selector(JsonPicker:didFailWithError:)])
    {
        [delegate JsonPicker:self didFailWithError:nil];
    }
}

-(void)postData:(NSDictionary *)data withBaseRequest:(NSString *)baseURL
{
    if ([[Reachability shareReachability] checkNetworking])
    {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        if (showActivityIndicator)
        {
            if (!HUD)
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                HUD = [[MBProgressHUD alloc] initWithView:window];
                HUD.delegate = self;
                [window addSubview:HUD];
            }
            HUD.mode = MBProgressHUDModeIndeterminate;
            if (loadingMessage==nil || [loadingMessage length]<=0)
            {
                HUD.labelText = kLoc(@"loading");
            }
            else
            {
                HUD.labelText = loadingMessage;
            }
            [HUD show:YES];
        }
        
        
        if (data)
        {
    
            NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
            //-------------------------HEAD-----------------
            //获取设备名称
            UIDevice *device = [UIDevice currentDevice];
            
            NSMutableDictionary *HEAD = [[NSMutableDictionary alloc] init];
            [HEAD setObject:@"etb_iPad" forKey:@"APP_ID"];
            [HEAD setObject:[device model] forKey:@"PLATFORM"];
            [HEAD setObject:@"yorkit_ios" forKey:@"SOURCE_CHANNEL"];
            
            NSString *system = [NSString stringWithFormat:@"%@(%@)", [UIDevice platformString], [device systemVersion]];
            [HEAD setObject:system forKey:@"UA"];
            
            NSString *sizeStr = [NSString stringWithFormat:@"%d x %d",(int)[[UIScreen mainScreen] currentMode].size.width,(int)[[UIScreen mainScreen] currentMode].size.height];
            [HEAD setObject:sizeStr forKey:@"SIZE"];
            
            
            //获取版本号
            NSBundle* mainBundle = [NSBundle mainBundle];
            NSDictionary* infoDictionary =  [mainBundle infoDictionary];
            NSString *appVersion =[infoDictionary objectForKey:@"CFBundleVersion"];
            [HEAD setObject:appVersion forKey:@"VERSION"];
            
            
            //本机当前语言
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
            NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
            NSString *currentLanguage = [languages objectAtIndex:0];
            
            //程序的当前语言
            NSString *savedLangType = [[NSUserDefaults standardUserDefaults] objectForKey:kApplicationLanguageKey];
            
            if ([savedLangType isEqualToString:@"ENG"])
            {
                currentLanguage = @"en";
            }
            else if ([savedLangType isEqualToString:@"CHS"])
            {
                currentLanguage = @"zh-Hans";
            }
            else if ([savedLangType isEqualToString:@"CHT"])
            {
                currentLanguage = @"zh-Hant";
            }
            
            [HEAD setObject:currentLanguage forKey:@"LANG"];
            [HEAD setObject:[NSNumber numberWithInt:1] forKey:@"TOKEN_TYPE"];
            
            //设备Token
            NSString *deviceTokenStr = [UIDevice getDeviceToken];
            [HEAD setObject:deviceTokenStr forKey:@"DEVICE_TOKEN"];
            
            //推送Token
            NSString *pushTokenStr = [defaults objectForKey:kPushToken];
            if ([pushTokenStr length]>0) {
                [HEAD setObject:pushTokenStr forKey:@"PUSH_TOKEN"];
            }
            else {
                [HEAD setObject:@"" forKey:@"PUSH_TOKEN"];
            }

            //登录令牌
            AccountManager *accountMgr = [AccountManager sharedAccountManager];
            NSString *oAuthToken = [accountMgr oAuthToken];
            if (oAuthToken!=nil && [oAuthToken length]>0) {
                [HEAD setObject:oAuthToken forKey:@"OAUTH_TOKEN"];
            }
            else {
                [HEAD setObject:@"" forKey:@"OAUTH_TOKEN"];
            }
            [post setObject:HEAD forKey:@"head"];
            [post setObject:data forKey:@"body"];
           
            NSError *error = nil;
            NSData *postData= [NSJSONSerialization dataWithJSONObject:post options:NSJSONWritingPrettyPrinted error:&error];
            
            NSURL *conURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kDomainURL, baseURL]];
            NSMutableURLRequest *connectionRequest = [NSMutableURLRequest requestWithURL:conURL];
            [connectionRequest setHTTPMethod:@"POST"];
            //设置超时间隔
            [connectionRequest setTimeoutInterval:30.0];
            [connectionRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
            [connectionRequest setHTTPBody:postData];
            
            if (jsonConnection) {
                jsonConnection = nil;
            }
            
            if (receivedData) {
                receivedData = nil;
            }
            
            jsonConnection = [[NSURLConnection alloc] initWithRequest:connectionRequest delegate:self];
            
            timeoutTimer = [[NSTimer alloc]initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:30.0] interval:30.0 target:self selector:@selector(cancelConnection) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop]addTimer:timeoutTimer forMode:NSDefaultRunLoopMode];
        }
	}
	else
    {
        if ([delegate respondsToSelector:@selector(JsonPicker:didFailWithNetwork:)])
        {
            [delegate JsonPicker:self didFailWithNetwork:nil];
        }
	}
}

-(void)postData:(NSDictionary *)data withMainURL:(NSString *)mainURL withBaseRequest:(NSString *)baseURL
{
    if ([[Reachability shareReachability] checkNetworking])
    {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        if (showActivityIndicator)
        {
            if (!HUD)
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                HUD = [[MBProgressHUD alloc] initWithView:window];
                HUD.delegate = self;
                [window addSubview:HUD];
            }
            HUD.mode = MBProgressHUDModeIndeterminate;
            if (loadingMessage==nil || [loadingMessage length]<=0)
            {
                HUD.labelText = kLoc(@"loading");
            }
            else
            {
                HUD.labelText = loadingMessage;
            }
            [HUD show:YES];
        }
        
        
        if (data)
        {
            
            NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
            //-------------------------HEAD-----------------
            //获取设备名称
            UIDevice *device = [UIDevice currentDevice];
            
            NSMutableDictionary *HEAD = [[NSMutableDictionary alloc] init];
            [HEAD setObject:@"etb_iPad" forKey:@"APP_ID"];
            [HEAD setObject:[device model] forKey:@"PLATFORM"];
            [HEAD setObject:@"yorkit_ios" forKey:@"SOURCE_CHANNEL"];
            
            NSString *system = [NSString stringWithFormat:@"%@(%@)", [UIDevice platformString], [device systemVersion]];
            [HEAD setObject:system forKey:@"UA"];
            
            NSString *sizeStr = [NSString stringWithFormat:@"%d x %d",(int)[[UIScreen mainScreen] currentMode].size.width,(int)[[UIScreen mainScreen] currentMode].size.height];
            [HEAD setObject:sizeStr forKey:@"SIZE"];
            
            
            //获取版本号
            NSBundle* mainBundle = [NSBundle mainBundle];
            NSDictionary* infoDictionary =  [mainBundle infoDictionary];
            NSString *appVersion =[infoDictionary objectForKey:@"CFBundleVersion"];
            [HEAD setObject:appVersion forKey:@"VERSION"];
            
            
            //本机当前语言
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
            NSString *currentLanguage = [languages objectAtIndex:0];
            [HEAD setObject:currentLanguage forKey:@"LANG"];
            [HEAD setObject:[NSNumber numberWithInt:1] forKey:@"TOKEN_TYPE"];
            
            //设备Token
            NSString *deviceTokenStr = [UIDevice getDeviceToken];
            [HEAD setObject:deviceTokenStr forKey:@"DEVICE_TOKEN"];
            
            //推送Token
            NSString *pushTokenStr = [defaults objectForKey:kPushToken];
            if ([pushTokenStr length]>0) {
                [HEAD setObject:pushTokenStr forKey:@"PUSH_TOKEN"];
            }
            else {
                [HEAD setObject:@"" forKey:@"PUSH_TOKEN"];
            }
            
            //登录令牌
            AccountManager *accountMgr = [AccountManager sharedAccountManager];
            NSString *oAuthToken = [accountMgr oAuthToken];
            if (oAuthToken!=nil && [oAuthToken length]>0) {
                [HEAD setObject:oAuthToken forKey:@"OAUTH_TOKEN"];
            }
            else {
                [HEAD setObject:@"" forKey:@"OAUTH_TOKEN"];
            }
            [post setObject:HEAD forKey:@"head"];
            [post setObject:data forKey:@"body"];
            
            NSError *error = nil;
            NSData *postData= [NSJSONSerialization dataWithJSONObject:post options:NSJSONWritingPrettyPrinted error:&error];
            
            NSURL *conURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", mainURL, baseURL]];
            NSMutableURLRequest *connectionRequest = [NSMutableURLRequest requestWithURL:conURL];
            [connectionRequest setHTTPMethod:@"POST"];
            //设置超时间隔
            [connectionRequest setTimeoutInterval:30.0];
            [connectionRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
            [connectionRequest setHTTPBody:postData];
            
            if (jsonConnection) {
                jsonConnection = nil;
            }
            
            if (receivedData) {
                receivedData = nil;
            }
            
            jsonConnection = [[NSURLConnection alloc] initWithRequest:connectionRequest delegate:self];
            
            timeoutTimer = [[NSTimer alloc]initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:30.0] interval:30.0 target:self selector:@selector(cancelConnection) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop]addTimer:timeoutTimer forMode:NSDefaultRunLoopMode];
        }
	}
	else
    {
        if ([delegate respondsToSelector:@selector(JsonPicker:didFailWithNetwork:)])
        {
            [delegate JsonPicker:self didFailWithNetwork:nil];
        }
	}
}

-(void)postDataForError:(NSString *)errorInfo withBaseRequest:(NSString *)baseURL
{
    if ([[Reachability shareReachability] checkNetworking])
    {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        if (showActivityIndicator)
        {
            if (!HUD)
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                HUD = [[MBProgressHUD alloc] initWithView:window];
                HUD.delegate = self;
                [window addSubview:HUD];
            }
            HUD.mode = MBProgressHUDModeIndeterminate;
            if (loadingMessage==nil || [loadingMessage length]<=0)
            {
                HUD.labelText = kLoc(@"loading");
            }
            else
            {
                HUD.labelText = loadingMessage;
            }
            [HUD show:YES];
        }
        
        
        if (errorInfo)
        {
            
            NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
            //-------------------------HEAD-----------------
            //获取设备名称
            UIDevice *device = [UIDevice currentDevice];
            
            NSMutableDictionary *HEAD = [[NSMutableDictionary alloc] init];
            [HEAD setObject:@"etb_iPad" forKey:@"APP_ID"];
            [HEAD setObject:[device model] forKey:@"PLATFORM"];
            [HEAD setObject:@"yorkit_ios" forKey:@"SOURCE_CHANNEL"];
            
            NSString *system = [NSString stringWithFormat:@"%@(%@)", [UIDevice platformString], [device systemVersion]];
            [HEAD setObject:system forKey:@"USER_AGENT"];
            
            NSString *sizeStr = [NSString stringWithFormat:@"%d x %d",(int)[[UIScreen mainScreen] currentMode].size.width,(int)[[UIScreen mainScreen] currentMode].size.height];
            [HEAD setObject:sizeStr forKey:@"SIZE"];
            
            
            //获取版本号
            NSBundle* mainBundle = [NSBundle mainBundle];
            NSDictionary* infoDictionary =  [mainBundle infoDictionary];
            NSString *appVersion =[infoDictionary objectForKey:@"CFBundleVersion"];
            [HEAD setObject:appVersion forKey:@"APP_VERSION"];
            
            
            //本机当前语言
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
            NSString *currentLanguage = [languages objectAtIndex:0];
            [HEAD setObject:currentLanguage forKey:@"LANG"];
            [HEAD setObject:[NSNumber numberWithInt:1] forKey:@"TOKEN_TYPE"];
            
            //设备Token
            NSString *deviceTokenStr = [UIDevice getDeviceToken];
            [HEAD setObject:deviceTokenStr forKey:@"DEVICE_TOKEN"];
            
            //推送Token
            NSString *pushTokenStr = [defaults objectForKey:kPushToken];
            if ([pushTokenStr length]>0) {
                [HEAD setObject:pushTokenStr forKey:@"PUSH_TOKEN"];
            }
            else {
                [HEAD setObject:@"" forKey:@"PUSH_TOKEN"];
            }
            
            //登录令牌
            AccountManager *accountMgr = [AccountManager sharedAccountManager];
            NSString *oAuthToken = [accountMgr oAuthToken];
            if (oAuthToken!=nil && [oAuthToken length]>0) {
                [HEAD setObject:oAuthToken forKey:@"OAUTH_TOKEN"];
            }
            else {
                [HEAD setObject:@"" forKey:@"OAUTH_TOKEN"];
            }
            [post setObject:HEAD forKey:@"head"];
            [post setObject:errorInfo forKey:@"errorInfo"];
            
            NSError *error = nil;
            NSData *postData= [NSJSONSerialization dataWithJSONObject:post options:NSJSONWritingPrettyPrinted error:&error];
            
            NSURL *conURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kDomainCommonURL, baseURL]];
            NSMutableURLRequest *connectionRequest = [NSMutableURLRequest requestWithURL:conURL];
            [connectionRequest setHTTPMethod:@"POST"];
            //设置超时间隔
            [connectionRequest setTimeoutInterval:30.0];
            [connectionRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
            [connectionRequest setHTTPBody:postData];
            
            if (jsonConnection) {
                jsonConnection = nil;
            }
            
            if (receivedData) {
                receivedData = nil;
            }
            
            jsonConnection = [[NSURLConnection alloc] initWithRequest:connectionRequest delegate:self];
            
            timeoutTimer = [[NSTimer alloc]initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:30.0] interval:30.0 target:self selector:@selector(cancelConnection) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop]addTimer:timeoutTimer forMode:NSDefaultRunLoopMode];
        }
	}
	else
    {
        if ([delegate respondsToSelector:@selector(JsonPicker:didFailWithNetwork:)])
        {
            [delegate JsonPicker:self didFailWithNetwork:nil];
        }
	}
}


#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!receivedData) {
        receivedData = [[NSMutableData alloc] init];
    }
    [receivedData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self connectionFailed];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (!receivedData)
    {
        [self connectionFailed];
        return;
    }
    
    NSError *error = nil;
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:&error];
    
    if (results==nil)
    {
        [self connectionFailed];
        return;
    }
    [timeoutTimer invalidate];
    
    int responseStatus = [[results objectForKey:@"status"] intValue];
    // 检测更新或登录状态
    switch (responseStatus) {
        case 200:
        {
            [HUD hide:YES];
            
            sleep(1);
            if (loadedSuccessfulMessage.length > 0) {
                if (showActivityIndicator)
                {
//                    [PSAlertView showWithMessage:loadedSuccessfulMessage];
                }
            }
            
            // 返回数据
            if ([delegate respondsToSelector:@selector(JsonPicker:didParsingSuccessfulWithDict:)]) {
                [delegate JsonPicker:self didParsingSuccessfulWithDict:results];
            }
            
            // 是否要进行版本更新
            if (self.isShowUpdateAlert) {
                [self performSelector:@selector(checkAppUpdate:) withObject:results afterDelay:1.0];
            }
            
            break;
        }
        case 102: {
            // 修改密码之后要重新登录
            [HUD hide:YES];
            
            // 修改密码后，重新登陆
            if (YES == self.isShowLoginAlertView) {
                // 返回数据
                if ([delegate respondsToSelector:@selector(JsonPicker:didFailWithError:)]) {
                    [delegate JsonPicker:self didFailWithError:nil];
                }
                [self performSelector:@selector(showReLoginAlert) withObject:nil afterDelay:1.0];
            } else {
                // 登录页面直接返回数据
                if ([delegate respondsToSelector:@selector(JsonPicker:didParsingSuccessfulWithDict:)]) {
                    [delegate JsonPicker:self didParsingSuccessfulWithDict:results];
                }
            }
            
            break;
        }
        default: {
            [HUD hide:YES];
            
            // 返回数据
            if ([delegate respondsToSelector:@selector(JsonPicker:didParsingSuccessfulWithDict:)]) {
                
                [delegate JsonPicker:self didParsingSuccessfulWithDict:results];
            }
            // 是否要进行版本更新
            if (self.isShowUpdateAlert) {
                [self performSelector:@selector(checkAppUpdate:) withObject:results afterDelay:1.0];
            }
            
            break;
        }
    }
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

@end
