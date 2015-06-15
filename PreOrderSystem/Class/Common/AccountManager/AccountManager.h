//
//  AccountManager.h
//  OnCall
//
//  Created by AaronKwok on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AccountManager : NSObject
//Singleton
+ (AccountManager *)sharedAccountManager;
//保存帐号(oAuthToken)
-(void)loginAccountWithToken:(NSString*)oAuthToken;
//保存帐号(保存用户名、密码、oAuthToken)
-(void)loginAccountWithUserName:(NSString*)username withPassword:(NSString *)password andToken:(NSString*)oAuthToken;
//返回上一次成功登录的帐号的oAuthToken
-(NSString*)oAuthToken;
//返回上一次成功登录的帐号的userName
-(NSString*)userName;
-(NSString*)userPassword;
//登出帐号
-(void)logoutAccount;
//判断是否己登录（若未登出或登录后闪退也表示己登录，返回YES;否则返回NO）
-(BOOL)isLogin;
/***保存餐厅名称***/
- (void)saveRestaurantName:(NSString *)nameStr;
/***获取餐厅名称***/
-(NSString*)getRestaurantName;
/***保存地址***/
- (void)saveRestaurantAddress:(NSString *)addressStr;
/***获取地址***/
-(NSString*)getRestaurantAddress;

@end
