//
//  CallServiceSuperDataClass.h
//  PreOrderSystem_iPhone
//
//  Created by SWen on 14-3-5.
//  Copyright (c) 2014年 sWen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallServiceButtonDataClass : NSObject

@property (nonatomic, strong) NSString *btnName;
@property (nonatomic, strong) NSString *btnValue;

- (id)initWithCallServiceButtonData:(NSDictionary *)dict;

@end

#pragma mark - CallServiceSuperDataClass

@interface CallServiceSuperDataClass : NSObject

@property (nonatomic, strong) NSArray *buttonsArray;//处理呼叫信息的按钮

- (id)initWithCallServiceSuperData:(NSDictionary *)dict;

@end