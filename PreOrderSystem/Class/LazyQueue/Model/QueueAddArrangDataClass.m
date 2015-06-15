//
//  QueueAddArrangDataClass.m
//  PreOrderSystem
//
//  Created by SWen on 14-2-10.
//
//

#import "QueueAddArrangDataClass.h"

@implementation QueueAddArrangDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithQueueAddArrangArrangData:(NSDictionary *)dict
{
    self = [super initWithQueueSuperData:dict];
    if (self)
    {
        self.addedInfoDict = [dict objectForKey:@"addedInfo"];
    }
    return self;
}

@end

#pragma mark - QueueAddArrangInfoDataClass

@implementation QueueAddArrangInfoDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithQueueAddArrangInfoData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.mobileStr = [NSString stringWithFormat:@"%@", [dict objectForKey:@"mobile"]];
        self.typeNameStr = [dict objectForKey:@"typeName"];
        self.number = [[dict objectForKey:@"number"] integerValue];
        self.people = [[dict objectForKey:@"people"] integerValue];
        self.typeId = [[dict objectForKey:@"typeId"] integerValue];
        self.waiting = [[dict objectForKey:@"waiting"] integerValue];
    }
    return self;
}

@end
