//
//  MyMD5.m
//  PreOrderSystem_iPhone
//
//  Created by SWen on 13-10-31.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import "MyMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MyMD5

+ (NSString *)getMD5Str:(NSString *)str
{
//    const char *cStr = [str UTF8String];
//    unsigned char result[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(cStr, strlen(cStr), result);
//    
//    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
//             result[0], result[1], result[2], result[3],
//             result[4], result[5], result[6], result[7],
//             result[8], result[9], result[10], result[11],
//             result[12], result[13], result[14], result[15]
//             ] lowercaseString];
    
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

@end
