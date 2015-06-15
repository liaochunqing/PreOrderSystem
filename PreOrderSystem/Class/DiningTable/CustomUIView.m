//
//  CustomUIView.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import "CustomUIView.h"

@implementation CustomUIView

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@",self.class] owner:self options:nil]lastObject];
    if (self) {
       
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@",self.class] owner:self options:nil]lastObject];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

#pragma mark show/dismiss view

- (void)showInView:(UIView *)aView withOriginPoint:(CGPoint)origin withAnimated:(BOOL)flag
{
    CGRect frame = self.frame;
    frame.origin.x = origin.x;
    frame.origin.y = origin.y;
    self.frame = frame;
    [aView addSubview:self];
    
    if (flag)
    {
        self.alpha = 0.0f;
        
        [UIView beginAnimations:@"animationID" context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationRepeatAutoreverses:NO];
        
        self.alpha = 1.0f;
        
        [UIView commitAnimations];
    }
}

- (void)dismissViewWithAnimated:(BOOL)flag
{
    if (flag)
    {
        [UIView beginAnimations:@"animationID" context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationRepeatAutoreverses:NO];
        
        [self removeFromSuperview];
        
        [UIView commitAnimations];
    }
    else
    {
        [self removeFromSuperview];
    }
}

@end
