//
//  CustomUIView.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import <UIKit/UIKit.h>

#define kPointForShowView  CGPointMake(170, 5)

@interface CustomUIView : UIView

- (void)showInView:(UIView *)aView withOriginPoint:(CGPoint)origin withAnimated:(BOOL)flag;
- (void)dismissViewWithAnimated:(BOOL)flag;

@end
