//
//  DetailTextView.m
//  
//
//  Created by Mac Pro on 4/27/12.
//  Copyright (c) 2012 Dawn. All rights reserved.
//

#import "DetailTextView.h"
#import <CoreText/CoreText.h>

@implementation DetailTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        resultAttributedString = [[NSMutableAttributedString alloc]init];
    }
    return self;
}
-(void)setText:(NSString *)text WithFont:(UIFont *)font AndColor:(UIColor *)color{
    self.text = text;
    int len = [text length];
    NSMutableAttributedString *mutaString = [[NSMutableAttributedString alloc]initWithString:text];
    [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName) value:(id)color.CGColor range:NSMakeRange(0, len)];
    CTFontRef ctFont2 = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize,NULL);
    [mutaString addAttribute:(NSString *)(kCTFontAttributeName) value:(__bridge id)ctFont2 range:NSMakeRange(0, len)];
    CFRelease(ctFont2);
    if (UITextAlignmentRight == self.textAlignment)
    {
        //创建文本对齐方式
        CTTextAlignment alignment = kCTTextAlignmentRight;//这种对齐方式会自动调整，使左右始终对齐
        CTParagraphStyleSetting alignmentStyle;
        alignmentStyle.spec = kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
        alignmentStyle.valueSize = sizeof(alignment);
        alignmentStyle.value = &alignment;
        //创建样式数组
        CTParagraphStyleSetting settings[]={
            alignmentStyle
        };
        //设置样式
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings));
        
        //给字符串添加样式attribute
        [mutaString addAttribute:(id)kCTParagraphStyleAttributeName
                       value:(__bridge id)paragraphStyle
                       range:NSMakeRange(0, [mutaString length])];
    }
    
    resultAttributedString = mutaString;
}
-(void)setKeyWordTextArray:(NSArray *)keyWordArray WithFont:(UIFont *)font AndColor:(UIColor *)keyWordColor{
    NSMutableArray *rangeArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < [keyWordArray count]; i++) {
        NSString *keyString = [keyWordArray objectAtIndex:i];
        NSRange range = [self.text rangeOfString:keyString];
        NSValue *value = [NSValue valueWithRange:range];
        if (range.length > 0) {
            [rangeArray addObject:value];
        }
    }
    for (NSValue *value in rangeArray) {
        NSRange keyRange = [value rangeValue];
        [resultAttributedString addAttribute:(NSString *)(kCTForegroundColorAttributeName) value:(id)keyWordColor.CGColor range:keyRange];
        CTFontRef ctFont1 = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize,NULL);
        [resultAttributedString addAttribute:(NSString *)(kCTFontAttributeName) value:(__bridge id)ctFont1 range:keyRange];
        CFRelease(ctFont1);
        
    }

}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (self.text !=nil) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0, 0.0);//move
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge  CFAttributedStringRef)resultAttributedString);
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGPathAddRect(pathRef,NULL , CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));//const CGAffineTransform *m
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), pathRef,NULL );//CFDictionaryRef frameAttributes
        
        CGContextTranslateCTM(context, 0, -self.bounds.size.height);
        CGContextSetTextPosition(context, 0, 0);
        CTFrameDraw(frame, context);
        CGContextRestoreGState(context);
        
        CGPathRelease(pathRef);
        CFRelease(framesetter);
        CFRelease(frame);
        
        UIGraphicsPushContext(context);

    }

}


@end