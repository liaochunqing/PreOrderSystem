//
//  UIImageAddOn.h
//  Ordering
//
//  Created by AaronKwok on 11-7-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (UIImageFunctions)

typedef struct argb_s {
    unsigned char a;
    unsigned char r;
    unsigned char g;
    unsigned char b;
} argb_t;

- (UIImage *)scaleToSize: (CGSize)size;
- (UIImage *)scaleProportionalToSize: (CGSize)size;
+ (UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size;
+ (UIImage *)modifyImageOrientation:(UIImage *)image;

/**
 * @brief   创建bitmapContext。
 *
 * @return  新的bitmapContext。
 *
 */
- (CGContextRef)bitmapRGBA8Context;

/**
 * @brief   转成bitmap字符(黑色点用1表示，其他用0表示)。
 *
 * @return  bitmap字符。
 */
- (unsigned char *)bitmapRGBA8Chars;

@end
