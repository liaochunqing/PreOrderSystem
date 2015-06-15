//
//  UIViewController+ShowInView.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-27.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (ShowInView)

- (void)showInView:(UIViewController *)aViewCtrl withOriginPoint:(CGPoint)origin withAnimated:(BOOL)flag;
- (void)dismissViewControllerWithAnimated:(BOOL)flag;
- (void)showInViewFromRightSide:(UIViewController *)aViewCtrl withStartOriginPoint:(CGPoint)startOrigin withEndOriginPoint:(CGPoint)endOrigin;
- (void)dismissViewToRight:(CGPoint)rightOrigin;

@end
