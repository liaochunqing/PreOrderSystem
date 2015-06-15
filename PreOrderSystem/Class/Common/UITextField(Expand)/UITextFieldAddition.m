//
//  UITextFieldAddition.m
//  PreOrderSystem
//
//  Created by YorkIT on 14-8-7.
//
//

#import "UITextFieldAddition.h"
#import "Constants.h"

@implementation UITextField (Addition)

#pragma mark - KeyboardInputAccessoryViewDelegate methods

- (void)hideKeyBoardWhenBtnClicked
{
    [self endEditing:YES];
}

#pragma mark - public methods

- (void)bindCloseButton
{
    if (kIsiPhone) {
        KeyBoardInputAccessoryView *accessoryView = nil;
        accessoryView = [[KeyBoardInputAccessoryView alloc] initWithFrame:CGRectZero];
        accessoryView.delegate = self;
        self.inputAccessoryView = accessoryView;
    }
}

@end
