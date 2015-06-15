//
//  DeviceHelper.h
//  TestPageController
//
//  Created by YorkIT on 14-3-19.
//  Copyright (c) 2014年 teehom. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief   获取设备信息。
 */
@interface DeviceHelper : NSObject

/**
 * @brief   获取设备的唯一标识。
 *
 * @return  设备的唯一标识。
 */
+ (NSString *)deviceIdentifier;

@end
