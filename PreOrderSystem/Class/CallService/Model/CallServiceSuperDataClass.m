//
//  CallServiceSuperDataClass.m
//  PreOrderSystem_iPhone
//
//  Created by SWen on 14-3-5.
//  Copyright (c) 2014年 sWen. All rights reserved.
//

#import "CallServiceSuperDataClass.h"

@implementation CallServiceButtonDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithCallServiceButtonData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.btnName = [dict objectForKey:@"name"];
        self.btnValue = [NSString stringWithFormat:@"%@", [dict objectForKey:@"value"]];
    }
    return self;
}

@end


#pragma mark - CallServiceSuperDataClass

@implementation CallServiceSuperDataClass


- (id)initWithCallServiceSuperData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        NSMutableArray *btnMutableArray = [[NSMutableArray alloc] init];
        NSArray *btnArray = [[dict objectForKey:@"data"] objectForKey:@"buttons"];
        NSInteger btnCount = [btnArray count];
        for (NSInteger i = 0; i < btnCount; i++)
        {
            CallServiceButtonDataClass *btnClass = [[CallServiceButtonDataClass alloc] initWithCallServiceButtonData:[btnArray objectAtIndex:i]];
            [btnMutableArray addObject:btnClass];
        }
        self.buttonsArray = [[NSArray alloc] initWithArray:btnMutableArray];
    }
    return self;
}

@end
