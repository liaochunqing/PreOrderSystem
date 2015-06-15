//
//  UILabel+AdjustFontSize.h
//  Ordering
//
//  Created by AaronKwok on 11-7-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UILabel (UILabel_AdjustFontSize)

- (void) adjustsFontSizeToFitWidthWithMultipleLinesFromFontWithName:(NSString*)fontName size:(NSInteger)fsize andDescreasingFontBy:(NSInteger)dSize;


- (float)adjustLabelHeight;

- (float)adjustLabelWidth:(CGFloat)maxWidth;

@end
