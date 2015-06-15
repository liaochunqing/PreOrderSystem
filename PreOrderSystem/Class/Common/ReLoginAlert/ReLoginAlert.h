//
//  ReLoginAlert.h
//  PreOrderSystem_iPhone
//
//  Created by sWen on 13-9-5.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JsonPicker.h"

@interface ReLoginAlert : NSObject<JsonPickerDelegate>

+ (ReLoginAlert *)sharedReLoginAlert;
- (void)showLoginAlertView;

@end
