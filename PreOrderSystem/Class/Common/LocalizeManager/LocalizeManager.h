//
//  LocalizeManager.h
//  PreOrderSystem_iPhone
//
//  Created by YorkIT on 14-6-5.
//  Copyright (c) 2014年 sWen. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 国际化语言标记key
#define kApplicationLanguageKey @"applicationLanguageKey"

/// 国际化简写
#define kLoc(__KEY__) ([LocalizeManager getLocalizedWithKey:__KEY__])

// 国际化图片，__KEY__务必要带上后缀名
#define kLocImage(__KEY__) ([LocalizeManager getLocalizedImageWithKey:__KEY__])

/**
 * @brief   国际化语言管理类。
 *
 */
@interface LocalizeManager : NSObject

/**
 * @brief   获取国际化语言。
 *
 * @param   keyString   国际化语言键。
 *
 * @return  国际化语言。
 */

+ (NSString *)getLocalizedWithKey:(NSString *)keyString;
/**
 * @brief   获取国际化图片。
 *
 * @param   keyString   图片名。
 *
 * @return  uiimage对象。
 */

+ (UIImage *)getLocalizedImageWithKey:(NSString *)imageName;
/**
 * @brief   保存国际化语言数据。
 *
 * @param   bundleData  国际化语言数据。
 * @param   bundleName  国际化语言包名称（如：zhs、zht、eng等）。
 *
 * @return  保存成功状态。
 */
+ (BOOL)saveLocalizedData:(NSData *)bundleData bundleName:(NSString *)bundleName;
+ (BOOL)saveLocalizedImageData:(NSData *)bundleData bundleName:(NSString *)bundleName andImageName:(NSString *)imageName;
@end
