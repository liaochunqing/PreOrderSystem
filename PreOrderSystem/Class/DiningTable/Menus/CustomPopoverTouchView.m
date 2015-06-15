//
//  CustomPopoverTouchView.m
//  PreOrderSystem
//
//  Created by SWen on 14-2-26.
//
//

#import "CustomPopoverTouchView.h"

@implementation CustomPopoverTouchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(customPopoverTouchView:touchesBegan:withEvent:)])
    {
        [self.delegate customPopoverTouchView:self touchesBegan:touches withEvent:event];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
