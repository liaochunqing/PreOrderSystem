//
//  QueueSuperDataClass.h
//  PreOrderSystem
//
//  Created by SWen on 14-2-10.
//
//

#import <Foundation/Foundation.h>

@interface QueueSuperDataClass : NSObject

@property (nonatomic, strong) NSString *corpAddr;
@property (nonatomic, strong) NSString *corpName;
@property (nonatomic, strong) NSArray *queueListArray;

- (id)initWithQueueSuperData:(NSDictionary *)dict;

@end
