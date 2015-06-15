//
//  UIImage+imageWithContentsOfFile.m
//  PreOrderSystem
//
//  Created by sWen on 13-3-2.
//
//

#import "UIImage+imageWithContentsOfFile.h"

@implementation UIImage (imageWithContentsOfFile)

+ (UIImage*)imageFromMainBundleFile:(NSString*)aFileName
{
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", bundlePath, aFileName]];
}

@end
