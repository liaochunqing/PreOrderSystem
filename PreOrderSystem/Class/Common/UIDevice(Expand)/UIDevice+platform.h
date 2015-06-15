//
//  UIDevice+platform.h
//  PreOrderSystem
//
//  Created by sWen on 13-5-13.
//
//

#import <UIKit/UIKit.h>

@interface UIDevice (platform)

+ (NSString *)platformString;
+ (NSString *)getDeviceToken;

/**
 * @brief   获取设备的dpi。
 *
 */
+ (CGFloat)dpiForDevice;

@end
