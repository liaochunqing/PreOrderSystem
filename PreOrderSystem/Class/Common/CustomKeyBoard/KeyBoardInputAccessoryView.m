//
//  KeyBoardInputAccessoryView.m
//  PreOrderSystem_iPhone
//
//  Created by sWen on 13-6-6.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import "KeyBoardInputAccessoryView.h"
#import "UIImage+imageWithContentsOfFile.h"

@implementation KeyBoardInputAccessoryView

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, 0, 480, 34);
    self = [super initWithFrame:frame];
    if (self)
    {
        UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [hideBtn setBackgroundImage:[UIImage imageNamed:@"hideKeyboardBtnBg"] forState:UIControlStateNormal];
        hideBtn.frame = CGRectMake(frame.size.width - 48, 0, 48, 34);
        [hideBtn addTarget:self action:@selector(hideBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:hideBtn];
    }
    return self;
}

- (void)hideBtnClicked:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(hideKeyBoardWhenBtnClicked)])
    {
        [self.delegate hideKeyBoardWhenBtnClicked];
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
