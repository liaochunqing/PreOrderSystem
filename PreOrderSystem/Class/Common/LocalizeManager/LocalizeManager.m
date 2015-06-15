//
//  LocalizeManager.m
//  PreOrderSystem_iPhone
//
//  Created by YorkIT on 14-6-5.
//  Copyright (c) 2014年 sWen. All rights reserved.
//

#import "LocalizeManager.h"

static LocalizeManager *sharedManager_ = nil;
@implementation LocalizeManager

#pragma mark - initlization methods

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}



#pragma mark - private methods

+ (LocalizeManager *)shareManager
{
    if (sharedManager_ == nil) {
        sharedManager_ = [self init];
    }
    return sharedManager_;
}

#pragma mark - public methods
+ (NSString *)currentSelectedResourcePathWithBandleName:(id)bundleName
{
    NSString *path = nil;
    if (bundleName && [bundleName isEqualToString:@"ENG"]) path = @"en.lproj";
    else if (bundleName && [bundleName isEqualToString:@"CHT"]) path = @"zh-Hant.lproj";
    else if(bundleName && [bundleName isEqualToString:@"CHS"]) path = @"zh-Hans.lproj";
    else//未匹配上， 则使用系统的语言设置
    {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
        NSString *language = [languages objectAtIndex:0];
        path = [language stringByAppendingString:@".lproj"];
    }
    
    return path;
}

+ (NSString *)getLocalizedWithKey:(NSString *)keyString
{
    id bundleName = [[NSUserDefaults standardUserDefaults] objectForKey:kApplicationLanguageKey];
    if (bundleName != nil)
    {
        // 获取document目录
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        // 获取bundle目录
        NSString *bundleFilePath = [docPath stringByAppendingPathComponent:bundleName];
        
        // 创建bundle对象
        NSBundle *bundle = nil;
        
        // 获取国际化文件目录
        NSString *localizableFilePath = [bundleFilePath stringByAppendingPathComponent:@"Localizable.strings"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:localizableFilePath])//沙盒文件夹中存在
        {
            bundle = [NSBundle bundleWithPath:bundleFilePath];
            
        }
        else//不存在，从系统资源中找..
        {
            NSString *sysLangPath = [self currentSelectedResourcePathWithBandleName:bundleName];
            bundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sysLangPath]];
        }
        
        // 获取国际化内容
        NSString *returnStr = [bundle localizedStringForKey:keyString value:@"" table:nil];
        return (returnStr != nil ? returnStr : @"");
    }
    else
    {
        //没有选择文件夹,则遵从系统自带本地化规则.
        NSString *returnStr = NSLocalizedString(keyString, nil);
        return (returnStr != nil ? returnStr : @"");
    }
}

/**
 * @brief   获取国际化图片。
 *
 * @param   keyString   图片名。
 *
 * @return  uiimage对象。
 */

+ (UIImage *)getLocalizedImageWithKey:(NSString *)imageName;
{
    id bundleName = [[NSUserDefaults standardUserDefaults] objectForKey:kApplicationLanguageKey];
    
    if (bundleName != nil)
    {
        // 有选择的文件夹
        
        // 获取document目录
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        // 获取bundle目录
        NSString *bundleFilePath = [docPath stringByAppendingPathComponent:bundleName];
        // 获取图片文件路径
        NSString *localizableFilePath = [bundleFilePath stringByAppendingPathComponent:imageName];
        // 检查图片是否存在
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:localizableFilePath])
        {
            // 图片存在，直接写文件
            return [UIImage imageWithContentsOfFile:localizableFilePath];;
        }

    }
    
    //沙盒中没能找到,则从系统资源中找.
  
    NSString *sysImage = [self currentSelectedResourcePathWithBandleName:bundleName];
    NSString *docuPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sysImage];
    NSString *imagePath = [docuPath stringByAppendingPathComponent:imageName];
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage imageWithData:data];
    
    return image;
}

//////////////////////
+ (BOOL)saveLocalizedData:(NSData *)bundleData bundleName:(NSString *)bundleName
{
    if (bundleData == nil || bundleData.length == 0 || bundleName.length == 0)
    {
        return NO;
    }
    
    // 获取document目录
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    // 获取bundle目录
    NSString *bundleFilePath = [docPath stringByAppendingPathComponent:bundleName];
    // 获取国际化文件目录
    NSString *localizableFilePath = [bundleFilePath stringByAppendingPathComponent:@"Localizable.strings"];
    // 检查bundle目录是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:bundleFilePath])
    {
        // 目录存在，直接写文件
        return [bundleData writeToFile:localizableFilePath atomically:YES];
    }
    else
    {
        // 目录不存在，创建bundle目录
        if ([fileManager createDirectoryAtPath:bundleFilePath withIntermediateDirectories:YES attributes:nil error:nil])
        {
            // 写文件
            return [bundleData writeToFile:localizableFilePath atomically:YES];
        }
        else
        {
            return NO;
        }
    }
}

/**
 *  @brief   保存国际化图片
 *
 *  @param bundleData 国际化图片数据
 *  @param bundleName 国际化语言包名称（如：zhs、zht、eng等）。
 *  @param imageName  图片名字
 *
 *  @return 保存是否成功
 */

+(BOOL)saveLocalizedImageData:(NSData *)bundleData bundleName:(NSString *)bundleName andImageName:(NSString *)imageName
{
    if (bundleData == nil || bundleData.length == 0 || bundleName.length == 0)
    {
        return NO;
    }
    // 获取document目录
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    // 获取bundle目录
    NSString *bundleFilePath = [docPath stringByAppendingPathComponent:bundleName];
    // 获取图片文件路径
    NSString *localizableFilePath = [bundleFilePath stringByAppendingPathComponent:imageName];
    // 检查图片是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:bundleFilePath])
    {
        // 图片存在，直接写文件
        return [bundleData writeToFile:localizableFilePath atomically:YES];
    }
    else
    {
        // 图片不存在，创建bundle目录
        if ([fileManager createDirectoryAtPath:bundleFilePath withIntermediateDirectories:YES attributes:nil error:nil])
        {
            // 写文件
            return [bundleData writeToFile:localizableFilePath atomically:YES];
        }
        else
        {
            return NO;
        }
    }
}

@end
