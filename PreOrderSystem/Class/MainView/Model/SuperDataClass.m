//
//  SuperDataClass.m
//  PreOrderSystem_iPhone
//
//  Created by SWen on 13-5-29.
//  Copyright (c) 2013年 sWen. All rights reserved.
//

#import "SuperDataClass.h"

@implementation SuperDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.alertMsg = [dict objectForKey:@"desc"];
        self.dataDict = [dict objectForKey:@"data"];
        self.responseStatus = [[dict objectForKey:@"status"] integerValue];
        self.serverTime = [[dict objectForKey:@"time"] longLongValue];
        
        NSDictionary *versonDict = [[NSDictionary alloc] initWithDictionary:[dict objectForKey:@"version"]];
        self.updateStatus = [[versonDict objectForKey:@"status"] integerValue];
        self.updateMessage = [versonDict objectForKey:@"desc"];
        self.updateUrl = [versonDict objectForKey:@"url"];
    }
    return self;
}

@end
