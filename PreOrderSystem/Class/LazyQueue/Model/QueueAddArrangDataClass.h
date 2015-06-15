//
//  QueueAddArrangDataClass.h
//  PreOrderSystem
//
//  Created by SWen on 14-2-10.
//
//

#import <Foundation/Foundation.h>
#import "QueueSuperDataClass.h"

@interface QueueAddArrangDataClass : QueueSuperDataClass

@property (nonatomic, strong) NSDictionary *addedInfoDict;

- (id)initWithQueueAddArrangArrangData:(NSDictionary *)dict;

@end

#pragma mark - QueueAddArrangInfoDataClass

@interface QueueAddArrangInfoDataClass : NSObject

@property (nonatomic, strong) NSString *mobileStr;
@property (nonatomic, strong) NSString *typeNameStr;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, assign) NSInteger people;
@property (nonatomic, assign) NSInteger typeId;
@property (nonatomic, assign) NSInteger waiting;

- (id)initWithQueueAddArrangInfoData:(NSDictionary *)dict;

@end
