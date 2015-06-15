//
//  CustomPopoverTouchView.h
//  PreOrderSystem
//
//  Created by SWen on 14-2-26.
//
//

#import <UIKit/UIKit.h>

@class CustomPopoverTouchView;
@protocol CustomPopoverTouchViewDelegate <NSObject>

- (void)customPopoverTouchView:(UIView*)view touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;

@end

@interface CustomPopoverTouchView : UIView

@property (nonatomic, weak) id <CustomPopoverTouchViewDelegate> delegate;

@end
