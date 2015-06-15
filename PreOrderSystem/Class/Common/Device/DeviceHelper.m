//
//  DeviceHelper.m
//  TestPageController
//
//  Created by YorkIT on 14-3-19.
//  Copyright (c) 2014年 teehom. All rights reserved.
//

#import "DeviceHelper.h"
#import "KeychainItemWrapper.h"
#import "MyMD5.h"

@implementation DeviceHelper

+ (NSString *)deviceIdentifier
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"DeviceIdentifierKeyChain" accessGroup:nil];
    
    NSString *identifier = [wrapper objectForKey:(__bridge id)kSecValueData];
    if (identifier.length == 0) {
        // 初始化
        [wrapper resetKeychainItem];
        // 生成Identifier（规则：APP ID + 当前时间于1970年的毫秒数 + 四位随机数，组成后再取MD5值）
        NSMutableString *keyString = [[NSMutableString alloc] init];
        // 追加APP唯一标识
        NSString *appIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
        [keyString appendString:appIdentifier];
        // 追加毫秒数
        [keyString appendFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
        // 追加随机数
        srand((unsigned)time(NULL));
        int randNumber = rand() % 10000;
        [keyString appendFormat:@"%.4d", randNumber];
        // 取MD5
        identifier = [MyMD5 getMD5Str:keyString];
        
        // 保存
        [wrapper setObject:@"Account" forKey:(__bridge id)kSecAttrAccount];
        [wrapper setObject:@"Service" forKey:(__bridge id)kSecAttrService];
        [wrapper setObject:identifier forKey:(__bridge id)kSecValueData];
    }
    return identifier;
}

@end
