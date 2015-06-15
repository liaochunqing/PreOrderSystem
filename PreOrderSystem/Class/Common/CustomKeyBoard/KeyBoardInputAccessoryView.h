//
//  KeyBoardInputAccessoryView.h
//  PreOrderSystem_iPhone
//
//  Created by sWen on 13-6-6.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeyboardInputAccessoryView;

@protocol KeyboardInputAccessoryViewDelegate <NSObject>

- (void)hideKeyBoardWhenBtnClicked;

@end

@interface KeyBoardInputAccessoryView : UIView

@property (nonatomic, weak) id <KeyboardInputAccessoryViewDelegate> delegate;

@end
