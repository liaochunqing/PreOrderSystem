//
//  AccountManager.m
//  OnCall
//
//  Created by AaronKwok on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AccountManager.h"
#import "Constants.h"

#define kRestaurantAddress @"restaurantAddress"

@implementation AccountManager

#pragma mark PUBLIC METHODS

+ (AccountManager *)sharedAccountManager{
    //此方法更适合于多线程的环境
    static AccountManager *sharedInstance;
    static dispatch_once_t done;
    dispatch_once(&done, ^{
        sharedInstance = [[AccountManager alloc] init];
    });
    return sharedInstance;
}

//保存帐号(oAuthToken)
-(void)loginAccountWithToken:(NSString*)oAuthToken{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:oAuthToken forKey:kOauthToken];
    [pref synchronize];
}

-(void)loginAccountWithUserName:(NSString*)username withPassword:(NSString *)password andToken:(NSString*)oAuthToken{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:username forKey:kAccountUserName];
    [pref setObject:password forKey:kAccountUserPassword];
    [pref setObject:oAuthToken forKey:kOauthToken];
    [pref synchronize];
}

-(NSString*)oAuthToken{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    return [pref objectForKey:kOauthToken];
}

-(NSString*)userName{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    return [pref objectForKey:kAccountUserName];
}

-(NSString*)userPassword{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    return [pref objectForKey:kAccountUserPassword];
}

-(void)logoutAccount{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:@"" forKey:kOauthToken];
    [pref synchronize];
}

//判断是否己登录（若未登出或登录后闪退也表示己登录，返回YES;否则返回NO）
-(BOOL)isLogin{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *oAuthToken = [pref objectForKey:kOauthToken];
    if (!oAuthToken || [oAuthToken length]==0) {
        return NO;
    }
    return YES;
}

/***保存餐厅名称***/
- (void)saveRestaurantName:(NSString *)nameStr{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:nameStr forKey:kRestaurantName];
    [pref synchronize];
}

/***获取餐厅名称***/
-(NSString*)getRestaurantName{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    return [pref objectForKey:kRestaurantName];
}

/***保存地址***/
- (void)saveRestaurantAddress:(NSString *)addressStr{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:addressStr forKey:kRestaurantAddress];
    [pref synchronize];
}

/***获取地址***/
-(NSString*)getRestaurantAddress{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRestaurantAddress];
}

@end
