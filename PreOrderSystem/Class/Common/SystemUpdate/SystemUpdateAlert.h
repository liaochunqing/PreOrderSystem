//
//  SystemUpdateAlert.h
//  PreOrderSystem_iPhone
//
//  Created by sWen on 13-8-27.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemUpdateAlert : NSObject

+ (SystemUpdateAlert *)sharedSystemUpdateAlert;
- (void)checkForSystemUpdate:(NSDictionary *)dict withAlwaysShowAlert:(BOOL)flag;

@end
