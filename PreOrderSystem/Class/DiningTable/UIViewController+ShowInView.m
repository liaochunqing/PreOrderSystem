//
//  UIViewController+ShowInView.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-27.
//
//

#import "UIViewController+ShowInView.h"

@implementation UIViewController (ShowInView)


#pragma mark show/dismiss view

- (void)showInView:(UIViewController *)aViewCtrl withOriginPoint:(CGPoint)origin withAnimated:(BOOL)flag
{
    CGRect frame = self.view.frame;
    frame.origin.x = origin.x;
    frame.origin.y = origin.y;
    self.view.frame = frame;
    [aViewCtrl addChildViewController:self];
    [aViewCtrl.view addSubview:self.view];
    
    if (flag)
    {
        self.view.alpha = 0.0f;
        
        [UIView beginAnimations:@"animationID" context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationRepeatAutoreverses:NO];
        
        self.view.alpha = 1.0f;
        
        [UIView commitAnimations];
    }
}

- (void)dismissViewControllerWithAnimated:(BOOL)flag
{
    [self removeFromParentViewController];
    if (flag)
    {
        [UIView beginAnimations:@"animationID" context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationRepeatAutoreverses:NO];
        
        [self.view removeFromSuperview];
        
        [UIView commitAnimations];
    }
    else
    {
        [self.view removeFromSuperview];
    }
}

- (void)showInViewFromRightSide:(UIViewController *)aViewCtrl withStartOriginPoint:(CGPoint)startOrigin withEndOriginPoint:(CGPoint)endOrigin
{
    self.view.alpha = 0.0f;
    CGRect frame = self.view.frame;
    frame.origin.x = startOrigin.x;
    frame.origin.y = startOrigin.y;
    self.view.frame = frame;
    
    [aViewCtrl addChildViewController:self];
    [aViewCtrl.view addSubview:self.view];
    
    
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    
    self.view.alpha = 1.0f;
    frame.origin.x = endOrigin.x;
    frame.origin.y = endOrigin.y;
    self.view.frame = frame;
    
    [UIView commitAnimations];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    [self removeFromParentViewController];
	[self.view removeFromSuperview];
}

- (void)dismissViewToRight:(CGPoint)rightOrigin
{
    self.view.alpha = 1.0f;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    CGRect aFrame = self.view.frame;
    aFrame.origin.x = rightOrigin.x;
    self.view.frame = aFrame;
    
    [UIView commitAnimations];
}

@end
