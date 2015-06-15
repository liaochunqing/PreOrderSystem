//
//  PSAlertView.m
//  PreOrderSystem
//
//  Created by YorkIT on 14-5-9.
//
//

#import "PSAlertView.h"

static PSAlertView *sharedAlertView_ = nil;

@implementation PSAlertView

#pragma mark - public methods

+ (void)showWithMessage:(NSString *)message
{
    [self showWithMessage:message buttonTitle:kLoc(@"confirm")];
}

+ (void)showWithMessage:(NSString *)message buttonTitle:(NSString *)buttonTitle
{
    if (sharedAlertView_ != nil) {
        // 如果有需要，先关闭
        if (sharedAlertView_.isVisible) {
            [sharedAlertView_ dismissWithClickedButtonIndex:sharedAlertView_.cancelButtonIndex
                                                   animated:NO];
        }
        sharedAlertView_ = nil;
    }
    
    if (message.length > 0) {
        sharedAlertView_ = [[PSAlertView alloc] initWithTitle:message
                                                      message:nil
                                                     delegate:nil
                                            cancelButtonTitle:buttonTitle
                                            otherButtonTitles:nil];
        [sharedAlertView_ show];
    }
}

@end
