//
//  UILabel+AdjustFontSize.m
//  Ordering
//
//  Created by AaronKwok on 11-7-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UILabel+AdjustFontSize.h"


@implementation UILabel (UILabel_AdjustFontSize)

- (void) adjustsFontSizeToFitWidthWithMultipleLinesFromFontWithName:(NSString*)fontName size:(NSInteger)fsize andDescreasingFontBy:(NSInteger)dSize{
    
    //Largest size used  
    self.font = [UIFont fontWithName:fontName size:fsize];
    
    //Calculate size of the rendered string with the current parameters
    float height = [self.text sizeWithFont:self.font
                         constrainedToSize:CGSizeMake(self.bounds.size.width,99999) 
                             lineBreakMode:NSLineBreakByWordWrapping].height;
    
    //Reduce font size by dSize while too large, break if no height (empty string)
    while (height > self.bounds.size.height && height != 0) {   
        fsize -= dSize;
        self.font = [UIFont fontWithName:fontName size:fsize];   
        height = [self.text sizeWithFont:self.font 
                       constrainedToSize:CGSizeMake(self.bounds.size.width,99999) 
                           lineBreakMode:NSLineBreakByWordWrapping].height;
    };
    
    // Loop through words in string and resize to fit
    for (NSString *word in [self.text componentsSeparatedByString:@" "]) {
        float width = [word sizeWithFont:self.font].width;
        while (width > self.bounds.size.width && width != 0) {
            fsize -= dSize;
            self.font = [UIFont fontWithName:fontName size:fsize];
            width = [word sizeWithFont:self.font].width;            
        }
    }
}


-(float)adjustLabelHeight{
    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width,9999);
    
    CGSize expectedLabelSize = [self.text sizeWithFont:self.font 
                                      constrainedToSize:maximumLabelSize 
                                          lineBreakMode:self.lineBreakMode]; 
    
    //adjust the label the the new height.
    CGRect newFrame = self.frame;
    newFrame.size.height = expectedLabelSize.height;
#ifdef DEBUG
    //NSLog(@"===adjustLabelheight:%f===", newFrame.size.height);
#endif
    self.frame = newFrame;
    return expectedLabelSize.height;
}

-(float)adjustLabelWidth:(CGFloat)maxWidth{
    CGSize maximumLabelSize = CGSizeMake(maxWidth,self.frame.size.height);
    
    CGSize expectedLabelSize = [self.text sizeWithFont:self.font 
                                     constrainedToSize:maximumLabelSize 
                                         lineBreakMode:self.lineBreakMode]; 
    
    //adjust the label the the new height.
    CGRect newFrame = self.frame;
    newFrame.size.width = expectedLabelSize.width;
#ifdef DEBUG
    //NSLog(@"===adjustLabelWidth:%f===", newFrame.size.width);
#endif
    self.frame = newFrame;
    return expectedLabelSize.width;
}

@end
