//
//  AssistiveTouch.h
//  navTest
//
//  Created by Lrs on 13-10-16.
//  Copyright (c) 2013年 Lrs. All rights reserved.
//悬浮窗

#import <UIKit/UIKit.h>
@protocol AssistiveTouchDelegate;
@interface AssistiveTouch : UIWindow
{
    UIImageView *_imageView;
}
@property(nonatomic,assign)BOOL isShowMenu;
@property(nonatomic,unsafe_unretained)id<AssistiveTouchDelegate> assistiveDelegate;
-(id)initWithFrame:(CGRect)frame imageName:(NSString*)name;
@end

@protocol AssistiveTouchDelegate <NSObject>
@optional
//悬浮窗点击事件
-(void)assistiveTocuhs;
@end
