//
//  QueueSuperDataClass.m
//  PreOrderSystem
//
//  Created by SWen on 14-2-10.
//
//

#import "QueueSuperDataClass.h"

@implementation QueueSuperDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithQueueSuperData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.corpAddr = [dict objectForKey:@"corpAddr"];
        self.corpName = [dict objectForKey:@"corpName"];
        self.queueListArray = [dict objectForKey:@"queueList"];
    }
    return self;
}

@end
