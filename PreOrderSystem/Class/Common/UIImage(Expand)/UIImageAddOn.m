//
//  UIImageAddOn.m
//  Ordering
//
//  Created by AaronKwok on 11-7-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImageAddOn.h"



@implementation UIImage (UIImageFunctions)

- (UIImage *) scaleToSize: (CGSize)size
{
    // Scalling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, /*kCGImageAlphaPremultipliedLast*/kCGBitmapByteOrderDefault);
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
	
    if(self.imageOrientation == UIImageOrientationRight)
    {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), self.CGImage);
    }
    else
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
	
    CGImageRef scaledImage=CGBitmapContextCreateImage(context);
	
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
	
    UIImage *image = [UIImage imageWithCGImage: scaledImage];
	
    CGImageRelease(scaledImage);
	
    return image;
}

- (UIImage *) scaleProportionalToSize: (CGSize)size
{
    float widthRatio = size.width/self.size.width;
    float heightRatio = size.height/self.size.height;
    
    if(widthRatio > heightRatio)
    {
        size=CGSizeMake(self.size.width*heightRatio,self.size.height*heightRatio);
    } else {
        size=CGSizeMake(self.size.width*widthRatio,self.size.height*widthRatio);
    }
    
    return [self scaleToSize:size];
}

+ (UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    CGSize newSize;
    if (image.size.height / image.size.width > 1)
    {
        newSize.height = size.height;
        newSize.width = size.height / image.size.height * image.size.width;
    }
    else if (image.size.height / image.size.width < 1)
    {
        newSize.height = size.width / image.size.width * image.size.height;
        newSize.width = size.width;
    }
    else
    {
        newSize = size;
    }
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0);
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

/*改变图片方向，避免图片倾斜*/
+ (UIImage *)modifyImageOrientation:(UIImage *)image
{
    CGAffineTransform imageTransform = CGAffineTransformIdentity;
    CGSize size = image.size;
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
    CGContextConcatCTM(context, imageTransform);
    CGContextTranslateCTM(context, size.width / -2, size.height / -2);
    [image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return targetImage;
}

- (CGContextRef)bitmapRGBA8Context
{
    CGImageRef imageRef = self.CGImage;
    
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint32_t *bitmapData;
    
    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (!colorSpace) {
        NSLog(@"Error allocating color space RGB\n");
        return NULL;
    }
    
    // Allocate memory for image data
    bitmapData = (uint32_t *)malloc(bufferLength);
    if (!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    // Create bitmap context
    context = CGBitmapContextCreate(bitmapData,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);    // RGBA
    if (!context) {
        free(bitmapData);
        NSLog(@"Bitmap context not created");
    }
    
    CGColorSpaceRelease(colorSpace);
    return context;
}

- (unsigned char *)bitmapRGBA8Chars
{
    CGImageRef imageRef = self.CGImage;
    
    // Create a bitmap context to draw the uiimage into
    CGContextRef context = [self bitmapRGBA8Context];
    
    if (!context) {
        return NULL;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, imageRef);
    // Get a pointer to the data
    unsigned char *bitmapData = (unsigned char *)CGBitmapContextGetData(context);
    
    unsigned char *newBitmap = NULL;
    argb_t *argb = (argb_t *)bitmapData;
    if (argb) {
        newBitmap = (unsigned char *)malloc(sizeof(unsigned char) * width * height);
        
        for (NSInteger i = 0; i < width * height; i++) {
            if ((!argb[i].r) && (!argb[i].g) && (!argb[i].b)) {
                newBitmap[i] = '1';
            } else {
                newBitmap[i] = '0';
            }
        }
        free(bitmapData);
    }
    
    CGContextRelease(context);
    return newBitmap;
}

@end
