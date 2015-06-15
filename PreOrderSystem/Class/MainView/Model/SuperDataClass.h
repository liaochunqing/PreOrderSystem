//
//  SuperDataClass.h
//  PreOrderSystem_iPhone
//
//  Created by SWen on 13-5-29.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuperDataClass : NSObject

@property (nonatomic, strong) NSString *alertMsg;
@property (nonatomic, strong) NSString *updateMessage;
@property (nonatomic, strong) NSString *updateUrl;
@property (nonatomic, strong) id dataDict;
@property (nonatomic, assign) int responseStatus;
@property (nonatomic, assign) long long serverTime;
@property (nonatomic, assign) int updateStatus;

- (id)initWithData:(NSDictionary *)dict;

@end