//
//  UIImage+imageWithContentsOfFile.h
//  PreOrderSystem
//
//  Created by sWen on 13-3-2.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (imageWithContentsOfFile)

+ (UIImage*)imageFromMainBundleFile:(NSString*)aFileName;

@end
