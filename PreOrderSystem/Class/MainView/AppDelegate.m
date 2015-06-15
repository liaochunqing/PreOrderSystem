//
//  AppDelegate.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "Constants.h"
#import "StaffManagementSuperDataClass.h"
#import "JsonPicker.h"



@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

#pragma mark PRIVATE METHODS
//配置PUSH通知
-(void)setupPushNotif{
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound)];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    uncaughtHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&myCaughtExceptionHandler);
    LoginViewController *naViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    self.viewController = [[UINavigationController alloc] initWithRootViewController:naViewController];
    [(UINavigationController *)self.viewController setDelegate:self];
    self.viewController.navigationBarHidden = YES;
    self.window.rootViewController = self.viewController;
    
    if (kIsiPhone) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    
    [self setupPushNotif];
    shouldRefreshPreorderView = NO;
    shouldRefreshTakeoutView = NO;
    shouldRefreshCallServiceView = NO;
    shouldRefreshDinnerTableView = NO;
    
    // 发送错误日志
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"crash.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filepath]) {
        NSString *str = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding  error:nil];
        [self saveErrorToServer:str];
        [fileManager removeItemAtPath:filepath error:nil];
    }
    
    // 显示版本信息
    NSString *areaString = nil;
#ifdef TEST
    areaString = @"TEST";
#elif DEMO
    areaString = @"DEMO";
#endif
    if ([areaString length] > 0) {
        CGSize winSize = self.window.bounds.size;
        areaWindow_ = [[UIWindow alloc] initWithFrame:self.window.bounds];
        areaWindow_.windowLevel = UIWindowLevelStatusBar + 1.0;
        areaWindow_.backgroundColor = [UIColor clearColor];
        areaWindow_.userInteractionEnabled = NO;
        
        areaLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 20.0)];
        areaLabel_.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        areaLabel_.font = [UIFont boldSystemFontOfSize:14.0];
        areaLabel_.textAlignment = NSTextAlignmentCenter;
        areaLabel_.textColor = [UIColor whiteColor];
        areaLabel_.text = areaString;
        areaLabel_.center = CGPointMake(winSize.width / 2.0, winSize.height / 2.0);
        CGFloat minSide = MIN(winSize.width, winSize.height);
        areaLabel_.layer.anchorPoint = CGPointMake(0.5,  (minSide - 40.0) / 40.0);
        // 默认方向
        UIInterfaceOrientation orientation = self.window.rootViewController.interfaceOrientation;
        switch (orientation) {
            case UIInterfaceOrientationLandscapeLeft: {
                areaLabel_.transform = CGAffineTransformMakeRotation(0.0 - M_PI_2);
                break;
            }
                
            case UIInterfaceOrientationLandscapeRight: {
                areaLabel_.transform = CGAffineTransformMakeRotation(M_PI_2);
                break;
            }
                
            default:
                break;
        }
        [areaWindow_ addSubview:areaLabel_];
        
        areaWindow_.hidden = NO;
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    shouldRefreshPreorderView = YES;
    shouldRefreshTakeoutView = YES;
    shouldRefreshCallServiceView = YES;
    shouldRefreshDinnerTableView = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSArray *authorityArray = [offlineMgr getAccountAuthority];
    if ((![authorityArray isKindOfClass:NSClassFromString(@"NSArray")]) || (![authorityArray count]))
    {
        return;
    }
    
    BOOL isOpenBooking = NO;
    BOOL isOpenTakeout = NO;
    BOOL isOpenCallService = NO;
    BOOL isOpenDinnerTable = NO;
    for (NSDictionary *authDict in authorityArray) {
        StaffManagementAuthDataClass *authClass = [[StaffManagementAuthDataClass alloc] initWithStaffManagementAuthData:authDict];
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfTakeoutIndexStr]) {
            isOpenTakeout = authClass.open;
            continue;
        }
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfBookingIndexStr]) {
            isOpenBooking = authClass.open;
            continue;
        }
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfCallServiceIndexStr]) {
            isOpenCallService = authClass.open;
            continue;
        }
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfDiningTableIndexStr]) {
            isOpenDinnerTable = authClass.open;
            continue;
        }
    }
    //只有在开通了权限才更新
    if (shouldRefreshPreorderView && isOpenBooking) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatedPreorderOrderListWhenEnterForeground object:nil];
    }
    if (shouldRefreshTakeoutView && isOpenTakeout) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatedTakeoutOrderListWhenEnterForeground object:nil];
    }
    if (shouldRefreshCallServiceView && isOpenCallService) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatedCallServiceListWhenEnterForeground object:nil];
    }
    if (shouldRefreshDinnerTableView && isOpenDinnerTable) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatedDinnerTableListWhenEnterForeground object:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSSetUncaughtExceptionHandler(uncaughtHandler);
}

- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration
{
    UIInterfaceOrientation orientation = self.window.rootViewController.interfaceOrientation;
    
    switch (orientation) {
            
        case UIInterfaceOrientationLandscapeLeft: {
            areaLabel_.transform = CGAffineTransformMakeRotation(M_PI_2);
            
            break;
        }
            
        case UIInterfaceOrientationLandscapeRight: {
            areaLabel_.transform = CGAffineTransformMakeRotation(0.0 - M_PI_2);
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - public methods

+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark - PUSH Notification

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSDictionary *data = [userInfo objectForKey:@"data"];
    if ((![data isKindOfClass:NSClassFromString(@"NSDictionary")]) || (0 == [data count])) {
        return;
    }
    
    int notifyType = [[data objectForKey:@"tid"] intValue];
    NSString *dinnerTableId = nil;
    switch (notifyType) {
        case 1: {
            //发送Notification，更新订单列表
            //[[NSNotificationCenter defaultCenter] postNotificationName:kUpdatePreOrderListWhenPush object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatePreOrderListWhenPush object:nil userInfo:data];
            shouldRefreshPreorderView = NO;
            
            break;
        }
        case 2: {
            //发送Notification，更新外卖列表
            //[[NSNotificationCenter defaultCenter] postNotificationName:kUpdateTakeoutOrderListWhenPush object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateTakeoutOrderListWhenPush object:nil userInfo:data];
            shouldRefreshTakeoutView = NO;
            
            break;
        }
        case 3: {
            //发送Notification，更新呼叫服务列表
            [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateCallServiceList object:nil];
            shouldRefreshCallServiceView = NO;
            
            break;
        }
        case 4: {
            //发送Notification，更新房台列表
            int oid = [[data objectForKey:@"oid"] intValue];
            if (oid != 0) {
                dinnerTableId = [NSString stringWithFormat:@"%d", oid];
            }
            
            shouldRefreshCallServiceView = NO;
            
            break;
        }
        case 5: {
            //发送Notification，更新外卖列表
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateTakeoutOrderListWhenPush
                                                                object:nil
                                                              userInfo:data];
            shouldRefreshTakeoutView = NO;
            
            break;
        }
        default:
            return;
    }
    
    // 更新房台badge
    if ([[data objectForKey:@"duc"] isKindOfClass:[NSNull class]] == NO) {
        int duc = [[data objectForKey:@"duc"] intValue];
        NSMutableDictionary *userInfo0 = [[NSMutableDictionary alloc] init];
        [userInfo0 setObject:[NSNumber numberWithInt:duc] forKey:@"num"];
        if ([dinnerTableId intValue] != 0 &&
            [UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
            [userInfo0 setObject:[NSNumber numberWithInt:1] forKey:@"select"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateDinnerTableBadge object:nil userInfo:userInfo0];
        
        if ([dinnerTableId intValue] != 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateDinningTableList
                                                                object:dinnerTableId];
        }
    }
    
    // 更新订座badge
    if ([[data objectForKey:@"puc"] isKindOfClass:[NSNull class]] == NO) {
        int puc = [[data objectForKey:@"puc"] intValue];
        NSDictionary *userInfo1 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:puc], @"num", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdatePreorderOrderNotifNum
                                                            object:nil
                                                          userInfo:userInfo1];
    }
    
    // 更新外卖badge
    if ([[data objectForKey:@"tuc"] isKindOfClass:[NSNull class]] == NO) {
        int tuc = [[data objectForKey:@"tuc"] intValue];
        NSDictionary *userInfo2 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:tuc], @"num", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateTakeoutOrderNotifNum
                                                            object:nil
                                                          userInfo:userInfo2];
    }
    
    // 更新呼叫服务badge
    if ([[data objectForKey:@"muc"] isKindOfClass:[NSNull class]] == NO) {
        int muc = [[data objectForKey:@"muc"] intValue];
        NSDictionary *userInfo3 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:muc], @"num", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateCallServiceNotifNum
                                                            object:nil
                                                          userInfo:userInfo3];
    }
    
    // 更新外卖催单的badge
    if ([[data objectForKey:@"ruc"] isKindOfClass:[NSNull class]] == NO) {
        int ruc = [[data objectForKey:@"ruc"] intValue];
        NSDictionary *userInfo4 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:ruc], @"num", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateTakeoutRemindersNotifNum
                                                            object:nil
                                                          userInfo:userInfo4];
    }
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    NSMutableString *token = [[NSMutableString alloc] initWithFormat:@"%@",deviceToken];
    [token replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [token length])];
    [token replaceOccurrencesOfString:@"<" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [token length])];
    [token replaceOccurrencesOfString:@">" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [token length])];
    
    [pref setObject:token forKey:kPushToken];
    [pref synchronize];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    //#if TARGET_IPHONE_SIMULATOR
    //
    //#elif
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
    //                                                    message:[error localizedDescription]
    //                                                   delegate:nil
    //                                          cancelButtonTitle:kLoc(@"确定", nil)
    //                                          otherButtonTitles:nil];
    //    [alert show];
    //#endif
    
}


void myCaughtExceptionHandler(NSException *exception)
{
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSString *str = [NSString stringWithFormat:@"\r\n=============CRASH=============\r\n\r\nName:   %@\r\nReason:   %@\r\nCallStackSymbols:\r\n%@\r\n", name, reason, [arr componentsJoinedByString:@"\n"]];
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"crash.txt"];
    [str writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void) saveErrorToServer:(NSString *)error
{
    if (nil == _jsonPicker)
    {
        _jsonPicker = [[JsonPicker alloc] init];
    }
    
    _jsonPicker.delegate = self;
    _jsonPicker.tag = 1;
    _jsonPicker.showActivityIndicator = YES;
    //    _jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
    _jsonPicker.loadedSuccessfulMessage = nil;
    
    
    [_jsonPicker postDataForError:error withBaseRequest:@"Auto/saveLog"];
}

#pragma mark - UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 缩放视图
    scaleView(viewController.view);
}

#pragma mark - JsonPickerDelegate

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    int responseStatus = [[dict objectForKey:@"responseStatus"] intValue];
    
    switch (responseStatus)
    {
        case 200:// 成功
        {
            [PSAlertView showWithMessage:[dict objectForKey:@"alertMsg"]];
            break;
        }
            
        default:
        {
            [PSAlertView showWithMessage:[dict objectForKey:@"alertMsg"]];
            break;
        }
    }
}




@end
